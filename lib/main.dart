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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FC),
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: pages[selectedIndex],
                  ),
                ],
              ),
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
                  final item = menuItems[index];
                  final selected = selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
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
                            Text(
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
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
                      Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Color(0xFFFF8A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
        ],
      ),
    );
  }
}


class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مرحبًا بك في لوحة إدارة NUMIZA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151525),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'من هنا يمكنك إدارة المستخدمين والسائقين والرحلات وإعدادات التطبيق.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF77778A),
            ),
          ),

          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int columns = 4;

              if (width < 900) {
                columns = 2;
              }

              if (width < 600) {
                columns = 1;
              }

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _StatCard(
                    icon: Icons.people_alt_rounded,
                    title: 'المستخدمون',
                    value: '—',
                  ),
                  _StatCard(
                    icon: Icons.drive_eta_rounded,
                    title: 'السائقون',
                    value: '—',
                  ),
                  _StatCard(
                    icon: Icons.local_taxi_rounded,
                    title: 'الرحلات',
                    value: '—',
                  ),
                  _StatCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'طلبات السائقين',
                    value: '—',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8E8F0),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نظرة عامة',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'سيتم ربط هذه الإحصائيات بقاعدة بيانات Supabase في الخطوة التالية.',
                  style: TextStyle(
                    color: Color(0xFF77778A),
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


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  style: const TextStyle(
                    color: Color(0xFF77778A),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151525),
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
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'سيتم تفعيل هذا القسم في الخطوات القادمة.',
            style: TextStyle(
              color: Color(0xFF77778A),
            ),
          ),
        ],
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
