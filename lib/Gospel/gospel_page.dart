import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

// Hive model for map metadata
class MapInfo {
  final String name;
  final String filePath;
  final String downloadUrl;
  final bool isTemporary;

  MapInfo({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
    this.isTemporary = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'filePath': filePath,
        'downloadUrl': downloadUrl,
        'isTemporary': isTemporary,
      };

  factory MapInfo.fromJson(Map<String, dynamic> json) => MapInfo(
        name: json['name'],
        filePath: json['filePath'],
        downloadUrl: json['downloadUrl'],
        isTemporary: json['isTemporary'] ?? false,
      );
}

// Hive adapter for MapInfo
class MapInfoAdapter extends TypeAdapter<MapInfo> {
  @override
  final int typeId = 1;

  @override
  MapInfo read(BinaryReader reader) {
    final json = reader.read() as Map<dynamic, dynamic>;
    return MapInfo.fromJson(json.cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, MapInfo obj) {
    writer.write(obj.toJson());
  }
}

// Data structure for directory hierarchy
class MapEntry {
  final String name;
  final String url;
  MapEntry({required this.name, required this.url});
}

class SubDirectory {
  final String name;
  final List<MapEntry> maps;
  SubDirectory({required this.name, required this.maps});
}

class Directory {
  final String name;
  final List<SubDirectory> subDirectories;
  Directory({required this.name, required this.subDirectories});
}

// MapManagerPage with manual download/upload and uploaded maps sections
class MapManagerPage extends StatefulWidget {
  final List<Directory> directories;
  final Box<MapInfo> mapBox;
  final String? currentMapFilePath;
  final Function(String) onLoadMap;
  final Function(String, String) onDownloadMap;
  final Function(String, String, bool) onUploadMap;

  const MapManagerPage({
    Key? key,
    required this.directories,
    required this.mapBox,
    required this.currentMapFilePath,
    required this.onLoadMap,
    required this.onDownloadMap,
    required this.onUploadMap,
  }) : super(key: key);

