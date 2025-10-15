import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/app_colors.dart';
import '../localization/localization_extensions.dart';
import '../utils/expression_evaluator.dart';

class MathGraphDisplay extends StatefulWidget {
  const MathGraphDisplay({
    super.key,
    required this.asciiMathExpression,
    this.minX = -10.0,
    this.maxX = 10.0,
    this.minY = -10.0,
    this.maxY = 10.0,
    this.pointCount = 100,
  });

  final String asciiMathExpression;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final int pointCount;

  /// 数式がグラフ化可能かどうかを判定
  static bool canGraphExpression(String asciiMathExpression) {
    try {
      // テスト用の値をいくつか試して、評価可能かチェック
      final testValues = [-5.0, 0.0, 5.0];
      int validCount = 0;
      
      for (final x in testValues) {
        final result = ExpressionEvaluator.evaluateExpression(asciiMathExpression, x);
        if (result != null && result.isFinite) {
          validCount++;
        }
      }
      
      // 3つのテスト値のうち2つ以上が有効な場合、グラフ化可能と判定
      return validCount >= 2;
    } catch (e) {
      return false;
    }
  }

  @override
  State<MathGraphDisplay> createState() => _MathGraphDisplayState();
}

class _MathGraphDisplayState extends State<MathGraphDisplay> {
  List<FlSpot>? _dataPoints;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateGraphData();
  }

  @override
  void didUpdateWidget(MathGraphDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asciiMathExpression != widget.asciiMathExpression ||
        oldWidget.minX != widget.minX ||
        oldWidget.maxX != widget.maxX ||
        oldWidget.minY != widget.minY ||
        oldWidget.maxY != widget.maxY ||
        oldWidget.pointCount != widget.pointCount) {
      _generateGraphData();
    }
  }

  void _generateGraphData() {
    final l10n = context.l10n;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataPoints = <FlSpot>[];
      final step = (widget.maxX - widget.minX) / widget.pointCount;
      int validPoints = 0;

      for (int i = 0; i <= widget.pointCount; i++) {
        final x = widget.minX + i * step;
        final y = ExpressionEvaluator.evaluateExpression(
          widget.asciiMathExpression,
          x,
        );

        if (y != null && y.isFinite && y >= widget.minY && y <= widget.maxY) {
          dataPoints.add(FlSpot(x, y));
          validPoints++;
        }
      }

      setState(() {
        _dataPoints = dataPoints;
        _isLoading = false;

        if (validPoints < 5) {
          _errorMessage = l10n.solutionGraphNotSupported;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = l10n.solutionGraphErrorMessage('$e');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.orange.shade400, size: 32),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_dataPoints == null || _dataPoints!.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: Text(context.l10n.solutionGraphNoDataMessage)),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: (widget.maxY - widget.minY) / 10,
              verticalInterval: (widget.maxX - widget.minX) / 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (widget.maxX - widget.minX) / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (widget.maxY - widget.minY) / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade400),
            ),
            minX: widget.minX,
            maxX: widget.maxX,
            minY: widget.minY,
            maxY: widget.maxY,
            lineBarsData: [
              LineChartBarData(
                spots: _dataPoints!,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
