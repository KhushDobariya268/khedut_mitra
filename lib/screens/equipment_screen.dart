import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';

class _Equipment {
  final IconData icon;
  final String nameGu;
  final String nameEn;
  final String brand;
  final String model;
  final int price;
  final int emi;

  const _Equipment({
    required this.icon,
    required this.nameGu,
    required this.nameEn,
    required this.brand,
    required this.model,
    required this.price,
    required this.emi,
  });

  factory _Equipment.fromFirestore(Map<String, dynamic> data) {
    return _Equipment(
      icon: Icons.agriculture,
      nameGu: data['nameGu'] ?? '',
      nameEn: data['nameEn'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      emi: (data['emi'] as num?)?.toInt() ?? 0,
    );
  }
}

const List<_Equipment> _defaultItems = [
  _Equipment(
    icon: Icons.agriculture,
    nameGu: 'ટ્રેક્ટર',
    nameEn: 'Tractor',
    brand: 'Mahindra',
    model: '575 DI',
    price: 725000,
    emi: 12500,
  ),
  _Equipment(
    icon: Icons.settings,
    nameGu: 'રોટાવેટર',
    nameEn: 'Rotavator',
    brand: 'Shaktiman',
    model: 'SRT-6',
    price: 68000,
    emi: 2200,
  ),
  _Equipment(
    icon: Icons.water_drop,
    nameGu: 'સ્પ્રેયર',
    nameEn: 'Sprayer',
    brand: 'Kisankraft',
    model: 'KK-16E',
    price: 4500,
    emi: 0,
  ),
  _Equipment(
    icon: Icons.grain,
    nameGu: 'ડ્રિપ ઇરિગેશન',
    nameEn: 'Drip Irrigation',
    brand: 'Jain Irrigation',
    model: 'J-Turbo',
    price: 32000,
    emi: 1500,
  ),
  _Equipment(
    icon: Icons.precision_manufacturing,
    nameGu: 'હાર્વેસ્ટર',
    nameEn: 'Harvester',
    brand: 'John Deere',
    model: 'W70',
    price: 1850000,
    emi: 28000,
  ),
  _Equipment(
    icon: Icons.opacity,
    nameGu: 'વોટર પંપ',
    nameEn: 'Water Pump',
    brand: 'Kirloskar',
    model: 'KDS-134',
    price: 15500,
    emi: 800,
  ),
];

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('equipment'))),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService().getEquipmentStream(),
            builder: (context, snapshot) {
              List<_Equipment> items = [];

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                items = snapshot.data!.docs
                    .map((doc) => _Equipment.fromFirestore(doc.data()))
                    .toList();
              } else {
                items = _defaultItems;
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final e = items[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                const Color(0xFF6D4C41).withOpacity(0.15),
                            child: Icon(e.icon,
                                color: const Color(0xFF6D4C41), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.lang == 'gu' ? e.nameGu : e.nameEn,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    '${app.t('brand')}: ${e.brand} · ${app.t('model')}: ${e.model}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(app.t('approxPrice'),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                          Text('₹${e.price}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E7D32))),
                                        ],
                                      ),
                                    ),
                                    if (e.emi > 0)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(app.t('emiEstimate'),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey)),
                                            Text(
                                                '₹${e.emi}${app.t('perMonth')}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(app.lang == 'gu'
                                              ? 'ડીલરનો સંપર્ક નંબર: 98765-43210'
                                              : 'Dealer contact: 98765-43210'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.call, size: 16),
                                    label: Text(app.t('contactDealer')),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2E7D32),
                                      side: const BorderSide(
                                          color: Color(0xFF2E7D32)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
