import 'package:flutter/material.dart';

import '../core/utils/maps_utils.dart';
import '../models/place.dart';

class GlobalPlacesView extends StatelessWidget {
  const GlobalPlacesView({
    super.key,
    required this.places,
    required this.onAddPlace,
  });

  final List<Place> places;
  final VoidCallback onAddPlace;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place_rounded, size: 52, color: Color(0xFFFF8A00)),
                  const SizedBox(height: 16),
                  const Text('Saved Places', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('เก็บสถานที่ที่อยากไปก่อน\nแล้วค่อยนำไปใส่ในแผนเที่ยว', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF75685E))),
                  const SizedBox(height: 20),
                  FilledButton.icon(onPressed: onAddPlace, icon: const Icon(Icons.add_location_alt_rounded), label: const Text('เพิ่มสถานที่')),
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
        FilledButton.icon(onPressed: onAddPlace, icon: const Icon(Icons.add_location_alt_rounded), label: const Text('เพิ่มสถานที่ใหม่')),
        const SizedBox(height: 16),
        for (final p in places)
          _GlobalPlaceCard(place: p),
      ],
    );
  }
}

class _GlobalPlaceCard extends StatelessWidget {
  const _GlobalPlaceCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_rounded, color: Color(0xFFFF8A00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                Checkbox(
                  value: place.isVisited,
                  onChanged: (val) => place.isVisited = val ?? false,
                ),
              ],
            ),
            if (place.address != null && place.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(place.address!, style: const TextStyle(color: Color(0xFF75685E), fontSize: 13)),
            ],
            if (place.mapsUrl != null && place.mapsUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => openMapsUrl(place.mapsUrl!),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('เปิดแผนที่'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  foregroundColor: const Color(0xFF2196F3),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}