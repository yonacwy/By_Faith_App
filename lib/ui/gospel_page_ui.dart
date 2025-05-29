import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';
import 'package:by_faith_app/ui/gospel_contacts_ui.dart' as gospel_contacts_ui;
import 'package:by_faith_app/ui/gospel_map_manager_ui.dart' as gospel_map_manager_ui;
import 'package:by_faith_app/ui/gospel_profile_ui.dart' as gospel_profile_ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DefaultAssetBundle, rootBundle;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_map_tile_caching/src/backend/backend_access.dart';

class GospelPageUi extends StatefulWidget {
  const GospelPageUi({super.key});

  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPageUi> {
  late fm.MapController _mapController;
  late Box<MapInfo> _mapBox;
  late Box<Contact> _contactBox;
  List<Directory> _availableMaps = [];
  bool _isLoadingMaps = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isHiveInitialized = false;
  List<fm.Marker> _markers = [];
  bool _isAddingMarker = false;
  bool _isDisposed = false;
  final Uuid _uuid = const Uuid();
  String? _currentMapName;
  int _markerUpdateKey = 0;
  String _tileProviderUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  double _currentZoom = 2.0;
  latlong2.LatLng _currentCenter = const latlong2.LatLng(0.0, 0.0);
  fm.TileProvider? _tileProvider;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
    _initHive().then((_) async {
      if (_isDisposed) return;
      _isHiveInitialized = true;
      _currentMapName = 'World';
      await _loadMapData();
      await _setupMarkers();
      await _initTileProvider();
      if (mounted) {
        setState(() {
          _isLoadingMaps = false;
        });
      }
      _contactBox.listenable().addListener(_onContactBoxChanged);
    });
  }

  Future<void> _initTileProvider({String storeName = 'osm_store'}) async {
    try {
      final store = fmtc.FMTCStore(storeName);
      await store.manage.create(); // Ensure the store exists
      final tileProvider = store.getTileProvider(httpClient: IOClient());
      if (mounted) {
        setState(() {
          _tileProvider = tileProvider;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tileProvider = fm.NetworkTileProvider(httpClient: IOClient());
        });
      }
    }
  }

  void _onContactBoxChanged() {
    if (!_isDisposed && mounted) {
      _setupMarkers().then((_) {
        if (mounted) {
          setState(() {
            _markerUpdateKey++;
          });
        }
      });
    }
  }

