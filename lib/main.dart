import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

final SupabaseClient supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const ConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const NumizaAdminApp());
}

// ============================================================
// APP
// ============================================================

class NumizaAdminApp extends StatelessWidget {
  const NumizaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUMIZA Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4FE9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        fontFamily: 'sans',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF5B4FE9),
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AdminLoginScreen(),
    );
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'خطأ في إعدادات التطبيق',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'تأكد من تمرير SUPABASE_URL و SUPABASE_PUBLISHABLE_KEY أثناء البناء.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _text(dynamic value) {
  if (value == null) return '-';
  final result = value.toString().trim();
  return result.isEmpty ? '-' : result;
}

String _formatDate(dynamic value) {
  if (value == null) return '-';

  final date = DateTime.tryParse(value.toString());
  if (date == null) return value.toString();

  final local = date.toLocal();

  String two(int n) => n.toString().padLeft(2, '0');

  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _formatDateOnly(dynamic value) {
  if (value == null) return '-';

  final date = DateTime.tryParse(value.toString());
  if (date == null) return value.toString();

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _roleText(dynamic role) {
  switch (role?.toString()) {
    case 'passenger':
    case 'user':
    case 'client':
      return 'راكب';
    case 'driver':
      return 'سائق';
    case 'admin':
      return 'مدير';
    case 'super_admin':
      return 'مدير أعلى';
    default:
      return _text(role);
  }
}

String _driverStatusText(dynamic status) {
  switch (status?.toString()) {
    case 'pending':
      return 'قيد المراجعة';
    case 'approved':
      return 'معتمد';
    case 'rejected':
      return 'مرفوض';
    case 'suspended':
      return 'موقوف';
    case 'online':
      return 'متصل';
    case 'offline':
      return 'غير متصل';
    default:
      return _text(status);
  }
}

String _rideStatusText(dynamic status) {
  switch (status?.toString()) {
    case 'searching':
      return 'جار البحث عن سائق';
    case 'accepted':
      return 'تم قبول الرحلة';
    case 'driver_arriving':
      return 'السائق في الطريق';
    case 'in_progress':
      return 'قيد الرحلة';
    case 'completed':
      return 'مكتملة';
    case 'cancelled':
      return 'ملغاة';
    case 'pending':
      return 'معلقة';
    default:
      return _text(status);
  }
}

String _reportStatusText(dynamic status) {
  switch (status?.toString()) {
    case 'open':
      return 'مفتوح';
    case 'pending':
      return 'قيد الانتظار';
    case 'in_review':
      return 'قيد المراجعة';
    case 'resolved':
      return 'تم الحل';
    case 'rejected':
      return 'مرفوض';
    case 'closed':
      return 'مغلق';
    default:
      return _text(status);
  }
}

String _reportTypeText(dynamic type) {
  switch (type?.toString()) {
    case 'driver':
      return 'بلاغ عن سائق';
    case 'passenger':
      return 'بلاغ عن راكب';
    case 'ride':
      return 'بلاغ عن رحلة';
    case 'payment':
      return 'دفع';
    case 'safety':
      return 'سلامة';
    case 'other':
      return 'أخرى';
    default:
      return _text(type);
  }
}

String _rideTypeText(dynamic type) {
  switch (type?.toString()) {
    case 'standard':
      return 'عادية';
    case 'comfort':
      return 'مريحة';
    case 'premium':
      return 'مميزة';
    default:
      return _text(type);
  }
}

String _applicationStatusText(dynamic status) {
  switch (status?.toString()) {
    case 'pending':
      return 'قيد المراجعة';
    case 'approved':
      return 'مقبول';
    case 'rejected':
      return 'مرفوض';
    default:
      return _text(status);
  }
}

String _settingLabel(String key) {
  switch (key) {
    case 'app_name':
      return 'اسم التطبيق';
    case 'support_phone':
      return 'هاتف الدعم';
    case 'support_email':
      return 'بريد الدعم';
    case 'maintenance_mode':
      return 'وضع الصيانة';
    case 'allow_new_driver_applications':
      return 'قبول طلبات السائقين';
    case 'allow_new_rides':
      return 'السماح بالرحلات';
    default:
      return key;
  }
}

bool _isBooleanSetting(String key) {
  return key == 'maintenance_mode' ||
      key == 'allow_new_driver_applications' ||
      key == 'allow_new_rides';
}

bool _boolValue(dynamic value) {
  return value?.toString().toLowerCase() == 'true';
}

void _showSnack(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : null,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من لوحة الإدارة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  await supabase.auth.signOut();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const AdminLoginScreen(),
    ),
    (_) => false,
  );
}

