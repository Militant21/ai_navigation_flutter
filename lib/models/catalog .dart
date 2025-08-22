class Region {
  String id;
  String name;
  String country;         // ISO kód (pl. GB, DE)
  String? version;        // régió-verzió (pl. 2025-08-01-uk-v1)
  String? pmtiles;
  String? mbtiles;
  String? pois;
  String? valhalla;
  int? approxSizeMb;
  Region({
    required this.id,
    required this.name,
    required this.country,
    this.version,
    this.pmtiles,
    this.mbtiles,
    this.pois,
    this.valhalla,
    this.approxSizeMb,
  });
}

class Catalog {
  String version;         // katalógus-verzió
  List<Region> regions;
  Catalog(this.version, this.regions);
}