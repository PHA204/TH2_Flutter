import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  int _selectedChartIndex = 0; // 0: Pie Chart, 1: Bar Chart

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // EMPTY STATE
        if (provider.expenseTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu thống kê',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thêm giao dịch để xem biểu đồ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              // TABS CHỌN LOẠI BIỂU ĐỒ
              _buildChartSelector(),
              
              const SizedBox(height: 16),
              
              // BIỂU ĐỒ
              if (_selectedChartIndex == 0)
                _buildPieChart(provider)
              else
                _buildBarChart(provider),
              
              const SizedBox(height: 24),
              
              // DANH SÁCH CHI TIẾT THEO CATEGORY
              _buildCategoryList(provider),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 1. TABS CHỌN LOẠI BIỂU ĐỒ
  // ============================================================
  Widget _buildChartSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PIE CHART TAB
          Expanded(
            child: _buildTab(
              index: 0,
              icon: Icons.pie_chart,
              label: 'Biểu đồ tròn',
            ),
          ),
          
          // BAR CHART TAB
          Expanded(
            child: _buildTab(
              index: 1,
              icon: Icons.bar_chart,
              label: 'Biểu đồ cột',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedChartIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedChartIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. PIE CHART (BIỂU ĐỒ TRÒN)
  // ============================================================
  Widget _buildPieChart(TransactionProvider provider) {
    final categoryData = provider.getCategoryData();
    
    if (categoryData.isEmpty) {
      return const SizedBox();
    }

    // Tính tổng
    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    
    // Tạo sections cho pie chart
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // TIÊU ĐỀ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chi tiêu theo danh mục',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                CurrencyFormatter.formatCompact(total),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // PIE CHART
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _createPieSections(categoryData, total),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // LEGEND (CHÚ THÍCH)
          _buildPieLegend(categoryData),
        ],
      ),
    );
  }

  // Tạo sections cho Pie Chart
  List<PieChartSectionData> _createPieSections(
    Map<String, double> categoryData,
    double total,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    int index = 0;
    return categoryData.entries.map((entry) {
      final category = Categories.getCategoryByName(
        entry.key,
        TransactionType.expense,
      );
      
      final percentage = (entry.value / total * 100);
      final color = category?.color ?? colors[index % colors.length];
      
      index++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: percentage > 10
            ? _buildBadge(category?.icon ?? Icons.help_outline, color)
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  // Badge icon cho Pie Chart
  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  // Chú thích cho Pie Chart
  Widget _buildPieLegend(Map<String, double> categoryData) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: categoryData.entries.map((entry) {
        final category = Categories.getCategoryByName(
          entry.key,
          TransactionType.expense,
        );
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: category?.color ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // 3. BAR CHART (BIỂU ĐỒ CỘT)
  // ============================================================
  Widget _buildBarChart(TransactionProvider provider) {
    final dailyData = provider.getDailyExpenses(days: 7);
    
    if (dailyData.isEmpty) {
      return const SizedBox();
    }

    // Tìm giá trị max để scale
    final maxY = dailyData.values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIÊU ĐỀ
          const Text(
            'Chi tiêu 7 ngày gần nhất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // BAR CHART
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2, // Thêm 20% để có khoảng trống trên
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        CurrencyFormatter.formatCompact(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final dates = dailyData.keys.toList()..sort();
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          final date = dates[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getWeekdayName(date.weekday),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          CurrencyFormatter.formatCompact(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: _createBarGroups(dailyData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tạo bar groups
  List<BarChartGroupData> _createBarGroups(Map<DateTime, double> dailyData) {
    final dates = dailyData.keys.toList()..sort();
    
    return List.generate(dates.length, (index) {
      final date = dates[index];
      final value = dailyData[date] ?? 0;
      
      // Màu khác cho hôm nay
      final isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: isToday ? Colors.blue : Colors.red,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    });
  }

  // Lấy tên thứ
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  // ============================================================
  // 4. DANH SÁCH CHI TIẾT THEO CATEGORY
  // ============================================================
  Widget _buildCategoryList(TransactionProvider provider) {
    final categoryData = provider.getCategoryData();
    
    if (categoryData.isEmpty) {
      return const SizedBox();
    }

    // Sắp xếp theo số tiền giảm dần
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi tiết theo danh mục',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tổng: ${CurrencyFormatter.formatCompact(total)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // DIVIDER
          Divider(height: 1, color: Colors.grey[200]),
          
          // DANH SÁCH
          ...sortedEntries.map((entry) {
            return _buildCategoryItem(
              entry.key,
              entry.value,
              total,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String categoryName,
    double amount,
    double total,
  ) {
    final category = Categories.getCategoryByName(
      categoryName,
      TransactionType.expense,
    );
    
    final percentage = (amount / total * 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ICON
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category?.color.withOpacity(0.1) ?? Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category?.icon ?? Icons.help_outline,
                  color: category?.color ?? Colors.grey,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // TÊN CATEGORY
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // SỐ TIỀN
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                category?.color ?? Colors.grey,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}