import 'dart:async';
import 'package:by_faith_app/models/gospel_contacts_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/ui/gospel_contacts_ui.dart' as gospel_contacts_ui;
import 'package:by_faith_app/ui/gospel_offline_maps_ui.dart' as gospel_offline_maps_ui;
import 'package:by_faith_app/ui/gospel_profile_ui.dart' as gospel_profile_ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:by_faith_app/database/database.dart'; // Import Drift database
import 'package:by_faith_app/database/database_provider.dart'; // Import DatabaseProvider
import 'package:drift/drift.dart' hide Column; // Import drift, hide Column to avoid conflict
import 'package:flutter_map/flutter_map.dart'; // Import for MapController.onReady

class GospelPageUi extends StatefulWidget {
  const GospelPageUi({super.key});

  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPageUi> {
  late fm.MapController _mapController;
  final AppDatabase _database = DatabaseProvider.instance; // Use singleton database instance
  bool _isLoadingMaps = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<fm.Marker> _markers = [];
  bool _isAddingMarker = false;
  bool _isDisposed = false;
  String? _currentMapName;
  bool _isDatabaseInitialized = false; // Moved to after _currentMapName
  int _markerUpdateKey = 0;
  String _tileProviderUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  double _currentZoom = 2.0;
  LatLng _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
  fm.TileProvider? _tileProvider;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
    _initDatabase().then((_) async {
      if (_isDisposed) return;
      _isDatabaseInitialized = true;
      // _isLoadingMaps will be set to false in the FlutterMap's onReady callback
      await _restoreLastMap(); // Call restoreLastMap after database is initialized
    });
  }

