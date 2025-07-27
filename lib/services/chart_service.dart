import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartService {
  // Sample data for onboarding charts
  static List<PieChartSectionData> getDonutChartSections() {
    return [
      PieChartSectionData(
        color: const Color(0xFF4285F4),
        value: 35,
        title: '35%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF34A853),
        value: 25,
        title: '25%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFFBBC05),
        value: 20,
        title: '20%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFEA4335),
        value: 20,
        title: '20%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  static List<BarChartGroupData> getBarChartData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 5,
            color: const Color(0xFF4285F4),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 7,
            color: const Color(0xFF34A853),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 4,
            color: const Color(0xFFFBBC05),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: 6,
            color: const Color(0xFFEA4335),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: 3,
            color: const Color(0xFF4285F4),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: 8,
            color: const Color(0xFF34A853),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 6,
        barRods: [
          BarChartRodData(
            toY: 5,
            color: const Color(0xFFFBBC05),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];
  }

  static Widget buildDonutChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: getDonutChartSections(),
          startDegreeOffset: -90,
        ),
      ),
    );
  }

  static Widget buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 24,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: getBarChartData(),
        ),
      ),
    );
  }

  static List<Widget> getCategoryLegends() {
    return [
      _buildLegend('Housing', const Color(0xFF4285F4)),
      const SizedBox(width: 8),
      _buildLegend('Food', const Color(0xFF34A853)),
      const SizedBox(width: 8),
      _buildLegend('Transport', const Color(0xFFFBBC05)),
      const SizedBox(width: 8),
      _buildLegend('Entertainment', const Color(0xFFEA4335)),
    ];
  }

  static Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
