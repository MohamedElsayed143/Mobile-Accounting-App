import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SummaryChartsWidget extends StatelessWidget {
  final double sales;
  final double purchases;

  const SummaryChartsWidget({
    super.key,
    required this.sales,
    required this.purchases,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كانت القيم صفر، نعرض شريحة افتراضية رمادية
    final bool isEmpty = sales == 0 && purchases == 0;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50, // مساحة الفراغ في المنتصف
        startDegreeOffset: -90,
        sections: isEmpty
            ? [PieChartSectionData(color: Colors.grey[300], value: 1, radius: 100, title: 'لا بيانات')]
            : _buildSections(),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    // زيادة الـ radius هنا هو ما يكبر حجم الدائرة نفسها
    const double chartRadius = 110.0;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: sales,
        title: 'مبيعات',
        radius: chartRadius,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.redAccent,
        value: purchases,
        title: 'مشتريات',
        radius: chartRadius,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
} // تأكدي من وجود هذا القوس النهائي لإصلاح خطأ الصورة الأخيرة