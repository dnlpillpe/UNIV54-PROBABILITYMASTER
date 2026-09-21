/// Navegación raíz: cinco destinos.
///
/// «Laboratorios» ocupa el centro a propósito: en esta app la simulación no
/// es un extra, es el camino principal.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../glossary/glossary_screen.dart';
import '../lab/labs_screen.dart';
import '../module/modules_screen.dart';
import '../progress/progress_screen.dart';
import '../tutor/tutor_screen.dart';
import 'home_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _titles = [
    'Inicio',
    'Aprender',
    'Laboratorios',
    'Tutor',
    'Progreso',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ModulesScreen(),
          LabsScreen(),
          TutorScreen(),
          ProgressScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          border: Border(top: BorderSide(color: scheme.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _titles.length; i++)
                Expanded(
                  child: _NavItem(
                    label: _titles[i],
                    icon: _iconFor(i),
                    selected: _index == i,
                    color: AppColors.module(i == 4 ? 0 : i),
                    onTap: () => setState(() => _index = i),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GlossaryScreen(),
                ),
              ),
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Glosario'),
            )
          : null,
    );
  }

  static IconData _iconFor(int i) {
    switch (i) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.school_outlined;
      case 2:
        return Icons.science_outlined;
      case 3:
        return Icons.psychology_outlined;
      default:
        return Icons.insights_outlined;
    }
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 21,
                color: selected ? color : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
