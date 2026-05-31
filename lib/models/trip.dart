import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'plan_item.dart';
import 'place.dart';
import 'checklist_item.dart';
import 'expense.dart';

part 'trip.g.dart';

@HiveType(typeId: 4)
enum TripStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  traveling,
  @HiveField(2)
  completed,
}

extension TripStatusUi on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.planning:
        return 'Planning';
      case TripStatus.traveling:
        return 'Traveling';
      case TripStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case TripStatus.planning:
        return const Color(0xFFFF8A00);
      case TripStatus.traveling:
        return const Color(0xFF4CAF50);
      case TripStatus.completed:
        return const Color(0xFF75685E);
    }
  }

  IconData get icon {
    switch (this) {
      case TripStatus.planning:
        return Icons.add_rounded;
      case TripStatus.traveling:
        return Icons.near_me_rounded;
      case TripStatus.completed:
        return Icons.done_rounded;
    }
  }
}

@HiveType(typeId: 5)
class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.budget,
    required this.spent,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final TripStatus status;

  @HiveField(6)
  final double budget;

  @HiveField(7)
  final double spent;

  @HiveField(8)
  final List<PlanItem> planItems = [];

  @HiveField(9)
  final List<Place> places = [];

  @HiveField(10)
  final List<ChecklistItem> checklistItems = [];

  @HiveField(11)
  final List<Expense> expenses = [];

  String get dateRange {
    final start = '${startDate.day} ${_monthShort(startDate.month)} ${startDate.year + 543}';
    final end = '${endDate.day} ${_monthShort(endDate.month)} ${endDate.year + 543}';
    return '$start - $end';
  }

  static String _monthShort(int m) {
    const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    return months[m - 1];
  }
}