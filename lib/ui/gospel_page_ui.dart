import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:archive/archive.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';
import 'package:by_faith_app/ui/gospel_contacts_ui.dart' as gospel_contacts_ui;
import 'package:by_faith_app/ui/gospel_map_manager_ui.dart' as gospel_map_manager_ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DefaultAssetBundle, rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:mapsforge_flutter/marker.dart';
import 'package:mapsforge_flutter/src/graphics/bitmap.dart';
import 'package:mapsforge_flutter/src/graphics/graphicfactory.dart';
import 'package:mapsforge_flutter/src/model/latlong.dart';
import 'package:mapsforge_flutter/src/model/mappoint.dart';
import 'package:mapsforge_flutter/src/projection/mercatorprojection.dart';
import 'package:mapsforge_flutter/src/projection/pixelprojection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class GospelPageUi extends StatefulWidget {
  const GospelPageUi({super.key});

  @override
  _GospelPageState createState() => _GospelPageState();
}

class CustomAssetMarker extends BasicPointMarker<Contact> {
  final Bitmap? image;
  final double width;
  final double height;
  final VoidCallback? onTap;
  Offset? _screenPoint;
  MarkerContext? _markerContext;

  CustomAssetMarker(
    LatLong latLong, {
    required this.image,
    required this.width,
    required this.height,
    this.onTap,
    Contact? item,
  }) : super(latLong: latLong, item: item);

  @override
  void render(MapCanvas mapCanvas, MarkerContext markerContext) {
    _markerContext = markerContext;
    super.render(mapCanvas, markerContext);
  }

  @override
  void renderBitmap(MapCanvas mapCanvas, MarkerContext markerContext) {
    if (image != null) {
      final paint = GraphicFactory().createPaint();
      mapCanvas.drawBitmap(
        bitmap: image!,
        left: -width / 2,
        top: -height / 2,
        paint: paint,
      );
    }
  }

  @override
  bool isTapped(TapEvent tapEvent) {
    if (_screenPoint != null && _markerContext != null) {
      final imageRect = Rect.fromLTWH(
        _screenPoint!.dx - width / 2,
        _screenPoint!.dy - height / 2,
        width,
        height,
      );
      if (imageRect.contains(Offset(tapEvent.mappoint.x, tapEvent.mappoint.y))) {
        onTap?.call();
        return true;
      }
    }
    return false;
  }
}

class _GospelPageState extends State<GospelPageUi> {
  late DisplayModel _displayModel;
  String? _currentMapFilePath;
  late Box<MapInfo> _mapBox;
  late Box<Contact> _contactBox;
  ViewModel? _viewModel;
  MapModel? _cachedMapModel;
  late Future<MapModel?> _mapModelFuture;
  late Future<ViewModel> _viewModelFuture;
  List<Directory> _availableMaps = [];
  bool _isLoadingMaps = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MarkerDataStore? _markerDataStore;
  late SymbolCache _symbolCache;
  bool _isHiveInitialized = false;
  List<CustomAssetMarker> _markers = [];
  bool _isAddingMarker = false;
  bool _isDisposed = false;
  final Uuid _uuid = const Uuid();
  Bitmap? _markerBitmap;
  String? _lastMapFilePath;
  int _markerUpdateKey = 0;

  @override
  void initState() {
    super.initState();
    print('Initializing GospelPageState');
    _displayModel = DisplayModel(deviceScaleFactor: 2.0);
    _viewModel = ViewModel(displayModel: _displayModel);
    _viewModelFuture = _createViewModelFuture();

    _initHive().then((_) async {
      if (_isDisposed) {
        print('Aborting init due to disposal');
        return;
      }
      _isHiveInitialized = true;
      _symbolCache = FileSymbolCache();
      print('Hive initialized, loading map data');

      if (_currentMapFilePath == null) {
        _viewModel?.setMapViewPosition(0.0, 0.0);
        _viewModel?.setZoomLevel(2);
      }

      _mapModelFuture = _createMapModelFuture();
      await _mapModelFuture; // Ensure map model is created before setting up markers
      await _loadMapData();
      await _setupMarkers(_symbolCache);
      setState(() {
        _isLoadingMaps = false;
      });
      print('Map data and markers loaded');
      _contactBox.listenable().addListener(_onContactBoxChanged);

      // Tap event handling will be done via MapOptions callbacks
    });
  }

