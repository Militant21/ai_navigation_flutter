import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool speedCameras = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await KV.get<Map>('settings');
    if (s != null) {
      setState(() {
        speedCameras = s['speedCameras'] ?? false;
      });
    }
  }

  Future<void> _save() async {
    await KV.set('settings', {
      'speedCameras': speedCameras,
    });
  }

  void _changeLang(Locale l) {
    context.setLocale(l);
    setState(() {}); // frissítés
  }

  void _showLegal() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Felhasználási feltételek"),
        content: const SingleChildScrollView(
          child: Text(
              "Ez az alkalmazás kamionos navigációs célokra készült. "
              "A traffipax figyelmeztetés funkció egyes országokban nem engedélyezett, "
              "ennek használatáért a felhasználó felel. "
              "Az adatok OSM alapúak, pontosságuk nem garantált."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("settings"))),
      body: ListView(
        children: [
          ListTile(
            title: Text(tr("language")),
            subtitle: Text(context.locale.languageCode),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              onChanged: (l) {
                if (l != null) _changeLang(l);
              },
              items: const [
                DropdownMenuItem(value: Locale("hu"), child: Text("Magyar")),
                DropdownMenuItem(value: Locale("en"), child: Text("English")),
                DropdownMenuItem(value: Locale("de"), child: Text("Deutsch")),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(tr("poi.cameras")), // „Traffipaxok”
            subtitle: Text(tr("settings_cameras_hint")),
            value: speedCameras,
            onChanged: (v) {
              setState(() => speedCameras = v);
              _save();
            },
          ),
          ListTile(
            title: const Text("Felhasználási feltételek"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLegal,
          ),
        ],
      ),
    );
  }
}