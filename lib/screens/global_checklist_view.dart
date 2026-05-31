import 'package:flutter/material.dart';
import '../models/checklist_item.dart';

class GlobalChecklistView extends StatelessWidget {
  const GlobalChecklistView({
    super.key,
    required this.items,
    required this.onAddItem,
  });

  final List<ChecklistItem> items;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.checklist_rounded, size: 52, color: Color(0xFFFF8A00)),
                  const SizedBox(height: 16),
                  const Text('Checklist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('รายการเตรียมตัวก่อนออกเดินทาง\n(ใช้ได้กับทุกทริป)', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                  const SizedBox(height: 20),
                  FilledButton.icon(onPressed: onAddItem, icon: const Icon(Icons.add_rounded), label: const Text('เพิ่มรายการ')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        FilledButton.icon(onPressed: onAddItem, icon: const Icon(Icons.add_rounded), label: const Text('เพิ่มรายการใหม่')),
        const SizedBox(height: 12),
        for (final item in items)
          Card(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.isChecked,
              onChanged: (val) => item.isChecked = val ?? false,
              activeColor: const Color(0xFF4CAF50),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ),
      ],
    );
  }
}