import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyEarningsChart extends StatefulWidget {
  final String? riderId; // null for admin (all riders)
  final String? shopId;  // for vendor

  const DailyEarningsChart({Key? key, this.riderId, this.shopId}) : super(key: key);

  @override
  State<DailyEarningsChart> createState() => _DailyEarningsChartState();
}

class _DailyEarningsChartState extends State<DailyEarningsChart> {
  List<Map<String, dynamic>> _dailyData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('orders');
      
      if (widget.riderId != null) {
        query = query.where('riderId', isEqualTo: widget.riderId);
      }
      if (widget.shopId != null) {
        query = query.where('shopId', isEqualTo: widget.shopId);
      }
      
      // Only delivered orders
      query = query.where('status', isEqualTo: 'Delivered');

      final snapshot = await query.get();

      // Group by date (using 'updatedAt' or 'createdAt')
      Map<String, double> dailyTotals = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['updatedAt'] as Timestamp? ?? data['createdAt'] as Timestamp?;
        if (timestamp == null) continue;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // For rider: use riderAmount, for admin/vendor: use vendorAmount
        double amount;
        if (widget.riderId != null) {
          amount = (data['riderAmount'] ?? data['deliveryFee'] ?? 0).toDouble();
        } else {
          // Admin: revenue = vendorAmount (or subtotal)
          amount = (data['vendorAmount'] ?? data['subtotal'] ?? 0).toDouble();
        }
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
      }

      // Convert to list and sort by date (most recent first, but chart expects chronological)
      final sortedKeys = dailyTotals.keys.toList()..sort();
      _dailyData = sortedKeys.map((key) => {
        'date': key,
        'amount': dailyTotals[key]!,
      }).toList();

    } catch (e) {
      print('Error fetching daily earnings: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dailyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Find max amount for scaling – ensure double
    final maxAmount = _dailyData.fold(0.0, (max, item) => item['amount'] > max ? item['amount'] : max);
    final safeMax = maxAmount > 0 ? maxAmount * 1.2 : 100.0; // ✅ cast to double

    // Limit to last 7 days for readability (optional)
    final displayData = _dailyData.length > 7 ? _dailyData.sublist(_dailyData.length - 7) : _dailyData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Earnings (Last 7 days)'),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: safeMax, // ✅ now a double
              barGroups: displayData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item['amount'].toDouble(), // ✅ cast to double
                      color: Colors.teal,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < displayData.length) {
                        final date = displayData[index]['date'];
                        final day = date.split('-')[2];
                        return Text(day, style: const TextStyle(fontSize: 12));
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('Rs.${value.toInt()}', style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}