import 'package:flutter/material.dart';
import '../data/app_state.dart';
import 'market_prices_screen.dart';
import 'ai_assistant_screen.dart';
import 'equipment_screen.dart';
import 'govt_schemes_screen.dart';
import 'animal_husbandry_screen.dart';
import 'expense_profit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(app.t('appName')),
            actions: [
              _LangSwitchButton(app: app),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Weather summary card ---
              Card(
                color: const Color(0xFF2E7D32),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_cloudy,
                          color: Colors.white, size: 42),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.t('weather'),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            const Text('32°C · Bhavnagar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              app.t('rainMsg'),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Feature grid ---
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _FeatureCard(
                    icon: Icons.storefront,
                    label: app.t('marketPrices'),
                    color: const Color(0xFFF9A825),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MarketPricesScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.smart_toy,
                    label: app.t('cropAdvisory'),
                    color: const Color(0xFF2E7D32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AiAssistantScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.agriculture,
                    label: app.t('equipment'),
                    color: const Color(0xFF6D4C41),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EquipmentScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.account_balance,
                    label: app.t('govtSchemes'),
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GovtSchemesScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.pets,
                    label: app.t('animalHusbandry'),
                    color: const Color(0xFF6A1B9A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnimalHusbandryScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.calculate,
                    label: app.t('expenseProfit'),
                    color: const Color(0xFFC62828),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExpenseProfitScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LangSwitchButton extends StatelessWidget {
  final AppState app;
  const _LangSwitchButton({required this.app});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: app.toggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(app.lang == 'gu' ? '🇮🇳' : '🇬🇧'),
            const SizedBox(width: 6),
            Text(
              app.lang == 'gu' ? 'ગુજરાતી' : 'English',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}