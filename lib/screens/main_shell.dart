import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';

/// Main navigation shell preserving tab states with IndexedStack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 2) {
      _historyKey.currentState?.loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateToDeteksi: () => _onNavigate(1),
            onNavigateToRiwayat: () => _onNavigate(2),
          ),
          AnalyzeScreen(
            onScanCompleted: () => _onNavigate(2), // Redirect to history on success
          ),
          HistoryScreen(key: _historyKey),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
      ),
    );
  }
}
