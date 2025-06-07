import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../providers/theme_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database.dart'; // Import your Drift database
import 'package:drift/drift.dart' hide Column; // Import drift and hide Column to avoid conflict with flutter

Future<bool> _requestStoragePermission() async {
  if (Platform.isAndroid || Platform.isIOS) {
    var status = await Permission.storage.request();
    return status.isGranted;
  }
  return true;
}
class HomeSettingsUi extends StatefulWidget {
  final Function(String, double) onFontChanged;
  final String initialFont;
  final double initialFontSize;

  const HomeSettingsUi({
    Key? key,
    required this.onFontChanged,
    required this.initialFont,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  _HomeSettingsUiState createState() => _HomeSettingsUiState();
}

class _HomeSettingsUiState extends State<HomeSettingsUi> {
  late String currentFont;
  late double currentFontSize;
  String? _selectedExportData = 'all';
  bool _isProcessing = false; // For progress indicator
  late AppDatabase _database; // Use Drift database instance

  @override
  void initState() {
    super.initState();
    currentFont = widget.initialFont;
    currentFontSize = widget.initialFontSize;
    _database = AppDatabase(AppDatabase.openConnection()); // Initialize Drift database
  }

  Future<void> _exportData() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission not granted')),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    try {
      // Fetch data from Drift tables
      Map<String, dynamic> exportData = {};

      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_contacts') {
        final contacts = await _database.select(_database.contacts).get();
        exportData['gospel_contacts'] = contacts.map((c) => c.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_map_info') {
        final mapInfo = await _database.select(_database.mapInfoEntries).get();
        exportData['gospel_map_info'] = mapInfo.map((m) => m.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_profile') {
        final profiles = await _database.select(_database.gospelProfiles).get();
        exportData['gospel_profile'] = profiles.map((p) => p.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'pray_data') {
        final prayers = await _database.select(_database.prayers).get();
        exportData['pray_data'] = prayers.map((p) => p.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'read_data') {
        final verseData = await _database.select(_database.verseDataEntries).get();
        final bookmarks = await _database.select(_database.bookmarks).get();
        final favorites = await _database.select(_database.favorites).get();
        exportData['read_data'] = {
          'verseData': verseData.map((v) => v.toJson()).toList(),
          'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
          'favorites': favorites.map((f) => f.toJson()).toList(),
        };
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'study_data') {
         final settings = await _database.select(_database.settings).get();
         exportData['study_data'] = settings.map((s) => s.toJson()).toList();
      }


      // Convert to JSON
      final jsonString = json.encode(exportData);

      // Create temporary file for JSON
      final tempDir = await getTemporaryDirectory();
      final jsonFile = File('${tempDir.path}/backup.json');
      await jsonFile.writeAsString(jsonString);

      // Create ZIP archive
      final archive = Archive();
      final jsonBytes = await jsonFile.readAsBytes();
      archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));

      // Encode ZIP
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      // Let user choose save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: 'by_faith_backup_${DateTime.now().toIso8601String()}.zip',
      );

      if (outputPath != null) {
        final zipFile = File(outputPath);
        await zipFile.writeAsBytes(zipData!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully')),
          );
        }
      }

      // Clean up
      await jsonFile.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }


  Future<void> _shareData() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission not granted')),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    try {
      // Fetch data from Drift tables
      Map<String, dynamic> exportData = {};

      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_contacts') {
        final contacts = await _database.select(_database.contacts).get();
        exportData['gospel_contacts'] = contacts.map((c) => c.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_map_info') {
        final mapInfo = await _database.select(_database.mapInfoEntries).get();
        exportData['gospel_map_info'] = mapInfo.map((m) => m.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'gospel_profile') {
        final profiles = await _database.select(_database.gospelProfiles).get();
        exportData['gospel_profile'] = profiles.map((p) => p.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'pray_data') {
        final prayers = await _database.select(_database.prayers).get();
        exportData['pray_data'] = prayers.map((p) => p.toJson()).toList();
      }
      if (_selectedExportData == 'all' || _selectedExportData == 'read_data') {
        final verseData = await _database.select(_database.verseDataEntries).get();
        final bookmarks = await _database.select(_database.bookmarks).get();
        final favorites = await _database.select(_database.favorites).get();
        exportData['read_data'] = {
          'verseData': verseData.map((v) => v.toJson()).toList(),
          'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
          'favorites': favorites.map((f) => f.toJson()).toList(),
        };
      }
       if (_selectedExportData == 'all' || _selectedExportData == 'study_data') {
         final settings = await _database.select(_database.settings).get();
         exportData['study_data'] = settings.map((s) => s.toJson()).toList();
      }


      // Convert to JSON
      final jsonString = json.encode(exportData);

      // Create temporary file for JSON
      final tempDir = await getTemporaryDirectory();
      final jsonFile = File('${tempDir.path}/backup.json');
      await jsonFile.writeAsString(jsonString);

      // Create ZIP archive
      final archive = Archive();
      final jsonBytes = await jsonFile.readAsBytes();
      archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));

      // Encode ZIP
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      // Create temporary file for ZIP
      final tempZipFile = File('${tempDir.path}/by_faith_backup_${DateTime.now().toIso8601String()}.zip');
      await tempZipFile.writeAsBytes(zipData!);

      await Share.shareXFiles([XFile(tempZipFile.path)]);

      // Clean up
      await jsonFile.delete();
      await tempZipFile.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data shared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importData() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission not granted')),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    try {
      // Pick ZIP file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        final zipFile = File(result.files.single.path!);
        final bytes = await zipFile.readAsBytes();

        // Decode ZIP
        final archive = ZipDecoder().decodeBytes(bytes);
        final jsonFile = archive.findFile('backup.json');
        if (jsonFile == null) {
          throw Exception('No backup.json found in zip file');
        }

