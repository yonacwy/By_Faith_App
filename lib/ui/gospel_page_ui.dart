import 'dart:async';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/user_preference_model.dart';
import 'package:by_faith_app/ui/gospel_contacts_ui.dart' as gospel_contacts_ui;
import 'package:by_faith_app/ui/gospel_offline_maps_ui.dart' as gospel_offline_maps_ui;
import 'package:by_faith_app/ui/gospel_profile_ui.dart' as gospel_profile_ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:by_faith_app/objectbox.dart';
import 'package:objectbox/objectbox.dart';

class GospelPageUi extends StatefulWidget {
  const GospelPageUi({super.key});

  @override
  _GospelPageState createState() => _GospelPageState();
}

class _GospelPageState extends State<GospelPageUi> {
  late fm.MapController _mapController;
  late Box<MapInfo> _mapInfoBox;
  late Box<Contact> _contactBox;
  late Box<UserPreference> _userPreferenceBox;
  bool _isLoadingMaps = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isObjectBoxInitialized = false;
  List<fm.Marker> _markers = [];
  bool _isAddingMarker = false;
  bool _isDisposed = false;
  String? _currentMapName;
  int _markerUpdateKey = 0;
  String _tileProviderUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  double _currentZoom = 2.0;
  LatLng _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
  fm.TileProvider? _tileProvider;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
    _initObjectBox().then((_) async {
      if (_isDisposed) return;
      _isObjectBoxInitialized = true;
      _userPreferenceBox = objectbox.userPreferenceBox;
      await _initTileProvider();
      await _restoreLastMap();
      await _setupMarkers();
      if (mounted) {
        setState(() {
          _isLoadingMaps = false;
        });
      }
      objectbox.contactBox.watch().listen((_) {
        _onContactBoxChanged();
      });
    });
  }

  Future<void> _restoreLastMap() async {
    if (_isDisposed || !mounted) return;
    final UserPreference? savedMapPref = _userPreferenceBox.query(UserPreference_.key.eq('currentMap')).build().findFirst();
    final String? savedMapName = savedMapPref?.value;

    if (savedMapName != null) {
      final mapInfo = objectbox.mapInfoBox.query(MapInfo_.name.eq(savedMapName)).build().findFirst();
      if (mapInfo != null) {
        await _loadMap(mapInfo);
      } else {
        // If the saved map is not found, default to "World"
        _currentMapName = 'World';
        _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
        _currentZoom = 2.0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_currentCenter, _currentZoom);
        });
      }
    } else {
      _currentMapName = 'World';
      _currentCenter = const LatLng(39.0, -98.0); // Center on the Americas
      _currentZoom = 2.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_currentCenter, _currentZoom);
      });
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

  Future<void> _initObjectBox() async {
    try {
      _mapInfoBox = objectbox.mapInfoBox;
      _contactBox = objectbox.contactBox;

      MapInfo? worldMapInfo = _mapInfoBox.query(MapInfo_.name.eq('World')).build().findFirst();

      if (worldMapInfo == null) {
        worldMapInfo = MapInfo(
          name: 'World',
          filePath: '',
          downloadUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          isTemporary: false,
          latitude: 39.0, // Center on the Americas
          longitude: -98.0,
          zoomLevel: 2,
        );
        _mapInfoBox.put(worldMapInfo);
      } else {
        worldMapInfo.latitude = 39.0; // Center on the Americas
        worldMapInfo.longitude = -98.0;
        worldMapInfo.zoomLevel = 2;
        _mapInfoBox.put(worldMapInfo);
      }
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
    final contacts = objectbox.contactBox.getAll();
    for (final contact in contacts) {
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
      point: LatLng(contact.latitude, contact.longitude),
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

  Future<void> _loadMap(MapInfo mapInfo) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Offline map "${mapInfo.name}" not found. Loading online map.')),
          );
        }
      } else {
        await _initTileProvider();
        _tileProviderUrl = mapInfo.downloadUrl.isNotEmpty
            ? mapInfo.downloadUrl
            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      }

      if (mounted) {
        setState(() {
          _currentMapName = mapInfo.name;
          _currentCenter = newCenter;
          _currentZoom = newZoom;
          _markerUpdateKey++;
        });

        // Save the current map name to user preferences
        final UserPreference currentMapPref = UserPreference(key: 'currentMap', value: mapInfo.name);
        _userPreferenceBox.put(currentMapPref);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(newCenter, newZoom);
        });
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

      final mapInfo = MapInfo(
        name: mapName,
        filePath: mapName,
        downloadUrl: _tileProviderUrl,
        isTemporary: false,
        latitude: (southWestLat + northEastLat) / 2,
        longitude: (southWestLng + northEastLng) / 2,
        zoomLevel: zoomLevel,
      );
      _mapInfoBox.put(mapInfo);

      if (mounted && Navigator.of(dialogContext).canPop()) {
        Navigator.of(dialogContext).pop();
      }
      await _loadMap(mapInfo);
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
    if (!_isObjectBoxInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_offline_maps_ui.OfflineMapsPage(
          currentMapName: _currentMapName,
          onLoadMap: (mapInfo) {
            _loadMap(mapInfo);
          },
          mapInfoBox: _mapInfoBox,
          onDownloadMap: _downloadMap,
          onUploadMap: (String mapFilePath, String mapName, bool isTemporary) {},
        ),
      ),
    );
  }

  void _showContacts() {
    if (!_isObjectBoxInitialized || _isDisposed || !mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.ContactsPage(contactBox: objectbox.contactBox),
      ),
    );
  }

  void _showProfile() {
    if (!_isObjectBoxInitialized || _isDisposed || !mounted) return;
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

  void addMarker(LatLng latLng) {
    if (!_isAddingMarker || _isDisposed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gospel_contacts_ui.AddEditContactPage(
          contactBox: objectbox.contactBox,
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
      body: _isLoadingMaps || !_isObjectBoxInitialized
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
                      if (_isAddingMarker) addMarker(point);
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
                      userAgentPackageName: 'com.example.app',
                    ),
                    fm.MarkerLayer(markers: _markers),
                    fm.RichAttributionWidget(
                      attributions: [
                        fm.TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => {},
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
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
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "add_marker_fab",
                        onPressed: _startAddingMarker,
                        child: const Icon(Icons.add_location_alt_outlined),
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
  final Stream<fmtc.DownloadProgress> downloadStream;

  const _DownloadProgressDialog({required this.mapName, required this.url, required this.storeName, required this.downloadStream});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Downloading ${widget.mapName}'),
      content: StreamBuilder<fmtc.DownloadProgress>(
        stream: widget.downloadStream,
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