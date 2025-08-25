import 'package:flutter/material.dart';
class TruckProfile {
  double height; // m
  double width;  // m
  double length; // m
  double weight; // t
  double axleLoad; // t
  int axleCount;
  bool hazmat; // ADR
  String? hazmatTunnel; // B,C,D,E
  bool includeFerry;
  bool includeRail;
  bool excludeUnpaved;
  bool avoidTolls;
  TruckProfile({
    this.height=4.0,this.width=2.55,this.length=16.5,this.weight=40,
    this.axleLoad=10,this.axleCount=5,this.hazmat=false,this.hazmatTunnel,
    this.includeFerry=false,this.includeRail=false,this.excludeUnpaved=true,this.avoidTolls=false});
  Map<String,dynamic> toJson()=>{
    'height':height,'width':width,'length':length,'weight':weight,'axle_load':axleLoad,'axle_count':axleCount,
    'hazmat':hazmat,'hazmat_tunnel_cat':hazmatTunnel,'include_ferry':includeFerry,'include_rail':includeRail,
    'exclude_unpaved':excludeUnpaved,'avoid_tolls':avoidTolls};
  static TruckProfile fromJson(Map<String,dynamic> j)=>TruckProfile(
    height:(j['height']??4.0)*1.0,width:(j['width']??2.55)*1.0,length:(j['length']??16.5)*1.0,
    weight:(j['weight']??40)*1.0,axleLoad:(j['axle_load']??10)*1.0,axleCount:(j['axle_count']??5).toInt(),
    hazmat:j['hazmat']??false,hazmatTunnel:j['hazmat_tunnel_cat'],includeFerry:j['include_ferry']??false,
    includeRail:j['include_rail']??false,excludeUnpaved:j['exclude_unpaved']??true,avoidTolls:j['avoid_tolls']??false);
}