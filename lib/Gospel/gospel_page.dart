import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:archive/archive.dart';

// Hive model for map metadata
class MapInfo {
  final String name;
  final String filePath;
  final String downloadUrl;

  MapInfo({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'filePath': filePath,
        'downloadUrl': downloadUrl,
      };

  factory MapInfo.fromJson(Map<String, dynamic> json) => MapInfo(
        name: json['name'],
        filePath: json['filePath'],
        downloadUrl: json['downloadUrl'],
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

// Updated MapManagerPage to handle real-time updates
class MapManagerPage extends StatefulWidget {
  final List<Map<String, String>> availableMaps;
  final Box<MapInfo> mapBox;
  final String? currentMapFilePath;
  final Function(String) onLoadMap;
  final Function(String, String) onDownloadMap;

  const MapManagerPage({
    Key? key,
    required this.availableMaps,
    required this.mapBox,
    required this.currentMapFilePath,
    required this.onLoadMap,
    required this.onDownloadMap,
  }) : super(key: key);

  @override
  _MapManagerPageState createState() => _MapManagerPageState();
}

class _MapManagerPageState extends State<MapManagerPage> {
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
                  ...widget.availableMaps.map((map) {
                    final isDownloaded = mapBox.values.any(
                      (m) => m.name == map['name'],
                    );
                    return ListTile(
                      title: Text(map['name']!),
                      trailing: isDownloaded
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => widget.onDownloadMap(map['url']!, map['name']!),
                            ),
                    );
                  }),
                  const Divider(),
                  const Text(
                    'Local Maps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...mapBox.values.map((map) => ListTile(
                        title: Text(map.name),
                        trailing: widget.currentMapFilePath == map.filePath
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  print('Deleting map: ${map.name}, path: ${map.filePath}');
                                  final file = File(map.filePath);
                                  if (await file.exists()) {
                                    await file.delete();
                                    print('Deleted file: ${map.filePath}');
                                  }
                                  await mapBox.deleteAt(mapBox.values.toList().indexOf(map));
                                  if (widget.currentMapFilePath == map.filePath) {
                                    final defaultMap = mapBox.values.isNotEmpty
                                        ? mapBox.values.first
                                        : null;
                                    widget.onLoadMap(defaultMap?.filePath ?? '');
                                  }
                                  // No setState needed due to ValueListenableBuilder
                                },
                              ),
                        onTap: () {
                          print('Selecting map: ${map.name}, path: ${map.filePath}');
                          widget.onLoadMap(map.filePath);
                          Navigator.pop(context);
                        },
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

  // Comprehensive list of available maps with working download links
  final List<Map<String, String>> _availableMaps = [
    // North America (Mapsforge v5) - Tennessee and bordering states
    {
      'name': 'United States - Tennessee',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/tennessee.map',
    },
    {
      'name': 'United States - Kentucky',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/kentucky.map',
    },
    {
      'name': 'United States - Virginia',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/virginia.map',
    },
    {
      'name': 'United States - North Carolina',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/north-carolina.map',
    },
    {
      'name': 'United States - Georgia',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/georgia.map',
    },
    {
      'name': 'United States - Alabama',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/alabama.map',
    },
    {
      'name': 'United States - Mississippi',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/mississippi.map',
    },
    {
      'name': 'United States - Arkansas',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/arkansas.map',
    },
    {
      'name': 'United States - Missouri',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/missouri.map',
    },
    // Other North America (Mapsforge v5)
    {
      'name': 'Canada',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/canada.map',
    },
    {
      'name': 'Mexico',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/mexico.map',
    },
    // Europe (OpenAndroMaps)
    {
      'name': 'Germany',
      'url': 'https://download.openandromaps.org/maps/europe/Germany.zip',
    },
    {
      'name': 'France',
      'url': 'https://download.openandromaps.org/maps/europe/France.zip',
    },
    {
      'name': 'United Kingdom',
      'url': 'https://download.openandromaps.org/maps/europe/United_Kingdom.zip',
    },
    {
      'name': 'Italy',
      'url': 'https://download.openandromaps.org/maps/europe/Italy.zip',
    },
    {
      'name': 'Spain',
      'url': 'https://download.openandromaps.org/maps/europe/Spain.zip',
    },
    {
      'name': 'Poland',
      'url': 'https://download.openandromaps.org/maps/europe/Poland.zip',
    },
    {
      'name': 'Netherlands',
      'url': 'https://download.openandromaps.org/maps/europe/Netherlands.zip',
    },
    // Asia (Mapsforge v5 and OpenAndroMaps)
    {
      'name': 'Israel and Palestine',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/israel-and-palestine.map',
    },
    {
      'name': 'Japan',
      'url': 'https://download.openandromaps.org/maps/asia/Japan.zip',
    },
    {
      'name': 'India',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/india.map',
    },
    {
      'name': 'South Korea',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/south-korea.map',
    },
    {
      'name': 'Thailand',
      'url': 'https://download.openandromaps.org/maps/asia/Thailand.zip',
    },
    // Africa (Mapsforge v5 and OpenAndroMaps)
    {
      'name': 'South Africa',
      'url': 'https://download.openandromaps.org/maps/africa/South_Africa.zip',
    },
    {
      'name': 'Egypt',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/africa/egypt.map',
    },
    {
      'name': 'Morocco',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/africa/morocco.map',
    },
    // South America (Mapsforge v5 and OpenAndroMaps)
    {
      'name': 'Brazil',
      'url': 'https://download.openandromaps.org/maps/south-america/Brazil.zip',
    },
    {
      'name': 'Argentina',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/south-america/argentina.map',
    },
    {
      'name': 'Chile',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/south-america/chile.map',
    },
    // Oceania (OpenAndroMaps)
    {
      'name': 'Australia',
      'url': 'https://download.openandromaps.org/maps/oceania/Australia.zip',
    },
    {
      'name': 'New Zealand',
      'url': 'https://download.openandromaps.org/maps/oceania/New_Zealand.zip',
    },
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

    // Initialize default map (israel-and-palestine.map) if it exists in assets
    const defaultMapName = 'israel-and-palestine.map';
    String? defaultMapPath;
    try {
      await DefaultAssetBundle.of(context).load('lib/assets/maps/$defaultMapName');
      defaultMapPath = await _copyAssetToFile(defaultMapName);
      if (!_mapBox.values.any((map) => map.filePath == defaultMapPath)) {
        await _mapBox.add(MapInfo(
          name: 'Israel and Palestine',
          filePath: defaultMapPath,
          downloadUrl: '',
        ));
      }
    } catch (e) {
      print('Default map not found in assets: $e');
      // Fallback to downloading if not in assets
      final map = _availableMaps.firstWhere((m) => m['name'] == 'Israel and Palestine');
      if (!_mapBox.values.any((m) => m.name == 'Israel and Palestine')) {
        await _downloadMap(map['url']!, map['name']!);
      }
    }

    // Load default or last used map
    MapInfo? lastMap;
    try {
      lastMap = _mapBox.values.firstWhere((map) => map.name == 'Israel and Palestine');
    } catch (e) {
      if (_mapBox.values.isNotEmpty) {
        lastMap = _mapBox.values.first;
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
      final mapFile = await MapFile.from(File(_currentMapFilePath!).path, null, null);
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
    double latitude = 31.7683; // Default: Jerusalem
    double longitude = 35.2137;
    int zoomLevel = 7;

    // Adjust coordinates for US states
    if (_currentMapFilePath != null) {
      final mapName = _mapBox.values
          .firstWhere(
            (map) => map.filePath == _currentMapFilePath,
            orElse: () => MapInfo(name: '', filePath: '', downloadUrl: ''),
          )
          .name;
      if (mapName.startsWith('United States -')) {
        // Approximate center coordinates for US states
        final stateCenters = {
          'United States - Tennessee': {'lat': 36.1627, 'lon': -86.7816}, // Nashville
          'United States - Kentucky': {'lat': 38.2009, 'lon': -84.8733}, // Frankfort
          'United States - Virginia': {'lat': 37.5407, 'lon': -77.4360}, // Richmond
          'United States - North Carolina': {'lat': 35.7796, 'lon': -78.6382}, // Raleigh
          'United States - Georgia': {'lat': 33.7490, 'lon': -84.3880}, // Atlanta
          'United States - Alabama': {'lat': 32.3182, 'lon': -86.9023}, // Montgomery
          'United States - Mississippi': {'lat': 32.2988, 'lon': -90.1848}, // Jackson
          'United States - Arkansas': {'lat': 34.7465, 'lon': -92.2896}, // Little Rock
          'United States - Missouri': {'lat': 38.5767, 'lon': -92.1735}, // Jefferson City
        };
        if (stateCenters.containsKey(mapName)) {
          latitude = stateCenters[mapName]!['lat']!;
          longitude = stateCenters[mapName]!['lon']!;
          zoomLevel = 8; // Better zoom for US states
        }
      }
    }

    print('Creating ViewModel with lat: $latitude, lon: $longitude, zoom: $zoomLevel');
    final position = MapViewPosition(
      latitude,
      longitude,
      zoomLevel,
      0, // rotation
      0, // paddingFactor
    );
    viewModel.setMapViewPosition(position.latitude!, position.longitude!);
    viewModel.setZoomLevel(position.zoomLevel);
    return viewModel;
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
    final mapsDir = Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final tempFile = File('${mapsDir.path}/$assetPath');
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    print('Asset copied to: ${tempFile.path}');
    return tempFile.path;
  }

  Future<void> _downloadMap(String url, String mapName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    // Sanitize mapName to avoid spaces and special characters
    final sanitizedMapName = mapName.replaceAll(RegExp(r'[\s-]'), '_').toLowerCase();
    final mapFilePath = '${mapsDir.path}/$sanitizedMapName.map';
    final tempZipPath = '${mapsDir.path}/$sanitizedMapName.zip';

    print('Downloading map: $mapName from $url to $mapFilePath');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Downloading $mapName...'),
          ],
        ),
      ),
    );

