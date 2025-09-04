import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

List<Marker> myLocationMarkers(double lat,double lon, Color color){
  return [
    Marker(point: LatLng(lat,lon), width:38, height:38,
      child: Container(decoration: BoxDecoration(
        shape: BoxShape.circle, color: color.withOpacity(.20),
        border: Border.all(color: color.withOpacity(.6), width: 2)))),
    Marker(point: LatLng(lat,lon), width:14, height:14,
      child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color))),
  ];
}