  @override
  _MapManagerPageState createState() => _MapManagerPageState();
}

class _MapManagerPageState extends State<MapManagerPage> {
  List<MapInfo> _uploadedMaps = [];

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> _uploadMapFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['map', 'zip'],
      );
      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      final file = result.files.single;
      if (file.path == null) {
        throw Exception('Invalid file path');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final tempDir = io.Directory('${appDir.path}/temp_maps');
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      final fileName = file.name;
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = io.File(tempFilePath);
      final sourceFile = io.File(file.path!);
      await sourceFile.copy(tempFilePath);

      String mapFilePath = tempFilePath;
      String mapName = fileName.replaceAll(RegExp(r'\.(map|zip)$'), '');

      if (fileName.endsWith('.zip')) {
        print('Processing zip file: $tempFilePath');
        final bytes = await tempFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        bool mapFound = false;
        for (final archivedFile in archive) {
          if (archivedFile.isFile && archivedFile.name.toLowerCase().endsWith('.map')) {
            mapFilePath = '${tempDir.path}/${archivedFile.name}';
            final mapFile = io.File(mapFilePath);
            await mapFile.writeAsBytes(archivedFile.content as List<int>);
            mapName = archivedFile.name.replaceAll(RegExp(r'\.map$'), '');
            mapFound = true;
            print('Extracted .map file: ${archivedFile.name} to $mapFilePath');
            break;
          }
        }
        if (!mapFound) {
          throw Exception('No .map file found in the zip');
        }
        await tempFile.delete();
      }

      print('Validating uploaded map file: $mapFilePath');
      await MapFile.from(mapFilePath, null, null);

      final mapInfo = MapInfo(
        name: mapName,
        filePath: mapFilePath,
        downloadUrl: '',
        isTemporary: true,
      );
      setState(() {
        _uploadedMaps.add(mapInfo);
      });
      print('Added to uploaded maps: $mapName, path: $mapFilePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded $mapName')),
      );
    } catch (e) {
      print('Error uploading map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading map: $e')),
      );
    }
  }

  Future<void> _installMap(MapInfo mapInfo) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mapsDir = io.Directory('${appDir.path}/maps');
      if (!await mapsDir.exists()) {
        await mapsDir.create(recursive: true);
      }

      final sanitizedMapName = mapInfo.name.replaceAll(RegExp(r'[\s-]'), '_').toLowerCase();
      final newFilePath = '${mapsDir.path}/$sanitizedMapName.map';
      final sourceFile = io.File(mapInfo.filePath);
      await sourceFile.copy(newFilePath);

      print('Validating installed map file: $newFilePath');
      await MapFile.from(newFilePath, null, null);

      await widget.mapBox.add(MapInfo(
        name: mapInfo.name,
        filePath: newFilePath,
        downloadUrl: mapInfo.downloadUrl,
        isTemporary: false,
      ));

      setState(() {
        _uploadedMaps.remove(mapInfo);
      });
      await sourceFile.delete();
      print('Installed map: ${mapInfo.name}, path: $newFilePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Installed ${mapInfo.name}')),
      );
    } catch (e) {
      print('Error installing map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error installing map: $e')),
      );
    }
  }

  Future<void> _uninstallMap(MapInfo mapInfo) async {
    try {
      final file = io.File(mapInfo.filePath);
      if (await file.exists()) {
        await file.delete();
        print('Uninstalled map: ${mapInfo.name}, path: ${mapInfo.filePath}');
      }
      setState(() {
        _uploadedMaps.remove(mapInfo);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uninstalled ${mapInfo.name}')),
      );
    } catch (e) {
      print('Error uninstalling map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uninstalling map: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MapManagerPage, local maps: ${widget.mapBox.values.map((m) => m.name).toList()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Maps'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('Navigating back from MapManagerPage');
            Navigator.pop(context);
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.mapBox.listenable(),
        builder: (context, Box<MapInfo> mapBox, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Maps to Download:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.directories.map((directory) => ExpansionTile(
                        title: Text(directory.name),
                        children: directory.subDirectories.map((subDir) => ExpansionTile(
                              title: Text(subDir.name),
                              children: subDir.maps.map((map) {
                                final isDownloaded = mapBox.values.any(
                                  (m) => m.name == map.name && !m.isTemporary,
                                );
                                return ListTile(
                                  title: Text(map.name),
                                  trailing: isDownloaded
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : IconButton(
                                          icon: const Icon(Icons.download),
                                          onPressed: () => widget.onDownloadMap(map.url, map.name),
                                        ),
                                );
                              }).toList(),
                            )).toList(),
                      )),
                  const Divider(),
                  const Text(
                    'Local Maps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...mapBox.values.where((map) => !map.isTemporary).map((map) => ListTile(
                        title: Text(map.name),
                        trailing: widget.currentMapFilePath == map.filePath
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  print('Deleting map: ${map.name}, path: ${map.filePath}');
                                  final file = io.File(map.filePath);
                                  if (await file.exists()) {
                                    await file.delete();
                                    print('Deleted file: ${map.filePath}');
                                  }
                                  await mapBox.deleteAt(mapBox.values.toList().indexOf(map));
                                  if (widget.currentMapFilePath == map.filePath) {
                                    final defaultMap = mapBox.values.isNotEmpty
                                        ? mapBox.values.firstWhere((m) => !m.isTemporary, orElse: () => mapBox.values.first)
                                        : null;
                                    widget.onLoadMap(defaultMap?.filePath ?? '');
                                  }
                                },
                              ),
                        onTap: () {
                          print('Selecting map: ${map.name}, path: ${map.filePath}');
                          widget.onLoadMap(map.filePath);
                          Navigator.pop(context);
                        },
                      )),
                  const Divider(),
                  const Text(
                    'Manual Download & Upload Maps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prebuilt Maps (If the map you want is not found in the list of Available Maps)\n'
                    'Prebuilt maps are available from the following servers.',
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchUrl('https://download.mapsforge.org/maps/v5/'),
                    child: const Text(
                      'Mapsforge Server (not suitable for mass downloads)',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchUrl('https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/'),
                    child: const Text(
                      'Mirror Rechenzentrum der Hochschule Esslingen, University of Applied Sciences (fast)',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _uploadMapFile,
                    child: const Text('Upload'),
                  ),
                  const Divider(),
                  const Text(
                    'Uploaded Maps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._uploadedMaps.map((map) => ListTile(
                        title: Text(map.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.install_desktop),
                              onPressed: () => _installMap(map),
                              tooltip: 'Install',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _uninstallMap(map),
                              tooltip: 'Uninstall',
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GospelPage extends StatefulWidget {
  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPage> {
  late DisplayModel _displayModel;
  String? _currentMapFilePath;
  late Box<MapInfo> _mapBox;
  ViewModel? _viewModel; // Store ViewModel for zoom control

  final List<Directory> _availableMaps = [
    Directory(
      name: 'Africa',
      subDirectories: [
        SubDirectory(
          name: 'Countries',
          maps: [
            MapEntry(
              name: 'Egypt',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/africa/egypt.map',
            ),
            MapEntry(
              name: 'Morocco',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/africa/morocco.map',
            ),
            MapEntry(
              name: 'South Africa',
              url: 'https://download.openandromaps.org/maps/africa/South_Africa.zip',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'Asia',
      subDirectories: [
        SubDirectory(
          name: 'Countries',
          maps: [
            MapEntry(
              name: 'India',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/india.map',
            ),
            MapEntry(
              name: 'Israel and Palestine',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/israel-and-palestine.map',
            ),
            MapEntry(
              name: 'South Korea',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/south-korea.map',
            ),
            MapEntry(
              name: 'Japan',
              url: 'https://download.openandromaps.org/maps/asia/Japan.zip',
            ),
            MapEntry(
              name: 'Thailand',
              url: 'https://download.openandromaps.org/maps/asia/Thailand.zip',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'Europe',
      subDirectories: [
        SubDirectory(
          name: 'Countries',
          maps: [
            MapEntry(
              name: 'Germany',
              url: 'https://download.openandromaps.org/maps/europe/Germany.zip',
            ),
            MapEntry(
              name: 'France',
              url: 'https://download.openandromaps.org/maps/europe/France.zip',
            ),
            MapEntry(
              name: 'United Kingdom',
              url: 'https://download.openandromaps.org/maps/europe/United_Kingdom.zip',
            ),
            MapEntry(
              name: 'Italy',
              url: 'https://download.openandromaps.org/maps/europe/Italy.zip',
            ),
            MapEntry(
              name: 'Spain',
              url: 'https://download.openandromaps.org/maps/europe/Spain.zip',
            ),
            MapEntry(
              name: 'Poland',
              url: 'https://download.openandromaps.org/maps/europe/Poland.zip',
            ),
            MapEntry(
              name: 'Netherlands',
              url: 'https://download.openandromaps.org/maps/europe/Netherlands.zip',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'North America',
      subDirectories: [
        SubDirectory(
          name: 'United States',
          maps: [
            MapEntry(
              name: 'United States - Alabama',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/alabama.map',
            ),
            MapEntry(
              name: 'United States - Arkansas',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/arkansas.map',
            ),
            MapEntry(
              name: 'United States - Georgia',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/georgia.map',
            ),
            MapEntry(
              name: 'United States - Kentucky',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/kentucky.map',
            ),
            MapEntry(
              name: 'United States - Mississippi',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/mississippi.map',
            ),
            MapEntry(
              name: 'United States - Missouri',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/missouri.map',
            ),
            MapEntry(
              name: 'United States - North Carolina',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/north-carolina.map',
            ),
            MapEntry(
              name: 'United States - Tennessee',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/tennessee.map',
            ),
            MapEntry(
              name: 'United States - Virginia',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/virginia.map',
            ),
          ],
        ),
        SubDirectory(
          name: 'Other',
          maps: [
            MapEntry(
              name: 'Canada',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/canada.map',
            ),
            MapEntry(
              name: 'Mexico',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/mexico.map',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'South America',
      subDirectories: [
        SubDirectory(
          name: 'Countries',
          maps: [
            MapEntry(
              name: 'Argentina',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/south-america/argentina.map',
            ),
            MapEntry(
              name: 'Chile',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/south-america/chile.map',
            ),
            MapEntry(
              name: 'Brazil',
              url: 'https://download.openandromaps.org/maps/south-america/Brazil.zip',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'Oceania',
      subDirectories: [
        SubDirectory(
          name: 'Countries',
          maps: [
            MapEntry(
              name: 'Australia',
              url: 'https://download.openandromaps.org/maps/oceania/Australia.zip',
            ),
            MapEntry(
              name: 'New Zealand',
              url: 'https://download.openandromaps.org/maps/oceania/New_Zealand.zip',
            ),
          ],
        ),
      ],
    ),
    Directory(
      name: 'World',
      subDirectories: [
        SubDirectory(
          name: 'Global',
          maps: [
            MapEntry(
              name: 'World',
              url: 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/world/world.map',
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _displayModel = DisplayModel(deviceScaleFactor: 2.0);
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(MapInfoAdapter().typeId)) {
      Hive.registerAdapter(MapInfoAdapter());
    }
    _mapBox = await Hive.openBox<MapInfo>('maps');

    // Initialize default map (world.map, 3.1MB from provided URL)
    const defaultMapName = 'world.map';
    String? defaultMapPath;
    try {
      await DefaultAssetBundle.of(context).load('lib/assets/maps/$defaultMapName');
      defaultMapPath = await _copyAssetToFile(defaultMapName);
      if (!_mapBox.values.any((map) => map.filePath == defaultMapPath && !map.isTemporary)) {
        await _mapBox.add(MapInfo(
          name: 'World',
          filePath: defaultMapPath,
          downloadUrl: '',
          isTemporary: false,
        ));
      }
    } catch (e) {
      print('Default map (world.map) not found in assets: $e');
      final worldDir = _availableMaps.firstWhere((dir) => dir.name == 'World');
      final globalSubDir = worldDir.subDirectories.firstWhere((subDir) => subDir.name == 'Global');
      final map = globalSubDir.maps.firstWhere((m) => m.name == 'World');
      if (!_mapBox.values.any((m) => m.name == 'World' && !m.isTemporary)) {
        await _downloadMap(map.url, map.name);
      }
    }

    MapInfo? lastMap;
    try {
      lastMap = _mapBox.values.firstWhere((map) => map.name == 'World' && !map.isTemporary);
    } catch (e) {
      if (_mapBox.values.isNotEmpty) {
        lastMap = _mapBox.values.firstWhere((m) => !m.isTemporary, orElse: () => _mapBox.values.first);
      }
    }

    if (lastMap != null) {
      _currentMapFilePath = lastMap.filePath;
      print('Initialized with map: ${lastMap.name}, path: $_currentMapFilePath');
    } else if (defaultMapPath != null) {
      _currentMapFilePath = defaultMapPath;
      print('Initialized with default map path: $defaultMapPath');
    } else {
      print('No map initialized, _currentMapFilePath is null');
    }

    setState(() {});
  }

  Future<MapModel> _createMapModelFuture() async {
    if (_currentMapFilePath == null) {
      throw StateError('No map file path available.');
    }
    print('Creating MapModel for: $_currentMapFilePath');
    try {
      final mapFile = await MapFile.from(io.File(_currentMapFilePath!).path, null, null);
      final renderThemeBuilder = RenderThemeBuilder();
      final xml = await rootBundle.loadString('lib/assets/maps/render_themes/defaultrender.xml');
      renderThemeBuilder.parseXml(_displayModel, xml);
      final renderTheme = renderThemeBuilder.build();
      final renderer = MapDataStoreRenderer(
        mapFile,
        renderTheme,
        FileSymbolCache(),
        false,
      );
      print('MapModel created successfully for: $_currentMapFilePath');
      return MapModel(
        displayModel: _displayModel,
        renderer: renderer,
      );
    } catch (e) {
      print('Error creating MapModel for $_currentMapFilePath: $e');
      rethrow;
    }
  }

  Future<ViewModel> _createViewModelFuture() async {
    final viewModel = ViewModel(displayModel: _displayModel);
    _viewModel = viewModel; // Store ViewModel for zoom control
    double latitude = 0.0;
    double longitude = 0.0;
    int zoomLevel = 2;

    if (_currentMapFilePath != null) {
      final mapName = _mapBox.values
          .firstWhere(
            (map) => map.filePath == _currentMapFilePath,
            orElse: () => MapInfo(name: '', filePath: '', downloadUrl: '', isTemporary: false),
          )
          .name;
      if (mapName.startsWith('United States -')) {
        final stateCenters = {
          'United States - Tennessee': {'lat': 36.1627, 'lon': -86.7816},
          'United States - Kentucky': {'lat': 38.2009, 'lon': -84.8733},
          'United States - Virginia': {'lat': 37.5407, 'lon': -77.4360},
          'United States - North Carolina': {'lat': 35.7796, 'lon': -78.6382},
          'United States - Georgia': {'lat': 33.7490, 'lon': -84.3880},
          'United States - Alabama': {'lat': 32.3182, 'lon': -86.9023},
          'United States - Mississippi': {'lat': 32.2988, 'lon': -90.1848},
          'United States - Arkansas': {'lat': 34.7465, 'lon': -92.2896},
          'United States - Missouri': {'lat': 38.5767, 'lon': -92.1735},
        };
        if (stateCenters.containsKey(mapName)) {
          latitude = stateCenters[mapName]!['lat']!;
          longitude = stateCenters[mapName]!['lon']!;
          zoomLevel = 8;
        }
      }
    }

    print('Creating ViewModel with lat: $latitude, lon: $longitude, zoom: $zoomLevel');
    final position = MapViewPosition(
      latitude,
      longitude,
      zoomLevel,
      0,
      0,
    );
    viewModel.setMapViewPosition(position.latitude!, position.longitude!);
    viewModel.setZoomLevel(position.zoomLevel);
    return viewModel;
  }

  void _zoomIn() {
    if (_viewModel != null && _viewModel!.mapViewPosition != null) {
      final currentZoom = _viewModel!.mapViewPosition!.zoomLevel;
      final newZoom = (currentZoom + 1).clamp(2, 18); // Max zoom: 18
      _viewModel!.setMapViewPosition(
        _viewModel!.mapViewPosition!.latitude!,
        _viewModel!.mapViewPosition!.longitude!,
      );
      _viewModel!.setZoomLevel(newZoom);
      setState(() {});
      print('Zoomed in to: $newZoom');
    }
  }

  void _zoomOut() {
    if (_viewModel != null && _viewModel!.mapViewPosition != null) {
      final currentZoom = _viewModel!.mapViewPosition!.zoomLevel;
      final newZoom = (currentZoom - 1).clamp(2, 18); // Min zoom: 2
      _viewModel!.setMapViewPosition(
        _viewModel!.mapViewPosition!.latitude!,
        _viewModel!.mapViewPosition!.longitude!,
      );
      _viewModel!.setZoomLevel(newZoom);
      setState(() {});
      print('Zoomed out to: $newZoom');
    }
  }

  void _loadMap(String mapFilePath) {
    print('Loading map: $mapFilePath');
    setState(() {
      _currentMapFilePath = mapFilePath.isNotEmpty ? mapFilePath : null;
    });
  }

  Future<String> _copyAssetToFile(String assetPath) async {
    print('Copying asset: $assetPath');
    final data = await rootBundle.load('lib/assets/maps/$assetPath');
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = io.Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final tempFile = io.File('${mapsDir.path}/$assetPath');
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    print('Asset copied to: ${tempFile.path}');
    return tempFile.path;
  }

  Future<void> _downloadMap(String url, String mapName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = io.Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final sanitizedMapName = mapName.replaceAll(RegExp(r'[\s-]'), '_').toLowerCase();
    final mapFilePath = '${mapsDir.path}/$sanitizedMapName.map';
    final tempZipPath = '${mapsDir.path}/$sanitizedMapName.zip';

    print('Downloading map: $mapName from $url to $mapFilePath');

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadProgressDialog(
        mapName: mapName,
        url: url,
      ),
    );

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to download $mapName');
      }

      final totalBytes = response.contentLength ?? 0;
      final tempFile = io.File(tempZipPath);
      final sink = tempFile.openWrite();
      int receivedBytes = 0;

      // Stream download and update progress
      await for (var chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (totalBytes > 0) {
          final progress = (receivedBytes / totalBytes * 100).toStringAsFixed(0);
          print('Download progress: $progress% ($receivedBytes/$totalBytes bytes)');
          // Update dialog via notification
          DownloadProgressNotification(progress).dispatch(context);
        }
      }

      await sink.close();
      print('Downloaded file size: ${await tempFile.length()} bytes');

      io.File? mapFile;
      if (url.endsWith('.zip')) {
        print('Extracting zip: $tempZipPath');
        final bytes = await tempFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          if (file.isFile && file.name.toLowerCase().endsWith('.map')) {
            mapFile = io.File(mapFilePath);
            await mapFile.writeAsBytes(file.content as List<int>);
            print('Extracted .map file: ${file.name} to $mapFilePath');
            break;
          }
        }
        if (mapFile == null) {
          throw Exception('No .map file found in the downloaded zip');
        }
        await tempFile.delete();
      } else {
        mapFile = io.File(mapFilePath);
        await tempFile.rename(mapFilePath);
        print('Saved .map file to: $mapFilePath');
      }

      if (await mapFile.length() == 0) {
        throw Exception('Downloaded file is empty');
      }

      print('Validating map file: $mapFilePath');
      await MapFile.from(mapFilePath, null, null);
      print('Map file validated successfully');

      await _mapBox.add(MapInfo(
        name: mapName,
        filePath: mapFilePath,
        downloadUrl: url,
        isTemporary: false,
      ));
      print('Stored in Hive: $mapName, path: $mapFilePath');
      print('Current Hive maps: ${_mapBox.values.map((m) => m.name).toList()}');

      setState(() {
        _currentMapFilePath = mapFilePath;
        _loadMap(mapFilePath);
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $mapName')),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error downloading map $mapName: $e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $mapName: $e')),
      );
    } finally {
      final tempFile = io.File(tempZipPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
        print('Cleaned up temp file: $tempZipPath');
      }
    }
  }

  Future<void> _uploadMap(String filePath, String mapName, bool isZip) async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = io.Directory('${appDir.path}/temp_maps');
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }

    final sanitizedMapName = mapName.replaceAll(RegExp(r'[\s-]'), '_').toLowerCase();
    final mapFilePath = '${tempDir.path}/$sanitizedMapName.map';
    final tempZipPath = '${tempDir.path}/$sanitizedMapName.zip';

    print('Uploading map: $mapName, path: $filePath, isZip: $isZip');

    try {
      io.File? mapFile;
      if (isZip) {
        print('Processing zip: $filePath');
        final sourceFile = io.File(filePath);
        final tempFile = io.File(tempZipPath);
        await sourceFile.copy(tempZipPath);
        final bytes = await tempFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final archivedFile in archive) {
          if (archivedFile.isFile && archivedFile.name.toLowerCase().endsWith('.map')) {
            mapFile = io.File(mapFilePath);
            await mapFile.writeAsBytes(archivedFile.content as List<int>);
            print('Extracted .map file: ${archivedFile.name} to $mapFilePath');
            break;
          }
        }
        if (mapFile == null) {
          throw Exception('No .map file found in the uploaded zip');
        }
        await tempFile.delete();
      } else {
        mapFile = io.File(mapFilePath);
        await io.File(filePath).copy(mapFilePath);
        print('Copied .map file to: $mapFilePath');
      }

      print('Validating uploaded map file: $mapFilePath');
      await MapFile.from(mapFilePath, null, null);

      print('Uploaded map validated: $mapName, path: $mapFilePath');
    } catch (e) {
      print('Error uploading map $mapName: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading map: $e')),
      );
    } finally {
      final tempFile = io.File(tempZipPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
        print('Cleaned up temp file: $tempZipPath');
      }
    }
  }

  void _navigateToMapManager() {
    print('Navigating to MapManagerPage');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapManagerPage(
          directories: _availableMaps,
          mapBox: _mapBox,
          currentMapFilePath: _currentMapFilePath,
          onLoadMap: _loadMap,
          onDownloadMap: _downloadMap,
          onUploadMap: _uploadMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget, current map path: $_currentMapFilePath');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gospel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _navigateToMapManager,
            tooltip: 'Manage Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          _currentMapFilePath != null
              ? MapviewWidget(
                  displayModel: _displayModel,
                  createMapModel: _createMapModelFuture,
                  createViewModel: _createViewModelFuture,
                  changeKey: _currentMapFilePath,
                )
              : const Center(child: CircularProgressIndicator()),
          // Zoom controls
          if (_currentMapFilePath != null)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.zoom_in, size: 20),
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.zoom_out, size: 20),
                      onPressed: _zoomOut,
                      tooltip: 'Zoom Out',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing GospelPage');
    Hive.close();
    super.dispose();
  }
}

// Notification for download progress
class DownloadProgressNotification extends Notification {
  final String progress;
  DownloadProgressNotification(this.progress);
}

// Download progress dialog
class _DownloadProgressDialog extends StatefulWidget {
  final String mapName;
  final String url;

  const _DownloadProgressDialog({required this.mapName, required this.url});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  String _progress = '0%';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: NotificationListener<DownloadProgressNotification>(
        onNotification: (notification) {
          setState(() {
            _progress = notification.progress;
          });
          return true; // Consume the notification
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Downloading ${widget.mapName}... $_progress'),
          ],
        ),
      ),
    );
  }
}