  Future<void> _restoreLastMap() async {
    if (_isDisposed || !mounted) return;
    // Use Drift to get the current map setting
    final settings = await _database.getSettings();
    final String? savedMapName = settings?.lastSelectedMapName; // Using new column for map name

    if (savedMapName != null) {
      // Use Drift to get the map info
      final mapInfo = await _database.getMapInfoByName(savedMapName);
      if (mapInfo != null) {
        await _loadMap(mapInfo);
      } else {
         // Handle case where saved map is not found in database
        _currentMapName = 'World';
        _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
        _currentZoom = 2.0;
        await _initTileProvider(); // Load online provider
        // The map will move to the correct center/zoom when onReady is called
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Saved map "$savedMapName" not found. Loading online map.')),
           );
        }
      }
    } else {
      _currentMapName = 'World';
      _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
      _currentZoom = 2.0;
      await _initTileProvider(); // Load online provider
      // The map will move to the correct center/zoom when onReady is called
    }
  }

  Future<void> _initTileProvider({String? storeName}) async {
    try {
      if (storeName != null) {
        final store = fmtc.FMTCStore(storeName);
        await store.manage.create();
        final tileProvider = store.getTileProvider();
        if (mounted) {
          setState(() {
            _tileProvider = tileProvider;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _tileProvider = fm.NetworkTileProvider();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tileProvider = fm.NetworkTileProvider();
        });
      }
    }
  }

  Future<void> _initDatabase() async {
    try {
      // Ensure the 'World' map exists in the database
      final worldMapInfo = await _database.getMapInfoByName('World');
      if (worldMapInfo == null) {
        await _database.insertMapInfo(MapInfoEntriesCompanion.insert(
          name: 'World',
          filePath: '',
          downloadUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          isTemporary: false,
          latitude: 39.0, // Center on the Americas
          longitude: -98.0,
          zoomLevel: 2,
        ));
      } else {
        // Update World map info if needed (e.g., center/zoom)
         await _database.updateMapInfo(worldMapInfo.toCompanion(false).copyWith(
           latitude: Value(39.0),
           longitude: Value(-98.0),
           zoomLevel: Value(2),
         ));
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingMaps = false;
        });
      }
    }
  }

  // Removed _setupMarkers as markers are handled by StreamBuilder

  fm.Marker _createMarker(ContactEntry contact) {
    return fm.Marker(
      point: LatLng(contact.latitude, contact.longitude),
      child: GestureDetector(
        onTap: () {
          if (_isDisposed || !mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => gospel_contacts_ui.AddEditContactPage(
                database: _database, // Pass the database instance
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

  Future<void> _loadMap(MapInfoEntry mapInfo) async {
    if (_isDisposed || !mounted) return;
    try {
      final newCenter = LatLng(mapInfo.latitude, mapInfo.longitude);
      final newZoom = mapInfo.zoomLevel.toDouble().clamp(2.0, 20.0);

      if (mapInfo.filePath.isNotEmpty) {
        final store = fmtc.FMTCStore(mapInfo.name);
        final bool storeReady = await store.manage.ready;
        if (storeReady) {
          await _initTileProvider(storeName: mapInfo.name);
          _tileProviderUrl = mapInfo.downloadUrl;
        } else {
          await _initTileProvider();
          _tileProviderUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
          _currentMapName = 'World';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Offline map "${mapInfo.name}" not found. Loading online map.')),
            );
          }
        }
      } else {
        await _initTileProvider();
        _tileProviderUrl = mapInfo.downloadUrl.isNotEmpty
            ? mapInfo.downloadUrl
            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      }

      // Update the current map setting in the database
      await _database.updateCurrentMapSetting(mapInfo.name);

      if (mounted) {
        setState(() {
          _currentMapName = mapInfo.name;
          _currentCenter = newCenter;
          _currentZoom = newZoom;
          _markerUpdateKey++;
        });

        // The map will move to the correct center/zoom when onReady is called
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load map (${mapInfo.name}): $error')),
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

  Future<void> _downloadMap(String mapName, double southWestLat, double southWestLng, double northEastLat, double northEastLng, int zoomLevel) async {
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

    final downloadOperation = store.download.startForeground(
      region: fmtc.RectangleRegion(
        fm.LatLngBounds(
          LatLng(southWestLat, southWestLng),
          LatLng(northEastLat, northEastLng),
        ),
      ).toDownloadable(
        minZoom: zoomLevel,
        maxZoom: zoomLevel,
        options: fm.TileLayer(
          urlTemplate: _tileProviderUrl,
          tileProvider: fm.NetworkTileProvider(),
        ),
      ),
    );

    final broadcastDownloadProgress = downloadOperation.downloadProgress.asBroadcastStream();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          if (!completer.isCompleted) completer.complete(dialogContext);
          return _DownloadProgressDialog(
            mapName: mapName,
            url: _tileProviderUrl,
            storeName: mapName,
            downloadStream: broadcastDownloadProgress,
          );
        },
      );
    }

    try {
      final dialogContext = await completer.future;
      await for (final progress in broadcastDownloadProgress) {}

      final mapInfo = MapInfoEntriesCompanion.insert( // Use Drift companion
        name: mapName,
        filePath: mapName,
        downloadUrl: _tileProviderUrl,
        isTemporary: false,
        latitude: (southWestLat + northEastLat) / 2,
        longitude: (southWestLng + northEastLng) / 2,
        zoomLevel: zoomLevel,
      );
      await _database.insertMapInfo(mapInfo); // Use Drift insert method

      if (mounted && Navigator.of(dialogContext).canPop()) {
        Navigator.of(dialogContext).pop();
      }
      // Load the newly downloaded map using the entry from the database
      final downloadedMapEntry = await _database.getMapInfoByName(mapName);
      if (downloadedMapEntry != null) {
         await _loadMap(downloadedMapEntry);
      }


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

  void _showOfflineMaps() {
    if (!_isDatabaseInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_offline_maps_ui.OfflineMapsPage(
          currentMapName: _currentMapName,
          onLoadMap: (mapInfo) {
            _loadMap(mapInfo);
          },
          database: _database, // Pass the database instance
          onDownloadMap: _downloadMap,
          onUploadMap: (String mapFilePath, String mapName, bool isTemporary) {},
        ),
      ),
    );
  }

  void _showContacts() {
    if (!_isDatabaseInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.ContactsPage(database: _database), // Pass the database instance
      ),
    );
  }

  void _showProfile() {
    if (!_isDatabaseInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_profile_ui.GospelProfileUi(), // Assuming profile doesn't directly use the database instance here
      ),
    );
  }

  void _startAddingMarker() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isAddingMarker = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap on map to place a marker')),
      );
    }
  }

  void addMarker(LatLng latLng) {
    if (!_isAddingMarker || _isDisposed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.AddEditContactPage(
          database: _database, // Pass the database instance
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

  void zoomIn() {
    if (_isDisposed || !mounted) return;
    final newZoom = (_mapController.camera.zoom + 1).clamp(2.0, 20.0);
    _mapController.move(_currentCenter, newZoom);
    setState(() {
      _currentZoom = newZoom;
    });
  }

  void zoomOut() {
    if (_isDisposed || !mounted) return;
    final newZoom = (_mapController.camera.zoom - 1).clamp(2.0, 20.0);
    _mapController.move(_currentCenter, newZoom);
    setState(() {
      _currentZoom = newZoom;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentMapName ?? 'Missions'),
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
              leading: const Icon(Icons.contacts_outlined),
              title: const Text('Contacts'),
              onTap: _showContacts,
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Offline Maps'),
              onTap: _showOfflineMaps,
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: _showProfile,
            ),
          ],
        ),
      ),
      body: _isLoadingMaps
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ContactEntry>>( // Use StreamBuilder for contacts
              stream: _database.watchAllContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading contacts: ${snapshot.error}'));
                } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  _markers = snapshot.data!.map((contact) => _createMarker(contact)).toList();
                  return fm.FlutterMap(
                    mapController: _mapController,
                    options: fm.MapOptions(
                      initialCenter: _currentCenter,
                      initialZoom: _currentZoom,
                      onTap: (tapPosition, latLng) {
                        if (_isAddingMarker) {
                          addMarker(latLng);
                        }
                      },
                      onMapReady: () async {
                        if (_isDisposed || !mounted) return;
                        await _restoreLastMap();
                        if (mounted) {
                          setState(() {
                            _isLoadingMaps = false; // Set to false when map is ready
                          });
                        }
                      },
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: _tileProviderUrl,
                        tileProvider: _tileProvider,
                      ),
                      fm.MarkerLayer(
                        markers: _markers,
                        key: ValueKey<int>(_markerUpdateKey),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No contacts found.'));
                }
              },
            ),
          );
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  const _DownloadProgressDialog({
    required this.mapName,
    required this.url,
    required this.storeName,
    required this.downloadStream,
  });

  final String mapName;
  final String url;
  final String storeName;
  final Stream<fmtc.DownloadProgress> downloadStream;

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0.0;
  String _status = 'Starting download...';
  StreamSubscription? _downloadSubscription;

  @override
  void initState() {
    super.initState();
    _downloadSubscription = widget.downloadStream.listen((progress) {
      if (mounted) {
        setState(() {
          _progress = progress.percentageProgress / 100;
          _status =
              'Downloaded ${progress.successfulTilesCount} of ${progress.maxTilesCount} tiles (${(progress.percentageProgress).toStringAsFixed(1)}%)';
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _status = 'Download failed: $error';
        });
      }
    }, onDone: () {
      if (mounted) {
        setState(() {
          _status = 'Download complete!';
        });
      }
    });
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Downloading ${widget.mapName}'),
      content: Column( // Explicitly use Flutter's Column
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text(_status),
        ],
      ),
    );
  }
}