import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../utils/date_formatter.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // Null = thêm mới, có giá trị = chỉnh sửa

  const AddTransactionScreen({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // FORM KEY - Để validate form
  final _formKey = GlobalKey<FormState>();

  // CONTROLLERS - Quản lý text input
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  // STATE VARIABLES
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Nếu đang edit, điền sẵn dữ liệu
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _dateController.text = DateFormatter.formatShort(_selectedDate);
    } else {
      // Mặc định là ngày hôm nay
      _dateController.text = DateFormatter.formatShort(_selectedDate);
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Thêm giao dịch' : 'Sửa giao dịch',
        ),
        actions: [
          // NÚT LƯU
          if (!_isLoading)
            TextButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CHỌN LOẠI: THU/CHI
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // NHẬP TIÊU ĐỀ
                    _buildTitleField(),
                    
                    const SizedBox(height: 16),
                    
                    // NHẬP SỐ TIỀN
                    _buildAmountField(),
                    
                    const SizedBox(height: 16),
                    
                    // CHỌN DANH MỤC
                    _buildCategoryDropdown(),
                    
                    const SizedBox(height: 16),
                    
                    // CHỌN NGÀY
                    _buildDatePicker(),
                    
                    const SizedBox(height: 32),
                    
                    // NÚT LƯU (ở dưới cũng có)
                    _buildSaveButton(),
                    
                    // NÚT XÓA (chỉ hiện khi edit)
                    if (widget.transaction != null) ...[
                      const SizedBox(height: 16),
                      _buildDeleteButton(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // 1. CHỌN LOẠI GIAO DỊCH (THU/CHI)
  // ============================================================
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại giao dịch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // NÚT THU NHẬP
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.income,
                label: 'Thu nhập',
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // NÚT CHI TIÊU
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.expense,
                label: 'Chi tiêu',
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null; // Reset category khi đổi loại
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. NHẬP TIÊU ĐỀ
  // ============================================================
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Tiêu đề',
        hintText: 'VD: Mua cafe, Lương tháng 10...',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLength: 50,
      
      // VALIDATION
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tiêu đề';
        }
        if (value.trim().length < 3) {
          return 'Tiêu đề phải có ít nhất 3 ký tự';
        }
        return null;
      },
    );
  }

  // ============================================================
  // 3. NHẬP SỐ TIỀN
  // ============================================================
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Số tiền',
        hintText: '0',
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: 'đ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      
      // CHỈ CHO PHÉP NHẬP SỐ
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      
      // VALIDATION
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập số tiền';
        }
        
        final amount = double.tryParse(value);
        if (amount == null) {
          return 'Số tiền không hợp lệ';
        }
        
        if (amount <= 0) {
          return 'Số tiền phải lớn hơn 0';
        }
        
        if (amount > 1000000000000) { // 1 nghìn tỷ
          return 'Số tiền quá lớn';
        }
        
        return null;
      },
    );
  }

  // ============================================================
  // 4. CHỌN DANH MỤC
  // ============================================================
  Widget _buildCategoryDropdown() {
    // Lấy danh sách category theo loại
    final categories = _selectedType == TransactionType.income
        ? Categories.incomeCategories
        : Categories.expenseCategories;

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Danh mục',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      
      // DANH SÁCH CATEGORY
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.name,
          child: Row(
            children: [
              Icon(
                category.icon,
                color: category.color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      
      // VALIDATION
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn danh mục';
        }
        return null;
      },
    );
  }

  // ============================================================
  // 5. CHỌN NGÀY
  // ============================================================
  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Ngày',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true, // Không cho nhập tay
      
      onTap: () async {
        // MỞ DATE PICKER
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('vi', 'VN'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: _selectedType == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _dateController.text = DateFormatter.formatShort(picked);
          });
        }
      },
      
      // VALIDATION
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn ngày';
        }
        return null;
      },
    );
  }

  // ============================================================
  // 6. NÚT LƯU
  // ============================================================
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedType == TransactionType.income
              ? Colors.green
              : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.transaction == null ? 'Thêm giao dịch' : 'Cập nhật',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 7. NÚT XÓA (chỉ khi edit)
  // ============================================================
  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _deleteTransaction,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.delete),
        label: const Text(
          'Xóa giao dịch',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // ============================================================
  // XỬ LÝ LƯU GIAO DỊCH
  // ============================================================
  Future<void> _saveTransaction() async {
    // VALIDATE FORM
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // TẠO OBJECT TRANSACTION
      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory!,
        type: _selectedType,
      );

      // THÊM HOẶC CẬP NHẬT
      if (widget.transaction == null) {
        await provider.addTransaction(transaction);
      } else {
        await provider.updateTransaction(transaction);
      }

      if (mounted) {
        // HIỂN THỊ THÔNG BÁO THÀNH CÔNG
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction == null
                  ? 'Đã thêm giao dịch'
                  : 'Đã cập nhật giao dịch',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // ĐÓNG MÀN HÌNH
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // XỬ LÝ XÓA GIAO DỊCH
  // ============================================================
  Future<void> _deleteTransaction() async {
    // XÁC NHẬN XÓA
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
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

    if (confirm != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      await provider.deleteTransaction(widget.transaction!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa giao dịch'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}