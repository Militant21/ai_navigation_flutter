import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PoisDB {
  final Database db;
  PoisDB(this.db);

  static Future<PoisDB> open(String path) async {
    final db = await openDatabase(path, readOnly: true);
    return PoisDB(db);
  }

  Future<List<Map<String, Object?>>> inBBox({
    required String table,
    required double west,
    required double south,
    required double east,
    required double north,
    int limit = 500,
  }) async {
    return db.query(
      table,
      columns: ['id','lon','lat','name','brand','capacity','type','maxspeed','country'],
      where: 'lon BETWEEN ? AND ? AND lat BETWEEN ? AND ?',
      whereArgs: [west, east, south, north],
      limit: limit,
    );
  }
}