// ============================================================
// LOGIN
// ============================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack(
        context,
        'أدخل البريد الإلكتروني وكلمة المرور.',
        error: true,
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('تعذر تسجيل الدخول.');
      }

      final admin = await supabase
          .from('admin_users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (admin == null ||
          admin['is_active'] != true ||
          (admin['role'] != 'admin' && admin['role'] != 'super_admin')) {
        await supabase.auth.signOut();

        throw Exception(
          'هذا الحساب ليس لديه صلاحية الدخول إلى لوحة الإدارة.',
        );
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'فشل تسجيل الدخول: ${e.toString().replaceFirst('Exception: ', '')}',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B4FE9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.local_taxi_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'NUMIZA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'لوحة الإدارة',
                        style: TextStyle(
                          color: Color(0xFF77778A),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => obscurePassword = !obscurePassword,
                              );
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: loading ? null : _login,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('تسجيل الدخول'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  final List<String> titles = const [
    'الرئيسية',
    'المستخدمون',
    'السائقون',
    'الرحلات',
    'البلاغات',
    'التسعيرة',
    'الإعدادات',
  ];

  final List<IconData> icons = const [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.drive_eta_rounded,
    Icons.route_rounded,
    Icons.report_problem_rounded,
    Icons.price_change_rounded,
    Icons.settings_rounded,
  ];

  final List<Widget> pages = const [
    _DashboardOverview(),
    _UsersPage(),
    _DriversPage(),
    _TripsPage(),
    _ReportsPage(),
    _PricingPage(),
    _AdminSettingsPage(),
  ];

  void _selectPage(int index) {
    setState(() => selectedIndex = index);

    final width = MediaQuery.of(context).size.width;

    if (width < 850) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildDrawer(bool permanent) {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Color(0xFFE8E8F0),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Row(
              children: [
                const SizedBox(width: 18),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B4FE9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_taxi_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMIZA',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Color(0xFF77778A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return _AdminMenuItem(
                    title: titles[index],
                    icon: icons[index],
                    selected: selectedIndex == index,
                    onTap: () => _selectPage(index),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _AdminMenuItem(
                title: 'تسجيل الخروج',
                icon: Icons.logout_rounded,
                selected: false,
                color: Colors.red,
                onTap: () => _confirmSignOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final permanent = constraints.maxWidth >= 850;

          return Scaffold(
            drawer: permanent ? null : Drawer(
              child: _buildDrawer(false),
            ),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.white,
              title: Text(
                titles[selectedIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              leading: permanent
                  ? null
                  : Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
            ),
            body: Row(
              children: [
                if (permanent) _buildDrawer(true),
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DASHBOARD OVERVIEW
// ============================================================

class _DashboardOverview extends StatefulWidget {
  const _DashboardOverview();

  @override
  State<_DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<_DashboardOverview> {
  bool loading = true;
  String? errorMessage;

  int users = 0;
  int drivers = 0;
  int trips = 0;
  int activeTrips = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final usersCount =
          await supabase.from('profiles').select('id').count();

      final driversCount = await supabase
          .from('profiles')
          .select('id')
          .eq('driver_status', 'approved')
          .count();

      final tripsCount =
          await supabase.from('ride_requests').select('id').count();

      final activeCount = await supabase
          .from('ride_requests')
          .select('id')
          .inFilter(
            'status',
            [
              'searching',
              'accepted',
              'driver_arriving',
              'in_progress',
            ],
          )
          .count();

      if (!mounted) return;

      setState(() {
        users = usersCount.count;
        drivers = driversCount.count;
        trips = tripsCount.count;
        activeTrips = activeCount.count;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'نظرة عامة',
              subtitle: 'إحصائيات NUMIZA الحالية',
              onRefresh: _loadStats,
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadStats,
              ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000
                      ? 4
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 3.2 : 1.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        title: 'المستخدمون',
                        value: users.toString(),
                        icon: Icons.people_alt_rounded,
                      ),
                      _StatCard(
                        title: 'السائقون المعتمدون',
                        value: drivers.toString(),
                        icon: Icons.drive_eta_rounded,
                      ),
                      _StatCard(
                        title: 'إجمالي الرحلات',
                        value: trips.toString(),
                        icon: Icons.route_rounded,
                      ),
                      _StatCard(
                        title: 'الرحلات النشطة',
                        value: activeTrips.toString(),
                        icon: Icons.navigation_rounded,
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'لوحة تحكم NUMIZA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'من هنا يمكنك إدارة المستخدمين والسائقين والرحلات '
                      'والبلاغات والتسعيرة وإعدادات التطبيق.',
                      style: TextStyle(
                        color: Color(0xFF77778A),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// USERS
// ============================================================

class _UsersPage extends StatefulWidget {
  const _UsersPage();

  @override
  State<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<_UsersPage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Map<String, dynamic>> get filteredUsers {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users.where((user) {
      final values = [
        user['full_name'],
        user['phone'],
        user['role'],
        user['driver_status'],
        user['active_mode'],
      ];

      return values.any(
        (value) => _text(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Future<void> _loadUsers() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('profiles')
          .select(
            'id,full_name,phone,role,avatar_url,created_at,updated_at,'
            'driver_status,active_mode,is_active',
          )
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        users = result
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(
    Map<String, dynamic> user,
  ) async {
    final current = user['is_active'] == true;

    try {
      await supabase
          .from('profiles')
          .update({'is_active': !current})
          .eq('id', user['id']);

      if (!mounted) return;

      _showSnack(
        context,
        current ? 'تم تعطيل الحساب.' : 'تم تفعيل الحساب.',
      );

      await _loadUsers();
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'تعذر تحديث حالة الحساب: $e',
        error: true,
      );
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تفاصيل المستخدم'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DetailRow(
                    label: 'الاسم',
                    value: _text(user['full_name']),
                  ),
                  _DetailRow(
                    label: 'الهاتف',
                    value: _text(user['phone']),
                  ),
                  _DetailRow(
                    label: 'الدور',
                    value: _roleText(user['role']),
                  ),
                  _DetailRow(
                    label: 'حالة السائق',
                    value: _driverStatusText(user['driver_status']),
                  ),
                  _DetailRow(
                    label: 'الوضع الحالي',
                    value: _driverStatusText(user['active_mode']),
                  ),
                  _DetailRow(
                    label: 'الحساب',
                    value: user['is_active'] == true
                        ? 'نشط'
                        : 'معطل',
                  ),
                  _DetailRow(
                    label: 'تاريخ الإنشاء',
                    value: _formatDate(user['created_at']),
                  ),
                  _DetailRow(
                    label: 'آخر تحديث',
                    value: _formatDate(user['updated_at']),
                  ),
                  _DetailRow(
                    label: 'المعرف',
                    value: _text(user['id']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final name = _text(user['full_name']);
    final avatar = _text(user['avatar_url']);
    final first = name != '-' && name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 22,
      backgroundImage:
          avatar != '-' ? NetworkImage(avatar) : null,
      child: avatar == '-' ? Text(first) : null,
    );
  }

  Widget _buildMobileCard(Map<String, dynamic> user) {
    final active = user['is_active'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(user['full_name']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _text(user['phone']),
                        style: const TextStyle(
                          color: Color(0xFF77778A),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  text: active ? 'نشط' : 'معطل',
                  positive: active,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الدور: ${_roleText(user['role'])}',
                  ),
                ),
                Expanded(
                  child: Text(
                    'السائق: ${_driverStatusText(user['driver_status'])}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showUserDetails(user),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('التفاصيل'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      active
                          ? Icons.block_rounded
                          : Icons.check_circle_outline,
                    ),
                    label: Text(active ? 'تعطيل' : 'تفعيل'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    final list = filteredUsers;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7FC),
          ),
          columns: const [
            DataColumn(label: Text('المستخدم')),
            DataColumn(label: Text('الهاتف')),
            DataColumn(label: Text('الدور')),
            DataColumn(label: Text('حالة السائق')),
            DataColumn(label: Text('الحساب')),
            DataColumn(label: Text('الإجراءات')),
          ],
          rows: list.map((user) {
            final active = user['is_active'] == true;

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      _buildUserAvatar(user),
                      const SizedBox(width: 10),
                      Text(_text(user['full_name'])),
                    ],
                  ),
                ),
                DataCell(Text(_text(user['phone']))),
                DataCell(Text(_roleText(user['role']))),
                DataCell(
                  _StatusBadge(
                    text: _driverStatusText(user['driver_status']),
                    positive: user['driver_status'] == 'approved',
                  ),
                ),
                DataCell(
                  _StatusBadge(
                    text: active ? 'نشط' : 'معطل',
                    positive: active,
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'التفاصيل',
                        onPressed: () => _showUserDetails(user),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      IconButton(
                        tooltip: active ? 'تعطيل' : 'تفعيل',
                        onPressed: () => _toggleUserStatus(user),
                        icon: Icon(
                          active
                              ? Icons.block_rounded
                              : Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'المستخدمون',
              subtitle: '${filteredUsers.length} مستخدم',
              onRefresh: _loadUsers,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الهاتف أو الدور...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadUsers,
              )
            else if (filteredUsers.isEmpty)
              const _EmptyView(
                icon: Icons.people_outline,
                message: 'لا توجد نتائج.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: filteredUsers
                          .map(_buildMobileCard)
                          .toList(),
                    );
                  }

                  return _buildDesktopTable();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DRIVERS
// ============================================================

class _DriversPage extends StatefulWidget {
  const _DriversPage();

  @override
  State<_DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<_DriversPage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> applications = [];

  bool loading = true;
  String? errorMessage;
  String statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_refresh);
    _loadApplications();
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  List<Map<String, dynamic>> get filteredApplications {
    final query = searchController.text.trim().toLowerCase();

    return applications.where((item) {
      final statusMatches =
          statusFilter == 'all' || item['status'] == statusFilter;

      if (!statusMatches) return false;

      if (query.isEmpty) return true;

      final values = [
        item['full_name'],
        item['phone'],
        item['license_number'],
        item['plate_number'],
        item['residence_wilaya'],
        item['vehicle_make'],
        item['vehicle_model'],
        item['status'],
      ];

      return values.any(
        (value) => _text(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Future<void> _loadApplications() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('driver_applications')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        applications = result
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _approveDriver(
    Map<String, dynamic> application,
  ) async {
    try {
      await supabase
          .from('driver_applications')
          .update({
            'status': 'approved',
            'rejection_reason': null,
          })
          .eq('id', application['id']);

      await supabase
          .from('profiles')
          .update({
            'driver_status': 'approved',
            'role': 'driver',
          })
          .eq('id', application['user_id']);

      if (!mounted) return;

      _showSnack(context, 'تم اعتماد السائق بنجاح.');
      await _loadApplications();
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'تعذر اعتماد السائق: $e',
        error: true,
      );
    }
  }

  Future<void> _rejectDriver(
    Map<String, dynamic> application,
  ) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('رفض طلب السائق'),
          content: TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض',
              hintText: 'اكتب سبب رفض الطلب...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final value = reasonController.text.trim();

                if (value.isEmpty) {
                  _showSnack(
                    context,
                    'اكتب سبب الرفض.',
                    error: true,
                  );
                  return;
                }

                Navigator.pop(context, value);
              },
              child: const Text('رفض الطلب'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null) return;

    try {
      await supabase
          .from('driver_applications')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
          })
          .eq('id', application['id']);

      await supabase
          .from('profiles')
          .update({
            'driver_status': 'rejected',
          })
          .eq('id', application['user_id']);

      if (!mounted) return;

      _showSnack(context, 'تم رفض طلب السائق.');
      await _loadApplications();
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'تعذر رفض الطلب: $e',
        error: true,
      );
    }
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تفاصيل طلب السائق'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DialogSectionTitle(
                    title: 'المعلومات الشخصية',
                  ),
                  _DetailRow(
                    label: 'الاسم',
                    value: _text(driver['full_name']),
                  ),
                  _DetailRow(
                    label: 'الهاتف',
                    value: _text(driver['phone']),
                  ),
                  _DetailRow(
                    label: 'تاريخ الميلاد',
                    value: _formatDateOnly(driver['birth_date']),
                  ),
                  _DetailRow(
                    label: 'العنوان',
                    value: _text(driver['address']),
                  ),
                  _DetailRow(
                    label: 'الولاية',
                    value: _text(driver['residence_wilaya']),
                  ),
                  const _DialogSectionTitle(
                    title: 'رخصة السياقة',
                  ),
                  _DetailRow(
                    label: 'رقم الرخصة',
                    value: _text(driver['license_number']),
                  ),
                  _DetailRow(
                    label: 'الصنف',
                    value: _text(driver['license_class']),
                  ),
                  _DetailRow(
                    label: 'تاريخ الانتهاء',
                    value: _formatDateOnly(
                      driver['license_expiry_date'],
                    ),
                  ),
                  const _DialogSectionTitle(
                    title: 'المركبة',
                  ),
                  _DetailRow(
                    label: 'النوع',
                    value: _text(driver['vehicle_type']),
                  ),
                  _DetailRow(
                    label: 'الصنف',
                    value: _text(driver['vehicle_class']),
                  ),
                  _DetailRow(
                    label: 'الصانع',
                    value: _text(driver['vehicle_make']),
                  ),
                  _DetailRow(
                    label: 'الموديل',
                    value: _text(driver['vehicle_model']),
                  ),
                  _DetailRow(
                    label: 'السنة',
                    value: _text(driver['vehicle_year']),
                  ),
                  _DetailRow(
                    label: 'اللون',
                    value: _text(driver['vehicle_color']),
                  ),
                  _DetailRow(
                    label: 'رقم اللوحة',
                    value: _text(driver['plate_number']),
                  ),
                  const _DialogSectionTitle(
                    title: 'التأمين',
                  ),
                  _DetailRow(
                    label: 'بداية التأمين',
                    value: _formatDateOnly(
                      driver['insurance_start_date'],
                    ),
                  ),
                  _DetailRow(
                    label: 'نهاية التأمين',
                    value: _formatDateOnly(
                      driver['insurance_end_date'],
                    ),
                  ),
                  const _DialogSectionTitle(
                    title: 'الوثائق',
                  ),
                  _UrlDetail(
                    label: 'صورة السيلفي',
                    url: driver['selfie_url'],
                  ),
                  _UrlDetail(
                    label: 'رخصة القيادة الأمامية',
                    url: driver['license_front_url'],
                  ),
                  _UrlDetail(
                    label: 'رخصة القيادة الخلفية',
                    url: driver['license_back_url'],
                  ),
                  _UrlDetail(
                    label: 'بطاقة التسجيل',
                    url: driver['registration_card_url'],
                  ),
                  _UrlDetail(
                    label: 'تأمين أمامي',
                    url: driver['insurance_front_url'],
                  ),
                  _UrlDetail(
                    label: 'تأمين خلفي',
                    url: driver['insurance_back_url'],
                  ),
                  _UrlDetail(
                    label: 'صورة المركبة الأمامية',
                    url: driver['vehicle_front_image_url'],
                  ),
                  _UrlDetail(
                    label: 'صورة المركبة الخلفية',
                    url: driver['vehicle_back_image_url'],
                  ),
                  const _DialogSectionTitle(
                    title: 'الحالة',
                  ),
                  _DetailRow(
                    label: 'الحالة',
                    value: _applicationStatusText(
                      driver['status'],
                    ),
                  ),
                  _DetailRow(
                    label: 'سبب الرفض',
                    value: _text(driver['rejection_reason']),
                  ),
                  _DetailRow(
                    label: 'تاريخ الطلب',
                    value: _formatDate(driver['created_at']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (driver['status'] == 'pending')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rejectDriver(driver);
                },
                child: const Text('رفض'),
              ),
            if (driver['status'] == 'pending')
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _approveDriver(driver);
                },
                child: const Text('اعتماد'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _driverCard(Map<String, dynamic> driver) {
    final pending = driver['status'] == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    _text(driver['full_name']) == '-'
                        ? '?'
                        : _text(driver['full_name'])
                            .substring(0, 1)
                            .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(driver['full_name']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _text(driver['phone']),
                        style: const TextStyle(
                          color: Color(0xFF77778A),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  text: _applicationStatusText(driver['status']),
                  positive: driver['status'] == 'approved',
                  warning: driver['status'] == 'pending',
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'المركبة: ${_text(driver['vehicle_make'])} '
              '${_text(driver['vehicle_model'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'اللوحة: ${_text(driver['plate_number'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'تاريخ الطلب: ${_formatDate(driver['created_at'])}',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showDriverDetails(driver),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('التفاصيل'),
                ),
                if (pending) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approveDriver(driver),
                      child: const Text('اعتماد'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectDriver(driver),
                      child: const Text('رفض'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7FC),
          ),
          columns: const [
            DataColumn(label: Text('السائق')),
            DataColumn(label: Text('الهاتف')),
            DataColumn(label: Text('المركبة')),
            DataColumn(label: Text('اللوحة')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('الإجراءات')),
          ],
          rows: filteredApplications.map((driver) {
            final pending = driver['status'] == 'pending';

            return DataRow(
              cells: [
                DataCell(Text(_text(driver['full_name']))),
                DataCell(Text(_text(driver['phone']))),
                DataCell(
                  Text(
                    '${_text(driver['vehicle_make'])} '
                    '${_text(driver['vehicle_model'])}',
                  ),
                ),
                DataCell(Text(_text(driver['plate_number']))),
                DataCell(
                  _StatusBadge(
                    text: _applicationStatusText(driver['status']),
                    positive: driver['status'] == 'approved',
                    warning: driver['status'] == 'pending',
                  ),
                ),
                DataCell(Text(_formatDate(driver['created_at']))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'التفاصيل',
                        onPressed: () => _showDriverDetails(driver),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      if (pending)
                        IconButton(
                          tooltip: 'اعتماد',
                          onPressed: () => _approveDriver(driver),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                      if (pending)
                        IconButton(
                          tooltip: 'رفض',
                          onPressed: () => _rejectDriver(driver),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'السائقون',
              subtitle: '${filteredApplications.length} طلب',
              onRefresh: _loadApplications,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 650) {
                  return Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'ابحث عن سائق...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'الحالة',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('كل الحالات'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('قيد المراجعة'),
                          ),
                          DropdownMenuItem(
                            value: 'approved',
                            child: Text('مقبول'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('مرفوض'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            statusFilter = value ?? 'all';
                          });
                        },
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'ابحث عن سائق...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        value: statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'الحالة',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('كل الحالات'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('قيد المراجعة'),
                          ),
                          DropdownMenuItem(
                            value: 'approved',
                            child: Text('مقبول'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('مرفوض'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            statusFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadApplications,
              )
            else if (filteredApplications.isEmpty)
              const _EmptyView(
                icon: Icons.drive_eta_outlined,
                message: 'لا توجد طلبات سائقين.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: filteredApplications
                          .map(_driverCard)
                          .toList(),
                    );
                  }

                  return _desktopTable();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TRIPS
// ============================================================

class _TripsPage extends StatefulWidget {
  const _TripsPage();

  @override
  State<_TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<_TripsPage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> trips = [];
  Map<String, Map<String, dynamic>> profiles = {};

  bool loading = true;
  String? errorMessage;
  String statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_refresh);
    _loadTrips();
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String _profileName(dynamic id) {
    if (id == null) return '-';

    return _text(profiles[id.toString()]?['full_name']);
  }

  List<Map<String, dynamic>> get filteredTrips {
    final query = searchController.text.trim().toLowerCase();

    return trips.where((trip) {
      if (statusFilter != 'all' &&
          trip['status'] != statusFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      final passenger = _profileName(trip['passenger_id']);
      final driver = _profileName(trip['driver_id']);

      final values = [
        passenger,
        driver,
        trip['pickup_address'],
        trip['destination_address'],
        trip['ride_type'],
        trip['status'],
      ];

      return values.any(
        (value) => _text(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Future<void> _loadTrips() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('ride_requests')
          .select()
          .order('created_at', ascending: false);

      final loadedTrips = result
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final ids = <String>{};

      for (final trip in loadedTrips) {
        final passengerId = trip['passenger_id']?.toString();
        final driverId = trip['driver_id']?.toString();

        if (passengerId != null) ids.add(passengerId);
        if (driverId != null) ids.add(driverId);
      }

      Map<String, Map<String, dynamic>> profileMap = {};

      if (ids.isNotEmpty) {
        final profileResult = await supabase
            .from('profiles')
            .select('id,full_name,phone')
            .inFilter('id', ids.toList());

        for (final item in profileResult) {
          final map = Map<String, dynamic>.from(item);
          profileMap[map['id'].toString()] = map;
        }
      }

      if (!mounted) return;

      setState(() {
        trips = loadedTrips;
        profiles = profileMap;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تفاصيل الرحلة'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DetailRow(
                    label: 'الراكب',
                    value: _profileName(trip['passenger_id']),
                  ),
                  _DetailRow(
                    label: 'السائق',
                    value: _profileName(trip['driver_id']),
                  ),
                  _DetailRow(
                    label: 'نوع الرحلة',
                    value: _rideTypeText(trip['ride_type']),
                  ),
                  _DetailRow(
                    label: 'الحالة',
                    value: _rideStatusText(trip['status']),
                  ),
                  _DetailRow(
                    label: 'نقطة الانطلاق',
                    value: _text(trip['pickup_address']),
                  ),
                  _DetailRow(
                    label: 'الوجهة',
                    value: _text(trip['destination_address']),
                  ),
                  _DetailRow(
                    label: 'إحداثيات الانطلاق',
                    value:
                        '${_text(trip['pickup_lat'])}, ${_text(trip['pickup_lng'])}',
                  ),
                  _DetailRow(
                    label: 'إحداثيات الوجهة',
                    value:
                        '${_text(trip['destination_lat'])}, ${_text(trip['destination_lng'])}',
                  ),
                  _DetailRow(
                    label: 'السعر التقديري',
                    value:
                        '${_text(trip['estimated_price'])} دج',
                  ),
                  _DetailRow(
                    label: 'المسافة',
                    value:
                        '${_text(trip['estimated_distance_km'])} كم',
                  ),
                  _DetailRow(
                    label: 'المدة',
                    value:
                        '${_text(trip['estimated_duration_minutes'])} دقيقة',
                  ),
                  _DetailRow(
                    label: 'تاريخ الطلب',
                    value: _formatDate(trip['created_at']),
                  ),
                  _DetailRow(
                    label: 'وقت القبول',
                    value: _formatDate(trip['accepted_at']),
                  ),
                  _DetailRow(
                    label: 'وقت البدء',
                    value: _formatDate(trip['started_at']),
                  ),
                  _DetailRow(
                    label: 'وقت الإكمال',
                    value: _formatDate(trip['completed_at']),
                  ),
                  _DetailRow(
                    label: 'وقت الإلغاء',
                    value: _formatDate(trip['cancelled_at']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _tripCard(Map<String, dynamic> trip) {
    final status = trip['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _profileName(trip['passenger_id']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusBadge(
                  text: _rideStatusText(status),
                  positive: status == 'completed',
                  warning: status == 'searching' ||
                      status == 'accepted' ||
                      status == 'driver_arriving' ||
                      status == 'in_progress',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'السائق: ${_profileName(trip['driver_id'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'من: ${_text(trip['pickup_address'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'إلى: ${_text(trip['destination_address'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'النوع: ${_rideTypeText(trip['ride_type'])}',
            ),
            const SizedBox(height: 6),
            Text(
              'السعر: ${_text(trip['estimated_price'])} دج',
            ),
            const SizedBox(height: 6),
            Text(
              'التاريخ: ${_formatDate(trip['created_at'])}',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showTripDetails(trip),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('عرض التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7FC),
          ),
          columns: const [
            DataColumn(label: Text('الراكب')),
            DataColumn(label: Text('السائق')),
            DataColumn(label: Text('المسار')),
            DataColumn(label: Text('النوع')),
            DataColumn(label: Text('السعر')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('')),
          ],
          rows: filteredTrips.map((trip) {
            final status = trip['status'];

            return DataRow(
              cells: [
                DataCell(
                  Text(_profileName(trip['passenger_id'])),
                ),
                DataCell(
                  Text(_profileName(trip['driver_id'])),
                ),
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      '${_text(trip['pickup_address'])} → '
                      '${_text(trip['destination_address'])}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(_rideTypeText(trip['ride_type'])),
                ),
                DataCell(
                  Text('${_text(trip['estimated_price'])} دج'),
                ),
                DataCell(
                  _StatusBadge(
                    text: _rideStatusText(status),
                    positive: status == 'completed',
                    warning: status != 'completed' &&
                        status != 'cancelled',
                  ),
                ),
                DataCell(
                  Text(_formatDate(trip['created_at'])),
                ),
                DataCell(
                  IconButton(
                    tooltip: 'التفاصيل',
                    onPressed: () => _showTripDetails(trip),
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'الرحلات',
              subtitle: '${filteredTrips.length} رحلة',
              onRefresh: _loadTrips,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final search = TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن رحلة أو راكب أو سائق...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );

                final filter = DropdownButtonFormField<String>(
                  value: statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('كل الحالات'),
                    ),
                    DropdownMenuItem(
                      value: 'searching',
                      child: Text('جار البحث'),
                    ),
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('مقبولة'),
                    ),
                    DropdownMenuItem(
                      value: 'driver_arriving',
                      child: Text('السائق في الطريق'),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('قيد الرحلة'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('مكتملة'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('ملغاة'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value ?? 'all';
                    });
                  },
                );

                if (constraints.maxWidth < 700) {
                  return Column(
                    children: [
                      search,
                      const SizedBox(height: 12),
                      filter,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: filter),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadTrips,
              )
            else if (filteredTrips.isEmpty)
              const _EmptyView(
                icon: Icons.route_outlined,
                message: 'لا توجد رحلات.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: filteredTrips.map(_tripCard).toList(),
                    );
                  }

                  return _desktopTable();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REPORTS
// ============================================================

class _ReportsPage extends StatefulWidget {
  const _ReportsPage();

  @override
  State<_ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<_ReportsPage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> reports = [];
  Map<String, Map<String, dynamic>> profiles = {};

  bool loading = true;
  String? errorMessage;
  String statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_refresh);
    _loadReports();
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String _profileName(dynamic id) {
    if (id == null) return '-';

    return _text(profiles[id.toString()]?['full_name']);
  }

  List<Map<String, dynamic>> get filteredReports {
    final query = searchController.text.trim().toLowerCase();

    return reports.where((report) {
      if (statusFilter != 'all' &&
          report['status'] != statusFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      final values = [
        report['subject'],
        report['description'],
        report['type'],
        report['status'],
        _profileName(report['reporter_id']),
        _profileName(report['reported_user_id']),
      ];

      return values.any(
        (value) => _text(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Future<void> _loadReports() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      final loaded = result
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final ids = <String>{};

      for (final report in loaded) {
        final reporter = report['reporter_id']?.toString();
        final reported = report['reported_user_id']?.toString();

        if (reporter != null) ids.add(reporter);
        if (reported != null) ids.add(reported);
      }

      Map<String, Map<String, dynamic>> profileMap = {};

      if (ids.isNotEmpty) {
        final profileResult = await supabase
            .from('profiles')
            .select('id,full_name,phone')
            .inFilter('id', ids.toList());

        for (final item in profileResult) {
          final map = Map<String, dynamic>.from(item);
          profileMap[map['id'].toString()] = map;
        }
      }

      if (!mounted) return;

      setState(() {
        reports = loaded;
        profiles = profileMap;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _updateReport(
    Map<String, dynamic> report,
  ) async {
    final noteController = TextEditingController(
      text: _text(report['admin_note']) == '-'
          ? ''
          : _text(report['admin_note']),
    );

    String selectedStatus =
        report['status']?.toString() ?? 'open';

    final initialStatus = selectedStatus;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final options = <String>[
          'open',
          'in_review',
          'resolved',
          'rejected',
          'closed',
        ];

        if (!options.contains(selectedStatus)) {
          options.insert(0, selectedStatus);
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تحديث البلاغ'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'الحالة',
                      ),
                      items: options.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            _reportStatusText(status),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: noteController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'الملاحظة الإدارية',
                        hintText: 'أضف ملاحظة للبلاغ...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      noteController.dispose();
      return;
    }

    try {
      await supabase
          .from('reports')
          .update({
            'status': selectedStatus,
            'admin_note': noteController.text.trim(),
          })
          .eq('id', report['id']);

      noteController.dispose();

      if (!mounted) return;

      _showSnack(
        context,
        initialStatus == selectedStatus
            ? 'تم تحديث البلاغ.'
            : 'تم تغيير حالة البلاغ.',
      );

      await _loadReports();
    } catch (e) {
      noteController.dispose();

      if (!mounted) return;

      _showSnack(
        context,
        'تعذر تحديث البلاغ: $e',
        error: true,
      );
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تفاصيل البلاغ'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DetailRow(
                    label: 'الموضوع',
                    value: _text(report['subject']),
                  ),
                  _DetailRow(
                    label: 'النوع',
                    value: _reportTypeText(report['type']),
                  ),
                  _DetailRow(
                    label: 'المبلّغ',
                    value: _profileName(report['reporter_id']),
                  ),
                  _DetailRow(
                    label: 'المبلّغ عنه',
                    value: _profileName(
                      report['reported_user_id'],
                    ),
                  ),
                  _DetailRow(
                    label: 'الرحلة',
                    value: _text(report['ride_id']),
                  ),
                  _DetailRow(
                    label: 'الحالة',
                    value: _reportStatusText(report['status']),
                  ),
                  _DetailRow(
                    label: 'الوصف',
                    value: _text(report['description']),
                  ),
                  _DetailRow(
                    label: 'الملاحظة الإدارية',
                    value: _text(report['admin_note']),
                  ),
                  _DetailRow(
                    label: 'تاريخ البلاغ',
                    value: _formatDate(report['created_at']),
                  ),
                  _DetailRow(
                    label: 'آخر تحديث',
                    value: _formatDate(report['updated_at']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _updateReport(report);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('تحديث'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _reportCard(Map<String, dynamic> report) {
    final status = report['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _text(report['subject']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusBadge(
                  text: _reportStatusText(status),
                  positive: status == 'resolved',
                  warning: status == 'open' ||
                      status == 'pending' ||
                      status == 'in_review',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'النوع: ${_reportTypeText(report['type'])}',
            ),
            const SizedBox(height: 5),
            Text(
              'المبلّغ: ${_profileName(report['reporter_id'])}',
            ),
            const SizedBox(height: 5),
            Text(
              'المبلّغ عنه: ${_profileName(report['reported_user_id'])}',
            ),
            const SizedBox(height: 5),
            Text(
              'التاريخ: ${_formatDate(report['created_at'])}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showReportDetails(report),
                    child: const Text('التفاصيل'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _updateReport(report),
                    child: const Text('تحديث'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7FC),
          ),
          columns: const [
            DataColumn(label: Text('الموضوع')),
            DataColumn(label: Text('النوع')),
            DataColumn(label: Text('المبلّغ')),
            DataColumn(label: Text('المبلّغ عنه')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('')),
          ],
          rows: filteredReports.map((report) {
            final status = report['status'];

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Text(
                      _text(report['subject']),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(_reportTypeText(report['type'])),
                ),
                DataCell(
                  Text(_profileName(report['reporter_id'])),
                ),
                DataCell(
                  Text(
                    _profileName(report['reported_user_id']),
                  ),
                ),
                DataCell(
                  _StatusBadge(
                    text: _reportStatusText(status),
                    positive: status == 'resolved',
                    warning: status == 'open' ||
                        status == 'pending' ||
                        status == 'in_review',
                  ),
                ),
                DataCell(
                  Text(_formatDate(report['created_at'])),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'التفاصيل',
                        onPressed: () =>
                            _showReportDetails(report),
                        icon: const Icon(
                          Icons.visibility_outlined,
                        ),
                      ),
                      IconButton(
                        tooltip: 'تحديث',
                        onPressed: () => _updateReport(report),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'البلاغات',
              subtitle: '${filteredReports.length} بلاغ',
              onRefresh: _loadReports,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final search = TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'ابحث في البلاغات...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );

                final filter = DropdownButtonFormField<String>(
                  value: statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('كل الحالات'),
                    ),
                    DropdownMenuItem(
                      value: 'open',
                      child: Text('مفتوح'),
                    ),
                    DropdownMenuItem(
                      value: 'in_review',
                      child: Text('قيد المراجعة'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('تم الحل'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('مرفوض'),
                    ),
                    DropdownMenuItem(
                      value: 'closed',
                      child: Text('مغلق'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value ?? 'all';
                    });
                  },
                );

                if (constraints.maxWidth < 700) {
                  return Column(
                    children: [
                      search,
                      const SizedBox(height: 12),
                      filter,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: filter),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadReports,
              )
            else if (filteredReports.isEmpty)
              const _EmptyView(
                icon: Icons.report_problem_outlined,
                message: 'لا توجد بلاغات.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: filteredReports.map(_reportCard).toList(),
                    );
                  }

                  return _desktopTable();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRICING
// ============================================================

class _PricingPage extends StatefulWidget {
  const _PricingPage();

  @override
  State<_PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<_PricingPage> {
  List<Map<String, dynamic>> pricing = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

  Future<void> _loadPricing() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('pricing_settings')
          .select()
          .order('ride_type');

      if (!mounted) return;

      setState(() {
        pricing = result
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _showPricingDialog({
    Map<String, dynamic>? existing,
  }) async {
    final rideTypeController = TextEditingController(
      text: existing?['ride_type']?.toString() ?? '',
    );

    final baseController = TextEditingController(
      text: existing?['base_price']?.toString() ?? '',
    );

    final perKmController = TextEditingController(
      text: existing?['price_per_km']?.toString() ?? '',
    );

    final perMinuteController = TextEditingController(
      text: existing?['price_per_minute']?.toString() ?? '',
    );

    final minimumController = TextEditingController(
      text: existing?['minimum_price']?.toString() ?? '',
    );

    bool active = existing?['is_active'] == true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? 'إضافة تسعيرة'
                    : 'تعديل التسعيرة',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: rideTypeController,
                        enabled: existing == null,
                        decoration: const InputDecoration(
                          labelText: 'نوع الرحلة',
                          hintText: 'مثال: standard',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: baseController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'السعر الأساسي',
                          suffixText: 'دج',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: perKmController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'السعر لكل كيلومتر',
                          suffixText: 'دج',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: perMinuteController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'السعر لكل دقيقة',
                          suffixText: 'دج',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: minimumController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'الحد الأدنى للسعر',
                          suffixText: 'دج',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('التسعيرة مفعلة'),
                        value: active,
                        onChanged: (value) {
                          setDialogState(() {
                            active = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      rideTypeController.dispose();
      baseController.dispose();
      perKmController.dispose();
      perMinuteController.dispose();
      minimumController.dispose();
      return;
    }

    final rideType = rideTypeController.text.trim();
    final base = double.tryParse(baseController.text.trim());
    final perKm = double.tryParse(perKmController.text.trim());
    final perMinute =
        double.tryParse(perMinuteController.text.trim());
    final minimum =
        double.tryParse(minimumController.text.trim());

    if (rideType.isEmpty ||
        base == null ||
        perKm == null ||
        perMinute == null ||
        minimum == null) {
      _showSnack(
        context,
        'تأكد من إدخال نوع الرحلة وجميع الأسعار بشكل صحيح.',
        error: true,
      );

      rideTypeController.dispose();
      baseController.dispose();
      perKmController.dispose();
      perMinuteController.dispose();
      minimumController.dispose();

      return;
    }

    try {
      if (existing == null) {
        await supabase.from('pricing_settings').insert({
          'ride_type': rideType,
          'base_price': base,
          'price_per_km': perKm,
          'price_per_minute': perMinute,
          'minimum_price': minimum,
          'is_active': active,
        });
      } else {
        await supabase
            .from('pricing_settings')
            .update({
              'base_price': base,
              'price_per_km': perKm,
              'price_per_minute': perMinute,
              'minimum_price': minimum,
              'is_active': active,
            })
            .eq('id', existing['id']);
      }

      if (!mounted) return;

      _showSnack(context, 'تم حفظ التسعيرة.');
      await _loadPricing();
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'تعذر حفظ التسعيرة: $e',
        error: true,
      );
    } finally {
      rideTypeController.dispose();
      baseController.dispose();
      perKmController.dispose();
      perMinuteController.dispose();
      minimumController.dispose();
    }
  }

  Widget _pricingCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _rideTypeText(item['ride_type']),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusBadge(
                  text: item['is_active'] == true
                      ? 'مفعلة'
                      : 'متوقفة',
                  positive: item['is_active'] == true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'السعر الأساسي: ${_text(item['base_price'])} دج',
            ),
            const SizedBox(height: 6),
            Text(
              'لكل كم: ${_text(item['price_per_km'])} دج',
            ),
            const SizedBox(height: 6),
            Text(
              'لكل دقيقة: ${_text(item['price_per_minute'])} دج',
            ),
            const SizedBox(height: 6),
            Text(
              'الحد الأدنى: ${_text(item['minimum_price'])} دج',
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _showPricingDialog(
                existing: item,
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('تعديل'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7FC),
          ),
          columns: const [
            DataColumn(label: Text('نوع الرحلة')),
            DataColumn(label: Text('الأساسي')),
            DataColumn(label: Text('لكل كم')),
            DataColumn(label: Text('لكل دقيقة')),
            DataColumn(label: Text('الحد الأدنى')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('')),
          ],
          rows: pricing.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Text(_rideTypeText(item['ride_type'])),
                ),
                DataCell(
                  Text('${_text(item['base_price'])} دج'),
                ),
                DataCell(
                  Text('${_text(item['price_per_km'])} دج'),
                ),
                DataCell(
                  Text('${_text(item['price_per_minute'])} دج'),
                ),
                DataCell(
                  Text('${_text(item['minimum_price'])} دج'),
                ),
                DataCell(
                  _StatusBadge(
                    text: item['is_active'] == true
                        ? 'مفعلة'
                        : 'متوقفة',
                    positive: item['is_active'] == true,
                  ),
                ),
                DataCell(
                  IconButton(
                    tooltip: 'تعديل',
                    onPressed: () => _showPricingDialog(
                      existing: item,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPricing,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'التسعيرة',
              subtitle: 'إدارة أسعار الرحلات',
              onRefresh: _loadPricing,
              action: FilledButton.icon(
                onPressed: () => _showPricingDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة تسعيرة'),
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadPricing,
              )
            else if (pricing.isEmpty)
              const _EmptyView(
                icon: Icons.price_change_outlined,
                message: 'لا توجد إعدادات تسعيرة.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: pricing.map(_pricingCard).toList(),
                    );
                  }

                  return _desktopTable();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// APP SETTINGS
// ============================================================

class _AdminSettingsPage extends StatefulWidget {
  const _AdminSettingsPage();

  @override
  State<_AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<_AdminSettingsPage> {
  List<Map<String, dynamic>> settings = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await supabase
          .from('app_settings')
          .select()
          .order('setting_key');

      if (!mounted) return;

      setState(() {
        settings = result
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _showSettingDialog({
    Map<String, dynamic>? existing,
  }) async {
    final keyController = TextEditingController(
      text: existing?['setting_key']?.toString() ?? '',
    );

    final valueController = TextEditingController(
      text: existing?['setting_value']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: existing?['description']?.toString() ?? '',
    );

    bool boolValue = _boolValue(existing?['setting_value']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final key = keyController.text.trim();
            final booleanSetting = _isBooleanSetting(key);

            return AlertDialog(
              title: Text(
                existing == null
                    ? 'إضافة إعداد'
                    : 'تعديل الإعداد',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: keyController,
                        enabled: existing == null,
                        onChanged: (_) {
                          setDialogState(() {});
                        },
                        decoration: const InputDecoration(
                          labelText: 'مفتاح الإعداد',
                          hintText: 'مثال: maintenance_mode',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (booleanSetting)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _settingLabel(key),
                          ),
                          value: boolValue,
                          onChanged: (value) {
                            setDialogState(() {
                              boolValue = value;
                            });
                            valueController.text =
                                value.toString();
                          },
                        )
                      else
                        TextField(
                          controller: valueController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'القيمة',
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      keyController.dispose();
      valueController.dispose();
      descriptionController.dispose();
      return;
    }

    final key = keyController.text.trim();
    final value = valueController.text.trim();
    final description = descriptionController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showSnack(
        context,
        'مفتاح الإعداد والقيمة مطلوبان.',
        error: true,
      );

      keyController.dispose();
      valueController.dispose();
      descriptionController.dispose();

      return;
    }

    try {
      if (existing == null) {
        await supabase.from('app_settings').insert({
          'setting_key': key,
          'setting_value': value,
          'description': description,
        });
      } else {
        await supabase
            .from('app_settings')
            .update({
              'setting_value': value,
              'description': description,
            })
            .eq('id', existing['id']);
      }

      if (!mounted) return;

      _showSnack(context, 'تم حفظ الإعداد.');
      await _loadSettings();
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        context,
        'تعذر حفظ الإعداد: $e',
        error: true,
      );
    } finally {
      keyController.dispose();
      valueController.dispose();
      descriptionController.dispose();
    }
  }

  Widget _settingCard(Map<String, dynamic> setting) {
    final key = _text(setting['setting_key']);
    final value = _text(setting['setting_value']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFF5B4FE9).withOpacity(0.1),
          child: Icon(
            _isBooleanSetting(key)
                ? Icons.toggle_on_outlined
                : Icons.tune_rounded,
            color: const Color(0xFF5B4FE9),
          ),
        ),
        title: Text(
          _settingLabel(key),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            _isBooleanSetting(key)
                ? (_boolValue(value) ? 'مفعل' : 'غير مفعل')
                : value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: IconButton(
          tooltip: 'تعديل',
          onPressed: () => _showSettingDialog(
            existing: setting,
          ),
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSettings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: 'إعدادات التطبيق',
              subtitle: 'إدارة إعدادات NUMIZA العامة',
              onRefresh: _loadSettings,
              action: FilledButton.icon(
                onPressed: () => _showSettingDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة إعداد'),
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(
                message: errorMessage!,
                onRetry: _loadSettings,
              )
            else if (settings.isEmpty)
              const _EmptyView(
                icon: Icons.settings_outlined,
                message: 'لا توجد إعدادات.',
              )
            else
              Column(
                children: settings.map(_settingCard).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;
  final Widget? action;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.onRefresh,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF77778A),
              ),
            ),
          ],
        );

        final buttons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action != null) action!,
            if (action != null) const SizedBox(width: 8),
            if (onRefresh != null)
              IconButton(
                tooltip: 'تحديث',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        );

        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: buttons,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleBlock),
            buttons,
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FE9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Color(0xFF5B4FE9),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF77778A),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ??
        (selected
            ? const Color(0xFF5B4FE9)
            : const Color(0xFF555568));

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected
            ? const Color(0xFF5B4FE9).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: itemColor,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final bool positive;
  final bool warning;

  const _StatusBadge({
    required this.text,
    this.positive = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color foreground;

    if (positive) {
      foreground = Colors.green.shade700;
    } else if (warning) {
      foreground = Colors.orange.shade700;
    } else {
      foreground = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: foreground.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8E8F0),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF77778A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogSectionTitle extends StatelessWidget {
  final String title;

  const _DialogSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 5,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF5B4FE9),
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _UrlDetail extends StatefulWidget {
  final String label;
  final dynamic url;

  const _UrlDetail({
    required this.label,
    required this.url,
  });

  @override
  State<_UrlDetail> createState() => _UrlDetailState();
}

class _UrlDetailState extends State<_UrlDetail> {
  String? imageUrl;
  String? errorMessage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final rawPath = widget.url?.toString().trim() ?? '';

    if (rawPath.isEmpty || rawPath == 'null') {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      return;
    }

    try {
      String path = rawPath;

      // إذا كانت القيمة المخزنة رابط Supabase كامل
      // نستخرج منه مسار الملف داخل Bucket.
      if (path.startsWith('http://') ||
          path.startsWith('https://')) {
        final uri = Uri.parse(path);

        const marker = '/storage/v1/object/';
        final index = uri.path.indexOf(marker);

        if (index != -1) {
          var storagePath =
              uri.path.substring(index + marker.length);

          // public/driver-documents/...
          // authenticated/driver-documents/...
          // sign/driver-documents/...
          final parts = storagePath.split('/');

          if (parts.isNotEmpty) {
            if (parts.first == 'public' ||
                parts.first == 'authenticated' ||
                parts.first == 'sign') {
              parts.removeAt(0);
            }
          }

          if (parts.isNotEmpty &&
              parts.first == 'driver-documents') {
            parts.removeAt(0);
          }

          path = parts.join('/');
        }
      }

      // إنشاء رابط مؤقت للوثيقة.
      final signedUrl = await supabase.storage
          .from('driver-documents')
          .createSignedUrl(
            path,
            60 * 60,
          );

      if (!mounted) return;

      setState(() {
        imageUrl = signedUrl;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE8E8F0),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade100,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage == null
                      ? '${widget.label}: الوثيقة غير موجودة'
                      : '${widget.label}: تعذر تحميل الوثيقة',
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE8E8F0),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              color: const Color(0xFFF7F7FC),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 220,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (
                  context,
                  child,
                  progress,
                ) {
                  if (progress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Text(
                      'تعذر عرض الوثيقة',
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(10),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showFullImage(
                    context,
                    widget.label,
                    imageUrl!,
                  );
                },
                icon: const Icon(
                  Icons.zoom_in,
                ),
                label: const Text(
                  'عرض بالحجم الكامل',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(
    BuildContext context,
    String title,
    String url,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBox({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade800,
                ),
              ),
            ),
            if (onRetry != null)
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyView({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 55,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 54,
              color: const Color(0xFF77778A),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF77778A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
