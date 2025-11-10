import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // LOADING STATE
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // EMPTY STATE
        if (provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để thêm giao dịch',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // DANH SÁCH GIAO DỊCH NHÓM THEO NGÀY
        final groupedTransactions = provider.getTransactionsGroupedByDate();
        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Mới nhất trước

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Để không bị che bởi FAB
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final transactions = groupedTransactions[date]!;
            
            return _buildDateGroup(context, date, transactions);
          },
        );
      },
    );
  }

  // NHÓM GIAO DỊCH THEO NGÀY
  Widget _buildDateGroup(
    BuildContext context,
    DateTime date,
    List<Transaction> transactions,
  ) {
    // Tính tổng thu/chi trong ngày
    double dailyIncome = 0;
    double dailyExpense = 0;
    
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        dailyIncome += transaction.amount;
      } else {
        dailyExpense += transaction.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER NGÀY
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatRelative(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${dailyIncome > 0 ? "+${CurrencyFormatter.formatCompact(dailyIncome)}" : ""} '
                '${dailyExpense > 0 ? "-${CurrencyFormatter.formatCompact(dailyExpense)}" : ""}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        
        // DANH SÁCH GIAO DỊCH TRONG NGÀY
        ...transactions.map((transaction) {
          return _buildTransactionItem(context, transaction);
        }).toList(),
      ],
    );
  }

  // ITEM GIAO DỊCH
  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final category = Categories.getCategoryByName(
      transaction.category,
      transaction.type,
    );

    return Slidable(
      // SWIPE ĐỂ XÓA/SỬA
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // NÚT SỬA
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(
                    transaction: transaction,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sửa',
          ),
          
          // NÚT XÓA
          SlidableAction(
            onPressed: (context) {
              _showDeleteDialog(context, transaction);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      
      child: InkWell(
        onTap: () {
          // Tap để xem chi tiết hoặc chỉnh sửa
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                transaction: transaction,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              // ICON CATEGORY
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category?.color.withOpacity(0.1) ?? Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Icons.help_outline,
                  color: category?.color ?? Colors.grey,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // TITLE VÀ CATEGORY
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.category,
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
                '${transaction.type == TransactionType.income ? "+" : "-"}${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: transaction.type == TransactionType.income
                      ? Colors.green[600]
                      : Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG XÁC NHẬN XÓA
  Future<void> _showDeleteDialog(
    BuildContext context,
    Transaction transaction,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa giao dịch "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await Provider.of<TransactionProvider>(context, listen: false)
            .deleteTransaction(transaction.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa giao dịch'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}