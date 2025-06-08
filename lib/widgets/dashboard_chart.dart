import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final String period; // daily, weekly, monthly

  const DashboardChart({super.key, required this.period});

  // Contoh data dummy berdasarkan periode
  List<BarChartGroupData> getBarGroups() {
    switch (period) {
      case 'daily':
        return List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (index + 1) * 30.0,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        });
      case 'weekly':
        return List.generate(4, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (index + 1) * 60.0,
                color: Colors.green,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        });
      case 'monthly':
        return List.generate(12, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (index + 1) * 20.0,
                color: Colors.orange,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        });
      default:
        return [];
    }
  }

  // Label sumbu X berdasarkan periode
  Widget getBottomTitle(double value, TitleMeta meta) {
  if (period == 'daily') {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Text(
      days[value.toInt() % days.length],
      style: const TextStyle(fontSize: 10),
    );
  } else if (period == 'weekly') {
    return Text(
      'Minggu ${value.toInt() + 1}',
      style: const TextStyle(fontSize: 10),
    );
  } else if (period == 'monthly') {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return Text(
      months[value.toInt() % months.length],
      style: const TextStyle(fontSize: 10),
    );
  } else {
    return const Text('');
  }
}
  // Widget untuk menampilkan grafik batang
  

  @override
  Widget build(BuildContext context) {
    final barGroups = getBarGroups();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 300,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitle,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
