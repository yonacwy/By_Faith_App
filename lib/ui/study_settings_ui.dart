import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class StudySettingsPageUi extends StatefulWidget {
  final Function(String, double) onFontChanged;
  final String initialFont;
  final double initialFontSize;

  StudySettingsPageUi({
    Key? key,
    required this.onFontChanged,
    required this.initialFont,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  _StudySettingsPageUiState createState() => _StudySettingsPageUiState();
}

class _StudySettingsPageUiState extends State<StudySettingsPageUi> {
  late String currentFont;
  late double currentFontSize;

  @override
  void initState() {
    super.initState();
    currentFont = widget.initialFont;
    currentFontSize = 20.0;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> fontOptions = [
      'Arial', // Added Arial to font options
      'Roboto',
      'Times New Roman',
      'Open Sans',
      'Lora',
    ];
    const String sampleText =
        "In the beginning God created the heaven and the earth.";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Settings'),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Font Family',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: currentFont,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: fontOptions.map((font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: Text(
                                font,
                                style: TextStyle(
                                  fontFamily: font,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => currentFont = value);
                              widget.onFontChanged(currentFont, currentFontSize);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Font Size: ${currentFontSize.toStringAsFixed(1)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        Slider(
                          value: currentFontSize,
                          min: 10.0,
                          max: 30.0,
                          divisions: 20,
                          label: currentFontSize.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() => currentFontSize = value);
                            widget.onFontChanged(currentFont, currentFontSize);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preview:',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sampleText,
                            style: TextStyle(
                              fontFamily: currentFont,
                              fontSize: currentFontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}