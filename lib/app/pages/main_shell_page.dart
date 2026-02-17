import 'package:flutter/material.dart';

import 'package:rodb_delivery_app/l10n/generated/app_localizations.dart';

import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';
import 'package:rodb_delivery_app/app/pages/performance-page/performance_page.dart';

/// The main shell with a [BottomNavigationBar].
///
/// Contains the primary tabs: Orders and Performance.
/// Each tab keeps its own navigation state via [IndexedStack].
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    OrdersPage(),
    PerformancePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context)!.ordersTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            label: AppLocalizations.of(context)!.performanceTitle,
          ),
        ],
      ),
    );
  }
}
