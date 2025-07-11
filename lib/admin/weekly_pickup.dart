import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:RecycleHub/services/schedule_service.dart';

class WeeklyPickupChartPage extends StatelessWidget {
  final FirebaseWasteService _service = FirebaseWasteService();

  WeeklyPickupChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.fetchWeeklyPickups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                maxY: data.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b).toDouble() + 1,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles( 
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          return Text(days[value.toInt()]);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value % 1 == 0) {
                          return Text(value.toInt().toString()); 
                        }
                        return const SizedBox.shrink(); 
                      },
                      interval: 1,
                    ),
                  ),

                ),
                barGroups: data.map((e) {
                  return BarChartGroupData(
                    x: e['day'],
                    barRods: [
                      BarChartRodData(
                        toY: (e['count'] as int).toDouble(),
                        color: Colors.green,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
