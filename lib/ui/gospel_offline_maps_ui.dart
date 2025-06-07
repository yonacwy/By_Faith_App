import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:flutter/material.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart'; // Keep the model for now, might need mapping
import 'package:flutter/material.dart';
import 'package:by_faith_app/database/database.dart'; // Import Drift database
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;
import 'gospel_map_selection_ui.dart'; // New file for map selection screen
import 'package:provider/provider.dart'; // Import provider
import 'package:drift/drift.dart' hide Column; // Import drift and hide Column to avoid conflict with flutter material

class OfflineMapsPage extends StatefulWidget {
  final String? currentMapName;
  final Function(MapInfoEntry) onLoadMap; // Use MapInfoEntry
  final Function(String, double, double, double, double, int) onDownloadMap; // Updated signature
  final Function(String, String, bool) onUploadMap;

  const OfflineMapsPage({
    super.key,
    required this.currentMapName,
    required this.onLoadMap,
    required this.onDownloadMap,
    required this.onUploadMap,
    required AppDatabase database, // Add database parameter
  });

  @override
  _OfflineMapsPageState createState() => _OfflineMapsPageState();
}

class _OfflineMapsPageState extends State<OfflineMapsPage> {
  late AppDatabase _database; // Declare database instance

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _database = Provider.of<AppDatabase>(context); // Get database instance
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
      await fmtc.FMTCStore(mapName).manage.delete();
      await _database.deleteMapInfo(mapName); // Implement deleteMapInfo in database.dart
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete map ($mapName): $error')),
        );
      }
    }
  }

  Future<void> _renameMap(MapInfoEntry mapInfo) async { // Use MapInfoEntry
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
        final updatedMapInfoCompanion = MapInfoEntriesCompanion( // Use MapInfoEntriesCompanion
          name: Value(newName),
          filePath: Value(mapInfo.filePath),
          downloadUrl: Value(mapInfo.downloadUrl),
          isTemporary: Value(mapInfo.isTemporary),
          latitude: Value(mapInfo.latitude),
          longitude: Value(mapInfo.longitude),
          zoomLevel: Value(mapInfo.zoomLevel),
        );
        await _database.updateMapInfo(updatedMapInfoCompanion); // Implement updateMapInfo in database.dart
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

  Future<void> _updateMap(MapInfoEntry mapInfo) async { // Use MapInfoEntry
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
                StreamBuilder<List<MapInfoEntry>>( // Use StreamBuilder and MapInfoEntry
                  stream: _database.watchAllMapInfo(), // Implement watchAllMapInfo in database.dart
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No maps downloaded yet.'));
                    } else {
                      final maps = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: maps.length,
                        itemBuilder: (context, index) {
                          final mapInfo = maps[index];
                          return ListTile(
                            title: Text(mapInfo.name),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'view') {
                                  widget.onLoadMap(mapInfo);
                                  // Need to save current map name to settings table in Drift
                                  // await _userPrefsBox.put('currentMap', mapInfo.name); // Removed Hive usage
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
                              // Need to save current map name to settings table in Drift
                              // _userPrefsBox.put('currentMap', mapInfo.name); // Removed Hive usage
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
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