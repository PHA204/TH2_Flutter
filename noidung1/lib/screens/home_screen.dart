import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'transaction_list_screen.dart';
import 'chart_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình con
  final List<Widget> _screens = [
    const TransactionListScreen(),
    const ChartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Chi tiêu'),
        actions: [
          // Nút chọn tháng
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showMonthPicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // Card hiển thị tổng quan
          _buildSummaryCard(),
          
          // Hiển thị tháng hiện tại
          _buildMonthSelector(),
          
          // Nội dung chính (List hoặc Chart)
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
      ),
      
      // Floating Action Button - Thêm giao dịch
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // CARD TỔNG QUAN
  Widget _buildSummaryCard() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // SỐ DƯ
              Text(
                'Số dư',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(provider.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // THU VÀ CHI
              Row(
                children: [
                  // THU NHẬP
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green[300]!,
                      label: 'Thu nhập',
                      amount: provider.totalIncome,
                    ),
                  ),
                  
                  // ĐƯỜNG KẺ DỌC
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  
                  // CHI TIÊU
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_upward,
                      iconColor: Colors.red[300]!,
                      label: 'Chi tiêu',
                      amount: provider.totalExpense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ITEM TRONG SUMMARY CARD
  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatCompact(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // CHỌN THÁNG
  Widget _buildMonthSelector() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // NÚT THÁNG TRƯỚC
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => provider.changeMonth(-1),
              ),
              
              // HIỂN THỊ THÁNG
              Text(
                DateFormatter.formatMonth(provider.selectedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              // NÚT THÁNG SAU
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => provider.changeMonth(1),
              ),
            ],
          ),
        );
      },
    );
  }

  // DIALOG CHỌN THÁNG
  Future<void> _showMonthPicker() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      provider.changeMonth(
        (picked.year - provider.selectedMonth.year) * 12 +
        (picked.month - provider.selectedMonth.month),
      );
    }
  }
}