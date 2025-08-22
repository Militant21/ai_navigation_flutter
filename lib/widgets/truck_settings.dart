import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../services/storage.dart';

class TruckSettings extends StatefulWidget {
  final TruckProfile initial;
  final ValueChanged<TruckProfile>? onChanged;
  const TruckSettings({super.key, required this.initial, this.onChanged});

  @override
  State<TruckSettings> createState() => _TruckSettingsState();
}

class _TruckSettingsState extends State<TruckSettings> {
  late TruckProfile p;

  @override
  void initState() {
    super.initState();
    p = widget.initial;
  }

  Future<void> _save() async {
    await KV.set('truckProfile', p.toJson());
    widget.onChanged?.call(p);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kamion beállítások mentve')),
    );
  }

  Widget n(String label, double v, ValueChanged<double> on) => Expanded(
    child: TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: v.toStringAsFixed(2)),
      onSubmitted: (t) => on(double.tryParse(t) ?? v),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          n('Magasság (m)', p.height, (v)=>setState(()=>p.height=v)),
          const SizedBox(width: 8),
          n('Szélesség (m)', p.width, (v)=>setState(()=>p.width=v)),
          const SizedBox(width: 8),
          n('Hossz (m)', p.length, (v)=>setState(()=>p.length=v)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          n('Tömeg (t)', p.weight, (v)=>setState(()=>p.weight=v)),
          const SizedBox(width: 8),
          n('Tengelyterh. (t)', p.axleLoad, (v)=>setState(()=>p.axleLoad=v)),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            decoration: const InputDecoration(labelText: 'Tengelyszám'),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: p.axleCount.toString()),
            onSubmitted: (t)=> setState(()=> p.axleCount = int.tryParse(t) ?? p.axleCount),
          )),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: DropdownButtonFormField<bool>(
            decoration: const InputDecoration(labelText: 'ADR / HAZMAT'),
            value: p.hazmat,
            items: const [
              DropdownMenuItem(value: false, child: Text('Nem')),
              DropdownMenuItem(value: true,  child: Text('Igen')),
            ],
            onChanged: (v)=> setState(()=> p.hazmat = v ?? false),
          )),
          const SizedBox(width: 8),
          Expanded(child: DropdownButtonFormField<String?>(
            decoration: const InputDecoration(labelText: 'Alagút kategória'),
            value: p.hazmatTunnel,
            items: const [
              DropdownMenuItem(value: null, child: Text('—')),
              DropdownMenuItem(value: 'B', child: Text('B')),
              DropdownMenuItem(value: 'C', child: Text('C')),
              DropdownMenuItem(value: 'D', child: Text('D')),
              DropdownMenuItem(value: 'E', child: Text('E')),
            ],
            onChanged: (v)=> setState(()=> p.hazmatTunnel = v),
          )),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _sw('Komp', p.includeFerry, (v)=> setState(()=> p.includeFerry=v)),
          _sw('Vasút', p.includeRail, (v)=> setState(()=> p.includeRail=v)),
          _sw('Földutak kerülése', p.excludeUnpaved, (v)=> setState(()=> p.excludeUnpaved=v)),
          _sw('Fizetős utak kerülése', p.avoidTolls, (v)=> setState(()=> p.avoidTolls=v)),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(onPressed: _save, child: const Text('Mentés')),
        ),
      ],
    );
  }

  Widget _sw(String t, bool v, ValueChanged<bool> on) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [Switch(value: v, onChanged: on), Text(t)],
  );
}