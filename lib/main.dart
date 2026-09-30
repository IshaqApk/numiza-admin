import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL');

const String supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

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
          seedColor: const Color(0xFF5B4FE9),
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Supabase configuration is missing.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

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
      showMessage('أدخل البريد الإلكتروني وكلمة المرور.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
  showMessage('تعذر تسجيل الدخول.');
  return;
}

final user = response.user!;

final admin = await Supabase.instance.client
    .from('admin_users')
    .select('id, full_name, role, is_active')
    .eq('id', user.id)
    .maybeSingle();

if (admin == null) {
  await Supabase.instance.client.auth.signOut();

  showMessage(
    'هذا الحساب غير مصرح له بالدخول إلى لوحة الإدارة.',
  );
  return;
}

final isActive = admin['is_active'] == true;
final role = admin['role']?.toString();

if (!isActive ||
    (role != 'super_admin' && role != 'admin')) {
  await Supabase.instance.client.auth.signOut();

  showMessage(
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
      showMessage(e.message);
    } catch (_) {
      showMessage('حدث خطأ أثناء تسجيل الدخول.');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FC),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(
                    color: Color(0xFFE8E8F0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B4FE9),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'NUMIZA Admin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لوحة إدارة منصة NUMIZA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
                          prefixIcon:
                              const Icon(Icons.email_outlined),
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
                          prefixIcon:
                              const Icon(Icons.lock_outline),
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
                          onPressed:
                              loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF5B4FE9),
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
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;
  bool sidebarOpen = false;

  final List<Widget> pages = const [
    _DashboardOverview(),
    _ComingSoonPage(
      icon: Icons.people_alt_rounded,
      title: 'المستخدمون',
    ),
    _ComingSoonPage(
      icon: Icons.drive_eta_rounded,
      title: 'السائقون',
    ),
    _ComingSoonPage(
      icon: Icons.local_taxi_rounded,
      title: 'الرحلات',
    ),
    _ComingSoonPage(
      icon: Icons.report_problem_rounded,
      title: 'البلاغات',
    ),
    _ComingSoonPage(
      icon: Icons.payments_rounded,
      title: 'التسعيرة',
    ),
    _ComingSoonPage(
      icon: Icons.settings_rounded,
      title: 'الإعدادات',
    ),
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
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
      (route) => false,
    );
  }

  bool _isMobile(double width) {
    return width < 700;
  }

  void _selectPage(int index) {
    setState(() {
      selectedIndex = index;
      sidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = _isMobile(constraints.maxWidth);

          return Scaffold(
            backgroundColor: const Color(0xFFF7F7FC),
            drawer: mobile ? _buildDrawer() : null,
            appBar: mobile ? _buildMobileAppBar() : null,
            body: Row(
              children: [
                if (!mobile) _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      if (!mobile) _buildDesktopTopBar(),
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
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Builder(
        builder: (context) {
          return IconButton(
            tooltip: 'القائمة',
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
          color: Color(0xFF151525),
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
      backgroundColor: const Color(0xFF151525),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
      color: const Color(0xFF151525),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
        onTap: () {
          _selectPage(index);

          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF5B4FE9)
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
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8E8F0),
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
              color: Color(0xFF151525),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.admin_panel_settings_rounded,
            color: Color(0xFF5B4FE9),
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


class _DashboardOverview extends StatefulWidget {
  const _DashboardOverview();

  @override
  State<_DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<_DashboardOverview> {
  bool loading = true;
  String? errorMessage;

  int usersCount = 0;
  int approvedDriversCount = 0;
  int ridesCount = 0;
  int activeRidesCount = 0;

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
      final supabase = Supabase.instance.client;

      final usersResponse = await supabase
          .from('profiles')
          .select('id');

      final driversResponse = await supabase
          .from('profiles')
          .select('id')
          .eq('driver_status', 'approved');

      final ridesResponse = await supabase
          .from('ride_requests')
          .select('id');

      final activeRidesResponse = await supabase
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

      if (!mounted) return;

      setState(() {
        usersCount = (usersResponse as List).length;
        approvedDriversCount = (driversResponse as List).length;
        ridesCount = (ridesResponse as List).length;
        activeRidesCount = (activeRidesResponse as List).length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'تعذر تحميل إحصائيات لوحة الإدارة.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 600 ? 16.0 : 28.0;

        return RefreshIndicator(
          onRefresh: _loadStatistics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(width),

                const SizedBox(height: 24),

                if (errorMessage != null)
                  _buildErrorMessage(),

                _buildStatsGrid(width),

                const SizedBox(height: 24),

                _buildOverviewCard(width),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بك في لوحة إدارة NUMIZA',
                style: TextStyle(
                  fontSize: width < 600 ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF151525),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'نظرة عامة على المستخدمين والسائقين والرحلات.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF77778A),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: loading ? null : _loadStatistics,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF5B4FE9),
                      ),
                    )
                  else
                    const Icon(
                      Icons.refresh_rounded,
                      size: 19,
                      color: Color(0xFF5B4FE9),
                    ),
                  const SizedBox(width: 7),
                  if (width >= 500)
                    const Text(
                      'تحديث',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B4FE9),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
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

  Widget _buildStatsGrid(double width) {
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
        value: loading ? '...' : usersCount.toString(),
        subtitle: 'إجمالي الحسابات',
      ),
      _StatCard(
        icon: Icons.drive_eta_rounded,
        title: 'السائقون',
        value: loading ? '...' : approvedDriversCount.toString(),
        subtitle: 'سائقون معتمدون',
      ),
      _StatCard(
        icon: Icons.local_taxi_rounded,
        title: 'الرحلات',
        value: loading ? '...' : ridesCount.toString(),
        subtitle: 'إجمالي الرحلات',
      ),
      _StatCard(
        icon: Icons.route_rounded,
        title: 'رحلات نشطة',
        value: loading ? '...' : activeRidesCount.toString(),
        subtitle: 'قيد التنفيذ أو البحث',
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: width < 600 ? 2.3 : 1.75,
      ),
      itemBuilder: (context, index) {
        return cards[index];
      },
    );
  }

  Widget _buildOverviewCard(double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width < 600 ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Color(0xFF5B4FE9),
              ),
              SizedBox(width: 10),
              Text(
                'حالة المنصة',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF151525),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _OverviewRow(
            icon: Icons.people_alt_rounded,
            title: 'المستخدمون المسجلون',
            value: loading ? '...' : usersCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.drive_eta_rounded,
            title: 'السائقون المعتمدون',
            value: loading ? '...' : approvedDriversCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.local_taxi_rounded,
            title: 'إجمالي الرحلات',
            value: loading ? '...' : ridesCount.toString(),
          ),

          const Divider(height: 24),

          _OverviewRow(
            icon: Icons.sync_rounded,
            title: 'الرحلات النشطة',
            value: loading ? '...' : activeRidesCount.toString(),
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
          color: const Color(0xFFE8E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FE9).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF5B4FE9),
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF77778A),
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
                    color: Color(0xFF151525),
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
            color: const Color(0xFF5B4FE9).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF5B4FE9),
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
            color: Color(0xFF151525),
          ),
        ),
      ],
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ComingSoonPage({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFF5B4FE9),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم تفعيل هذا القسم في الخطوات القادمة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF77778A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AdminMenuItem {
  final IconData icon;
  final String title;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
  });
}
