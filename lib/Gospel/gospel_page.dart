import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, DefaultAssetBundle;
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:by_faith_app/models/map_entry_data.dart';
import 'package:by_faith_app/models/sub_directory.dart';
import 'package:by_faith_app/models/directory.dart';

part 'gospel_page.g.dart';

@HiveType(typeId: 1)
class MapInfo extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final String downloadUrl;

  @HiveField(3)
  final bool isTemporary;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final int zoomLevel;

  MapInfo({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
    this.isTemporary = false,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'filePath': filePath,
        'downloadUrl': downloadUrl,
        'isTemporary': isTemporary,
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
      };

  factory MapInfo.fromJson(Map<String, dynamic> json) => MapInfo(
        name: json['name'] as String,
        filePath: json['filePath'] as String,
        downloadUrl: json['downloadUrl'] as String,
        isTemporary: json['isTemporary'] as bool? ?? false,
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        zoomLevel: json['zoomLevel'] as int,
      );
}

class SubDirectory {
  final String name;

  final List<MapEntryData> maps;

  final List<SubDirectory> subDirectories;

  SubDirectory({
    required this.name,
    this.maps = const [],
    this.subDirectories = const [],
  });

  factory SubDirectory.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) => SubDirectory(
        name: json['name'] as String,
        maps: (json['maps'] as List<dynamic>?)
                ?.map((m) => MapEntryData.fromJson(m as Map<String, dynamic>, coordinateMap))
                .toList() ??
            [],
        subDirectories: (json['subDirectories'] as List<dynamic>?)
                ?.map((s) => SubDirectory.fromJson(s as Map<String, dynamic>, coordinateMap))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'maps': maps.map((m) => m.toJson()).toList(),
        'subDirectories': subDirectories.map((s) => s.toJson()).toList(),
      };
}

class Directory {
  final String name;

  final List<SubDirectory> subDirectories;

  Directory({
    required this.name,
    required this.subDirectories,
  });

  factory Directory.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> coordinateMap) => Directory(
        name: json['name'] as String,
        subDirectories: (json['subDirectories'] as List<dynamic>?)
                ?.map((s) => SubDirectory.fromJson(s as Map<String, dynamic>, coordinateMap))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'subDirectories': subDirectories.map((s) => s.toJson()).toList(),
      };
}

class MapManagerPage extends StatefulWidget {
  final List<Directory> directories;
  final Box<MapInfo> mapBox;
  final String? currentMapFilePath;
  final Function(String) onLoadMap;
  final Function(String, String) onDownloadMap;
  final Function(String, String, bool) onUploadMap;

