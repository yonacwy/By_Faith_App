import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:quill_delta/quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus
import '../models/pray_model.dart';
import '../providers/theme_notifier.dart';
import 'dart:convert';

class PrayShareUi extends StatefulWidget {
  const PrayShareUi({Key? key}) : super(key: key);

  @override
  State<PrayShareUi> createState() => _PrayShareUiState();
}

class _PrayShareUiState extends State<PrayShareUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
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
                'Social Media',
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
                      leading: const Icon(Icons.share),
                      title: const Text('Share a Prayer'),
                      subtitle: const Text('Send a prayer through messages, email, or other apps'),
                      onTap: () => _sharePrayer(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePrayer(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final prayersBox = await Prayer.openBox();
      final allPrayers = prayersBox.values.toList();

      if (allPrayers.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('No prayers to share.')),
        );
        return;
      }

      final List<Prayer> selectedPrayers = await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return _PrayerSelectionDialog(prayers: allPrayers);
        },
      );

      if (selectedPrayers.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('No prayers selected for sharing.')),
        );
        return;
      }

      final String prayersText = selectedPrayers.map((p) {
        final QuillController _controller = QuillController(
          document: Document.fromJson(jsonDecode(p.richTextJson)),
          selection: const TextSelection.collapsed(offset: 0),
        );
        final String plainText = _controller.document.toPlainText().trim();
        _controller.dispose();
        return plainText.isNotEmpty ? plainText : 'Empty Prayer';
      }).join('\n\n');

      if (prayersText.isNotEmpty) {
        await Share.share(prayersText, subject: 'My Prayers');
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('No content to share.')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error sharing prayers: $e')),
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