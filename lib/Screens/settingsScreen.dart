import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/localization/localization_service.dart';
import 'package:spotfinder/l10n/app_localizations.dart';
import 'package:spotfinder/main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final box = GetStorage();
  bool _isDyslexicFontEnabled = false;
  bool _settingsChanged = false;
  String? _selectedTheme;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _isDyslexicFontEnabled = box.read('font') == 'Dyslexia';
    _selectedTheme = box.read('theme') ?? 'Light';
    _selectedLanguage = box.read('lang') ?? 'en';
  }

  void _changeFont(bool isDyslexicFont) {
    final String font = isDyslexicFont ? 'Dyslexia' : 'Default';
    box.write('font', font);
    runApp(MyApp());
  }

  void _changeTheme(String theme) {
    box.write('theme', theme);
    runApp(MyApp());
    setState(() {
      _settingsChanged = true;
    });
  }

  void _changeLanguage(String langCode) {
    LocalizationService().changeLocale(langCode);
    runApp(MyApp());
    setState(() {
      _selectedLanguage = langCode;
    });
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Theme',
                      style: TextStyle(color: Pallete.backgroundColor)),
                  IconButton(
                    onPressed: () {
                      Get.back(result: _settingsChanged);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Light'),
                    value: 'Light',
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: const Text('Dark'),
                    value: 'Dark',
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: const Text('Colorblind Accessible'),
                    value: 'Custom',
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeTheme(_selectedTheme!);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Language',
                      style: TextStyle(color: Pallete.backgroundColor)),
                  IconButton(
                    onPressed: () {
                      Get.back(result: _settingsChanged);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: LocalizationService.locales.keys.map((langCode) {
                  return RadioListTile<String>(
                    title: Text(langCode.toUpperCase()),
                    value: langCode,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                    activeColor: Colors.green,
                  );
                }).toList(),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeLanguage(_selectedLanguage!);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Pallete.textColor,
          ),
          onPressed: () {
            Get.to(() => HomePage(initialIndex: 3));
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Pallete.textColor),
        ),
      ),
      backgroundColor: Pallete.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              height: 40,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Enable Dyslexic-Friendly Font',
                  style: TextStyle(color: Pallete.textColor),
                ),
                value: _isDyslexicFontEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDyslexicFontEnabled = value;
                    _changeFont(value);
                  });
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
                activeTrackColor: Colors.green[200],
                secondary: Icon(Icons.text_fields, color: Pallete.textColor),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _showThemeDialog(context);
              },
              child: Row(
                children: [
                  Icon(Icons.color_lens, color: Pallete.textColor),
                  const SizedBox(width: 8, height: 40),
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: Pallete.textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _showLanguageDialog(context);
              },
              child: Row(
                children: [
                  Icon(Icons.language, color: Pallete.textColor),
                  const SizedBox(width: 8, height: 40),
                  Text(
                    'Language',
                    style: TextStyle(
                      color: Pallete.textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
