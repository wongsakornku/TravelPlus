import 'package:hive/hive.dart';

part 'place.g.dart';

@HiveType(typeId: 0)
class Place {
  Place({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.note,
    this.mapsUrl,
    this.isVisited = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final String? mapsUrl; // Can be a full Google Maps URL or will be normalized from lat,lng input

  @HiveField(6)
  bool isVisited;
}