  void _onContactBoxChanged() {
    if (!_isDisposed && mounted) {
      print('Contact box changed, updating markers. Current contacts: ${_contactBox.values.length}');
      _setupMarkers(_symbolCache).then((_) {
        if (mounted) {
          setState(() {
            _markerUpdateKey++;
            _mapModelFuture = Future.value(_cachedMapModel);
          });
        }
      });
    }
  }

  Future<void> _initHive() async {
    print('Initializing Hive');
    try {
      await Hive.initFlutter();
      _mapBox = await Hive.openBox<MapInfo>('maps');
      _contactBox = await Hive.openBox<Contact>('contacts');
      print('Hive boxes opened: maps, contacts');

      const defaultMapName = 'world.map';
      String? defaultMapPath;
      try {
        final manifest = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
        final assets = jsonDecode(manifest) as Map<String, dynamic>;
        if (assets.containsKey('lib/assets/maps/$defaultMapName')) {
          defaultMapPath = await _copyAssetToFile(defaultMapName);
          print('Default map path: $defaultMapPath');
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
            print('Added world map to mapBox');
          }
          _currentMapFilePath = defaultMapPath;
        } else {
          print('World map asset not found in AssetManifest');
        }
      } catch (e) {
        print('Error loading default map: $e');
        if (_mapBox.isNotEmpty) {
          _currentMapFilePath = _mapBox.values.firstWhere((m) => !m.isTemporary).filePath;
          print('Falling back to existing map: $_currentMapFilePath');
        }
      }

      if (_currentMapFilePath != null) {
        final mapInfo = _mapBox.values.firstWhere(
          (map) => map.filePath == _currentMapFilePath,
          orElse: () => MapInfo(
            name: 'World',
            filePath: _currentMapFilePath!,
            downloadUrl: '',
            latitude: 0.0,
            longitude: 0.0,
            zoomLevel: 2,
          ),
        );
        _viewModel?.setMapViewPosition(mapInfo.latitude, mapInfo.longitude);
        _viewModel?.setZoomLevel(mapInfo.zoomLevel);
        print('Set initial map position: lat=${mapInfo.latitude}, lon=${mapInfo.longitude}, zoom=${mapInfo.zoomLevel}');
      }
    } catch (e) {
      print('Hive initialization error: $e');
      setState(() {
        _isLoadingMaps = false;
      });
    }
  }

  Future<void> _setupMarkers(SymbolCache symbolCache) async {
    if (_isDisposed) {
      print('Aborting marker setup due to disposal');
      return;
    }
    print('Setting up markers');
    try {
      _markerBitmap = await symbolCache.getOrCreateSymbol('lib/assets/marker.png', 32, 32).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Timeout loading marker.png');
          throw TimeoutException('Failed to load marker.png');
        },
      );
      print('Marker bitmap loaded');
    } catch (e) {
      print('Error loading marker bitmap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load marker image: $e')),
      );
      return;
    }

    _markerDataStore = MarkerDataStore();
    _markerDataStore?.clearMarkers();
    _markers.clear();
    print('Contacts in _contactBox: ${_contactBox.values.length}');
    if (_markerBitmap != null) {
      for (var contact in _contactBox.values) {
        print('Creating marker for contact: ${contact.name} at (${contact.latitude}, ${contact.longitude})');
        final marker = _createMarker(contact);
        _markerDataStore?.addMarker(marker);
        _markers.add(marker);
      }
      print('Added ${_markers.length} markers to _markers list');

      if (_cachedMapModel != null && _markerDataStore != null) {
        final newMapModel = MapModel(
          displayModel: _cachedMapModel!.displayModel,
          renderer: _cachedMapModel!.renderer,
          symbolCache: _cachedMapModel!.symbolCache,
        );
        newMapModel.markerDataStores.add(_markerDataStore!);
        _cachedMapModel = newMapModel;
        print('Created new MapModel instance with updated MarkerDataStore');
      } else if (_markerDataStore != null) {
        print('Warning: _cachedMapModel is null during marker setup. Markers might not be added to the initial MapModel.');
      }
    } else {
      print('Marker bitmap is null, cannot create markers');
    }
  }

  CustomAssetMarker _createMarker(Contact contact) {
    print('Creating marker for contact: ${contact.name} with bitmap: ${_markerBitmap != null}');
    return CustomAssetMarker(
      LatLong(contact.latitude, contact.longitude),
      image: _markerBitmap,
      width: 32,
      height: 32,
      onTap: () {
        if (_isDisposed) {
          print('Marker tap ignored: widget is disposed');
          return;
        }
        print('Marker tapped for contact: ${contact.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => gospel_contacts_ui.AddEditContactPage(
              contactBox: _contactBox,
              contact: contact,
              latitude: contact.latitude,
              longitude: contact.longitude,
              onContactAdded: (newContact) {
                print('Contact updated from map: ${newContact.name}');
                _setupMarkers(_symbolCache).then((_) {
                  if (mounted) {
                    setState(() {
                      _markerUpdateKey++;
                      _mapModelFuture = Future.value(_cachedMapModel);
                    });
                  }
                });
              },
            ),
          ),
        );
      },
      item: contact,
    );
  }

  Future<void> _loadMapData() async {
    print('Loading map data');
    try {
      final coordinateJsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/map_coordinates.json');
      final coordinateData = jsonDecode(coordinateJsonString) as Map<String, dynamic>;
      final coordinateMap = <String, Map<String, dynamic>>{
        for (final entry in coordinateData.entries) entry.key: entry.value as Map<String, dynamic>,
      };
      print('Loaded map_coordinates.json');

      final jsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/maps.json');
      final decodedJson = jsonDecode(jsonString) as List<dynamic>;
      print('Loaded maps.json');

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
      print('Loaded ${_availableMaps.length} map directories');
    } catch (e) {
      print('Error loading map data: $e');
      setState(() {
        _isLoadingMaps = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load map data: $e')),
      );
    }
  }

  Future<MapModel> _createMapModelFuture() async {
    print('Creating MapModel for: $_currentMapFilePath');
    if (_currentMapFilePath == null) {
      print('No map file path available');
      throw StateError('No map file path available. Please select a map.');
    }

    if (_cachedMapModel != null) {
      print('Returning cached MapModel with latest markers');
      return _cachedMapModel!;
    }

    final file = io.File(_currentMapFilePath!);
    if (!await file.exists()) {
      print('Map file does not exist: $_currentMapFilePath');
      throw StateError('Map file does not exist at: $_currentMapFilePath');
    }

    print('Loading map file: $_currentMapFilePath, size: ${await file.length()} bytes');
    try {
      final mapFile = await MapFile.from(file.path, null, null).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Timeout loading map file: $_currentMapFilePath');
          throw TimeoutException('Map file loading timed out');
        },
      );
      print('MapFile loaded');

      final renderThemeBuilder = RenderThemeBuilder();
      RenderTheme? renderTheme;
      try {
        final xml = await DefaultAssetBundle.of(context)
            .loadString('lib/assets/maps/render_themes/defaultrender.xml')
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                print('Timeout loading defaultrender.xml');
                throw TimeoutException('Render theme loading timed out');
              },
            );
        renderThemeBuilder.parseXml(_displayModel, xml);
        renderTheme = renderThemeBuilder.build();
        print('Render theme built');
      } catch (e) {
        print('Error loading render theme: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load render theme: $e')),
        );
        renderTheme = RenderThemeBuilder().build();
      }

      final symbolCache = FileSymbolCache();
      print('Creating renderer');
      final renderer = MapDataStoreRenderer(mapFile, renderTheme, symbolCache, false);

      print('Setting up marker data store');
      _markerDataStore = MarkerDataStore();

      final mapModel = MapModel(
        displayModel: _displayModel,
        renderer: renderer,
        symbolCache: symbolCache,
      );
      mapModel.markerDataStores.add(_markerDataStore!);
      print('MapModel created');

      _cachedMapModel = mapModel;
      _lastMapFilePath = _currentMapFilePath;
      return mapModel;
    } catch (e, stack) {
      print('Error creating MapModel: $e\n$stack');
      rethrow;
    }
  }

  Future<ViewModel> _createViewModelFuture() async {
    print('Creating ViewModel');
    if (_viewModel == null) {
      print('ViewModel is not initialized');
      throw StateError('ViewModel is not initialized');
    }
    return _viewModel!;
  }

  void _zoomIn() {
    if (_isDisposed || _viewModel == null || _viewModel!.mapViewPosition == null) {
      print('Cannot zoom in: disposed or no map position');
      return;
    }
    final currentZoom = _viewModel!.mapViewPosition!.zoomLevel;
    final newZoom = (currentZoom + 1).clamp(2, 18);
    _viewModel!.setMapViewPosition(
      _viewModel!.mapViewPosition!.latitude!,
      _viewModel!.mapViewPosition!.longitude!,
    );
    _viewModel!.setZoomLevel(newZoom);
    print('Zoomed in to: $newZoom');
  }

  void _zoomOut() {
    if (_isDisposed || _viewModel == null || _viewModel!.mapViewPosition == null) {
      print('Cannot zoom out: disposed or no map position');
      return;
    }
    final currentZoom = _viewModel!.mapViewPosition!.zoomLevel;
    final newZoom = (currentZoom - 1).clamp(2, 18);
    _viewModel!.setMapViewPosition(
      _viewModel!.mapViewPosition!.latitude!,
      _viewModel!.mapViewPosition!.longitude!,
    );
    _viewModel!.setZoomLevel(newZoom);
    print('Zoomed out to: $newZoom');
  }

  void _loadMap(String mapFilePath) {
    if (_isDisposed) {
      print('Aborting map load due to disposal');
      return;
    }
    print('Loading map: $mapFilePath');
    try {
      final mapInfo = _mapBox.values.firstWhere(
        (map) => map.filePath == mapFilePath,
        orElse: () => MapInfo(
          name: '',
          filePath: mapFilePath,
          downloadUrl: '',
          latitude: 0.0,
          longitude: 0.0,
          zoomLevel: 2,
        ),
      );

      if (_currentMapFilePath != mapFilePath) {
        setState(() {
          _currentMapFilePath = mapFilePath.isNotEmpty ? mapFilePath : null;
          _viewModel?.dispose();
          _viewModel = ViewModel(displayModel: _displayModel);
          _viewModel?.setMapViewPosition(mapInfo.latitude, mapInfo.longitude);
          _viewModel?.setZoomLevel(mapInfo.zoomLevel);
          _markerDataStore?.clearMarkers();
          _markers.clear();
          _mapModelFuture = _createMapModelFuture();
          // Tap event handling will be implemented differently
        });
        _setupMarkers(_symbolCache);
        print('Map loaded: $mapFilePath');
      } else {
        _viewModel?.setMapViewPosition(mapInfo.latitude, mapInfo.longitude);
        _viewModel?.setZoomLevel(mapInfo.zoomLevel);
        print('Map view updated without reloading: $mapFilePath');
      }
    } catch (e) {
      print('Error loading map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load map: $e')),
      );
    }
  }

  Future<String> _copyAssetToFile(String assetPath) async {
    print('Copying asset: $assetPath');
    try {
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
    } catch (e) {
      print('Error copying asset: $e');
      throw Exception('Failed to copy asset: $e');
    }
  }

  Future<bool> _checkNetwork() async {
    print('Checking network');
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasNetwork = connectivityResult != ConnectivityResult.none;
      print('Network status: $connectivityResult, connected: $hasNetwork');
      return hasNetwork;
    } catch (e) {
      print('Error checking network: $e');
      return false;
    }
  }

  Future<void> _downloadMap(GospelMapEntryData map, String mapName) async {
    if (_isDisposed) {
      print('Aborting download due to disposal');
      return;
    }
    if (!await _checkNetwork()) {
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your network.')),
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
            throw Exception('HTTP ${response.statusCode}: Failed to download $mapName');
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
            print('Download progress: $progress');
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

          if (mapFile != null) {
            final mapInfo = MapInfo(
              name: mapName,
              filePath: mapFile.path,
              downloadUrl: mirrorUrl,
              isTemporary: false,
              latitude: map.latitude,
              longitude: map.longitude,
              zoomLevel: map.zoomLevel,
            );
            await _mapBox.add(mapInfo);
            _loadMap(mapFile.path);
            print('Map downloaded and loaded: $mapName');
            Navigator.of(dialogContext).pop();
            return;
          }
        } catch (e) {
          lastError = e as Exception;
          print('Download failed for $mirrorUrl (attempt $attempt): $e');
          if (attempt == maxRetries && mirrorUrl == mirrors.last) {
            final dialogContext = await completer.future;
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to download map ($mapName): $e')),
            );
            print('Download error: $e');
            throw lastError;
          }
        }
      }
    }
  }

  void _showMapManager() {
    if (!_isHiveInitialized) {
      print('Map manager not initialized or disposed');
      return;
    }
    print('Showing MapManagerPage');
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => gospel_map_manager_ui.MapManagerPage(
          currentMapFilePath: _currentMapFilePath,
          directories: _availableMaps,
          onLoadMap: (mapFilePath) {
            _loadMap(mapFilePath);
          },
          mapBox: _mapBox,
          onDownloadMap: _downloadMap,
          onUploadMap: (String mapFilePath, String mapName, bool isTemporary) {
            print('Uploaded map: $mapName, path: $mapFilePath, temporary: $isTemporary');
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    );
  }

  void _showContacts() {
    if (!_isHiveInitialized || _isDisposed) {
      print('Cannot show contacts: Hive not initialized or disposed');
      return;
    }
    // print('Showing ContactsPage'); // Commented out due to variable shadowing error and potential redundancy
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => gospel_contacts_ui.ContactsPage(contactBox: _contactBox),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    );
  }

  void _startAddingMarker() {
    if (_isDisposed || _viewModel?.mapViewPosition == null) {
      print('Cannot start adding marker: disposed or no map view');
      return;
    }
    print('Starting marker addition');
    setState(() {
      _isAddingMarker = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap on map to place a marker')),
    );
  }

  void _addMarker(LatLong latLong) {
    print('Adding marker at: (${latLong.latitude}, ${latLong.longitude})');
    if (!_isAddingMarker || _isDisposed || _viewModel?.mapViewPosition == null) {
      print('Cannot add marker: not adding, disposed, or no map view');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.AddEditContactPage(
          contactBox: _contactBox,
          latitude: latLong.latitude,
          longitude: latLong.longitude,
          onContactAdded: (contact) {
            print('Added contact from map: ${contact.name}');
            _setupMarkers(_symbolCache).then((_) {
              if (mounted) {
                setState(() {
                  _isAddingMarker = false;
                  _markerUpdateKey++;
                  _mapModelFuture = Future.value(_cachedMapModel);
                });
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing GospelPageState');
    _isDisposed = true;
    _contactBox.listenable().removeListener(_onContactBoxChanged);
    _viewModel?.dispose();
    _markerDataStore?.dispose();
    _markerBitmap?.dispose();
    _cachedMapModel?.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building GospelPageUi');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gospel Map'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [ // Move menu icon to actions for right side
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer(); // Open end drawer
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer( // Changed back to endDrawer for right side
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map Manager'),
              onTap: _showMapManager,
            ),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Contacts'),
              onTap: _showContacts,
            ),
            ListTile( // Add settings to the drawer
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Implement settings page for Gospel Map
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings not implemented yet')),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoadingMaps
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<MapModel?>(
              future: _mapModelFuture,
              builder: (context, snapshot) {
                print('FutureBuilder state: ${snapshot.connectionState}, hasError: ${snapshot.hasError}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Map load error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading map: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _mapModelFuture = _createMapModelFuture();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || _currentMapFilePath == null) {
                  print('No map data or path');
                  return const Center(child: Text('No map loaded. Please select a map.'));
                } else {
                  print('Rendering MapviewWidget with ${_markerDataStore?.getAllMarkers()?.length ?? 0} markers');
                  return Stack(
                    children: [
                      MapviewWidget(
                        key: ValueKey(_markerUpdateKey),
                        displayModel: _displayModel,
                        createMapModel: _createMapModelFuture,
                        createViewModel: _createViewModelFuture,
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              key: const ValueKey('add_marker_fab'),
                              heroTag: const ValueKey('add_marker_fab'),
                              mini: true,
                              onPressed: _startAddingMarker,
                              child: const Icon(Icons.add_location),
                              tooltip: 'Add Marker',
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              key: const ValueKey('zoom_in_fab'),
                              heroTag: const ValueKey('zoom_in_fab'),
                              mini: true,
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              key: const ValueKey('zoom_out_fab'),
                              heroTag: const ValueKey('zoom_out_fab'),
                              mini: true,
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }
}

class _DownloadProgressDialog extends StatelessWidget {
  final String mapName;
  final String url;

  const _DownloadProgressDialog({required this.mapName, required this.url});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Downloading $mapName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          NotificationListener<DownloadProgressNotification>(
            onNotification: (notification) {
              return true;
            },
            child: Text('Progress: ...'),
          ),
        ],
      ),
    );
  }
}

class DownloadProgressNotification extends Notification {
  final String content;

  const DownloadProgressNotification(this.content);
}

// AddEditContactPage remains unchanged as it functions correctly once tap is captured
class AddEditContactPage extends StatefulWidget {
  final Box<Contact> contactBox;
  final double? latitude;
  final double? longitude;
  final Contact? contact;
  final Function(Contact) onContactAdded;

  const AddEditContactPage({
    super.key,
    required this.contactBox,
    this.latitude,
    this.longitude,
    this.contact,
    required this.onContactAdded,
  });

  @override
  _AddEditContactPageState createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _addressController;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _addressController = TextEditingController(text: widget.contact?.address ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes != null ? jsonEncode(widget.contact!.notes) : '');
    _latitude = widget.contact?.latitude ?? widget.latitude ?? 0.0;
    _longitude = widget.contact?.longitude ?? widget.longitude ?? 0.0;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      String fullName = _nameController.text;
      String firstName;
      String lastName;
      int firstSpaceIndex = fullName.indexOf(' ');
      if (firstSpaceIndex != -1) {
        firstName = fullName.substring(0, firstSpaceIndex);
        lastName = fullName.substring(firstSpaceIndex + 1);
      } else {
        firstName = fullName;
        lastName = '';
      }

      final contact = Contact(
        id: widget.contact?.id ?? const Uuid().v4(),
        firstName: firstName,
        lastName: lastName,
        address: _addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        notes: _notesController.text.isNotEmpty ? jsonDecode(_notesController.text) : null,
      );
      if (widget.contact == null) {
        widget.contactBox.add(contact);
      } else {
        widget.contactBox.put(widget.contact!.key, contact);
      }
      widget.onContactAdded(contact);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              Text('Latitude: ${_latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${_longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text(widget.contact == null ? 'Add Contact' : 'Save Changes'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}