import 'package:flutter/material.dart';
import 'dashboard_chart.dart';
import 'package:google_fonts/google_fonts.dart';


class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  // Filter periode untuk tiap kategori
  final Map<String, String> _selectedPeriod = {
    'ayam': 'monthly',
    'telur': 'monthly',
    'pakan': 'monthly',
    'kesehatan': 'monthly',
  };

  final Map<String, List<String>> _periodOptions = {
    'ayam': ['daily', 'weekly', 'monthly'],
    'telur': ['daily', 'weekly', 'monthly'],
    'pakan': ['daily', 'weekly', 'monthly'],
    'kesehatan': ['daily', 'weekly', 'monthly'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Statistik',
          style: GoogleFonts.poppins(
            color: Colors.white, // ⬅️ Warna teks putih
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _statistikSection(
            context,
            title: 'Statistik Ayam',
            icon: Icons.pets,
            type: 'ayam',
            summary: [
              _summaryBox('Total', '1200'),
              _summaryBox('Rata-rata', '40/hari'),
              _summaryBox('Naik', '+5%', color: Colors.green),
            ],
          ),
          const SizedBox(height: 28),
          _statistikSection(
            context,
            title: 'Statistik Telur',
            icon: Icons.egg,
            type: 'telur',
            summary: [
              _summaryBox('Total', '3000'),
              _summaryBox('Rata-rata', '100/hari'),
              _summaryBox('Turun', '-2%', color: Colors.red),
            ],
          ),
          const SizedBox(height: 28),
          _statistikSection(
            context,
            title: 'Statistik Pakan',
            icon: Icons.rice_bowl,
            type: 'pakan',
            summary: [
              _summaryBox('Total', '500kg'),
              _summaryBox('Rata-rata', '16kg/hari'),
              _summaryBox('Stabil', '0%', color: Colors.grey),
            ],
          ),
          const SizedBox(height: 28),
          _statistikSection(
            context,
            title: 'Statistik Kesehatan',
            icon: Icons.health_and_safety,
            type: 'kesehatan',
            summary: [
              _summaryBox('Kasus', '12'),
              _summaryBox('Rata-rata', '0.4/hari'),
              _summaryBox('Turun', '-1%', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statistikSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String type,
    required List<Widget> summary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title, icon, context),
        const SizedBox(height: 12),
        Row(children: summary),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DropdownButton<String>(
              value: _selectedPeriod[type],
              borderRadius: BorderRadius.circular(12),
              items: _periodOptions[type]!
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p == 'daily'
                              ? 'Harian'
                              : p == 'weekly'
                                  ? 'Mingguan'
                                  : 'Bulanan',
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPeriod[type] = val;
                  });
                }
              },
            ),
          ],
        ),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DashboardChart(period: _selectedPeriod[type]!, type: type),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.green[700], size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
        ),
      ],
    );
  }

  Widget _summaryBox(String label, String value, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
      color: ((color ?? Colors.green[50])!).withValues(alpha: (0.8 * 255)),
      borderRadius: BorderRadius.circular(8),
    ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color ?? Colors.green[900])),
        ],
      ),
    );
  }
}