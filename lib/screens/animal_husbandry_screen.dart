import 'package:flutter/material.dart';
import '../data/app_state.dart';

class _AnimalCare {
  final IconData icon;
  final String titleGu;
  final String titleEn;
  final String descGu;
  final String descEn;
  const _AnimalCare({
    required this.icon,
    required this.titleGu,
    required this.titleEn,
    required this.descGu,
    required this.descEn,
  });
}

const List<_AnimalCare> _care = [
  _AnimalCare(
    icon: Icons.local_drink,
    titleGu: 'ડેરી ફાર્મિંગ સબસિડી',
    titleEn: 'Dairy Farming Subsidy',
    descGu: 'દૂધાળા પશુ ખરીદી પર 25-33% સબસિડી ઉપલબ્ધ',
    descEn: '25-33% subsidy available on dairy animal purchase',
  ),
  _AnimalCare(
    icon: Icons.vaccines,
    titleGu: 'રસીકરણ સમયપત્રક',
    titleEn: 'Vaccination Schedule',
    descGu: 'FMD અને ગળસૂંઢો રસી વર્ષમાં બે વાર આપો',
    descEn: 'Give FMD and HS vaccines twice a year',
  ),
  _AnimalCare(
    icon: Icons.egg,
    titleGu: 'મરઘાં ઉછેર સહાય',
    titleEn: 'Poultry Farming Support',
    descGu: 'નાના પાયે મરઘાં ફાર્મ માટે લોન અને તાલીમ',
    descEn: 'Loans and training for small-scale poultry farms',
  ),
  _AnimalCare(
    icon: Icons.pets,
    titleGu: 'બકરી ઉછેર યોજના',
    titleEn: 'Goat Rearing Scheme',
    descGu: 'બકરી એકમ સ્થાપવા માટે 50% સુધી સબસિડી',
    descEn: 'Up to 50% subsidy for setting up a goat unit',
  ),
];

class AnimalHusbandryScreen extends StatelessWidget {
  const AnimalHusbandryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('animalHusbandry'))),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _care.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = _care[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor:
                    const Color(0xFF6A1B9A).withOpacity(0.12),
                    child: Icon(c.icon, color: const Color(0xFF6A1B9A)),
                  ),
                  title: Text(
                    app.lang == 'gu' ? c.titleGu : c.titleEn,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      app.lang == 'gu' ? c.descGu : c.descEn,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(app.t('viewDetails')),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      app.t('viewDetails'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}