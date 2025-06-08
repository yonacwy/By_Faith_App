import 'package:flutter/material.dart';
import '../objectbox.dart';
import '../objectbox.g.dart';
import '../models/read_page_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class ReadSettingsUi extends StatefulWidget {
  final Function(String, double) onFontChanged;
  final String initialFont;
  final double initialFontSize;
  final Function(bool) onAutoScrollChanged;
  final bool initialAutoScrollState;
  final Function(String) onAutoScrollModeChanged; // New callback for mode
  final String initialAutoScrollMode; // New initial mode

  const ReadSettingsUi({
    super.key,
    required this.onFontChanged,
    required this.initialFont,
    required this.initialFontSize,
    required this.onAutoScrollChanged,
    required this.initialAutoScrollState,
    required this.onAutoScrollModeChanged,
    required this.initialAutoScrollMode,
  });

  @override
  _ReadSettingsUiState createState() => _ReadSettingsUiState();
}

class _ReadSettingsUiState extends State<ReadSettingsUi> {
  String? currentFont;
  double? currentFontSize;
  bool? _isAutoScrollingEnabled;
  String? _autoScrollMode; // New: 'Normal' or 'Continuous'
  late ObjectBox objectbox;
  late Box<UserPreference> userPreferenceBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentFont = widget.initialFont;
    currentFontSize = widget.initialFontSize;
    _isAutoScrollingEnabled = widget.initialAutoScrollState;
    _autoScrollMode = widget.initialAutoScrollMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      objectbox = await ObjectBox.create();
      userPreferenceBox = objectbox.store.box<UserPreference>();

      UserPreference? prefs = userPreferenceBox.get(1); // Assuming a single UserPreference object with ID 1

      setState(() {
        currentFont = prefs?.selectedFont ?? widget.initialFont;
        currentFontSize = prefs?.selectedFontSize ?? widget.initialFontSize;
        _isAutoScrollingEnabled = prefs?.isAutoScrollingEnabled ?? widget.initialAutoScrollState;
        _autoScrollMode = prefs?.autoScrollMode ?? widget.initialAutoScrollMode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
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
    const String sampleText = "Till I come, give attendance to reading, to exhortation, to doctrine.";

    if (_isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                currentFont = value;
                                widget.onFontChanged(currentFont!, currentFontSize!);
                                UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference(fontSize: 16.0);
                                prefs.selectedFont = value;
                                userPreferenceBox.put(prefs);
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
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          value: currentFontSize!,
                          min: 12.0,
                          max: 24.0,
                          divisions: 24,
                          label: currentFontSize!.toStringAsFixed(1),
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                          onChanged: (value) {
                            setState(() {
                              currentFontSize = value;
                              widget.onFontChanged(currentFont!, currentFontSize!);
                              UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference(fontSize: 16.0);
                              prefs.selectedFontSize = value;
                              userPreferenceBox.put(prefs);
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
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
                  'Auto Scroll',
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
                        title: const Text('Enable Auto Scroll'),
                        trailing: Switch(
                          value: _isAutoScrollingEnabled!,
                          onChanged: (value) {
                            setState(() {
                              _isAutoScrollingEnabled = value;
                              widget.onAutoScrollChanged(value);
                              UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference(fontSize: 16.0);
                              prefs.isAutoScrollingEnabled = value;
                              userPreferenceBox.put(prefs);
                            });
                          },
                        ),
                        subtitle: Text(
                          _isAutoScrollingEnabled! ? 'On' : 'Off',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      if (_isAutoScrollingEnabled!) ...[
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: const Text('Normal (Stop at chapter end)'),
                          value: 'Normal',
                          groupValue: _autoScrollMode,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _autoScrollMode = value;
                                widget.onAutoScrollModeChanged(value);
                                UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference(fontSize: 16.0);
                                prefs.autoScrollMode = value;
                                userPreferenceBox.put(prefs);
                              });
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Continuous (Scroll through entire Bible)'),
                          value: 'Continuous',
                          groupValue: _autoScrollMode,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _autoScrollMode = value;
                                widget.onAutoScrollModeChanged(value);
                                UserPreference prefs = userPreferenceBox.get(1) ?? UserPreference(fontSize: 16.0);
                                prefs.autoScrollMode = value;
                                userPreferenceBox.put(prefs);
                              });
                            }
                          },
                        ),
                      ],
                    ],
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