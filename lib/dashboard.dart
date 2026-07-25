import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _logs = [];
  List<dynamic> _stock = [];
  List<dynamic> _payroll = [];
  List<dynamic> _posSales = [];
  List<dynamic> _warehouses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final List<Map<String, String>> _chatMessages = [
    {
      'sender': 'ai',
      'text':
          'Hello! I am your FinCore AI Accountant. Ask me about your warehouses, P&L, expenses, or inventory!',
    },
  ];
  final TextEditingController _chatController = TextEditingController();
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchLogs(),
      _fetchStock(),
      _fetchPayroll(),
      _fetchPosSales(),
      _fetchWarehouses(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchLogs() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/logs'),
      );
      if (response.statusCode == 200) {
        setState(() => _logs = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }
  }

  Future<void> _fetchStock() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/stock'),
      );
      if (response.statusCode == 200) {
        setState(() => _stock = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Error fetching stock: $e');
    }
  }

  Future<void> _fetchPayroll() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/payroll'),
      );
      if (response.statusCode == 200) {
        setState(() => _payroll = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Error fetching payroll: $e');
    }
  }

  Future<void> _fetchPosSales() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/pos/sales'),
      );
      if (response.statusCode == 200) {
        setState(() => _posSales = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Error fetching POS sales: $e');
    }
  }

  Future<void> _fetchWarehouses() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/warehouses'),
      );
      if (response.statusCode == 200) {
        setState(() => _warehouses = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Error fetching warehouses: $e');
    }
  }

  double _calculateTotalExpenses() {
    double total = 0.0;
    for (var log in _logs) {
      total += (log['amount'] is int)
          ? (log['amount'] as int).toDouble()
          : (log['amount'] ?? 0.0);
    }
    return total;
  }

  double _calculateTotalStockValue() {
    double total = 0.0;
    for (var item in _stock) {
      double qty = (item['quantity'] is int)
          ? (item['quantity'] as int).toDouble()
          : (item['quantity'] ?? 0.0);
      double price = (item['unit_price'] is int)
          ? (item['unit_price'] as int).toDouble()
          : (item['unit_price'] ?? 0.0);
      total += (qty * price);
    }
    return total;
  }

  double _calculateTotalPayroll() {
    double total = 0.0;
    for (var item in _payroll) {
      total += (item['total_pay'] is int)
          ? (item['total_pay'] as int).toDouble()
          : (item['total_pay'] ?? 0.0);
    }
    return total;
  }

  double _calculateTotalPosRevenue() {
    double total = 0.0;
    for (var sale in _posSales) {
      total += (sale['total_price'] is int)
          ? (sale['total_price'] as int).toDouble()
          : (sale['total_price'] ?? 0.0);
    }
    return total;
  }

  Future<void> _addLog({
    required String voucherType,
    required String payee,
    required String description,
    required double amount,
    required String category,
    required String accountHead,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/logs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'voucher_type': voucherType,
          'payee': payee,
          'description': description,
          'amount': amount,
          'category': category,
          'account_head': accountHead,
          'date': date,
        }),
      );
      if (response.statusCode == 201) _fetchLogs();
    } catch (e) {
      debugPrint('Error adding log: $e');
    }
  }

  Future<void> _addStock({
    required String itemName,
    required double quantity,
    required double unitPrice,
    required String category,
    required int warehouseId,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/stock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'item_name': itemName,
          'quantity': quantity,
          'unit_price': unitPrice,
          'category': category,
          'warehouse_id': warehouseId,
          'date': date,
        }),
      );
      if (response.statusCode == 201) _fetchStock();
    } catch (e) {
      debugPrint('Error adding stock: $e');
    }
  }

  Future<void> _addPayroll({
    required String workerName,
    required String role,
    required double dailyWage,
    required double daysWorked,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/payroll'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'worker_name': workerName,
          'role': role,
          'daily_wage': dailyWage,
          'days_worked': daysWorked,
          'date': date,
        }),
      );
      if (response.statusCode == 201) _fetchPayroll();
    } catch (e) {
      debugPrint('Error adding payroll: $e');
    }
  }

  Future<void> _addWarehouse({
    required String name,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/warehouses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'warehouse_name': name, 'location': location}),
      );
      if (response.statusCode == 201) _fetchWarehouses();
    } catch (e) {
      debugPrint('Error adding warehouse: $e');
    }
  }

  Future<void> _processPosSale({
    required int itemId,
    required String itemName,
    required double quantitySold,
    required double unitPrice,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/pos/sales'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'item_id': itemId,
          'item_name': itemName,
          'quantity_sold': quantitySold,
          'unit_price': unitPrice,
          'payment_method': paymentMethod,
          'date': DateTime.now().toString().split(' ')[0],
        }),
      );
      if (response.statusCode == 201) {
        _fetchPosSales();
        _fetchStock();
      }
    } catch (e) {
      debugPrint('Error processing POS sale: $e');
    }
  }

  Future<void> _deleteLog(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/api/logs/$id'));
    _fetchLogs();
  }

  Future<void> _deleteStock(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/api/stock/$id'));
    _fetchStock();
  }

  Future<void> _deletePayroll(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/api/payroll/$id'));
    _fetchPayroll();
  }

  Future<void> _deletePosSale(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/api/pos/sales/$id'));
    _fetchPosSales();
  }

  void _downloadFile(String endpoint, String filename) {
    html.window.open('http://localhost:3000/api/export/$endpoint', '_blank');
  }

  void _backupDatabase() {
    html.window.open('http://localhost:3000/api/backup', '_blank');
  }

  void _showAddVoucherDialog() {
    final payeeController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String voucherType = 'CPV';
    String selectedCategory = 'General';
    String accountHead = 'General Cash';

    final voucherTypes = ['CPV', 'BPV', 'JV', 'Petty Cash'];
    final categories = [
      'General',
      'Materials',
      'Transport',
      'Labor',
      'Equipment',
    ];
    final accountHeads = [
      'General Cash',
      'Meezan Bank Account',
      'Petty Cash Box',
      'Accounts Payable',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Create Accounting Voucher',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: voucherType,
                  decoration: const InputDecoration(
                    labelText: 'Voucher Type',
                    prefixIcon: Icon(Icons.receipt),
                  ),
                  items: voucherTypes
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => voucherType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: payeeController,
                  decoration: const InputDecoration(
                    labelText: 'Payee / Contractor',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description / Narration',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (PKR)',
                    prefixIcon: Icon(Icons.money),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Expense Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: accountHead,
                  decoration: const InputDecoration(
                    labelText: 'Account Head',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accountHeads
                      .map(
                        (acc) => DropdownMenuItem(value: acc, child: Text(acc)),
                      )
                      .toList(),
                  onChanged: (val) => setDialogState(() => accountHead = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final date = DateTime.now().toString().split(' ')[0];
                _addLog(
                  voucherType: voucherType,
                  payee: payeeController.text,
                  description: descController.text,
                  amount: amount,
                  category: selectedCategory,
                  accountHead: accountHead,
                  date: date,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              child: const Text('Post Voucher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWarehouseDialog() {
    final nameController = TextEditingController();
    final locController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Regional Warehouse / Branch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Warehouse Name',
                prefixIcon: Icon(Icons.warehouse),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locController,
              decoration: const InputDecoration(
                labelText: 'Location / City',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addWarehouse(
                name: nameController.text,
                location: locController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5A44),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Warehouse'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    String category = 'Materials';
    int selectedWarehouseId = _warehouses.isNotEmpty
        ? _warehouses.first['id']
        : 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Add Stock / Inventory Item',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.inventory),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price (PKR)',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedWarehouseId,
                decoration: const InputDecoration(
                  labelText: 'Assigned Warehouse',
                  prefixIcon: Icon(Icons.warehouse),
                ),
                items: _warehouses
                    .map(
                      (w) => DropdownMenuItem<int>(
                        value: w['id'],
                        child: Text(
                          '${w['warehouse_name']} (${w['location']})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedWarehouseId = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addStock(
                  itemName: nameController.text,
                  quantity: double.tryParse(qtyController.text) ?? 0.0,
                  unitPrice: double.tryParse(priceController.text) ?? 0.0,
                  category: category,
                  warehouseId: selectedWarehouseId,
                  date: DateTime.now().toString().split(' ')[0],
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPayrollDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Laborer');
    final wageController = TextEditingController();
    final daysController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Payroll / Labor Wage',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Worker Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role / Trade',
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Wage (PKR)',
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days Worked',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addPayroll(
                workerName: nameController.text,
                role: roleController.text,
                dailyWage: double.tryParse(wageController.text) ?? 0.0,
                daysWorked: double.tryParse(daysController.text) ?? 0.0,
                date: DateTime.now().toString().split(' ')[0],
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5A44),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Wage Record'),
          ),
        ],
      ),
    );
  }

  void _showPosCheckoutDialog() {
    if (_stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No stock available to checkout. Add inventory first!'),
        ),
      );
      return;
    }

    dynamic selectedItem = _stock.first;
    final qtyController = TextEditingController(text: '1');
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double unitPrice = (selectedItem['unit_price'] is int)
              ? (selectedItem['unit_price'] as int).toDouble()
              : (selectedItem['unit_price'] ?? 0.0);
          double qty = double.tryParse(qtyController.text) ?? 1.0;
          double total = unitPrice * qty;

          return AlertDialog(
            title: const Text(
              'POS Register Checkout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<dynamic>(
                  value: selectedItem,
                  decoration: const InputDecoration(
                    labelText: 'Select Stock Item',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  items: _stock.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        '${item['item_name']} [${item['warehouse_name'] ?? 'Main'}] (Qty: ${item['quantity']})',
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => selectedItem = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity to Sell',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  onChanged: (val) => setDialogState(() {}),
                ),
                const Divider(height: 24),
                Text(
                  'Total Payable: PKR ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5A44),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  double qSold = double.tryParse(qtyController.text) ?? 1.0;
                  double availableQty = (selectedItem['quantity'] is int)
                      ? (selectedItem['quantity'] as int).toDouble()
                      : (selectedItem['quantity'] ?? 0.0);

                  if (qSold > availableQty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: Sale quantity exceeds warehouse stock!',
                        ),
                      ),
                    );
                    return;
                  }

                  _processPosSale(
                    itemId: selectedItem['id'],
                    itemName: selectedItem['item_name'],
                    quantitySold: qSold,
                    unitPrice: unitPrice,
                    paymentMethod: paymentMethod,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete Checkout'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAiQuery(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _chatMessages.add({'sender': 'user', 'text': query});
      _chatController.clear();
    });

    String response = "I'm your FinCore AI accountant. ";
    String q = query.toLowerCase();

    if (q.contains('profit') || q.contains('loss') || q.contains('p&l')) {
      double rev = _calculateTotalPosRevenue();
      double exp = _calculateTotalExpenses() + _calculateTotalPayroll();
      double net = rev - exp;
      response =
          "P&L Summary: Total Revenue is PKR ${rev.toStringAsFixed(2)}, Total Expenses are PKR ${exp.toStringAsFixed(2)}, Net Profit is PKR ${net.toStringAsFixed(2)}.";
    } else {
      response =
          "I have analyzed your ${_warehouses.length} warehouses, ${_stock.length} inventory items, and ${_posSales.length} POS sales. Feel free to ask about specific warehouse stocks or net profit!";
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _chatMessages.add({'sender': 'ai', 'text': response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text(
          'FinCore Enterprise ERP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E5A44),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance), text: 'Financial Ledger'),
            Tab(icon: Icon(Icons.inventory), text: 'Stock & Warehouses'),
            Tab(icon: Icon(Icons.badge), text: 'Payroll & Labor'),
            Tab(icon: Icon(Icons.point_of_sale), text: 'POS Checkout'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics & P&L'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _backupDatabase,
            icon: const Icon(Icons.backup, color: Colors.white),
            label: const Text(
              'Backup DB',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _downloadFile('csv', 'fincore_ledger_book.csv'),
            icon: const Icon(Icons.table_chart, color: Colors.white),
            label: const Text(
              'Ledger CSV',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildLedgerTab(),
              _buildStockTab(),
              _buildPayrollTab(),
              _buildPosTab(),
              _buildAnalyticsTab(),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isChatOpen)
                  Container(
                    width: 340,
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E5A44),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.smart_toy,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'FinCore AI Accountant',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _isChatOpen = false),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _chatMessages.length,
                            itemBuilder: (context, index) {
                              final msg = _chatMessages[index];
                              bool isAi = msg['sender'] == 'ai';
                              return Align(
                                alignment: isAi
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  constraints: const BoxConstraints(
                                    maxWidth: 260,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAi
                                        ? Colors.grey.shade100
                                        : const Color(0xFF2E5A44),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    msg['text']!,
                                    style: TextStyle(
                                      color: isAi
                                          ? Colors.black87
                                          : Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  onSubmitted: _handleAiQuery,
                                  decoration: const InputDecoration(
                                    hintText: 'Ask AI accountant...',
                                    hintStyle: TextStyle(fontSize: 12),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Color(0xFF2E5A44),
                                ),
                                onPressed: () =>
                                    _handleAiQuery(_chatController.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  onPressed: () => setState(() => _isChatOpen = !_isChatOpen),
                  backgroundColor: const Color(0xFF2E5A44),
                  icon: const Icon(Icons.smart_toy, color: Colors.white),
                  label: Text(
                    _isChatOpen ? 'Close AI Assistant' : 'AI Accountant',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab() {
    final totalAssets = _calculateTotalExpenses();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Accounting Vouchers & Ledger',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddVoucherDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create Voucher'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryCard(
                'Total Vouchers Value',
                'PKR ${totalAssets.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Total Entries',
                '${_logs.length} Records',
                Icons.receipt_long,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _logs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No vouchers recorded yet.')),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _logs.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE8ECE9),
                          child: Text(
                            log['voucher_type'] ?? 'CPV',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E5A44),
                            ),
                          ),
                        ),
                        title: Text(
                          log['payee'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${log['description']} • Head: ${log['account_head']} • ${log['date']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PKR ${log['amount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2E5A44),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteLog(log['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock Inventory & Regional Warehouses',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddWarehouseDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.warehouse),
                    label: const Text('Add Warehouse'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddStockDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5A44),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_box),
                    label: const Text('Add Stock Item'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _warehouses.map((w) {
              return Chip(
                avatar: const Icon(Icons.store, color: Color(0xFF2E5A44)),
                label: Text(
                  '${w['warehouse_name']} (${w['location']})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _stock.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No stock added across warehouses yet.'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stock.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = _stock[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8ECE9),
                          child: Icon(Icons.widgets, color: Color(0xFF2E5A44)),
                        ),
                        title: Text(
                          item['item_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Warehouse: ${item['warehouse_name'] ?? 'Main'} • Qty: ${item['quantity']} • Price: PKR ${item['unit_price']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteStock(item['id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollTab() {
    final totalPayrollVal = _calculateTotalPayroll();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payroll & Labor Wage Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddPayrollDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.badge),
                label: const Text('Add Wage Entry'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryCard(
                'Total Wage Disbursed',
                'PKR ${totalPayrollVal.toStringAsFixed(2)}',
                Icons.payments,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Total Workers Logged',
                '${_payroll.length} Records',
                Icons.group,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _payroll.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No payroll records added yet.')),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _payroll.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = _payroll[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8ECE9),
                          child: Icon(
                            Icons.engineering,
                            color: Color(0xFF2E5A44),
                          ),
                        ),
                        title: Text(
                          item['worker_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Role: ${item['role']} • Daily: PKR ${item['daily_wage']} × ${item['days_worked']} Days',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PKR ${item['total_pay']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2E5A44),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deletePayroll(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosTab() {
    final totalPosVal = _calculateTotalPosRevenue();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Point of Sale (POS) Checkout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showPosCheckoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.point_of_sale),
                label: const Text('New Checkout Register'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryCard(
                'Total POS Sales Revenue',
                'PKR ${totalPosVal.toStringAsFixed(2)}',
                Icons.point_of_sale,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Completed Transactions',
                '${_posSales.length} Sales',
                Icons.receipt_long,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _posSales.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No POS checkout sales recorded yet.'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posSales.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final sale = _posSales[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8ECE9),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Color(0xFF2E5A44),
                          ),
                        ),
                        title: Text(
                          sale['item_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Qty Sold: ${sale['quantity_sold']} • Paid via: ${sale['payment_method']}',
                        ),
                        trailing: Text(
                          'PKR ${sale['total_price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2E5A44),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final double totalRevenue = _calculateTotalPosRevenue();
    final double voucherExpenses = _calculateTotalExpenses();
    final double payrollDisbursed = _calculateTotalPayroll();
    final double totalExpenses = voucherExpenses + payrollDisbursed;
    final double netProfit = totalRevenue - totalExpenses;
    final double inventoryValuation = _calculateTotalStockValue();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Analytics & Profit & Loss (P&L)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryCard(
                'Total Revenue',
                'PKR ${totalRevenue.toStringAsFixed(2)}',
                Icons.trending_up,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Total Expenses',
                'PKR ${totalExpenses.toStringAsFixed(2)}',
                Icons.trending_down,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                netProfit >= 0 ? 'Net Profit' : 'Net Loss',
                'PKR ${netProfit.abs().toStringAsFixed(2)}',
                netProfit >= 0 ? Icons.check_circle : Icons.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Executive P&L Statement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _buildPlaRow(
                  '1. Total POS Sales Revenue',
                  totalRevenue,
                  isPositive: true,
                ),
                _buildPlaRow(
                  '2. Vouchers & Operating Expenses',
                  voucherExpenses,
                  isPositive: false,
                ),
                _buildPlaRow(
                  '3. Payroll & Labor Wages Disbursed',
                  payrollDisbursed,
                  isPositive: false,
                ),
                _buildPlaRow(
                  '4. Active Inventory Valuation (Assets)',
                  inventoryValuation,
                  isPositive: true,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      netProfit >= 0
                          ? 'Net Operating Profit:'
                          : 'Net Operating Loss:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'PKR ${netProfit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: netProfit >= 0
                            ? const Color(0xFF2E5A44)
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaRow(String title, double amount, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF2E5A44) : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2E5A44)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
