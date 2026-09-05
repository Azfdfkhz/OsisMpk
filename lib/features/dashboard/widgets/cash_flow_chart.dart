import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/dashboard_models.dart';

/// Grafik "Ringkasan Arus Kas" (pemasukan vs pengeluaran) memakai fl_chart,
/// menampilkan data dari view `v_cash_flow_daily`.
class CashFlowChart extends StatelessWidget {
  final List<CashFlowPoint> points;

  const CashFlowChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: Text('Belum ada data')));
    }

    final maxY = points
        .map((p) => p.pemasukan > p.pengeluaran ? p.pemasukan : p.pengeluaran)
        .reduce((a, b) => a > b ? a : b);
    // num.clamp() returns num, bukan double -- perlu di-cast eksplisit agar
    // bisa dipakai sebagai `double` pada horizontalInterval / interval di bawah.
    final interval = (maxY / 4).ceilToDouble().clamp(1, double.infinity).toDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  CurrencyFormatter.formatCompactJuta(value),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormatter.shortNoYear(points[idx].tanggal),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.navy,
              // Kedua garis (pemasukan & pengeluaran) tersentuh bersamaan pada
              // titik x yang sama, tapi kita hanya ingin SATU kotak tooltip
              // (sesuai desain) -- isi lengkap hanya pada spot pertama,
              // spot kedua dikembalikan `null` supaya tidak digambar.
              getTooltipItems: (spots) => spots.map((s) {
                if (s.barIndex != 0) return null;
                final idx = s.x.toInt();
                final point = points[idx];
                return LineTooltipItem(
                  '${DateFormatter.short(point.tanggal)}\n'
                  'Pemasukan: ${CurrencyFormatter.format(point.pemasukan)}\n'
                  'Pengeluaran: ${CurrencyFormatter.format(point.pengeluaran)}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            _line(
              points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.pemasukan)).toList(),
              AppColors.success,
            ),
            _line(
              points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.pengeluaran)).toList(),
              AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}

/// Legenda kecil "● Pemasukan  ● Pengeluaran" di atas grafik.
class CashFlowLegend extends StatelessWidget {
  const CashFlowLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendDot(color: AppColors.success, label: 'Pemasukan'),
        SizedBox(width: 16),
        _LegendDot(color: AppColors.danger, label: 'Pengeluaran'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
