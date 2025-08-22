import 'package:flutter/material.dart';

class PoiToggles extends StatelessWidget {
  final bool parks;
  final bool fuel;
  final bool services;
  final ValueChanged<bool> onParks;
  final ValueChanged<bool> onFuel;
  final ValueChanged<bool> onServices;
  const PoiToggles({
    super.key,
    required this.parks,
    required this.fuel,
    required this.services,
    required this.onParks,
    required this.onFuel,
    required this.onServices,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 8, children: [
      _sw('Kamionparkolók', parks, onParks),
      _sw('Kamionos kutak', fuel, onFuel),
      _sw('Szervizek', services, onServices),
      // a traffipax kapcsoló a Beállítások képernyőn van (jogilag ott kezeljük)
    ]);
  }

  Widget _sw(String t, bool v, ValueChanged<bool> on) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [Switch(value: v, onChanged: on), Text(t)],
  );
}