import 'package:flutter/material.dart';

import 'core/utils/maps_utils.dart';
import 'data/local/hive_service.dart';
import 'models/models.dart';
import 'screens/global_places_view.dart';
import 'screens/global_checklist_view.dart';
import 'screens/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const TravelPlusApp());
}

class TravelPlusApp extends StatelessWidget {
  const TravelPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Trip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A00),
          primary: const Color(0xFFFF8A00),
          secondary: const Color(0xFFFFD180),
          surface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const TripHomePage(),
    );
  }
}

class TripHomePage extends StatefulWidget {
  const TripHomePage({super.key});

  @override
  State<TripHomePage> createState() => _TripHomePageState();
}

class _TripHomePageState extends State<TripHomePage> {
  int currentIndex = 0;

  List<Trip> trips = [];
  List<Place> globalPlaces = [];
  List<ChecklistItem> globalChecklist = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      trips = HiveService.getAllTrips();
      globalPlaces = HiveService.getAllGlobalPlaces();
      globalChecklist = HiveService.getAllGlobalChecklist();

      // Seed sample data only on first run (if nothing exists)
      if (trips.isEmpty && globalPlaces.isEmpty && globalChecklist.isEmpty) {
        _seedSampleData();
      }
    });
  }

  Future<void> _seedSampleData() async {
    final sampleTrip = Trip(
      id: 'trip_001',
      title: 'เชียงใหม่ 3 วัน 2 คืน',
      location: 'เชียงใหม่, ประเทศไทย',
      startDate: DateTime(2026, 12, 12),
      endDate: DateTime(2026, 12, 14),
      status: TripStatus.planning,
      budget: 5000,
      spent: 2350,
    );
    await HiveService.saveTrip(sampleTrip);

    setState(() {
      trips = HiveService.getAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TripsView(trips: trips, onAddTrip: _showAddTripSheet),
      GlobalPlacesView(places: globalPlaces, onAddPlace: _showAddGlobalPlace),
      _BudgetView(trips: trips),
      GlobalChecklistView(items: globalChecklist, onAddItem: _showAddGlobalChecklistItem),
      SettingsView(
        tripCount: trips.length,
        placeCount: globalPlaces.length,
        checklistCount: globalChecklist.length,
        onClearData: _clearAllData,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(child: pages[currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.luggage_rounded), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.place_rounded), label: 'Places'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Checklist'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  void _showAddTripSheet() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final budgetController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('สร้างทริปใหม่', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'ชื่อทริป')),
                  const SizedBox(height: 10),
                  TextField(controller: locationController, decoration: const InputDecoration(labelText: 'สถานที่')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(startDate == null ? 'วันที่เริ่มต้น' : _formatShortDate(startDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(endDate == null ? 'วันที่สิ้นสุด' : _formatShortDate(endDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now().add(const Duration(days: 2)),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(() => endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'งบประมาณ (บาท)'),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final newTrip = Trip(
                        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text.trim().isEmpty ? 'ทริปใหม่' : titleController.text.trim(),
                        location: locationController.text.trim().isEmpty ? 'ยังไม่ระบุ' : locationController.text.trim(),
                        startDate: startDate ?? now,
                        endDate: endDate ?? now.add(const Duration(days: 2)),
                        status: TripStatus.planning,
                        budget: double.tryParse(budgetController.text.trim()) ?? 0,
                        spent: 0,
                      );

                      await HiveService.saveTrip(newTrip);

                      setState(() {
                        trips.insert(0, newTrip);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('บันทึกทริป'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatShortDate(DateTime d) {
    const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  // === Global Places (Saved Places ระดับแอพ) ===
  void _showAddGlobalPlace() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();
    final mapsUrlController = TextEditingController();
    String selectedCategory = 'ที่เที่ยว';
    final categories = ['ที่เที่ยว', 'ร้านอาหาร', 'คาเฟ่', 'โรงแรม', 'จุดถ่ายรูป', 'การเดินทาง', 'อื่น ๆ'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('เพิ่มสถานที่ที่อยากไป', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ชื่อสถานที่')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setSheet(() => selectedCategory = val!),
                  decoration: const InputDecoration(labelText: 'ประเภท'),
                ),
                const SizedBox(height: 10),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'ที่อยู่ (ถ้ามี)')),
                const SizedBox(height: 10),
                TextField(controller: noteController, maxLines: 2, decoration: const InputDecoration(labelText: 'หมายเหตุ')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: mapsUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Google Maps (URL หรือ lat,lng)',
                          hintText: '13.7563,100.5018 หรือ https://maps...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.map_rounded),
                      tooltip: 'เปิด Google Maps เพื่อค้นหาและคัดลอก',
                      onPressed: openGoogleMapsForSearch,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    final normalized = normalizeMapsInput(mapsUrlController.text);

                    final newPlace = Place(
                      id: 'gplace_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      mapsUrl: normalized,
                    );

                    await HiveService.saveGlobalPlace(newPlace);

                    setState(() {
                      globalPlaces.insert(0, newPlace);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึกสถานที่'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // === Global Checklist (ระดับแอพ) ===
  void _showAddGlobalChecklistItem() {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('เพิ่มรายการเช็คลิสต์', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'รายการที่ต้องเตรียม', hintText: 'เช่น บัตรประชาชน, ที่ชาร์จ, ยาประจำตัว'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  final newItem = ChecklistItem(
                    id: 'gcheck_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text.trim(),
                  );

                  await HiveService.saveGlobalChecklistItem(newItem);

                  setState(() {
                    globalChecklist.add(newItem);
                  });
                  Navigator.pop(context);
                },
                child: const Text('เพิ่มรายการ'),
              ),
            ],
          ),
        );
      },
    );
  }

  // === Settings ===
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ล้างข้อมูลทั้งหมด?'),
        content: const Text('ข้อมูลทริป สถานที่ และเช็คลิสต์ทั้งหมดจะถูกลบ (ใช้สำหรับทดสอบ)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () async {
              await HiveService.clearAllData();
              setState(() {
                trips.clear();
                globalPlaces.clear();
                globalChecklist.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ล้างข้อมูลเรียบร้อย')),
              );
            },
            child: const Text('ล้างข้อมูล'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFFFFB15A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Trip', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text('ทริปส่วนตัวของคุณ', style: TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}

class _TripsView extends StatelessWidget {
  const _TripsView({required this.trips, required this.onAddTrip});

  final List<Trip> trips;
  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final totalBudget = trips.fold<double>(0, (sum, trip) => sum + trip.budget);
    final totalSpent = trips.fold<double>(0, (sum, trip) => sum + trip.spent);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        FilledButton.icon(
          onPressed: onAddTrip,
          icon: const Icon(Icons.add_rounded),
          label: const Text('สร้างทริปใหม่'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        ),
        const SizedBox(height: 16),
        _SummaryCard(totalBudget: totalBudget, totalSpent: totalSpent, tripCount: trips.length),
        const SizedBox(height: 22),
        Text('ทริปล่าสุด', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final trip in trips) ...[
          _TripCard(
            trip: trip,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalBudget, required this.totalSpent, required this.tripCount});

  final double totalBudget;
  final double totalSpent;
  final int tripCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE0B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ภาพรวมทริป', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Metric(label: 'Trips', value: '$tripCount')),
              Expanded(child: _Metric(label: 'Budget', value: '${totalBudget.toStringAsFixed(0)}฿')),
              Expanded(child: _Metric(label: 'Spent', value: '${totalSpent.toStringAsFixed(0)}฿')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFF8A00))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF75685E))),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, this.onTap});

  final Trip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: trip.status.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(trip.status.icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${trip.location} • ${trip.dateRange}', style: const TextStyle(color: Color(0xFF75685E))),
                    const SizedBox(height: 6),
                    Text('${trip.status.label} • งบ ${trip.budget.toStringAsFixed(0)} บาท', style: TextStyle(color: trip.status.color, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Color(0xFF75685E)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetView extends StatelessWidget {
  const _BudgetView({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final totalBudget = trips.fold<double>(0, (sum, trip) => sum + trip.budget);
    final totalSpent = trips.fold<double>(0, (sum, trip) => sum + trip.spent);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _SummaryCard(totalBudget: totalBudget, totalSpent: totalSpent, tripCount: trips.length),
        const SizedBox(height: 16),
        for (final trip in trips)
          _TripCard(
            trip: trip,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
            ),
          ),
      ],
    );
  }
}

class _SimpleView extends StatelessWidget {
  const _SimpleView({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: const Color(0xFFFF8A00)),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF75685E))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global views have been extracted to lib/screens/
// - GlobalPlacesView
// - GlobalChecklistView
// - SettingsView

class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key, required this.trip});

  final Trip trip;

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _tabLabels = const ['แผน', 'สถานที่', 'งบประมาณ', 'เช็คลิสต์', 'ความทรงจำ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPlanItemSheet() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final costController = TextEditingController();

    final startDay = DateTime(widget.trip.startDate.year, widget.trip.startDate.month, widget.trip.startDate.day);
    final endDay = DateTime(widget.trip.endDate.year, widget.trip.endDate.month, widget.trip.endDate.day);

    DateTime selectedDate = startDay;
    String selectedTime = '09:00';
    String selectedCategory = 'ที่เที่ยว';

    final categories = ['เดินทาง', 'อาหาร', 'ที่เที่ยว', 'ที่พัก', 'อื่น ๆ'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('เพิ่มกิจกรรม', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),

                  // Day selector
                  const Text('วันที่', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var d = startDay; !d.isAfter(endDay); d = d.add(const Duration(days: 1)))
                        ChoiceChip(
                          label: Text('${d.day}/${d.month}'),
                          selected: selectedDate.year == d.year && selectedDate.month == d.month && selectedDate.day == d.day,
                          onSelected: (_) => setSheet(() => selectedDate = d),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Time + Category row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('เวลา', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.access_time_rounded),
                              label: Text(selectedTime),
                              onPressed: () async {
                                final parts = selectedTime.split(':');
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                                );
                                if (picked != null) {
                                  setSheet(() {
                                    selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ประเภท', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) => setSheet(() => selectedCategory = val!),
                              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม', hintText: 'เช่น กินข้าวร้านดัง, เดินตลาดกลางคืน'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ค่าใช้จ่ายโดยประมาณ (บาท)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'หมายเหตุ (ถ้ามี)'),
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      final newItem = PlanItem(
                        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                        date: selectedDate,
                        time: selectedTime,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                        estimatedCost: double.tryParse(costController.text.trim()) ?? 0,
                      );

                      widget.trip.planItems.add(newItem);
                      Navigator.pop(context);
                      setState(() {}); // refresh the detail page
                    },
                    child: const Text('บันทึกกิจกรรม'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPlaceSheet() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();
    final mapsUrlController = TextEditingController();

    String selectedCategory = 'ที่เที่ยว';
    final categories = ['ที่เที่ยว', 'ร้านอาหาร', 'คาเฟ่', 'โรงแรม', 'จุดถ่ายรูป', 'การเดินทาง', 'อื่น ๆ'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('เพิ่มสถานที่', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อสถานที่',
                      hintText: 'เช่น วัดพระธาตุดอยสุเทพ, ร้านข้าวซอยแม่',
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('ประเภทสถานที่', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setSheet(() => selectedCategory = val!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'ที่อยู่ (ถ้ามี)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'หมายเหตุ (เช่น เวลาเปิดปิด, อยากไปเพราะ...)'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: mapsUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Google Maps (URL หรือ lat,lng)',
                            hintText: '13.7563,100.5018 หรือ https://maps...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.map_rounded),
                        tooltip: 'เปิด Google Maps เพื่อค้นหาและคัดลอก',
                        onPressed: openGoogleMapsForSearch,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;

                      final normalized = normalizeMapsInput(mapsUrlController.text);

                      final newPlace = Place(
                        id: 'place_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        category: selectedCategory,
                        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                        mapsUrl: normalized,
                      );

                      widget.trip.places.add(newPlace);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('บันทึกสถานที่'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExpenseSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    String selectedCategory = 'อาหาร';
    final categories = ['ค่าเดินทาง', 'ที่พัก', 'อาหาร', 'ค่าเข้าชม', 'ช้อปปิ้ง', 'อื่น ๆ'];

    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('เพิ่มค่าใช้จ่าย', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'ชื่อรายการ', hintText: 'เช่น ตั๋วเครื่องบิน, ข้าวซอย'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'จำนวนเงิน (บาท)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('วันที่', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 4),
                            OutlinedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) setSheet(() => selectedDate = picked);
                              },
                              child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year + 543}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('หมวดหมู่', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setSheet(() => selectedCategory = val!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'หมายเหตุ (ถ้ามี)'),
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text.trim()) ?? 0;
                      if (titleController.text.trim().isEmpty || amount <= 0) return;

                      final newExpense = Expense(
                        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text.trim(),
                        amount: amount,
                        category: selectedCategory,
                        date: selectedDate,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );

                      widget.trip.expenses.add(newExpense);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('บันทึกรายจ่าย'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddChecklistItemSheet() {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('เพิ่มรายการเช็คลิสต์', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'รายการที่ต้องเตรียม',
                  hintText: 'เช่น บัตรประชาชน, ผ้าเช็ดตัว, พาวเวอร์แบงก์',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  widget.trip.checklistItems.add(
                    ChecklistItem(
                      id: 'check_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('เพิ่มรายการ'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleChecklistItem(ChecklistItem item, bool value) {
    setState(() {
      item.isChecked = value;
    });
  }

  void _togglePlanItem(PlanItem item, bool value) {
    setState(() {
      item.isDone = value;
    });
  }

  void _togglePlace(Place place, bool value) {
    setState(() {
      place.isVisited = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(widget.trip.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFF8A00),
          unselectedLabelColor: const Color(0xFF75685E),
          indicatorColor: const Color(0xFFFF8A00),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PlanTab(
            trip: widget.trip,
            onAddPlan: _showAddPlanItemSheet,
            onTogglePlanItem: _togglePlanItem,
          ),
          _PlacesTab(
            trip: widget.trip,
            onAddPlace: _showAddPlaceSheet,
            onTogglePlace: _togglePlace,
          ),
          _BudgetTab(trip: widget.trip, onAddExpense: _showAddExpenseSheet),
          _ChecklistTab(
            trip: widget.trip,
            onAddItem: _showAddChecklistItemSheet,
            onToggle: _toggleChecklistItem,
          ),
          _MemoriesTab(trip: widget.trip),
        ],
      ),
    );
  }
}

// --- Tab contents (ตามโครงสร้างใน AGENTS.md) ---

class _PlanTab extends StatelessWidget {
  const _PlanTab({
    required this.trip,
    required this.onAddPlan,
    required this.onTogglePlanItem,
  });

  final Trip trip;
  final VoidCallback onAddPlan;
  final void Function(PlanItem item, bool value) onTogglePlanItem;

  @override
  Widget build(BuildContext context) {
    final days = _generateDays(trip);

    if (trip.planItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(
            title: 'ตารางเที่ยวรายวัน',
            subtitle: 'Day 1 - Day ${trip.endDate.difference(trip.startDate).inDays + 1}',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.event_note_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('ยังไม่มีแผนเที่ยว', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('เพิ่มกิจกรรมรายวัน เช่น เดินทาง, ร้านอาหาร, ที่เที่ยว', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onAddPlan,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('เพิ่มกิจกรรม'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Group items by date
    final grouped = <DateTime, List<PlanItem>>{};
    for (final item in trip.planItems) {
      final key = DateTime(item.date.year, item.date.month, item.date.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final sortedDates = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          title: 'ตารางเที่ยวรายวัน',
          subtitle: 'Day 1 - Day ${trip.endDate.difference(trip.startDate).inDays + 1}',
        ),
        const SizedBox(height: 12),
        for (final date in sortedDates) ...[
          _DayHeader(date: date, tripStart: trip.startDate),
          const SizedBox(height: 8),
          for (final item in grouped[date]!..sort((a, b) => a.time.compareTo(b.time)))
            _PlanItemCard(item: item, onToggle: onTogglePlanItem),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onAddPlan,
          icon: const Icon(Icons.add_rounded),
          label: const Text('เพิ่มกิจกรรม'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }

  List<DateTime> _generateDays(Trip trip) {
    final days = <DateTime>[];
    var current = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final end = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.tripStart});

  final DateTime date;
  final DateTime tripStart;

  @override
  Widget build(BuildContext context) {
    final dayNumber = date.difference(DateTime(tripStart.year, tripStart.month, tripStart.day)).inDays + 1;
    const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Day $dayNumber • ${date.day} ${months[date.month - 1]}',
        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF8B5A00)),
      ),
    );
  }
}

class _PlanItemCard extends StatelessWidget {
  const _PlanItemCard({required this.item, required this.onToggle});

  final PlanItem item;
  final void Function(PlanItem item, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon(item.category);
    final categoryColor = _getCategoryColor(item.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: categoryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.time, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.category, style: TextStyle(fontSize: 11, color: categoryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.note!, style: const TextStyle(color: Color(0xFF75685E), fontSize: 13)),
                  ],
                  if (item.estimatedCost > 0) ...[
                    const SizedBox(height: 6),
                    Text('≈ ${item.estimatedCost.toStringAsFixed(0)} บาท', style: const TextStyle(color: Color(0xFFFF8A00), fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: item.isDone,
              onChanged: (val) => onToggle(item, val ?? false),
              activeColor: const Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'เดินทาง': return Icons.flight_rounded;
      case 'อาหาร': return Icons.restaurant_rounded;
      case 'ที่เที่ยว': return Icons.place_rounded;
      case 'ที่พัก': return Icons.hotel_rounded;
      default: return Icons.event_note_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'เดินทาง': return const Color(0xFF2196F3);
      case 'อาหาร': return const Color(0xFFFF7043);
      case 'ที่เที่ยว': return const Color(0xFF4CAF50);
      case 'ที่พัก': return const Color(0xFF9C27B0);
      default: return const Color(0xFFFF8A00);
    }
  }
}

class _PlacesTab extends StatelessWidget {
  const _PlacesTab({
    required this.trip,
    required this.onAddPlace,
    required this.onTogglePlace,
  });

  final Trip trip;
  final VoidCallback onAddPlace;
  final void Function(Place place, bool value) onTogglePlace;

  @override
  Widget build(BuildContext context) {
    if (trip.places.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'สถานที่ที่อยากไป', subtitle: 'Saved Places สำหรับทริปนี้'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.place_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('ยังไม่มีสถานที่บันทึก', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('เพิ่มสถานที่ที่อยากไป (ที่เที่ยว, ร้านอาหาร, คาเฟ่, โรงแรม...)', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onAddPlace,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('เพิ่มสถานที่'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'สถานที่ที่อยากไป', subtitle: 'Saved Places สำหรับทริปนี้'),
        const SizedBox(height: 12),
        for (final place in trip.places) _PlaceCard(place: place, onToggle: onTogglePlace),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onAddPlace,
          icon: const Icon(Icons.add_location_alt_rounded),
          label: const Text('เพิ่มสถานที่'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onToggle});

  final Place place;
  final void Function(Place place, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final catIcon = _getPlaceIcon(place.category);
    final catColor = _getPlaceColor(place.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(catIcon, color: catColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  if (place.address != null && place.address!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(place.address!, style: const TextStyle(color: Color(0xFF75685E), fontSize: 13)),
                  ],
                  if (place.note != null && place.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(place.note!, style: const TextStyle(fontSize: 13, color: Color(0xFF75685E))),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(place.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: catColor)),
                  ),
                  if (place.mapsUrl != null && place.mapsUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => openMapsUrl(place.mapsUrl!),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('เปิดแผนที่'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: place.isVisited,
              onChanged: (val) => onToggle(place, val ?? false),
              activeColor: const Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlaceIcon(String cat) {
    switch (cat) {
      case 'ที่เที่ยว': return Icons.landscape_rounded;
      case 'ร้านอาหาร': return Icons.restaurant_rounded;
      case 'คาเฟ่': return Icons.local_cafe_rounded;
      case 'โรงแรม': return Icons.hotel_rounded;
      case 'จุดถ่ายรูป': return Icons.camera_alt_rounded;
      case 'การเดินทาง': return Icons.directions_bus_rounded;
      default: return Icons.place_rounded;
    }
  }

  Color _getPlaceColor(String cat) {
    switch (cat) {
      case 'ที่เที่ยว': return const Color(0xFF4CAF50);
      case 'ร้านอาหาร': return const Color(0xFFFF7043);
      case 'คาเฟ่': return const Color(0xFF795548);
      case 'โรงแรม': return const Color(0xFF9C27B0);
      case 'จุดถ่ายรูป': return const Color(0xFF2196F3);
      case 'การเดินทาง': return const Color(0xFF00BCD4);
      default: return const Color(0xFFFF8A00);
    }
  }
}

class _BudgetTab extends StatelessWidget {
  const _BudgetTab({required this.trip, required this.onAddExpense});

  final Trip trip;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    // Calculate real spent from expenses
    final realSpent = trip.expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final remaining = trip.budget - realSpent;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'งบประมาณทริป', subtitle: 'ติดตามรายจ่ายจริง'),
        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('งบทั้งหมด', style: TextStyle(color: Color(0xFF75685E))),
                  Text('${trip.budget.toStringAsFixed(0)} ฿', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ใช้ไปแล้ว', style: TextStyle(color: Color(0xFF75685E))),
                  Text('${realSpent.toStringAsFixed(0)} ฿', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('คงเหลือ', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('${remaining.toStringAsFixed(0)} ฿', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: remaining >= 0 ? const Color(0xFF4CAF50) : Colors.red)),
                ],
              ),
            ],
          ),
        ),

        // Expenses List
        if (trip.expenses.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('รายการใช้จ่าย', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final exp in (trip.expenses..sort((a, b) => b.date.compareTo(a.date))))
            _ExpenseCard(expense: exp),
        ],

        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAddExpense,
          icon: const Icon(Icons.add_card_rounded),
          label: const Text('เพิ่มค่าใช้จ่าย'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE0B8),
          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF8A00)),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${expense.category} • ${_formatDate(expense.date)}'),
        trailing: Text('-${expense.amount.toStringAsFixed(0)} ฿', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent, fontSize: 15)),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year + 543}';
  }
}

class _ChecklistTab extends StatelessWidget {
  const _ChecklistTab({
    required this.trip,
    required this.onAddItem,
    required this.onToggle,
  });

  final Trip trip;
  final VoidCallback onAddItem;
  final void Function(ChecklistItem item, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'เช็คลิสต์ก่อนเดินทาง', subtitle: 'ติ๊กเมื่อเตรียมเสร็จ'),
        const SizedBox(height: 12),

        if (trip.checklistItems.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.checklist_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('ยังไม่มีรายการ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('เพิ่มรายการที่ต้องเตรียม เช่น บัตรประชาชน, ที่ชาร์จ, ยา', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                ],
              ),
            ),
          ),

        for (final item in trip.checklistItems)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.isChecked,
              onChanged: (val) => onToggle(item, val ?? false),
              activeColor: const Color(0xFF4CAF50),
              controlAffinity: ListTileControlAffinity.trailing, // checkbox อยู่ขวา
            ),
          ),

        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onAddItem,
          icon: const Icon(Icons.add_rounded),
          label: const Text('เพิ่มรายการ'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

class _MemoriesTab extends StatelessWidget {
  const _MemoriesTab({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'บันทึกความทรงจำ', subtitle: 'รูปภาพ + โน้ต + คะแนน'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.photo_camera_back_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('ยังไม่มี Memory', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('หลังเที่ยวเสร็จ สามารถเพิ่มรูป + เขียนความประทับใจ + ให้คะแนนได้ที่นี่', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ฟีเจอร์ Memories จะพัฒนาในขั้นตอนถัดไป')),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('เพิ่ม Memory'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Color(0xFF75685E))),
      ],
    );
  }
}

// Models have been moved to lib/models/
// See: models/models.dart (Trip, PlanItem, Place, ChecklistItem, Expense)
