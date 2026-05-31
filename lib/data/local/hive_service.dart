import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/models.dart';

class HiveService {
  static const String tripsBoxName = 'trips';
  static const String globalPlacesBoxName = 'global_places';
  static const String globalChecklistBoxName = 'global_checklist';

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Adapters
    Hive.registerAdapter(PlaceAdapter());
    Hive.registerAdapter(ChecklistItemAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(PlanItemAdapter());
    Hive.registerAdapter(TripStatusAdapter());
    Hive.registerAdapter(TripAdapter());

    // Open boxes
    await Hive.openBox<Trip>(tripsBoxName);
    await Hive.openBox<Place>(globalPlacesBoxName);
    await Hive.openBox<ChecklistItem>(globalChecklistBoxName);
  }

  static Box<Trip> get tripsBox => Hive.box<Trip>(tripsBoxName);
  static Box<Place> get globalPlacesBox => Hive.box<Place>(globalPlacesBoxName);
  static Box<ChecklistItem> get globalChecklistBox => Hive.box<ChecklistItem>(globalChecklistBoxName);

  // Trip operations
  static Future<void> saveTrip(Trip trip) async {
    await tripsBox.put(trip.id, trip);
  }

  static Future<void> deleteTrip(String id) async {
    await tripsBox.delete(id);
  }

  static List<Trip> getAllTrips() {
    return tripsBox.values.toList();
  }

  // Global Places
  static Future<void> saveGlobalPlace(Place place) async {
    await globalPlacesBox.put(place.id, place);
  }

  static Future<void> deleteGlobalPlace(String id) async {
    await globalPlacesBox.delete(id);
  }

  static List<Place> getAllGlobalPlaces() {
    return globalPlacesBox.values.toList();
  }

  // Global Checklist
  static Future<void> saveGlobalChecklistItem(ChecklistItem item) async {
    await globalChecklistBox.put(item.id, item);
  }

  static Future<void> deleteGlobalChecklistItem(String id) async {
    await globalChecklistBox.delete(id);
  }

  static List<ChecklistItem> getAllGlobalChecklist() {
    return globalChecklistBox.values.toList();
  }

  static Future<void> clearAllData() async {
    await tripsBox.clear();
    await globalPlacesBox.clear();
    await globalChecklistBox.clear();
  }
}