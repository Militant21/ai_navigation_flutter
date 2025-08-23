import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/catalog.dart';
import '../services/manifest.dart';
import '../services/downloader.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String url = '';
  Catalog? cat;
  bool busy = false;
  String? msg;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByCountry(cat?.regions ?? []);
    return Scaffold(
      appBar: AppBar(title: Text(tr('download_region'))),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: tr('catalog_url'),
                hintText: 'https://.../manifest.json',
              ),
              onChanged: (v) => url = v,
            ),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(
                onPressed: busy ? null : () async {
                  setState(()=> busy = true);
                  try {
                    cat = await fetchCatalog(url);
                    msg = null;
                  } catch (e) { msg = '$e'; }
                  setState(()=> busy = false);
                },
                child: const Text('Load'),
              ),
              if (busy) const Padding(
                padding: EdgeInsets.only(left: 12),
                child: CircularProgressIndicator(),
              ),
            ]),
            if (msg != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(msg!, style: const TextStyle(color: Colors.red)),
            ),
            const Divider(),
            Expanded(
              child: (cat==null)
                ? Center(child: Text(tr('no_regions')))
                : ListView(
                    children: [
                      for (final country in groups.keys)
                        _countrySection(country, groups[country]!)
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Region>> _groupByCountry(List<Region> regions) {
    final m = <String, List<Region>>{};
    for (final r in regions) {
      (m[r.country] ??= []).add(r);
    }
    // ABC szerint
    for (final k in m.keys) { m[k]!.sort((a,b)=> a.name.compareTo(b.name)); }
    final sorted = Map.fromEntries(m.entries.toList()..sort((a,b)=> a.key.compareTo(b.key)));
    return sorted;
  }

  Widget _countrySection(String iso, List<Region> rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(iso, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...rs.map((r) => FutureBuilder<String?>(
          future: installedVersion(r.id),
          builder: (c, snap) {
            final instVer = snap.data;
            final isInstalled = instVer != null && instVer.isNotEmpty;
            final hasUpdate = isInstalled && r.version != null && r.version!.isNotEmpty && r.version != instVer;

            return Card(
              child: ListTile(
                title: Text(r.name),
                subtitle: Text('${r.approxSizeMb ?? 0} MB'
                    '${r.version!=null ? ' • v${r.version}' : ''}'
                    '${isInstalled ? ' • Telepítve: v${instVer ?? "-"}' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasUpdate)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Frissítés', style: TextStyle(color: Colors.orange)),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => _installOrUpdate(r),
                      child: Text(isInstalled ? (hasUpdate ? 'Frissít' : 'Újratelepít') : 'Letölt'),
                    ),
                  ],
                ),
              ),
            );
          },
        ))
      ],
    );
  }

  Future<void> _installOrUpdate(Region r) async {
    final p = await regionPaths(r.id);
    try {
      setState(()=> busy = true);
      if (r.pmtiles != null && r.pmtiles!.isNotEmpty) {
        await downloadFile(r.pmtiles!, p.pmtiles);
      } else if (r.mbtiles != null && r.mbtiles!.isNotEmpty) {
        await downloadFile(r.mbtiles!, p.mbtiles);
      }
      if (r.pois != null && r.pois!.isNotEmpty) {
        await downloadFile(r.pois!, p.pois);
      }
      if (r.valhalla != null && r.valhalla!.isNotEmpty) {
        await downloadFile(r.valhalla!, p.valhalla);
      }
      await markInstalled(r.id, r.version);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${r.name} telepítve')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    } finally {
      setState(()=> busy = false);
    }
  }
}