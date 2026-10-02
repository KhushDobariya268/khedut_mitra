import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';
import 'scheme_application_screen.dart';

class _Scheme {
  final IconData icon;
  final String nameGu;
  final String nameEn;
  final String benefitGu;
  final String benefitEn;
  final String eligGu;
  final String eligEn;

  const _Scheme({
    required this.icon,
    required this.nameGu,
    required this.nameEn,
    required this.benefitGu,
    required this.benefitEn,
    required this.eligGu,
    required this.eligEn,
  });

  factory _Scheme.fromFirestore(Map<String, dynamic> data) {
    int code = (data['iconCode'] as num?)?.toInt() ?? 0xe1f5;
    return _Scheme(
      icon: IconData(code, fontFamily: 'MaterialIcons'),
      nameGu: data['nameGu'] ?? '',
      nameEn: data['nameEn'] ?? '',
      benefitGu: data['benefitGu'] ?? '',
      benefitEn: data['benefitEn'] ?? '',
      eligGu: data['eligGu'] ?? '',
      eligEn: data['eligEn'] ?? '',
    );
  }
}

const List<_Scheme> _defaultSchemes = [
  _Scheme(
    icon: Icons.currency_rupee,
    nameGu: 'પ્રધાનમંત્રી કિસાન સન્માન નિધિ',
    nameEn: 'PM-KISAN',
    benefitGu: 'વાર્ષિક ₹6,000 ત્રણ હપ્તામાં ખાતામાં જમા',
    benefitEn: '₹6,000/year credited in 3 installments',
    eligGu: 'તમામ ખેડૂત પરિવારો (નાની/સીમાંત જમીનધારકો સહિત)',
    eligEn: 'All landholding farmer families',
  ),
  _Scheme(
    icon: Icons.shield,
    nameGu: 'પ્રધાનમંત્રી ફસલ વીમા યોજના',
    nameEn: 'Fasal Bima Yojana',
    benefitGu: 'કુદરતી આપત્તિથી પાક નુકસાનનું વીમા કવચ',
    benefitEn: 'Crop insurance against natural calamities',
    eligGu: 'લોન ધારક અને બિન-લોન ધારક ખેડૂતો',
    eligEn: 'Loanee and non-loanee farmers',
  ),
  _Scheme(
    icon: Icons.science,
    nameGu: 'સોઈલ હેલ્થ કાર્ડ યોજના',
    nameEn: 'Soil Health Card Scheme',
    benefitGu: 'મફત જમીન પરીક્ષણ અને ખાતર સલાહ',
    benefitEn: 'Free soil testing and fertilizer advice',
    eligGu: 'તમામ ખેડૂતો',
    eligEn: 'All farmers',
  ),
  _Scheme(
    icon: Icons.credit_card,
    nameGu: 'કિસાન ક્રેડિટ કાર્ડ',
    nameEn: 'Kisan Credit Card',
    benefitGu: 'ઓછા વ્યાજે ટૂંકા ગાળાની ખેતી લોન',
    benefitEn: 'Low-interest short-term farm credit',
    eligGu: 'જમીન ધરાવતા ખેડૂતો, ભાડૂત ખેડૂતો',
    eligEn: 'Landowning and tenant farmers',
  ),
  _Scheme(
    icon: Icons.water_drop,
    nameGu: 'ડ્રિપ ઇરિગેશન સબસિડી',
    nameEn: 'Drip Irrigation Subsidy',
    benefitGu: 'ડ્રિપ સિસ્ટમ પર 50-80% સબસિડી',
    benefitEn: '50-80% subsidy on drip irrigation systems',
    eligGu: 'નાના અને સીમાંત ખેડૂતો',
    eligEn: 'Small and marginal farmers',
  ),
];

class GovtSchemesScreen extends StatelessWidget {
  const GovtSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('govtSchemes'))),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService().getGovtSchemesStream(),
            builder: (context, snapshot) {
              List<_Scheme> schemes = [];

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                schemes = snapshot.data!.docs
                    .map((doc) => _Scheme.fromFirestore(doc.data()))
                    .toList();
              } else {
                schemes = _defaultSchemes;
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  schemes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: schemes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = schemes[i];
                  final schemeTitle = app.lang == 'gu' ? s.nameGu : s.nameEn;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    const Color(0xFF1565C0).withOpacity(0.12),
                                child: Icon(s.icon,
                                    color: const Color(0xFF1565C0), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  schemeTitle,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${app.t('benefit')}: ${app.lang == 'gu' ? s.benefitGu : s.benefitEn}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${app.t('eligibility')}: ${app.lang == 'gu' ? s.eligGu : s.eligEn}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SchemeApplicationScreen(
                                      schemeName: schemeTitle,
                                    ),
                                  ),
                                );
                              },
                              child: Text(app.t('applyNow')),
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
