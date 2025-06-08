import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';

class DashboardChart extends StatelessWidget {
  final String period; // 'daily', 'weekly', 'monthly'
  final String? type;  // 'telur', 'ayam', 'pakan', 'kesehatan'

  const DashboardChart({super.key, required this.period, this.type});

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];
    final chartType = type ?? 'telur';

    // Ambil data dari DataService
    List<Map<String, dynamic>> data;
    if (chartType == 'telur') {
      data = dataService.dataTelur;
    } else if (chartType == 'ayam') {
      data = dataService.dataAyam;
    } else if (chartType == 'pakan') {
      data = dataService.dataPakan;
    } else if (chartType == 'kesehatan') {
      data = dataService.dataKesehatan;
    } else {
      data = [];
    }

    // Pengelompokan data berdasarkan periode
    if (period == 'daily') {
      labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      for (int i = 0; i < labels.length; i++) {
        final hariData = data.where((d) => d['hari'] == i).toList();
        if (chartType == 'telur') {
          final masuk = hariData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = hariData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'ayam') {
          final masuk = hariData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final mati = hariData.fold(0.0, (sum, d) => sum + ((d['mati'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: mati, color: Colors.red),
            ]),
          );
        } else if (chartType == 'pakan') {
          final masuk = hariData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = hariData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.brown),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'kesehatan') {
          final sakit = hariData.fold(0.0, (sum, d) => sum + ((d['sakit'] ?? 0) as num).toDouble());
          final flu = hariData.fold(0.0, (sum, d) => sum + ((d['flu'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: sakit, color: Colors.red),
              BarChartRodData(toY: flu, color: Colors.blue),
            ]),
          );
        }
      }
    } else if (period == 'weekly') {
      labels = ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'];
      for (int i = 0; i < labels.length; i++) {
        final mingguData = data.where((d) => d['minggu'] == i).toList();
        if (chartType == 'telur') {
          final masuk = mingguData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = mingguData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'ayam') {
          final masuk = mingguData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final mati = mingguData.fold(0.0, (sum, d) => sum + ((d['mati'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: mati, color: Colors.red),
            ]),
          );
        } else if (chartType == 'pakan') {
          final masuk = mingguData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = mingguData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.brown),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'kesehatan') {
          final sakit = mingguData.fold(0.0, (sum, d) => sum + ((d['sakit'] ?? 0) as num).toDouble());
          final flu = mingguData.fold(0.0, (sum, d) => sum + ((d['flu'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: sakit, color: Colors.red),
              BarChartRodData(toY: flu, color: Colors.blue),
            ]),
          );
        }
      }
    } else if (period == 'monthly') {
      labels = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      for (int i = 0; i < labels.length; i++) {
        final bulanData = data.where((d) => d['bulan'] == i).toList();
        if (chartType == 'telur') {
          final masuk = bulanData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = bulanData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'ayam') {
          final masuk = bulanData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final mati = bulanData.fold(0.0, (sum, d) => sum + ((d['mati'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.green),
              BarChartRodData(toY: mati, color: Colors.red),
            ]),
          );
        } else if (chartType == 'pakan') {
          final masuk = bulanData.fold(0.0, (sum, d) => sum + ((d['masuk'] ?? 0) as num).toDouble());
          final keluar = bulanData.fold(0.0, (sum, d) => sum + ((d['keluar'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: masuk, color: Colors.brown),
              BarChartRodData(toY: keluar, color: Colors.orange),
            ]),
          );
        } else if (chartType == 'kesehatan') {
          final sakit = bulanData.fold(0.0, (sum, d) => sum + ((d['sakit'] ?? 0) as num).toDouble());
          final flu = bulanData.fold(0.0, (sum, d) => sum + ((d['flu'] ?? 0) as num).toDouble());
          barGroups.add(
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: sakit, color: Colors.red),
              BarChartRodData(toY: flu, color: Colors.blue),
            ]),
          );
        }
      }
    }

    // Legend dinamis
    List<Widget> legend;
    if (chartType == 'telur') {
      legend = [
        _legendItem('Masuk', Colors.green),
        _legendItem('Keluar', Colors.orange),
      ];
    } else if (chartType == 'ayam') {
      legend = [
        _legendItem('Masuk', Colors.green),
        _legendItem('Mati', Colors.red),
      ];
    } else if (chartType == 'pakan') {
      legend = [
        _legendItem('Masuk', Colors.brown),
        _legendItem('Keluar', Colors.orange),
      ];
    } else if (chartType == 'kesehatan') {
      legend = [
        _legendItem('Sakit', Colors.red),
        _legendItem('Flu', Colors.blue),
      ];
    } else {
      legend = [];
    }

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: legend,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: _getMaxY(barGroups),
                barGroups: barGroups,
                groupsSpace: 18,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final barColor = rod.color ?? Colors.black;
                      return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        TextStyle(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _getYInterval(barGroups),
                      getTitlesWidget: (value, meta) {
                        if (_getYInterval(barGroups) >= 10) {
                          if (value % _getYInterval(barGroups) != 0) return const SizedBox.shrink();
                          return Text(value.toInt().toString());
                        }
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < labels.length) {
                          return Text(labels[value.toInt()], style: const TextStyle(fontSize: 12));
                        }
                        return const SizedBox.shrink();
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 16),
      ],
    );
  }

  double _getMaxY(List<BarChartGroupData> groups) {
    double maxY = 0;
    for (final group in groups) {
      for (final rod in group.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    return maxY + (maxY * 0.2);
  }

  double _getYInterval(List<BarChartGroupData> groups) {
    double maxY = _getMaxY(groups);
    if (maxY > 500) return 100;
    if (maxY > 200) return 50;
    if (maxY > 100) return 20;
    if (maxY > 50) return 10;
    if (maxY > 20) return 5;
    if (maxY > 10) return 2;
    return 1;
  }
}