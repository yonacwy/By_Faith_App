import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:by_faith_app/objectbox.dart'; // ObjectBox import
import '../models/pray_model.dart';
import '../providers/theme_notifier.dart';

class PraySettingsUi extends StatefulWidget {
  const PraySettingsUi({Key? key}) : super(key: key);

  @override
  State<PraySettingsUi> createState() => _PraySettingsUiState();
}

class _PraySettingsUiState extends State<PraySettingsUi> {
  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: const Text('Theme'),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                    },
                  ),
                  subtitle: Text(
                    Theme.of(context).brightness == Brightness.light ? 'Light Mode' : 'Dark Mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Export Prayers'),
                      subtitle: const Text('Save your prayers to a file'),
                      onTap: () => _exportPrayers(context),
                    ),
                    ListTile(
                      title: const Text('Import Prayers'),
                      subtitle: const Text('Load prayers from a file'),
                      onTap: () => _importPrayers(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _exportPrayers(BuildContext context) async {
   final scaffoldMessenger = ScaffoldMessenger.of(context);
   try {
       // Request storage permission
       var status = await Permission.storage.status;
       if (!status.isGranted) {
         status = await Permission.storage.request();
       }

       if (!status.isGranted) {
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('Storage permission not granted. Cannot export prayers.')),
         );
         return;
       }

       final prayersBox = objectbox.store.box<Prayer>(); // Get ObjectBox Prayer Box
       final unansweredPrayers = prayersBox.query(Prayer_.status.equals('unanswered')).build().find();

       if (unansweredPrayers.isEmpty) {
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('No unanswered prayers to export.')),
         );
         return;
       }

       final List<Prayer> selectedPrayers = await showDialog(
         context: context,
         builder: (BuildContext dialogContext) {
           return _PrayerSelectionDialog(prayers: unansweredPrayers);
         },
       );

       if (selectedPrayers.isEmpty) {
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('No prayers selected for export.')),
         );
         return;
       }

       final jsonString = jsonEncode(selectedPrayers.map((p) => p.toJson()).toList());

       String? outputFile = await FilePicker.platform.saveFile(
         dialogTitle: 'Save Prayers Export',
         fileName: 'prayers_export.json',
         type: FileType.custom,
         allowedExtensions: ['json'],
       );

       if (outputFile == null) {
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('No export location selected.')),
         );
         return;
       }

       final file = File(outputFile);
       await file.writeAsBytes(utf8.encode(jsonString));

       scaffoldMessenger.showSnackBar(
         SnackBar(content: Text('Selected prayers exported to $outputFile')),
       );
   } catch (e) {
     scaffoldMessenger.showSnackBar(
       SnackBar(content: Text('Error exporting prayers: $e')),
     );
   }
 }

 Future<void> _importPrayers(BuildContext context) async {
   final scaffoldMessenger = ScaffoldMessenger.of(context);
   try {
       FilePickerResult? result = await FilePicker.platform.pickFiles(
         withData: true,
         type: FileType.custom,
         allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
       );

       if (result != null && result.files.single.path != null) {
         final file = File(result.files.single.path!);
         final String contents = await file.readAsString();
         final List<dynamic> jsonList = jsonDecode(contents);
         final List<Prayer> importedPrayers = jsonList.map((json) => Prayer.fromJson(json)).toList();

         final prayersBox = objectbox.store.box<Prayer>(); // Get ObjectBox Prayer Box
         for (var prayer in importedPrayers) {
           // Ensure imported prayers are marked as 'unanswered'
           prayer.status = 'unanswered';
           prayersBox.put(prayer); // Use ObjectBox put
         }

         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('Prayers imported successfully!')),
         );
       } else {
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('No file selected.')),
         );
       }
   } catch (e) {
     scaffoldMessenger.showSnackBar(
       SnackBar(content: Text('Error importing prayers: $e')),
     );
   }
 }
}

class _PrayerSelectionDialog extends StatefulWidget {
 final List<Prayer> prayers;

 const _PrayerSelectionDialog({Key? key, required this.prayers}) : super(key: key);

 @override
 __PrayerSelectionDialogState createState() => __PrayerSelectionDialogState();
}

class __PrayerSelectionDialogState extends State<_PrayerSelectionDialog> {
 late Map<String, bool> _selectedPrayers;

 @override
 void initState() {
   super.initState();
   _selectedPrayers = {for (var prayer in widget.prayers) prayer.id: false};
 }

 @override
 Widget build(BuildContext context) {
   return AlertDialog(
     title: const Text('Select Prayers to Export'),
     content: SingleChildScrollView(
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: widget.prayers.map((prayer) {
           final QuillController _controller = QuillController(
             document: Document.fromJson(jsonDecode(prayer.richTextJson)),
             selection: const TextSelection.collapsed(offset: 0),
           );
           final String plainText = _controller.document.toPlainText().trim();
           _controller.dispose();
           return CheckboxListTile(
             title: Text(plainText.isNotEmpty ? plainText : 'Empty Prayer'),
             value: _selectedPrayers[prayer.id],
             onChanged: (bool? value) {
               setState(() {
                 _selectedPrayers[prayer.id] = value!;
               });
               },
           );
         }).toList(),
       ),
     ),
     actions: [
       TextButton(
         onPressed: () {
           Navigator.of(context).pop([]);
         },
         child: const Text('Cancel'),
       ),
       ElevatedButton(
         onPressed: () {
           final selected = widget.prayers
               .where((prayer) => _selectedPrayers[prayer.id] == true)
               .toList();
           Navigator.of(context).pop(selected);
         },
         child: const Text('Export Selected'),
       ),
     ],
   );
 }
}