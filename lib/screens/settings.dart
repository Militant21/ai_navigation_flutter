import 'package:flutter/material.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.language), title: Text('Nyelv'), subtitle: Text('Magyar')),
          Divider(),
          ListTile(leading: Icon(Icons.map), title: Text('Térkép tárhely'), subtitle: Text('Belső tárhely / ai_nav_maps')),
          Divider(),
          SwitchListTile(value: true, onChanged: null, title: Text('Sötét mód (később)')),
        ],
      ),
    );
  }
}
