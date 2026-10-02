import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';

class _CropRate {
  final String nameGu;
  final String nameEn;
  final String market;
  final int min;
  final int max;
  final int avg;
  final double changePercent;
  final String updatedAt;

  const _CropRate({
    required this.nameGu,
    required this.nameEn,
    required this.market,
    required this.min,
    required this.max,
    required this.avg,
    required this.changePercent,
    this.updatedAt = '8:00 AM',
  });

  factory _CropRate.fromFirestore(Map<String, dynamic> data) {
    return _CropRate(
      nameGu: data['nameGu'] ?? '',
      nameEn: data['nameEn'] ?? '',
      market: data['market'] ?? '',
      min: (data['min'] as num?)?.toInt() ?? 0,
      max: (data['max'] as num?)?.toInt() ?? 0,
      avg: (data['avg'] as num?)?.toInt() ?? 0,
      changePercent: (data['changePercent'] as num?)?.toDouble() ?? 0.0,
      updatedAt: data['updatedAt'] ?? '8:00 AM',
    );
  }
}

const List<_CropRate> _defaultRates = [
  _CropRate(
    nameGu: 'કપાસ',
    nameEn: 'Cotton',
    market: 'Bhavnagar Yard',
    min: 1450,
    max: 1620,
    avg: 1540,
    changePercent: 1.8,
  ),
  _CropRate(
    nameGu: 'મગફળી',
    nameEn: 'Groundnut',
    market: 'Rajkot Yard',
    min: 1180,
    max: 1340,
    avg: 1260,
    changePercent: -0.9,
  ),
  _CropRate(
    nameGu: 'ઘઉં',
    nameEn: 'Wheat',
    market: 'Bhavnagar Yard',
    min: 480,
    max: 540,
    avg: 512,
    changePercent: 0.4,
  ),
  _CropRate(
    nameGu: 'બાજરી',
    nameEn: 'Bajra',
    market: 'Amreli Yard',
    min: 410,
    max: 460,
    avg: 435,
    changePercent: 2.1,
  ),
  _CropRate(
    nameGu: 'ડુંગળી',
    nameEn: 'Onion',
    market: 'Rajkot Yard',
    min: 260,
    max: 340,
    avg: 300,
    changePercent: -3.2,
  ),
];

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('marketPrices'))),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService().getMarketPricesStream(),
            builder: (context, snapshot) {
              List<_CropRate> rates = [];

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                rates = snapshot.data!.docs
                    .map((doc) => _CropRate.fromFirestore(doc.data()))
                    .toList();
              } else {
                rates = _defaultRates;
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  rates.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final r = rates[i];
                  final isUp = r.changePercent >= 0;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  app.lang == 'gu' ? r.nameGu : r.nameEn,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isUp ? Colors.green : Colors.red)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUp
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 14,
                                      color: isUp ? Colors.green : Colors.red,
                                    ),
                                    Text(
                                      ' ${r.changePercent.abs().toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color:
                                            isUp ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${app.t('market')}: ${r.market}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _priceStat(app.t('min'), r.min),
                              _priceStat(app.t('max'), r.max),
                              _priceStat(app.t('avg'), r.avg, bold: true),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${app.t('lastUpdated')}: ${app.t('today')}, ${r.updatedAt}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
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

  Widget _priceStat(String label, int value, {bool bold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            '₹$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: bold ? const Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