  Future<void> _initHive() async {
    try {
      await Hive.initFlutter();
      _mapBox = await Hive.openBox<MapInfo>('maps');
      _contactBox = await Hive.openBox<Contact>('contacts');
      MapInfo? worldMapInfo = _mapBox.values.firstWhere(
        (map) => map.name == 'World',
        orElse: () => MapInfo(
          name: 'World',
          filePath: '',
          downloadUrl: '',
          isTemporary: false,
          latitude: 20.0,
          longitude: -70.0,
          zoomLevel: 1,
        ),
      );

      if (!_mapBox.values.any((map) => map.name == 'World')) {
        await _mapBox.add(worldMapInfo);
      } else {
        // Update existing World map entry if it's not already set to the desired coordinates
        if (worldMapInfo.latitude != 20.0 || worldMapInfo.longitude != -70.0 || worldMapInfo.zoomLevel != 3) {
          final key = _mapBox.keyAt(_mapBox.values.toList().indexOf(worldMapInfo));
          worldMapInfo.latitude = 20.0;
          worldMapInfo.longitude = -70.0;
          worldMapInfo.zoomLevel = 3;
          await _mapBox.put(key, worldMapInfo);
        }
      }

      _currentMapName = worldMapInfo.name;
      _currentCenter = latlong2.LatLng(worldMapInfo.latitude, worldMapInfo.longitude);
      _currentZoom = worldMapInfo.zoomLevel.toDouble();
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingMaps = false;
        });
      }
    }
  }

  Future<void> _setupMarkers() async {
    if (_isDisposed || !mounted) return;
    final List<fm.Marker> newMarkers = [];
    for (final contact in _contactBox.values) {
      final marker = _createMarker(contact);
      newMarkers.add(marker);
    }
    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  fm.Marker _createMarker(Contact contact) {
    return fm.Marker(
      point: latlong2.LatLng(contact.latitude, contact.longitude),
      child: GestureDetector(
        onTap: () {
          if (_isDisposed || !mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => gospel_contacts_ui.AddEditContactPage(
                contactBox: _contactBox,
                contact: contact,
                latitude: contact.latitude,
                longitude: contact.longitude,
                onContactAdded: (newOrUpdatedContact) {},
              ),
            ),
          );
        },
        child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
      ),
    );
  }

  Future<void> _loadMapData() async {
    if (!mounted) return;
    try {
      final coordinateJsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/map_coordinates.json');
      final coordinateData = jsonDecode(coordinateJsonString) as Map<String, dynamic>;
      final Map<String, Map<String, dynamic>> coordinateMap = {
        for (final entry in coordinateData.entries) entry.key: entry.value as Map<String, dynamic>,
      };

      final jsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/maps.json');
      final decodedJson = jsonDecode(jsonString) as List<dynamic>;

      if (decodedJson.isEmpty) throw Exception('Top-level directory not found');
      final topLevelJson = decodedJson.first as Map<String, dynamic>;
      if (!topLevelJson.containsKey('subDirectories')) throw Exception('subDirectories not found');

      final List<dynamic> topLevelSubDirsJson = topLevelJson['subDirectories'];
      final v5Json = topLevelSubDirsJson.firstWhere(
        (subDirJson) => (subDirJson as Map<String, dynamic>)['name'] == 'V5',
        orElse: () => null,
      );
      if (v5Json == null || !v5Json.containsKey('subDirectories')) throw Exception('V5 directory not found');

      final List<dynamic> continentDirsJson = v5Json['subDirectories'];
      final List<Directory> directories = continentDirsJson
          .map((continentDirJson) => Directory.fromJson(continentDirJson as Map<String, dynamic>, coordinateMap))
          .toList();

      if (mounted) {
        setState(() {
          _availableMaps = directories;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load map data: $error')),
        );
      }
    }
  }

  void zoomIn() {
    if (_isDisposed || !mounted) return;
    final newZoom = (_mapController.camera.zoom + 1).clamp(2.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void zoomOut() {
    if (_isDisposed || !mounted) return;
    final newZoom = (_mapController.camera.zoom - 1).clamp(2.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void _loadMap(String mapName) {
    if (_isDisposed || !mounted) return;
    try {
      final mapInfo = _mapBox.values.firstWhere(
        (map) => map.name == mapName,
        orElse: () => MapInfo(
          name: mapName,
          filePath: '',
          downloadUrl: '',
          isTemporary: false,
          latitude: 0.0,
          longitude: 0.0,
          zoomLevel: 2,
        ),
      );

      final newCenter = latlong2.LatLng(mapInfo.latitude, mapInfo.longitude);
      final newZoom = mapInfo.zoomLevel.toDouble();

      _initTileProvider(storeName: mapInfo.filePath.isNotEmpty ? mapInfo.name : 'osm_store');

      if (mounted) {
        setState(() {
          _currentMapName = mapName;
          _currentCenter = newCenter;
          _currentZoom = newZoom;
          _mapController.move(newCenter, newZoom);
          _markerUpdateKey++;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load map ($mapName): $error')),
        );
      }
    }
  }

  Future<bool> _checkNetwork() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (error) {
      return false;
    }
  }

  Future<void> _downloadMap(GospelMapEntryData mapData, String mapName) async {
    if (_isDisposed || !mounted) return;

    if (!await _checkNetwork()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      }
      return;
    }

    final store = fmtc.FMTCStore(mapName);
    await store.manage.create();

    final completer = Completer<BuildContext>();
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          if (!completer.isCompleted) completer.complete(dialogContext);
          return _DownloadProgressDialog(mapName: mapName, url: mapData.primaryUrl, storeName: mapName);
        },
      );
    }

    try {
      final dialogContext = await completer.future;
      final downloadStream = store.download.startForeground(
        region: fmtc.RectangleRegion(
          fm.LatLngBounds(
            latlong2.LatLng(mapData.bounds.southwest.latitude, mapData.bounds.southwest.longitude),
            latlong2.LatLng(mapData.bounds.northeast.latitude, mapData.bounds.northeast.longitude),
          ),
        ).toDownloadable(
          minZoom: mapData.zoomLevel,
          maxZoom: mapData.zoomLevel,
          options: fm.TileLayer(
            urlTemplate: mapData.primaryUrl,
            tileProvider: fmtc.FMTCStore(mapName).getTileProvider(),
            minZoom: mapData.zoomLevel.toDouble(),
            maxZoom: mapData.zoomLevel.toDouble(),
          ),
        ),
      );

      await for (final progress in downloadStream.downloadProgress) {}

      final mapInfo = MapInfo(
        name: mapName,
        filePath: mapName,
        downloadUrl: mapData.primaryUrl,
        isTemporary: false,
        latitude: mapData.latitude,
        longitude: mapData.longitude,
        zoomLevel: mapData.zoomLevel,
      );
      await _mapBox.add(mapInfo);

      if (mounted && Navigator.of(dialogContext).canPop()) {
        Navigator.of(dialogContext).pop();
      }
      _loadMap(mapName);
    } catch (error) {
      if (completer.isCompleted) {
        final dialogContext = await completer.future;
        if (mounted && Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download map ($mapName): $error')),
        );
      }
    }
  }

  void _showMapManager() {
    if (!_isHiveInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_map_manager_ui.MapManagerPage(
          currentMapName: _currentMapName,
          directories: _availableMaps,
          onLoadMap: (mapName) {
            _loadMap(mapName);
          },
          mapBox: _mapBox,
          onDownloadMap: _downloadMap,
          onUploadMap: (String mapFilePath, String mapName, bool isTemporary) {},
        ),
      ),
    );
  }

  void _showContacts() {
    if (!_isHiveInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.ContactsPage(contactBox: _contactBox),
      ),
    );
  }

  void _showProfile() {
    if (!_isHiveInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_profile_ui.GospelProfileUi(),
      ),
    );
  }

  void _startAddingMarker() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isAddingMarker = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap on map to place a marker')),
    );
  }

  void _addMarker(latlong2.LatLng latLng) {
    if (!_isAddingMarker || _isDisposed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.AddEditContactPage(
          contactBox: _contactBox,
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          onContactAdded: (contact) {
            if (mounted) {
              setState(() {
                _isAddingMarker = false;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _contactBox.listenable().removeListener(_onContactBoxChanged);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentMapName ?? 'Gospel Map'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
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
              leading: const Icon(Icons.map_outlined),
              title: const Text('Map Manager'),
              onTap: _showMapManager,
            ),
            ListTile(
              leading: const Icon(Icons.contacts_outlined),
              title: const Text('Contacts'),
              onTap: _showContacts,
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: _showProfile,
            ),
          ],
        ),
      ),
      body: _isLoadingMaps || !_isHiveInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                fm.FlutterMap(
                  key: ValueKey(_markerUpdateKey),
                  mapController: _mapController,
                  options: fm.MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: _currentZoom,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) {
                      if (_isAddingMarker) _addMarker(point);
                    },
                    onPositionChanged: (position, hasGesture) {
                      if (mounted && position.center != null && position.zoom != null) {
                        setState(() {
                          _currentCenter = position.center!;
                          _currentZoom = position.zoom!;
                        });
                      }
                    },
                  ),
                  children: [
                    fm.TileLayer(
                      urlTemplate: _tileProviderUrl,
                      tileProvider: _tileProvider ?? fm.NetworkTileProvider(),
                    ),
                    fm.MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "add_marker_fab",
                        mini: true,
                        onPressed: _startAddingMarker,
                        child: const Icon(Icons.add_location_alt_outlined),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_in_fab",
                        mini: true,
                        onPressed: zoomIn,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_out_fab",
                        mini: true,
                        onPressed: zoomOut,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  final String mapName;
  final String url;
  final String storeName;

  const _DownloadProgressDialog({required this.mapName, required this.url, required this.storeName});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  Stream<fmtc.DownloadProgress>? _progressStream;

  @override
  void initState() {
    super.initState();
    _progressStream = StreamController<fmtc.DownloadProgress>.broadcast().stream;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Downloading ${widget.mapName}'),
      content: StreamBuilder<fmtc.DownloadProgress>(
        stream: _progressStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Initializing download...'),
                SizedBox(height: 16),
                LinearProgressIndicator(),
              ],
            );
          }
          final progress = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress.percentageProgress / 100),
              const SizedBox(height: 16),
              Text('Progress: ${progress.percentageProgress.toStringAsFixed(1)}%'),
            ],
          );
        },
      ),
    );
  }
}