import 'package:by_faith_app/models/gospel_map_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';
import 'package:by_faith_app/models/gospel_map_info_model.dart';
import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as fmtc;

class MapManagerPage extends StatefulWidget {
  final String? currentMapName;
  final List<Directory> directories;
  final Function(String) onLoadMap;
  final Box<MapInfo> mapBox;
  final Function(GospelMapEntryData, String) onDownloadMap;
  final Function(String, String, bool) onUploadMap;

  const MapManagerPage({
    super.key,
    required this.currentMapName,
    required this.directories,
    required this.onLoadMap,
    required this.mapBox,
    required this.onDownloadMap,
    required this.onUploadMap,
  });

  @override
  _MapManagerPageState createState() => _MapManagerPageState();
}

class _MapManagerPageState extends State<MapManagerPage> {
  late Box _userPrefsBox; // Declare userPrefsBox

  @override
  void initState() {
    super.initState();
    _openUserPrefsBox(); // Open user preferences box
  }

  Future<void> _openUserPrefsBox() async {
    _userPrefsBox = await Hive.openBox('userPreferences');
    setState(() {}); // Trigger rebuild after box is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Manager'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ExpansionTile(
              title: Text(
                'Available Maps',
                style: Theme.of(context).textTheme.headlineSmall,
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteMap(mapInfo.name),
                          ),
                          onTap: () {
                            widget.onLoadMap(mapInfo.name);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ExpansionTile(
              title: Text(
                'Downloadable Maps',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              initiallyExpanded: true,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.directories.length,
                  itemBuilder: (context, index) {
                    final directory = widget.directories[index];
                    return _buildDirectoryTile(directory);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryTile(dynamic entry) {
    if (entry is Directory) {
      return ExpansionTile(
        title: Text(entry.name),
        children: [
          ...entry.subDirectories.map((subDirectory) => _buildDirectoryTile(subDirectory)).toList(),
          // Directories do not have 'maps' directly, only subdirectories do
        ],
      );
    } else if (entry is SubDirectory) {
      return ExpansionTile(
        title: Text(entry.name),
        children: [
          ...entry.subDirectories.map((subDirectory) => _buildDirectoryTile(subDirectory)).toList(),
          ...entry.maps.map((mapEntry) => _buildMapListTile(mapEntry)).toList(),
        ],
      );
    } else if (entry is GospelMapEntryData) {
      return _buildMapListTile(entry);
    }
    return Container(); // Should not happen
  }

  Widget _buildMapListTile(GospelMapEntryData mapEntry) {
    final isDownloaded = widget.mapBox.values.any((map) => map.name == mapEntry.name);
    return ListTile(
      title: Text(mapEntry.name),
      trailing: isDownloaded
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteMap(mapEntry.name),
            )
          : IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => widget.onDownloadMap(mapEntry, mapEntry.name),
            ),
      onTap: () {
        if (isDownloaded) {
          widget.onLoadMap(mapEntry.name);
          // Save the current map name to user preferences
          _userPrefsBox.put('currentMap', mapEntry.name); // Use the instance
          print('[_buildMapListTile] currentMap saved: ${mapEntry.name}'); // Debug print
          Navigator.pop(context);
        }
      },
    );
  }
 
  Future<void> _deleteMap(String mapName) async {
    try {
      final mapInfo = widget.mapBox.values.firstWhere((map) => map.name == mapName);
      await fmtc.FMTCStore(mapInfo.name).manage.delete();
      await widget.mapBox.delete(mapInfo.key);
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete map ($mapName): $error')),
        );
      }
    }
  }
}