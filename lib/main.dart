import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL');

const String supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

const Color primaryColor = Color(0xFF5B4FE9);
const Color darkColor = Color(0xFF151525);
const Color backgroundColor = Color(0xFFF7F7FC);
const Color borderColor = Color(0xFFE8E8F0);
const Color secondaryTextColor = Color(0xFF77778A);

SupabaseClient get supabase => Supabase.instance.client;

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
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Arial',
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: AdminLoginScreen(),
      ),
    );
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'إعدادات Supabase غير موجودة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _message('أدخل البريد الإلكتروني وكلمة المرور.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        _message('تعذر تسجيل الدخول.');
        return;
      }

      final admin = await supabase
          .from('admin_users')
          .select('id, full_name, role, is_active')
          .eq('id', user.id)
          .maybeSingle();

      if (admin == null) {
        await supabase.auth.signOut();
        _message(
          'هذا الحساب غير مصرح له بالدخول إلى لوحة الإدارة.',
        );
        return;
      }

      final isActive = admin['is_active'] == true;
      final role = admin['role']?.toString();

      if (!isActive ||
          (role != 'super_admin' && role != 'admin')) {
        await supabase.auth.signOut();

        _message(
          'ليس لديك صلاحية للوصول إلى لوحة الإدارة.',
        );
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } on AuthException catch (e) {
      _message(e.message);
    } catch (e) {
      _message('حدث خطأ أثناء تسجيل الدخول.');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(
                  color: borderColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(21),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'NUMIZA Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: darkColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'لوحة إدارة منصة NUMIZA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textDirection: TextDirection.ltr,
                      onSubmitted: (_) => login(),
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
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
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    _DashboardOverview(),
    _UsersPage(),
    _DriversPage(),
    _TripsPage(),
    _ReportsPage(),
    _PricingPage(),
    _AdminSettingsPage(),
  ];

  final List<_AdminMenuItem> menuItems = const [
    _AdminMenuItem(
      icon: Icons.dashboard_rounded,
      title: 'الرئيسية',
    ),
    _AdminMenuItem(
      icon: Icons.people_alt_rounded,
      title: 'المستخدمون',
    ),
    _AdminMenuItem(
      icon: Icons.drive_eta_rounded,
      title: 'السائقون',
    ),
    _AdminMenuItem(
      icon: Icons.local_taxi_rounded,
      title: 'الرحلات',
    ),
    _AdminMenuItem(
      icon: Icons.report_problem_rounded,
      title: 'البلاغات',
    ),
    _AdminMenuItem(
      icon: Icons.payments_rounded,
      title: 'التسعيرة',
    ),
    _AdminMenuItem(
      icon: Icons.settings_rounded,
      title: 'الإعدادات',
    ),
  ];

  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
      (route) => false,
    );
  }

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;

          return Scaffold(
            backgroundColor: backgroundColor,
            drawer: mobile ? _buildDrawer() : null,
            appBar: mobile
                ? _buildMobileAppBar()
                : null,
            body: Row(
              children: [
                if (!mobile) _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      if (!mobile)
                        _buildDesktopTopBar(),
                      Expanded(
                        child: pages[selectedIndex],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Text(
        menuItems[selectedIndex].title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: darkColor,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'تسجيل الخروج',
          onPressed: () => logout(context),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      backgroundColor: darkColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            const Text(
              'NUMIZA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'لوحة الإدارة',
              style: TextStyle(
                color: Color(0xFFB8B8C8),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(index);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: darkColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const Text(
              'NUMIZA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'لوحة الإدارة',
              style: TextStyle(
                color: Color(0xFFB8B8C8),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 35),

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(index);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final item = menuItems[index];
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => selectPage(index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected
                    ? Colors.white
                    : const Color(0xFFB8B8C8),
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFFD0D0DA),
                    fontSize: 14,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => logout(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF343446),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF8A8A),
              size: 21,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Color(0xFFFF8A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            menuItems[selectedIndex].title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.admin_panel_settings_rounded,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          const Text(
            'مدير NUMIZA',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF555566),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class _DashboardOverview extends StatefulWidget {
  const _DashboardOverview();

  @override
  State<_DashboardOverview> createState() =>
      _DashboardOverviewState();
}

class _DashboardOverviewState
    extends State<_DashboardOverview> {
  bool loading = true;
  String? errorMessage;

  int usersCount = 0;
  int approvedDriversCount = 0;
  int pendingDriversCount = 0;
  int ridesCount = 0;
  int activeRidesCount = 0;
  int reportsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final users = await supabase
          .from('profiles')
          .select('id');

      final approvedDrivers = await supabase
          .from('profiles')
          .select('id')
          .eq('driver_status', 'approved');

      final pendingDrivers = await supabase
          .from('driver_applications')
          .select('id')
          .eq('status', 'pending');

      final rides = await supabase
          .from('ride_requests')
          .select('id');

      final activeRides = await supabase
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
      );

      int reports = 0;

      try {
        final reportData = await supabase
            .from('reports')
            .select('id')
            .eq('status', 'pending');

        reports = (reportData as List).length;
      } catch (_) {
        reports = 0;
      }

      if (!mounted) return;

      setState(() {
        usersCount = (users as List).length;
        approvedDriversCount =
            (approvedDrivers as List).length;
        pendingDriversCount =
            (pendingDrivers as List).length;
        ridesCount = (rides as List).length;
        activeRidesCount =
            (activeRides as List).length;
        reportsCount = reports;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage =
            'تعذر تحميل إحصائيات لوحة الإدارة.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = width < 600 ? 16.0 : 28.0;

        return RefreshIndicator(
          onRefresh: _loadStatistics,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildHeader(width),

                const SizedBox(height: 24),

                if (errorMessage != null)
                  _buildError(),

                _buildStats(width),

                const SizedBox(height: 24),

                _buildPlatformStatus(width),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double width) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بك في لوحة إدارة NUMIZA',
                style: TextStyle(
                  fontSize: width < 600 ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'نظرة عامة على المستخدمين والسائقين والرحلات.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed:
              loading ? null : _loadStatistics,
          icon: loading
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  size: 19,
                ),
          label: const Text('تحديث'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD5D5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD64545),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F3030),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadStatistics,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(double width) {
    int columns;

    if (width < 600) {
      columns = 1;
    } else if (width < 950) {
      columns = 2;
    } else if (width < 1250) {
      columns = 3;
    } else {
      columns = 4;
    }

    final cards = [
      _StatCard(
        icon: Icons.people_alt_rounded,
        title: 'المستخدمون',
        value:
            loading ? '...' : usersCount.toString(),
        subtitle: 'إجمالي الحسابات',
      ),
      _StatCard(
        icon: Icons.drive_eta_rounded,
        title: 'السائقون',
        value: loading
            ? '...'
            : approvedDriversCount.toString(),
        subtitle: 'سائقون معتمدون',
      ),
      _StatCard(
        icon: Icons.local_taxi_rounded,
        title: 'الرحلات',
        value:
            loading ? '...' : ridesCount.toString(),
        subtitle: 'إجمالي الرحلات',
      ),
      _StatCard(
        icon: Icons.route_rounded,
        title: 'رحلات نشطة',
        value: loading
            ? '...'
            : activeRidesCount.toString(),
        subtitle: 'قيد التنفيذ أو البحث',
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio:
            width < 600 ? 2.3 : 1.75,
      ),
      itemBuilder: (_, index) => cards[index],
    );
  }

  Widget _buildPlatformStatus(double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        width < 600 ? 18 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: primaryColor,
              ),
              SizedBox(width: 10),
              Text(
                'حالة المنصة',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _OverviewRow(
            icon: Icons.people_alt_rounded,
            title: 'المستخدمون المسجلون',
            value: loading
                ? '...'
                : usersCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.drive_eta_rounded,
            title: 'السائقون المعتمدون',
            value: loading
                ? '...'
                : approvedDriversCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.pending_actions_rounded,
            title: 'طلبات السائقين المعلقة',
            value: loading
                ? '...'
                : pendingDriversCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.local_taxi_rounded,
            title: 'إجمالي الرحلات',
            value: loading
                ? '...'
                : ridesCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.sync_rounded,
            title: 'الرحلات النشطة',
            value: loading
                ? '...'
                : activeRidesCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.report_problem_rounded,
            title: 'البلاغات المعلقة',
            value: loading
                ? '...'
                : reportsCount.toString(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9999AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _OverviewRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primaryColor.withValues(
              alpha: 0.08,
            ),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555566),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: darkColor,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COMMON HELPERS
// ============================================================

String formatDate(dynamic value) {
  if (value == null) return 'غير متوفر';

  try {
    final date = DateTime.parse(value.toString()).toLocal();

    String two(int n) => n.toString().padLeft(2, '0');

    return '${date.year}/${two(date.month)}/${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  } catch (_) {
    return value.toString();
  }
}

String textValue(dynamic value) {
  if (value == null) return 'غير متوفر';

  final text = value.toString().trim();

  return text.isEmpty ? 'غير متوفر' : text;
}

String roleText(dynamic value) {
  switch (value?.toString()) {
    case 'driver':
      return 'سائق';
    case 'passenger':
      return 'راكب';
    case 'admin':
      return 'مدير';
    case 'super_admin':
      return 'مدير رئيسي';
    default:
      return textValue(value);
  }
}

String driverStatusText(dynamic value) {
  switch (value?.toString()) {
    case 'approved':
      return 'معتمد';
    case 'pending':
      return 'قيد المراجعة';
    case 'rejected':
      return 'مرفوض';
    case 'suspended':
      return 'موقوف';
    default:
      return textValue(value);
  }
}

String rideStatusText(dynamic value) {
  switch (value?.toString()) {
    case 'searching':
      return 'البحث عن سائق';
    case 'accepted':
      return 'تم قبول الرحلة';
    case 'driver_arriving':
      return 'السائق في الطريق';
    case 'in_progress':
      return 'الرحلة جارية';
    case 'completed':
      return 'مكتملة';
    case 'cancelled':
      return 'ملغاة';
    default:
      return textValue(value);
  }
}

String reportStatusText(dynamic value) {
  switch (value?.toString()) {
    case 'pending':
      return 'قيد المراجعة';
    case 'reviewing':
      return 'قيد المعالجة';
    case 'resolved':
      return 'تم الحل';
    case 'rejected':
      return 'مرفوض';
    default:
      return textValue(value);
  }
}

String rideTypeText(dynamic value) {
  switch (value?.toString()) {
    case 'standard':
      return 'عادية';
    case 'comfort':
      return 'مريحة';
    case 'premium':
      return 'فاخرة';
    default:
      return textValue(value);
  }
}

void showAppMessage(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor:
          error ? Colors.red.shade700 : null,
      content: Text(message),
    ),
  );
}

// ============================================================
// MENU MODEL
// ============================================================

class _AdminMenuItem {
  final IconData icon;
  final String title;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
  });
}

