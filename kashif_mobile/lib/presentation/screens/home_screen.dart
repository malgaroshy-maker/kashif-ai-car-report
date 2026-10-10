import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/history_provider.dart';
import 'scan_screen.dart';
import 'report_screen.dart';
import 'dtc_lookup_screen.dart';
import 'history_screen.dart';
import 'dictionary_screen.dart';
import 'settings_screen.dart';
import 'fuse_box_screen.dart';
import 'dashboard_lights_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      ScanScreen(onReportReady: () => _navigateToTab(1)),
      const ReportScreen(),
      DtcLookupScreen(onReportGenerated: () => _navigateToTab(1)),
      const FuseBoxScreen(showAppBar: false),
      const DictionaryScreen(),
    ];

    final titles = [
      'فحص جديد',
      'تقرير الفحص',
      'الأعطال',
      'دليل ومكتشف الفيوزات',
      'قاموس الورش',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFF5C84C),
                    Color(0xFFA67C1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Flow Cars',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF070E1E),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titles[_currentIndex],
              style: KashifTypography.arabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? KashifColors.darkTextPrimary
                    : KashifColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Dashboard Warning Lights Guide button
          IconButton(
            icon: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
            ),
            tooltip: 'دليل لمبات الطبلون',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DashboardLightsScreen(),
                ),
              );
            },
          ),
          // Reports History button (Moved to Header)
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              size: 21,
              color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
            ),
            tooltip: 'سجل الفحوصات المحفوظة',
            onPressed: () {
              ref.read(historyProvider.notifier).loadHistory();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    showAppBar: true,
                    onReportSelected: () {
                      Navigator.of(context).pop();
                      _navigateToTab(1);
                    },
                  ),
                ),
              );
            },
          ),
          // Settings button
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 20,
              color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
            ),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: isDark
            ? KashifColors.darkCell
            : KashifColors.lightCell,
        indicatorColor:
            (isDark ? KashifColors.goldLight : KashifColors.royalBlue)
                .withValues(alpha: 0.16),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(
              Icons.document_scanner,
              color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
            ),
            label: 'الفحص',
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: Icon(
              Icons.assignment,
              color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
            ),
            label: 'التقرير',
          ),
          NavigationDestination(
            icon: const Icon(Icons.troubleshoot_outlined),
            selectedIcon: Icon(
              Icons.troubleshoot_rounded,
              color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
            ),
            label: 'الأعطال',
          ),
          NavigationDestination(
            icon: const Icon(Icons.electric_bolt_outlined),
            selectedIcon: Icon(
              Icons.electric_bolt_rounded,
              color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
            ),
            label: 'الفيوزات',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(
              Icons.menu_book_rounded,
              color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
            ),
            label: 'القاموس',
          ),
        ],
      ),
    );
  }
}