  const MapManagerPage({
    super.key,
    required this.directories,
    required this.mapBox,
    required this.currentMapFilePath,
    required this.onLoadMap,
    required this.onDownloadMap,
    required this.onUploadMap,
  });

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
        allowedExtensions: ['map', 'MAP', 'zip', 'ZIP'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      final file = result.files.single;
      print('Selected file: ${file.name}, path: ${file.path}');
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
      String mapName = fileName.replaceAll(RegExp(r'\.(map|zip)$', caseSensitive: false), '');

      if (fileName.toLowerCase().endsWith('.zip')) {
        print('Processing zip file: $tempFilePath');
        final bytes = await tempFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        bool mapFound = false;
        for (final archivedFile in archive) {
          if (archivedFile.isFile && archivedFile.name.toLowerCase().endsWith('.map')) {
            mapFilePath = '${tempDir.path}/${archivedFile.name}';
            final mapFile = io.File(mapFilePath);
            await mapFile.writeAsBytes(archivedFile.content as List<int>);
            mapName = archivedFile.name.replaceAll(RegExp(r'\.map$', caseSensitive: false), '');
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
        latitude: 0.0,
        longitude: 0.0,
        zoomLevel: 2,
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
        latitude: mapInfo.latitude,
        longitude: mapInfo.longitude,
        zoomLevel: mapInfo.zoomLevel,
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

  Widget _buildSubDirectoryTile(SubDirectory subDir, int depth) {
    return ExpansionTile(
      title: Text(subDir.name),
      children: [
        ...subDir.maps.map((map) {
          final isDownloaded = widget.mapBox.values.any((m) => m.name == map.name && !m.isTemporary);
          return ListTile(
            title: Text(map.name),
            leading: SizedBox(width: depth * 16.0),
            trailing: isDownloaded
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => widget.onDownloadMap(map.primaryUrl, map.name),
                  ),
          );
        }),
        ...subDir.subDirectories.map((nestedSubDir) => _buildSubDirectoryTile(nestedSubDir, depth + 1)),
      ],
    );
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
                        children: directory.subDirectories.map((subDir) => _buildSubDirectoryTile(subDir, 1)).toList(),
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
                    onTap: () => _launchUrl(
                        'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/'),
                    child: const Text(
                      'Mirror Rechenzentrum der Hochschule Esslingen (fast)',
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
  const GospelPage({super.key});

  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPage> {
  late DisplayModel _displayModel;
  String? _currentMapFilePath;
  late Box<MapInfo> _mapBox;
  ViewModel? _viewModel;
  List<Directory> _availableMaps = [];
  bool _isLoadingMaps = true;

  @override
  void initState() {
    super.initState();
    _displayModel = DisplayModel(deviceScaleFactor: 2.0);
    _viewModel = ViewModel(displayModel: _displayModel); // Initialize ViewModel here
    _initHive().then((_) async { // Added async here
      // Set initial map position after Hive is ready and _currentMapFilePath is set
      if (_currentMapFilePath != null) {
        final mapInfo = _mapBox.values.firstWhere(
          (map) => map.filePath == _currentMapFilePath,
          orElse: () => MapInfo(name: '', filePath: '', downloadUrl: '', latitude: 0.0, longitude: 0.0, zoomLevel: 2),
        );
        _viewModel?.setMapViewPosition(mapInfo.latitude, mapInfo.longitude);
        _viewModel?.setZoomLevel(mapInfo.zoomLevel);
      }
      setState(() {}); // Trigger a rebuild now that _viewModel is initialized
      await _loadMapData(); // Moved this line inside the then block
    });
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    // Adapters are now registered in main.dart
    _mapBox = await Hive.openBox<MapInfo>('maps');

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
          latitude: 0.0,
          longitude: 0.0,
          zoomLevel: 2,
        ));
      }
    } catch (e) {
      print('Default map (world.map) not found in assets: $e');
      if (_availableMaps.isNotEmpty) {
        final worldDir = _availableMaps.firstWhere(
          (dir) => dir.name == 'World',
          orElse: () => Directory(name: '', subDirectories: []),
        );
        if (worldDir.subDirectories.isNotEmpty) {
          final globalSubDir = worldDir.subDirectories.firstWhere(
            (subDir) => subDir.name == 'Global',
            orElse: () => SubDirectory(name: '', maps: []),
          );
          final map = globalSubDir.maps.firstWhere(
            (m) => m.name == 'World',
            orElse: () => MapEntryData(
              name: '',
              primaryUrl: '',
              fallbackUrl: '',
              latitude: 0.0,
              longitude: 0.0,
              zoomLevel: 2,
            ),
          );
          if (map.primaryUrl.isNotEmpty &&
              !_mapBox.values.any((m) => m.name == 'World' && !m.isTemporary)) {
            await _downloadMap(map, map.name);
          }
        }
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

  Future<void> _loadMapData() async {
    try {
      // Load map_coordinates.json
      final coordinateJsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/map_coordinates.json');
      final coordinateData = jsonDecode(coordinateJsonString) as Map<String, dynamic>;
      final coordinateMap = <String, Map<String, dynamic>>{
        for (final entry in coordinateData.entries)
          entry.key: entry.value as Map<String, dynamic>,
      };

      // Load maps.json
      final jsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/maps.json');
      final decodedJson = jsonDecode(jsonString) as List<dynamic>;

      if (decodedJson.isEmpty) {
        throw Exception('Top level directory not found');
      }

      final topLevelJson = decodedJson.first as Map<String, dynamic>;
      if (!topLevelJson.containsKey('subDirectories')) {
        throw Exception('Top level subDirectories not found');
      }

      final List<dynamic> topLevelSubDirsJson = topLevelJson['subDirectories'];
      final v5Json = topLevelSubDirsJson.firstWhere(
        (subDirJson) => (subDirJson as Map<String, dynamic>)['name'] == 'V5',
        orElse: () => null,
      );

      if (v5Json == null || !v5Json.containsKey('subDirectories')) {
        throw Exception('V5 directory or its subdirectories not found');
      }

      final List<dynamic> continentDirsJson = v5Json['subDirectories'];
      final List<Directory> directories = continentDirsJson
          .map((continentDirJson) => Directory.fromJson(continentDirJson as Map<String, dynamic>, coordinateMap))
          .toList();

      setState(() {
        _availableMaps = directories;
        _isLoadingMaps = false;
      });
      print('Loaded ${_availableMaps.length} map directories with coordinates');
    } catch (e) {
      print('Error loading map data: $e');
      setState(() {
        _isLoadingMaps = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load map data')),
      );
    }
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
      final renderer = MapDataStoreRenderer(mapFile, renderTheme, FileSymbolCache(), false);
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

  void _zoomIn() {
    if (_viewModel != null && _viewModel!.mapViewPosition != null) {
      final currentZoom = _viewModel!.mapViewPosition!.zoomLevel;
      final newZoom = (currentZoom + 1).clamp(2, 18);
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
      final newZoom = (currentZoom - 1).clamp(2, 18);
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
    final mapInfo = _mapBox.values.firstWhere(
      (map) => map.filePath == mapFilePath,
      orElse: () => MapInfo(name: '', filePath: '', downloadUrl: '', latitude: 0.0, longitude: 0.0, zoomLevel: 2), // Provide a default MapInfo
    );
    setState(() {
      _currentMapFilePath = mapFilePath.isNotEmpty ? mapFilePath : null;
      _viewModel = ViewModel(
        displayModel: _displayModel,
      );
      _viewModel?.setMapViewPosition(mapInfo.latitude, mapInfo.longitude);
      _viewModel?.setZoomLevel(mapInfo.zoomLevel);
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

  Future<bool> _checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    print('Network status: $connectivityResult');
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _downloadMap(MapEntryData map, String mapName) async {
    if (!await _checkNetwork()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection. Please check your network.')),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = io.Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final sanitizedMapName = mapName.replaceAll(RegExp(r'[\s-]'), '_').toLowerCase();
    final mapFilePath = '${mapsDir.path}/$sanitizedMapName.map';
    final tempZipPath = '${mapsDir.path}/$sanitizedMapName.zip';

    print('Downloading map: $mapName from ${map.primaryUrl}');

    final mirrors = [map.primaryUrl, map.fallbackUrl];
    final completer = Completer<BuildContext>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        completer.complete(dialogContext);
        return _DownloadProgressDialog(mapName: mapName, url: map.primaryUrl);
      },
    );

    io.File? mapFile;
    Exception? lastError;

    const maxRetries = 3;
    for (var mirrorUrl in mirrors) {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          final dialogContext = await completer.future;
          final client = http.Client();
          final request = http.Request('GET', Uri.parse(mirrorUrl));
          print('Attempt $attempt/$maxRetries for $mirrorUrl');
          final response = await client.send(request).timeout(const Duration(seconds: 30));

          if (response.statusCode != 200) {
            throw Exception('HTTP ${response.statusCode}: Failed to download $mapName from $mirrorUrl');
          }

          final totalBytes = response.contentLength ?? -1;
          final tempFile = io.File(tempZipPath);
          final sink = tempFile.openWrite();
          int receivedBytes = 0;

          await for (var chunk in response.stream) {
            receivedBytes += chunk.length;
            sink.add(chunk);
            String progress;
            if (totalBytes > 0) {
              progress = (receivedBytes / totalBytes * 100).toStringAsFixed(0) + '%';
            } else {
              progress = '${(receivedBytes / 1024 / 1024).toStringAsFixed(1)} MB';
            }
            print('Download progress: $progress from $mirrorUrl');
            DownloadProgressNotification(progress).dispatch(dialogContext);
          }

          await sink.close();
          print('Downloaded file size: ${await tempFile.length()} bytes');

          if (mirrorUrl.endsWith('.zip')) {
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
          break;
        } catch (e) {
          print('Error downloading from $mirrorUrl (attempt $attempt/$maxRetries): $e');
          lastError = e is Exception ? e : Exception('Unknown error: $e');
          if (attempt == maxRetries) continue;
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      if (mapFile != null) break;
    }

    try {
      if (mapFile == null) {
        throw lastError ?? Exception('All mirrors failed for $mapName');
      }

      await _mapBox.add(MapInfo(
        name: mapName,
        filePath: mapFilePath,
        downloadUrl: map.primaryUrl,
        isTemporary: false,
        latitude: map.latitude,
        longitude: map.longitude,
        zoomLevel: map.zoomLevel,
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
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading map: $e')),
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

      // Load coordinates for the uploaded map
      double latitude = 0.0;
      double longitude = 0.0;
      int zoomLevel = 2;
      try {
        final coordinateJsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/map_coordinates.json');
        final coordinateData = jsonDecode(coordinateJsonString) as Map<String, dynamic>;
        final coordinateMap = <String, Map<String, dynamic>>{
          for (final entry in coordinateData.entries)
            entry.key: entry.value as Map<String, dynamic>,
        };
        final coords = coordinateMap[mapName] ?? {'latitude': 0.0, 'longitude': 0.0, 'zoomLevel': 2};
        latitude = coords['latitude'] as double;
        longitude = coords['longitude'] as double;
        zoomLevel = coords['zoomLevel'] as int;
      } catch (e) {
        print('Error loading map_coordinates.json for uploaded map: $e');
      }

      await _mapBox.add(MapInfo(
        name: mapName,
        filePath: mapFilePath,
        downloadUrl: '',
        isTemporary: true,
        latitude: latitude,
        longitude: longitude,
        zoomLevel: zoomLevel,
      ));

      print('Uploaded and added to mapBox: $mapName, path: $mapFilePath');
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
          onDownloadMap: (url, name) => _downloadMap(
            MapEntryData(
              name: name,
              primaryUrl: url,
              fallbackUrl: url.replaceFirst('ftp-stud.hs-esslingen.de', 'download.mapsforge.org'),
              latitude: 0.0,
              longitude: 0.0,
              zoomLevel: 2,
            ),
            name,
          ),
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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _isLoadingMaps ? null : _navigateToMapManager,
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
                  createViewModel: () => Future.value(_viewModel!),
                  changeKey: _currentMapFilePath,
                )
              : const Center(child: CircularProgressIndicator()),
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
    super.dispose();
  }
}

class DownloadProgressNotification extends Notification {
  final String progress;
  DownloadProgressNotification(this.progress);
}

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
    print('Building _DownloadProgressDialog, current progress: $_progress');
    return AlertDialog(
      content: NotificationListener<DownloadProgressNotification>(
        onNotification: (notification) {
          print('Received DownloadProgressNotification: ${notification.progress}');
          setState(() {
            _progress = notification.progress;
          });
          return true;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_progress == '0%') const CircularProgressIndicator(),
            if (_progress != '0%')
              _progress.endsWith('%')
                  ? LinearProgressIndicator(value: double.tryParse(_progress.replaceAll('%', ''))! / 100)
                  : const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text('Downloading ${widget.mapName}... $_progress'),
          ],
        ),
      ),
    );
  }
}