    try {
      final client = http.Client();
      final request = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (request.statusCode != 200) {
        throw Exception('HTTP ${request.statusCode}: Failed to download $mapName');
      }

      final tempFile = File(tempZipPath);
      await tempFile.writeAsBytes(request.bodyBytes);
      print('Downloaded file size: ${await tempFile.length()} bytes');

      File? mapFile;
      if (url.endsWith('.zip')) {
        print('Extracting zip: $tempZipPath');
        final bytes = await tempFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          if (file.isFile && file.name.toLowerCase().endsWith('.map')) {
            mapFile = File(mapFilePath);
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
        mapFile = File(mapFilePath);
        await mapFile.writeAsBytes(request.bodyBytes);
        print('Saved .map file to: $mapFilePath');
      }

      if (await mapFile.length() == 0) {
        throw Exception('Downloaded file is empty');
      }

      // Validate the map file
      print('Validating map file: $mapFilePath');
      await MapFile.from(mapFilePath, null, null);
      print('Map file validated successfully');

      // Store in Hive
      await _mapBox.add(MapInfo(
        name: mapName,
        filePath: mapFilePath,
        downloadUrl: url,
      ));
      print('Stored in Hive: $mapName, path: $mapFilePath');
      print('Current Hive maps: ${_mapBox.values.map((m) => m.name).toList()}');

      // Update current map and reload
      setState(() {
        _currentMapFilePath = mapFilePath;
        _loadMap(mapFilePath);
      });

      Navigator.pop(context); // Close download dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $mapName')),
      );

      // Redirect to GospelPage with the new map
      Navigator.pop(context); // Ensure MapManagerPage is closed
    } catch (e) {
      print('Error downloading map $mapName: $e');
      Navigator.pop(context); // Close download dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $mapName: $e')),
      );
    } finally {
      final tempFile = File(tempZipPath);
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
          availableMaps: _availableMaps,
          mapBox: _mapBox,
          currentMapFilePath: _currentMapFilePath,
          onLoadMap: _loadMap,
          onDownloadMap: _downloadMap,
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
      body: _currentMapFilePath != null
          ? MapviewWidget(
              displayModel: _displayModel,
              createMapModel: _createMapModelFuture,
              createViewModel: _createViewModelFuture,
              changeKey: _currentMapFilePath,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    print('Disposing GospelPage');
    Hive.close();
    super.dispose();
  }
}