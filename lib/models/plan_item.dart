import 'package:hive/hive.dart';

part 'plan_item.g.dart';

@HiveType(typeId: 3)
class PlanItem {
  PlanItem({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.category,
    this.note,
    required this.estimatedCost,
    this.isDone = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String time;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final double estimatedCost;

  @HiveField(7)
  bool isDone;
}