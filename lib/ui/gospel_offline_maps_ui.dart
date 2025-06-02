import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;
import 'gospel_map_selection_ui.dart'; // New file for map selection screen

class OfflineMapsPage extends StatefulWidget {
  final String? currentMapName;
  final Function(MapInfo) onLoadMap;
  final Box<MapInfo> mapBox;
  final Function(String, double, double, double, double, int) onDownloadMap; // Updated signature
  final Function(String, String, bool) onUploadMap;

  const OfflineMapsPage({
    super.key,
    required this.currentMapName,
    required this.onLoadMap,
    required this.mapBox,
    required this.onDownloadMap,
    required this.onUploadMap,
  });

  @override
  _OfflineMapsPageState createState() => _OfflineMapsPageState();
}

class _OfflineMapsPageState extends State<OfflineMapsPage> {
  late Box _userPrefsBox;

  @override
  void initState() {
    super.initState();
    _openUserPrefsBox();
  }

  Future<void> _openUserPrefsBox() async {
    _userPrefsBox = await Hive.openBox('userPreferences');
    if (mounted) setState(() {});
  }

  void _showMapSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
          onDownloadMap: (name, southWestLat, southWestLng, northEastLat, northEastLng, zoomLevel) {
            widget.onDownloadMap(name, southWestLat, southWestLng, northEastLat, northEastLng, zoomLevel);
          },
        ),
      ),
    );
  }

  Future<void> _deleteMap(String mapName) async {
    try {
      final mapInfo = widget.mapBox.values.firstWhere((map) => map.name == mapName);
      await fmtc.FMTCStore(mapInfo.name).manage.delete();
      await widget.mapBox.delete(mapInfo.key);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete map ($mapName): $error')),
        );
      }
    }
  }

  Future<void> _renameMap(MapInfo mapInfo) async {
    TextEditingController controller = TextEditingController(text: mapInfo.name);
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Map'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new map name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != mapInfo.name) {
      try {
        final updatedMapInfo = MapInfo(
          name: newName,
          filePath: mapInfo.filePath,
          downloadUrl: mapInfo.downloadUrl,
          isTemporary: mapInfo.isTemporary,
          latitude: mapInfo.latitude,
          longitude: mapInfo.longitude,
          zoomLevel: mapInfo.zoomLevel,
        );
        await widget.mapBox.put(mapInfo.key, updatedMapInfo);
        // Update store name in FMTC
        final store = fmtc.FMTCStore(mapInfo.name);
        await store.manage.rename(newName);
        if (mounted) setState(() {});
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to rename map: $error')),
          );
        }
      }
    }
  }

  Future<void> _updateMap(MapInfo mapInfo) async {
    // Re-download the map with the same parameters
    try {
      await widget.onDownloadMap(
        mapInfo.name,
        mapInfo.latitude - 0.05, // Assuming square overlay size
        mapInfo.longitude - 0.05,
        mapInfo.latitude + 0.05,
        mapInfo.longitude + 0.05,
        mapInfo.zoomLevel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Map "${mapInfo.name}" updated successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update map: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.map), // Added map icon
              title: Text(
                'Select your own map',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _showMapSelection,
            ),
            ExpansionTile(
              title: Text(
                'Downloaded Maps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: true,
              children: [
                ValueListenableBuilder(
                  valueListenable: widget.mapBox.listenable(),
                  builder: (context, Box<MapInfo> box, _) {
                    if (box.isEmpty) {
                      return const Center(child: Text('No maps downloaded yet.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final mapInfo = box.getAt(index)!;
                        return ListTile(
                          title: Text(mapInfo.name),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'view') {
                                widget.onLoadMap(mapInfo);
                                await _userPrefsBox.put('currentMap', mapInfo.name);
                                Navigator.pop(context);
                              } else if (value == 'update') {
                                await _updateMap(mapInfo);
                              } else if (value == 'rename') {
                                await _renameMap(mapInfo);
                              } else if (value == 'delete') {
                                await _deleteMap(mapInfo.name);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'view', child: Text('View')),
                              const PopupMenuItem(value: 'update', child: Text('Update')),
                              const PopupMenuItem(value: 'rename', child: Text('Rename')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                          onTap: () {
                            widget.onLoadMap(mapInfo);
                            _userPrefsBox.put('currentMap', mapInfo.name);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}