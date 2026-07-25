import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const FinCoreApp());
}

class FinCoreApp extends StatelessWidget {
  const FinCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinCore Enterprise ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(String username, String password) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://fincorebackend.vercel.app/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DashboardScreen(username: data['username'], role: data['role']),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSignupDialog() {
    final sUser = TextEditingController();
    final sPass = TextEditingController();
    String sRole = 'Store Clerk';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Account & RBAC Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sUser,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: sPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: sRole,
                decoration: const InputDecoration(labelText: 'User Role'),
                items: ['Admin', 'Store Clerk', 'Employee']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => setDialogState(() => sRole = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.post(
                  Uri.parse('http://localhost:3000/api/signup'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'username': sUser.text,
                    'password': sPass.text,
                    'role': sRole,
                  }),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account registered!')),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 64, color: Color(0xFF2E5A44)),
              const SizedBox(height: 16),
              const Text(
                'FinCore ERP Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5A44),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5A44),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () =>
                            _login(_userController.text, _passController.text),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Admin Demo'),
                    onPressed: () => _login('admin', '12345678'),
                  ),
                  ActionChip(
                    label: const Text('Clerk Demo'),
                    onPressed: () => _login('clerk', '12345678'),
                  ),
                  ActionChip(
                    label: const Text('Employee Demo'),
                    onPressed: () => _login('employee', '12345678'),
                  ),
                ],
              ),
              const Divider(height: 24),
              TextButton(
                onPressed: _showSignupDialog,
                child: const Text(
                  'Create New Account',
                  style: TextStyle(
                    color: Color(0xFF2E5A44),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String username;
  final String role;
  const DashboardScreen({
    super.key,
    required this.username,
    required this.role,
  });

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
  List<dynamic> _postings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      _fetchPostings(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchLogs() async {
    final res = await http.get(Uri.parse('http://localhost:3000/api/logs'));
    if (res.statusCode == 200) {
      setState(() => _logs = jsonDecode(res.body)['data']);
    }
  }

  Future<void> _fetchStock() async {
    final res = await http.get(Uri.parse('http://localhost:3000/api/stock'));
    if (res.statusCode == 200) {
      setState(() => _stock = jsonDecode(res.body)['data']);
    }
  }

  Future<void> _fetchPayroll() async {
    final res = await http.get(Uri.parse('http://localhost:3000/api/payroll'));
    if (res.statusCode == 200) {
      setState(() => _payroll = jsonDecode(res.body)['data']);
    }
  }

  Future<void> _fetchPosSales() async {
    final res = await http.get(
      Uri.parse('http://localhost:3000/api/pos/sales'),
    );
    if (res.statusCode == 200) {
      setState(() => _posSales = jsonDecode(res.body)['data']);
    }
  }

  Future<void> _fetchWarehouses() async {
    final res = await http.get(
      Uri.parse('http://localhost:3000/api/warehouses'),
    );
    if (res.statusCode == 200) {
      setState(() => _warehouses = jsonDecode(res.body)['data']);
    }
  }

  Future<void> _fetchPostings() async {
    final res = await http.get(Uri.parse('http://localhost:3000/api/postings'));
    if (res.statusCode == 200) {
      setState(() => _postings = jsonDecode(res.body)['data']);
    }
  }

  double _calculateTotalExpenses() =>
      _logs.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
  double _calculateTotalStockVal() => _stock.fold(
    0.0,
    (sum, item) =>
        sum + ((item['quantity'] ?? 0.0) * (item['unit_price'] ?? 0.0)),
  );
  double _calculateTotalPayroll() =>
      _payroll.fold(0.0, (sum, item) => sum + (item['total_pay'] ?? 0.0));
  double _calculateTotalRevenue() =>
      _posSales.fold(0.0, (sum, item) => sum + (item['total_price'] ?? 0.0));

  void _downloadFile(String endpoint, String filename) {
    html.window.open('http://localhost:3000/api/export/$endpoint', '_blank');
  }

  void _showAddVoucherDialog() {
    final payeeController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String voucherType = 'CPV';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Accounting Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: voucherType,
                decoration: const InputDecoration(labelText: 'Voucher Type'),
                items: ['CPV', 'BPV', 'JV', 'Petty Cash']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) => setDialogState(() => voucherType = val!),
              ),
              TextField(
                controller: payeeController,
                decoration: const InputDecoration(
                  labelText: 'Payee / Contractor',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (PKR)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.post(
                  Uri.parse('http://localhost:3000/api/logs'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'voucher_type': voucherType,
                    'payee': payeeController.text,
                    'description': descController.text,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'category': 'General',
                    'account_head': 'General Cash',
                    'date': DateTime.now().toString().split(' ')[0],
                  }),
                );
                _fetchLogs();
                Navigator.pop(context);
              },
              child: const Text('Post Voucher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    int selectedWarehouseId = _warehouses.isNotEmpty
        ? _warehouses.first['id']
        : 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Stock Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price (PKR)',
                ),
              ),
              DropdownButtonFormField<int>(
                initialValue: selectedWarehouseId,
                decoration: const InputDecoration(labelText: 'Warehouse'),
                items: _warehouses
                    .map(
                      (w) => DropdownMenuItem<int>(
                        value: w['id'],
                        child: Text(w['warehouse_name']),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.post(
                  Uri.parse('http://localhost:3000/api/stock'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'item_name': nameController.text,
                    'quantity': double.tryParse(qtyController.text) ?? 0.0,
                    'unit_price': double.tryParse(priceController.text) ?? 0.0,
                    'category': 'General',
                    'warehouse_id': selectedWarehouseId,
                    'date': DateTime.now().toString().split(' ')[0],
                  }),
                );
                _fetchStock();
                Navigator.pop(context);
              },
              child: const Text('Save Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWarehouseDialog() {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Warehouse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Warehouse Name'),
            ),
            TextField(
              controller: locCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5A44),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await http.post(
                Uri.parse('http://localhost:3000/api/warehouses'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'warehouse_name': nameCtrl.text,
                  'location': locCtrl.text,
                }),
              );
              _fetchWarehouses();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPayrollDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Laborer');
    final wageCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payroll Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Worker Name'),
            ),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: wageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daily Wage'),
            ),
            TextField(
              controller: daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Days Worked'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5A44),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await http.post(
                Uri.parse('http://localhost:3000/api/payroll'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'worker_name': nameCtrl.text,
                  'role': roleCtrl.text,
                  'daily_wage': double.tryParse(wageCtrl.text) ?? 0.0,
                  'days_worked': double.tryParse(daysCtrl.text) ?? 0.0,
                  'date': DateTime.now().toString().split(' ')[0],
                }),
              );
              _fetchPayroll();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPosCheckoutDialog() {
    if (_stock.isEmpty) return;
    dynamic selectedItem = _stock.first;
    final qtyCtrl = TextEditingController(text: '1');
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('POS Checkout with Local Gateway'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<dynamic>(
                initialValue: selectedItem,
                items: _stock
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          '${s['item_name']} (Stock: ${s['quantity']})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedItem = val),
              ),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Gateway'),
                items: ['Cash', 'JazzCash', 'EasyPaisa']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setDialogState(() => paymentMethod = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.post(
                  Uri.parse('http://localhost:3000/api/pos/sales'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'item_id': selectedItem['id'],
                    'item_name': selectedItem['item_name'],
                    'quantity_sold': double.tryParse(qtyCtrl.text) ?? 1.0,
                    'unit_price': selectedItem['unit_price'],
                    'payment_method': paymentMethod,
                    'date': DateTime.now().toString().split(' ')[0],
                  }),
                );
                _fetchPosSales();
                _fetchStock();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment processed successfully via $paymentMethod!',
                    ),
                  ),
                );
              },
              child: const Text('Complete Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPostingDialog() {
    final contentCtrl = TextEditingController();
    String mediaType = 'text';
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Posting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: mediaType,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text Only')),
                  DropdownMenuItem(value: 'photo', child: Text('Photo Link')),
                  DropdownMenuItem(value: 'file', child: Text('Document Link')),
                  DropdownMenuItem(value: 'video', child: Text('Video Link')),
                  DropdownMenuItem(value: 'audio', child: Text('Audio Link')),
                ],
                onChanged: (val) => setDialogState(() => mediaType = val!),
              ),
              if (mediaType != 'text')
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(labelText: '$mediaType URL'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5A44),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.post(
                  Uri.parse('https://fincorebackend.vercel.app/api/postings'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'author': widget.username,
                    'content': contentCtrl.text,
                    'media_type': mediaType,
                    'media_url': urlCtrl.text,
                    'date': DateTime.now().toString().split(' ')[0],
                  }),
                );
                _fetchPostings();
                Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.role == 'Admin';
    bool isClerk = widget.role == 'Store Clerk' || isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          'FinCore ERP — ${widget.username} (${widget.role})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2E5A44),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.feed), text: 'Enterprise Feed'),
            Tab(icon: Icon(Icons.account_balance), text: 'Financial Ledger'),
            Tab(icon: Icon(Icons.inventory), text: 'Stock & Warehouses'),
            Tab(icon: Icon(Icons.badge), text: 'Payroll & Labor'),
            Tab(icon: Icon(Icons.point_of_sale), text: 'POS Checkout'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics & P&L'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download, color: Colors.white),
            onSelected: (val) {
              if (val == 'csv') _downloadFile('csv', 'ledger.csv');
              if (val == 'pdf') _downloadFile('pdf', 'report.pdf');
              if (val == 'backup') _downloadFile('backup', 'fincore_backup.db');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('Export Ledger CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Export PDF Report')),
              PopupMenuItem(value: 'backup', child: Text('Download DB Backup')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          isAdmin
              ? _buildLedgerTab()
              : _buildRestricted('Financial Ledger (Admin Only)'),
          isClerk
              ? _buildStockTab()
              : _buildRestricted('Stock & Warehouses (Clerk/Admin Only)'),
          isAdmin
              ? _buildPayrollTab()
              : _buildRestricted('Payroll & Labor (Admin Only)'),
          isClerk
              ? _buildPosTab()
              : _buildRestricted('POS Checkout (Clerk/Admin Only)'),
          isAdmin
              ? _buildAnalyticsTab()
              : _buildRestricted('Analytics & P&L (Admin Only)'),
        ],
      ),
    );
  }

  Widget _buildRestricted(String msg) {
    return Center(
      child: Text(
        'Access Restricted: $msg',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Company Feed & Bulletin Board',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                onPressed: _showAddPostingDialog,
                label: const Text('Create Posting'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _postings.isEmpty
              ? const Center(child: Text('No postings available.'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _postings.length,
                  itemBuilder: (context, index) {
                    final p = _postings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['author'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              p['date'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(height: 16),
                            Text(p['content']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Ledger Vouchers',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                onPressed: _showAddVoucherDialog,
                label: const Text('Create Voucher'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _logs.isEmpty
              ? const Center(child: Text('No vouchers recorded yet.'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8ECE9),
                        child: Text(log['voucher_type'] ?? 'CPV'),
                      ),
                      title: Text(
                        log['payee'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${log['description']} • ${log['date']}'),
                      trailing: Text(
                        'PKR ${log['amount']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2E5A44),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock Inventory & Warehouses',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.warehouse),
                    onPressed: _showAddWarehouseDialog,
                    label: const Text('Add Warehouse'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5A44),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_box),
                    onPressed: _showAddStockDialog,
                    label: const Text('Add Stock'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _stock.isEmpty
              ? const Center(child: Text('No stock recorded yet.'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stock.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _stock[index];
                    return ListTile(
                      title: Text(
                        item['item_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Warehouse: ${item['warehouse_name']} • Qty: ${item['quantity']}',
                      ),
                      trailing: Text(
                        'PKR ${item['unit_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5A44),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPayrollTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payroll & Labor Wages',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.badge),
                onPressed: _showAddPayrollDialog,
                label: const Text('Add Wage Entry'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _payroll.isEmpty
              ? const Center(child: Text('No payroll records yet.'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _payroll.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _payroll[index];
                    return ListTile(
                      title: Text(
                        item['worker_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Role: ${item['role']} • Days: ${item['days_worked']}',
                      ),
                      trailing: Text(
                        'PKR ${item['total_pay']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5A44),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'POS Checkout Register',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5A44),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.point_of_sale),
                onPressed: _showPosCheckoutDialog,
                label: const Text('New Checkout'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _posSales.isEmpty
              ? const Center(child: Text('No POS sales recorded yet.'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _posSales.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final sale = _posSales[index];
                    return ListTile(
                      title: Text(
                        sale['item_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Qty Sold: ${sale['quantity_sold']} • Gateway: ${sale['payment_method']} • ${sale['date']}',
                      ),
                      trailing: Text(
                        'PKR ${sale['total_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5A44),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final double rev = _calculateTotalRevenue();
    final double exp = _calculateTotalExpenses() + _calculateTotalPayroll();
    final double net = rev - exp;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics & Profit & Loss (P&L)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryCard(
                'Total Revenue',
                'PKR ${rev.toStringAsFixed(2)}',
                Icons.trending_up,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Total Expenses',
                'PKR ${exp.toStringAsFixed(2)}',
                Icons.trending_down,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Net Profit',
                'PKR ${net.toStringAsFixed(2)}',
                Icons.check_circle,
              ),
            ],
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
                color: Colors.grey,
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
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