        // Parse JSON
        final jsonString = utf8.decode(jsonFile.content as List<int>);
        final importData = json.decode(jsonString) as Map<String, dynamic>;

        // Validate JSON structure
        final validTables = [
          'gospel_contacts',
          'gospel_map_info',
          'gospel_profile',
          'pray_data',
          'read_data',
          'study_data'
        ];
        for (var key in importData.keys) {
          if (!validTables.contains(key)) {
            throw Exception('Invalid table name in backup: $key');
          }
        }

        // Confirm import with user
        bool? confirmImport = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Import'),
            content: const Text(
                'Importing will overwrite existing data. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirmImport != true) {
          throw Exception('Import cancelled by user');
        }

        // Restore data to Drift tables
        if (importData.containsKey('gospel_contacts')) {
          await _database.delete(_database.contacts).go();
          final contacts = (importData['gospel_contacts'] as List).map((json) => ContactEntry.fromJson(json)).toList();
          await _database.batch((batch) {
            batch.insertAll(_database.contacts, contacts);
          });
        }
         if (importData.containsKey('gospel_map_info')) {
          await _database.delete(_database.mapInfoEntries).go();
          final mapInfo = (importData['gospel_map_info'] as List).map((json) => MapInfoEntry.fromJson(json)).toList();
          await _database.batch((batch) {
            batch.insertAll(_database.mapInfoEntries, mapInfo);
          });
        }
         if (importData.containsKey('gospel_profile')) {
          await _database.delete(_database.gospelProfiles).go();
          final profiles = (importData['gospel_profile'] as List).map((json) => GospelProfileEntry.fromJson(json)).toList();
          await _database.batch((batch) {
            batch.insertAll(_database.gospelProfiles, profiles);
          });
        }
         if (importData.containsKey('pray_data')) {
          await _database.delete(_database.prayers).go();
          final prayers = (importData['pray_data'] as List).map((json) => PrayerEntry.fromJson(json)).toList();
          await _database.batch((batch) {
            batch.insertAll(_database.prayers, prayers);
          });
        }
         if (importData.containsKey('read_data')) {
          await _database.delete(_database.verseDataEntries).go();
          await _database.delete(_database.bookmarks).go();
          await _database.delete(_database.favorites).go();
          final readData = importData['read_data'] as Map<String, dynamic>;
          final verseData = (readData['verseData'] as List).map((json) => VerseDataEntry.fromJson(json)).toList();
          final bookmarks = (readData['bookmarks'] as List).map((json) => BookmarkEntry.fromJson(json)).toList();
          final favorites = (readData['favorites'] as List).map((json) => FavoriteEntry.fromJson(json)).toList();
           await _database.batch((batch) {
            batch.insertAll(_database.verseDataEntries, verseData);
            batch.insertAll(_database.bookmarks, bookmarks);
            batch.insertAll(_database.favorites, favorites);
          });
        }
         if (importData.containsKey('study_data')) {
          await _database.delete(_database.settings).go();
          final settings = (importData['study_data'] as List).map((json) => SettingsEntry.fromJson(json)).toList();
          await _database.batch((batch) {
            batch.insertAll(_database.settings, settings);
          });
        }


        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> fontOptions = [
      'Roboto',
      'Times New Roman',
      'Open Sans',
      'Lora',
    ];
    const String sampleText = "This is a sample dashboard text.";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        title: const Text('Theme'),
                        trailing: Switch(
                          value: Theme.of(context).brightness == Brightness.dark,
                          onChanged: (value) {
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .toggleTheme();
                          },
                        ),
                        subtitle: Text(
                          Theme.of(context).brightness == Brightness.light
                              ? 'Light Mode'
                              : 'Dark Mode',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Text Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Font Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            DropdownButton<String>(
                              value: currentFont,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              underline: const SizedBox(),
                              items: fontOptions.map((font) {
                                return DropdownMenuItem<String>(
                                  value: font,
                                  child: Text(
                                    font,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    currentFont = value;
                                    widget.onFontChanged(
                                        currentFont, currentFontSize);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Font Size',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Slider(
                              value: currentFontSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 24,
                              label: currentFontSize.toStringAsFixed(1),
                              activeColor: Theme.of(context).colorScheme.primary,
                              inactiveColor:
                                  Theme.of(context).colorScheme.outlineVariant,
                              onChanged: (value) {
                                setState(() {
                                  currentFontSize = value;
                                  widget.onFontChanged(
                                      currentFont, currentFontSize);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Text Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          sampleText,
                          style: TextStyle(
                            fontSize: currentFontSize,
                            fontFamily: currentFont,
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Backup',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Data',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select data to share:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            RadioListTile<String>(
                              title: const Text('All Data'),
                              value: 'all',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Contacts'),
                              value: 'gospel_contacts',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Map Info'),
                              value: 'gospel_map_info',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Profile'),
                              value: 'gospel_profile',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Pray Data'),
                              value: 'pray_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              title: const Text('Read Data'),
                              value: 'read_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Study Data'),
                              value: 'study_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isProcessing ? null : _shareData,
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Share'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export/Import Data',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select data to export:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            RadioListTile<String>(
                              title: const Text('All Data'),
                              value: 'all',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Contacts'),
                              value: 'gospel_contacts',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Map Info'),
                              value: 'gospel_map_info',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Gospel Profile'),
                              value: 'gospel_profile',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Pray Data'),
                              value: 'pray_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Read Data'),
                              value: 'read_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Study Data'),
                              value: 'study_data',
                              groupValue: _selectedExportData,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExportData = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _isProcessing ? null : _exportData,
                                  child: _isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Export'),
                                ),
                                ElevatedButton(
                                  onPressed: _isProcessing ? null : _importData,
                                  child: _isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Import'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}