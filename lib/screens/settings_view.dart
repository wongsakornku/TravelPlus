import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.tripCount,
    required this.placeCount,
    required this.checklistCount,
    required this.onClearData,
  });

  final int tripCount;
  final int placeCount;
  final int checklistCount;
  final VoidCallback onClearData;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('ตั้งค่า', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ข้อมูลแอพ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                _InfoRow(label: 'ทริปทั้งหมด', value: '$tripCount'),
                _InfoRow(label: 'สถานที่ที่บันทึก', value: '$placeCount'),
                _InfoRow(label: 'รายการเช็คลิสต์', value: '$checklistCount'),
                const Divider(height: 24),
                const Text('ข้อมูลทั้งหมดถูกเก็บไว้ในเครื่องเท่านั้น (MVP)', style: TextStyle(color: Color(0xFF75685E), fontSize: 13)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text('ล้างข้อมูลทั้งหมด', style: TextStyle(color: Colors.red)),
            subtitle: const Text('ลบทริป สถานที่ และเช็คลิสต์ทั้งหมด (สำหรับทดสอบ)'),
            onTap: onClearData,
          ),
        ),

        const SizedBox(height: 16),
        const Text('TravelPlus v1.0.0 • MVP', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E), fontSize: 12)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF75685E))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}