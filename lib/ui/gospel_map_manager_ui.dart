import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/datastore.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:by_faith_app/models/gospel_map_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_sub_directory_model.dart';
import 'package:by_faith_app/models/gospel_map_entry_data_model.dart';

part 'gospel_map_manager_ui.g.dart';

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