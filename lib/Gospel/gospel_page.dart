import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

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

class GospelPage extends StatefulWidget {
  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPage> {
  late DisplayModel _displayModel; // Declare DisplayModel as a class member
  String? _currentMapFilePath;
  late Box<MapInfo> _mapBox;

  // Available maps for download (replace with actual URLs)
  final List<Map<String, String>> _availableMaps = [
    {
      'name': 'Tennessee',
      'url': 'https://example.com/maps/tennessee.map', // Replace with valid URL
    },
    {
      'name': 'California',
      'url': 'https://example.com/maps/california.map', // Replace with valid URL
    },
  ];

  @override
  void initState() {
    super.initState();
    _displayModel = DisplayModel(deviceScaleFactor: 2.0); // Initialize DisplayModel
    _initHive();
  }

  // Initialize Hive and load default map
  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(MapInfoAdapter().typeId)) {
      Hive.registerAdapter(MapInfoAdapter());
    }
    _mapBox = await Hive.openBox<MapInfo>('maps');

    // Initialize default map (tennessee.map)
    final defaultMapName = 'tennessee.map';
    final defaultMapPath = await _copyAssetToFile(defaultMapName);
    if (!_mapBox.values.any((map) => map.filePath == defaultMapPath)) {
      await _mapBox.add(MapInfo(
        name: 'Tennessee',
        filePath: defaultMapPath,
        downloadUrl: '',
      ));
    }

    // Load default or last used map
    final lastMap = _mapBox.values.isNotEmpty ? _mapBox.values.first : null;
    if (lastMap != null) {
      _currentMapFilePath = lastMap.filePath;
    }
    setState(() {}); // Trigger initial build with _currentMapFilePath
  }

  // Create MapModel future for MapviewWidget
  Future<MapModel> _createMapModelFuture() async {
    if (_currentMapFilePath == null) {
      throw StateError("No map file path available.");
    }
    final mapFile = await MapFile.from(File(_currentMapFilePath!).path, null, null);
    final renderThemeBuilder = RenderThemeBuilder();
    final xml = await rootBundle
        .loadString('lib/assets/maps/render_themes/defaultrender.xml');
    renderThemeBuilder.parseXml(_displayModel, xml);
    final renderTheme = renderThemeBuilder.build();
    final renderer = MapDataStoreRenderer(
      mapFile,
      renderTheme,
      FileSymbolCache(),
      false, // enableTextAntialiasing
    );
    return MapModel(
      displayModel: _displayModel,
      renderer: renderer,
    );
  }

  // Create ViewModel future for MapviewWidget
  Future<ViewModel> _createViewModelFuture() async {
    final viewModel = ViewModel(displayModel: _displayModel);
    final position = MapViewPosition(
      36.1627, // latitude (Nashville, TN)
      -86.7816, // longitude
      7, // zoomLevel
      0, // rotation
      0, // paddingFactor
    );
    // Fix: Use setMapViewPosition with latitude and longitude
    viewModel.setMapViewPosition(position.latitude!, position.longitude!);
    // Set zoom level separately
    viewModel.setZoomLevel(position.zoomLevel);
    return viewModel;
  }

  // Refactored _loadMap to just update the path and trigger rebuild
  void _loadMap(String mapFilePath) {
    setState(() {
      _currentMapFilePath = mapFilePath;
    });
  }

  // Copy asset to a writable file
  Future<String> _copyAssetToFile(String assetPath) async {
    final data = await rootBundle.load('lib/assets/maps/$assetPath');
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final tempFile = File('${mapsDir.path}/$assetPath');
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    return tempFile.path;
  }

  // Download a map file
  Future<void> _downloadMap(String url, String mapName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final mapFilePath = '${mapsDir.path}/$mapName.map';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(mapFilePath);
        await file.writeAsBytes(response.bodyBytes);
        await _mapBox.add(MapInfo(
          name: mapName,
          filePath: mapFilePath,
          downloadUrl: url,
        ));
        setState(() {
          _currentMapFilePath = mapFilePath;
          _loadMap(mapFilePath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $mapName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download $mapName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $mapName: $e')),
      );
    }
  }

  // Show map selection dialog
  void _showMapSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Maps'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Available Maps to Download:'),
              ..._availableMaps.map((map) => ListTile(
                    title: Text(map['name']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: _mapBox.values.any((m) =>
                              m.filePath.endsWith('${map['name']!.toLowerCase()}.map'))
                          ? null
                          : () => _downloadMap(map['url']!, map['name']!),
                    ),
                  )),
              const Divider(),
              const Text('Local Maps:'),
              ..._mapBox.values.map((map) => ListTile(
                    title: Text(map.name),
                    trailing: _currentMapFilePath == map.filePath
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _currentMapFilePath = map.filePath;
                        _loadMap(map.filePath);
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gospel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showMapSelectionDialog,
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
    Hive.close();
    super.dispose();
  }
}