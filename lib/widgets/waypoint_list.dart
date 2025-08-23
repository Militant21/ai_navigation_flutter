import 'package:flutter/material.dart';
import '../models/route_models.dart';

class WaypointList extends StatelessWidget {
  final List<Coord> wps;
  final ValueChanged<List<Coord>> onChanged;
  const WaypointList({super.key, required this.wps, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i=0; i<wps.length; i++)
          Row(children: [
            SizedBox(width: 70, child: Text(i==0? 'Start' : (i==wps.length-1? 'Cél' : 'Stop $i'))),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText: 'Lon'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: wps[i].lon.toStringAsFixed(5)),
              onSubmitted: (t){ final a=[...wps]; a[i]=Coord(double.tryParse(t)??wps[i].lon, a[i].lat); onChanged(a); },
            )),
            const SizedBox(width:8),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText: 'Lat'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: wps[i].lat.toStringAsFixed(5)),
              onSubmitted: (t){ final a=[...wps]; a[i]=Coord(a[i].lon, double.tryParse(t)??wps[i].lat); onChanged(a); },
            )),
            const SizedBox(width:8),
            if(i>0) IconButton(onPressed: (){
              final a=[...wps]; a.removeAt(i); onChanged(a);
            }, icon: const Icon(Icons.close)),
          ]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: (){
            onChanged([...wps, const Coord(0,0)]);
          }, icon: const Icon(Icons.add), label: const Text('Útpont hozzáadása')),
        )
      ],
    );
  }
}