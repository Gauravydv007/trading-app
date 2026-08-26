import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bitcoin_chart_controller.dart';

class BitcoinChart extends StatelessWidget {
  const BitcoinChart({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _up = Color(0xFF00E676);
  static const _down = Color(0xFFFF1744);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BitcoinChartController());

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(c: c),
            Expanded(child: _ChartSection(c: c)),
            _TimeFilters(c: c),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.c});
  final BitcoinChartController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUp = c.isPriceUp.value;
      final accent = isUp ? BitcoinChart._up : BitcoinChart._down;
      final changeAbs = c.priceChange.value;
      final changePct = c.priceChangePercent.value;
      final sign = changeAbs >= 0 ? '+' : '';

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: BitcoinChart._surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CryptoIcon(crypto: c.selectedCrypto.value),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.selectedCrypto.value.name} Live Price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      '${c.selectedCrypto.value.symbol} / USDT',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _CryptoDropdown(c: c),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c.currentPrice.value == 0
                      ? '---'
                      : '\$${_fmt(c.currentPrice.value)}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 14),
                if (c.currentPrice.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _ChangeBadge(
                      accent: accent,
                      isUp: isUp,
                      label:
                          '$sign${changeAbs.toStringAsFixed(2)}  ($sign${changePct.toStringAsFixed(2)}%)',
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  static String _fmt(double price) => price
      .toStringAsFixed(2)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.c});
  final BitcoinChartController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final spots = c.chartSpots;
      final isUp = c.isPriceUp.value;
      final accent = isUp ? BitcoinChart._up : BitcoinChart._down;

      if (spots.length < 2) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                c.connectionStatus.value,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        );
      }

      final prices = spots.map((s) => s.y).toList();
      final minY = prices.reduce(min);
      final maxY = prices.reduce(max);
      final padding = (maxY - minY) == 0 ? 10.0 : (maxY - minY) * 0.15;

      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
        child: LineChart(
          _buildChartData(
            spots: spots.toList(),
            accent: accent,
            minY: minY - padding,
            maxY: maxY + padding,
          ),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  LineChartData _buildChartData({
    required List<FlSpot> spots,
    required Color accent,
    required double minY,
    required double maxY,
  }) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: Color(0xFF1E1E35), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 72,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                '\$${_shortPrice(value)}',
                style: const TextStyle(
                  color: Color(0xFF555577),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: accent,
          barWidth: 2.2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withValues(alpha: 0.25),
                accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1A1A2E),
          tooltipBorder: BorderSide(color: accent.withValues(alpha: 0.5)),
          tooltipRoundedRadius: 8,
          getTooltipItems: (spots) => spots
              .map(
                (s) => LineTooltipItem(
                  '\$${s.y.toStringAsFixed(2)}',
                  TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  static String _shortPrice(double v) {
    if (v >= 100000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 1000) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}

class _TimeFilters extends StatelessWidget {
  const _TimeFilters({required this.c});
  final BitcoinChartController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BitcoinChart._surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: BitcoinChartController.filters.map((f) {
            final selected = c.selectedFilter.value == f;
            return GestureDetector(
              onTap: () => c.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? BitcoinChart._up.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected
                        ? BitcoinChart._up
                        : const Color(0xFF2A2A45),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? BitcoinChart._up : Colors.white38,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CryptoIcon extends StatelessWidget {
  const _CryptoIcon({required this.crypto});
  final CryptoOption crypto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [crypto.color, crypto.color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        crypto.symbol.length <= 3
            ? crypto.symbol
            : crypto.symbol.substring(0, 3),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _CryptoDropdown extends StatelessWidget {
  const _CryptoDropdown({required this.c});
  final BitcoinChartController c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Obx(() {
        final crypto = c.selectedCrypto.value;
        final isLive = c.connectionStatus.value == 'Live';
        final color = isLive ? BitcoinChart._up : Colors.orange;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: crypto.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: crypto.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive)
                _PulseDot(color: color)
              else
                Icon(Icons.sync, color: color, size: 10),
              const SizedBox(width: 5),
              Text(
                crypto.symbol,
                style: TextStyle(
                  color: crypto.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, color: crypto.color, size: 18),
            ],
          ),
        );
      }),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161627),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CryptoPicker(c: c),
    );
  }
}

class _CryptoPicker extends StatelessWidget {
  const _CryptoPicker({required this.c});
  final BitcoinChartController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Crypto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: BitcoinChartController.popularCryptos.length,
            itemBuilder: (_, i) {
              final crypto = BitcoinChartController.popularCryptos[i];
              return Obx(() {
                final selected =
                    c.selectedCrypto.value.wsSymbol == crypto.wsSymbol;
                return GestureDetector(
                  onTap: () {
                    c.changeCrypto(crypto);
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? crypto.color.withValues(alpha: 0.15)
                          : const Color(0xFF0D0D1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? crypto.color.withValues(alpha: 0.6)
                            : const Color(0xFF2A2A45),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: crypto.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            crypto.symbol.length <= 3
                                ? crypto.symbol
                                : crypto.symbol.substring(0, 3),
                            style: TextStyle(
                              color: crypto.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crypto.symbol,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              crypto.name,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: crypto.color,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({
    required this.accent,
    required this.isUp,
    required this.label,
  });

  final Color accent;
  final bool isUp;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: accent,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
