import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/settings_provider.dart';
import 'scan_screen.dart';
import 'report_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'dictionary_screen.dart';
import 'settings_screen.dart';

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
    final settings = ref.watch(settingsProvider);

    final screens = [
      ScanScreen(onReportReady: () => _navigateToTab(1)),
      ReportScreen(onOpenChat: () => _navigateToTab(2)),
      const ChatScreen(),
      HistoryScreen(onReportSelected: () => _navigateToTab(1)),
      const DictionaryScreen(),
    ];

    final titles = [
      'فحص جديد',
      'تقرير الفحص',
      'الأسطى الذكي',
      'سجل الفحوصات',
      'قاموس الورش',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'كاشف AI',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titles[_currentIndex],
              style: KashifTypography.arabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // Quick theme toggle
          IconButton(
            icon: Icon(
              settings.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: 'تغيير المظهر',
            onPressed: () {
              final newMode = settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              ref.read(settingsProvider.notifier).updateThemeMode(newMode);
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: isDark ? KashifColors.darkCell : KashifColors.lightCell,
        indicatorColor: (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight).withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
            label: 'الفحص',
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
            label: 'التقرير',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
            label: 'الأسطى',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
            label: 'السجل',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
            label: 'القاموس',
          ),
        ],
      ),
    );
  }
}
