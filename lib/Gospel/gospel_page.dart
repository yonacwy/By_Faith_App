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
    // United States (OpenAndroMaps)
    {
      'name': 'California',
      'url': 'https://download.openandromaps.org/maps/usa/California.zip',
    },
    {
      'name': 'Tennessee',
      'url': 'https://download.openandromaps.org/maps/usa/Tennessee.zip',
    },
    {
      'name': 'Colorado',
      'url': 'https://download.openandromaps.org/maps/usa/Colorado.zip',
    },
    {
      'name': 'New York',
      'url': 'https://download.openandromaps.org/maps/usa/New_York.zip',
    },
    // Additional US regions (Mapsforge)
    {
      'name': 'Texas',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/texas.map',
    },
    {
      'name': 'Florida',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/north-america/us/florida.map',
    },
    // Global regions (OpenAndroMaps)
    {
      'name': 'Germany',
      'url': 'https://download.openandromaps.org/maps/europe/Germany.zip',
    },
    {
      'name': 'France',
      'url': 'https://download.openandromaps.org/maps/europe/France.zip',
    },
    {
      'name': 'Japan',
      'url': 'https://download.openandromaps.org/maps/asia/Japan.zip',
    },
    {
      'name': 'Australia',
      'url': 'https://download.openandromaps.org/maps/oceania/Australia.zip',
    },
    // Added Israel and Palestine map
    {
      'name': 'Israel and Palestine',
      'url': 'https://ftp-stud.hs-esslingen.de/pub/Mirrors/download.mapsforge.org/maps/v5/asia/israel-and-palestine.map',
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
      // Try to find the 'Israel and Palestine' map first.
      lastMap = _mapBox.values.firstWhere((map) => map.name == 'Israel and Palestine');
    } catch (e) {
      // If 'Israel and Palestine' map is not found, try to get the first available map.
      if (_mapBox.values.isNotEmpty) {
        lastMap = _mapBox.values.first;
      }
      // If no maps are available at all, lastMap remains null.
    }

    if (lastMap != null) {
      _currentMapFilePath = lastMap.filePath;
    } else if (defaultMapPath != null) {
      // Fallback to the default map path if no map was loaded from Hive
      _currentMapFilePath = defaultMapPath;
    }
    // Ensure _currentMapFilePath is set if possible, otherwise it remains null
    // and the UI will show a loading indicator or an error message.

    setState(() {});
  }

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
      false,
    );
    return MapModel(
      displayModel: _displayModel,
      renderer: renderer,
    );
  }

  Future<ViewModel> _createViewModelFuture() async {
    final viewModel = ViewModel(displayModel: _displayModel);
    final position = MapViewPosition(
      31.7683, // latitude (Jerusalem)
      35.2137, // longitude
      7, // zoomLevel
      0, // rotation
      0, // paddingFactor
    );
    viewModel.setMapViewPosition(position.latitude!, position.longitude!);
    viewModel.setZoomLevel(position.zoomLevel);
    return viewModel;
  }

  void _loadMap(String mapFilePath) {
    setState(() {
      _currentMapFilePath = mapFilePath;
    });
  }

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

  Future<void> _downloadMap(String url, String mapName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory('${appDir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    final mapFilePath = '${mapsDir.path}/$mapName.map';
    final tempZipPath = '${mapsDir.path}/$mapName.zip';

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
      if (request.statusCode == 200) {
        final tempFile = File(tempZipPath);
        await tempFile.writeAsBytes(request.bodyBytes);

        if (url.endsWith('.zip')) {
          final bytes = await tempFile.readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          File? mapFile;
          for (final file in archive) {
            if (file.isFile && file.name.endsWith('.map')) {
              mapFile = File(mapFilePath);
              await mapFile.writeAsBytes(file.content as List<int>);
              break;
            }
          }
          if (mapFile == null) {
            throw Exception('No .map file found in the downloaded zip');
          }
          await tempFile.delete();
        } else {
          final file = File(mapFilePath);
          await file.writeAsBytes(request.bodyBytes);
        }

        if (await File(mapFilePath).length() == 0) {
          throw Exception('Downloaded file is empty');
        }

        // Validate the map file by attempting to create a MapFile object.
        // If this fails, it will throw an exception, caught by the outer try-catch.
        await MapFile.from(File(mapFilePath).path, null, null);
        // The MapFile object created here is temporary for validation and does not need to be explicitly closed
        // as it's not stored or used further in this local scope.

        await _mapBox.add(MapInfo(
          name: mapName,
          filePath: mapFilePath,
          downloadUrl: url,
        ));

        setState(() {
          _currentMapFilePath = mapFilePath;
          _loadMap(mapFilePath);
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $mapName')),
        );
      } else {
        throw Exception('HTTP ${request.statusCode}: Failed to download $mapName');
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $mapName: $e')),
      );
    } finally {
      final tempFile = File(tempZipPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

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
              ..._availableMaps.map((map) {
                final isDownloaded = _mapBox.values.any(
                  (m) => m.name == map['name'],
                );
                return ListTile(
                  title: Text(map['name']!),
                  trailing: isDownloaded
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadMap(map['url']!, map['name']!),
                        ),
                );
              }),
              const Divider(),
              const Text('Local Maps:'),
              ..._mapBox.values.map((map) => ListTile(
                    title: Text(map.name),
                    trailing: _currentMapFilePath == map.filePath
                        ? const Icon(Icons.check, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final file = File(map.filePath);
                              if (await file.exists()) {
                                await file.delete();
                              }
                              await _mapBox.deleteAt(_mapBox.values.toList().indexOf(map));
                              if (_currentMapFilePath == map.filePath) {
                                final defaultMap = _mapBox.values.isNotEmpty
                                    ? _mapBox.values.first
                                    : null;
                                setState(() {
                                  _currentMapFilePath = defaultMap?.filePath;
                                });
                              }
                              setState(() {});
                              Navigator.pop(context);
                              _showMapSelectionDialog();
                            },
                          ),
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