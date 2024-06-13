import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final box = GetStorage();
  bool _isDyslexicFontEnabled = false;
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _isDyslexicFontEnabled = box.read('font') == 'Dyslexia';
    _selectedTheme = box.read('theme') ?? 'Light';
  }

  void _changeFont(bool isDyslexicFont) {
    final String font = isDyslexicFont ? 'Dyslexia' : 'Default';
    box.write('font', font);
    runApp(
      MyApp(), // Se reinicia la aplicación con la nueva configuración
    );
  }

  void _changeTheme(String theme) {
    box.write('theme', theme);
    runApp(
      MyApp(), // Se reinicia la aplicación con la nueva configuración
    );
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
                  Text('Select Theme', style: TextStyle(color: Colors.black)),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('Light'),
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
                    title: Text('Dark'),
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
                    title: Text('Custom'),
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
                      color: Colors.green, // Color del texto del botón
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
        title: Text('Settings'),
      ),
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
                title: const Text(
                  'Enable Dyslexic-Friendly Font',
                  style: TextStyle(color: Colors.black),
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
                secondary: Icon(Icons.text_fields, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _showThemeDialog(context);
              },
              child: const Row(
                children: [
                  Icon(Icons.color_lens, color: Colors.black),
                  SizedBox(width: 8, height: 40),
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: Colors.black,
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

// Main app class with theme selection logic
class MyApp extends StatelessWidget {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    String theme = box.read('theme') ?? 'Light';
    ThemeData themeData;

    switch (theme) {
      case 'Dark':
        themeData = ThemeData.dark().copyWith(
          primaryColor: Colors.white,
          backgroundColor: Colors.black,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
            ),
          ),
        );
        break;
      case 'Custom':
        themeData = ThemeData.custom().copyWith(
          primaryColor: Color(0xFF7E1E9C), 
          backgroundColor: Color(0xFFF97306),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7E1E9C), // morado
            ),
          ),
        );
        break;
      case 'Light':
      default:
        themeData = ThemeData.light().copyWith(
          primaryColor: Colors.black,
          backgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
        );
        break;
    }

    return MaterialApp(
      theme: themeData,
      home: SettingsScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
