/// Cuadrícula interactiva del espacio muestral.
///
/// Es el widget central de la decisión D2: el estudiante marca con el dedo
/// los resultados que cumplen un evento y ve cuántos son, en vez de aceptar
/// un número que le dan hecho.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/math/sample_space.dart';

class SampleSpaceGrid extends StatelessWidget {
  final SampleSpace space;

  /// Índices marcados por el estudiante.
  final Set<int> selected;

  /// Índices que forman la respuesta correcta; si no es `null`, se muestran
  /// como revisión (verdes los aciertos, rojos los que faltan o sobran).
  final Set<int>? solution;

  final void Function(int index)? onToggle;

  /// Frecuencias observadas por etiqueta, para teñir la celda según cuántas
  /// veces salió en la simulación.
  final Map<String, int>? counts;
  final int maxCount;

  const SampleSpaceGrid({
    super.key,
    required this.space,
    this.selected = const {},
    this.solution,
    this.onToggle,
    this.counts,
    this.maxCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final columns = _columnsFor(space);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        final width = constraints.maxWidth;
        final cell = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < space.size; i++)
              _Cell(
                size: cell,
                label: space.outcomes[i].label,
                state: _stateOf(i),
                intensity: _intensity(space.outcomes[i].label),
                onTap: onToggle == null ? null : () => onToggle!(i),
                outline: scheme.outline,
                onSurface: scheme.onSurface,
                surface: scheme.surfaceContainerHighest,
              ),
          ],
        );
      },
    );
  }

  double _intensity(String label) {
    if (counts == null || maxCount <= 0) return 0;
    final c = counts![label] ?? 0;
    return (c / maxCount).clamp(0.0, 1.0);
  }

  _CellState _stateOf(int i) {
    final sel = selected.contains(i);
    if (solution == null) {
      return sel ? _CellState.selected : _CellState.plain;
    }
    final inSolution = solution!.contains(i);
    if (sel && inSolution) return _CellState.correct;
    if (sel && !inSolution) return _CellState.wrong;
    if (!sel && inSolution) return _CellState.missed;
    return _CellState.plain;
  }

  static int _columnsFor(SampleSpace space) {
    if (space.id.startsWith('dice_2')) return 6;
    if (space.id == 'card52') return 13;
    if (space.size <= 4) return space.size;
    if (space.size <= 8) return 4;
    if (space.size <= 16) return 4;
    if (space.size <= 36) return 6;
    return 8;
  }
}

enum _CellState { plain, selected, correct, wrong, missed }

class _Cell extends StatelessWidget {
  final double size;
  final String label;
  final _CellState state;
  final double intensity;
  final VoidCallback? onTap;
  final Color outline;
  final Color onSurface;
  final Color surface;

  const _Cell({
    required this.size,
    required this.label,
    required this.state,
    required this.intensity,
    required this.onTap,
    required this.outline,
    required this.onSurface,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text = onSurface;
    switch (state) {
      case _CellState.selected:
        bg = AppColors.indigo.withValues(alpha: 0.85);
        border = AppColors.indigo;
        text = Colors.white;
        break;
      case _CellState.correct:
        bg = AppColors.success.withValues(alpha: 0.85);
        border = AppColors.success;
        text = Colors.white;
        break;
      case _CellState.wrong:
        bg = AppColors.danger.withValues(alpha: 0.80);
        border = AppColors.danger;
        text = Colors.white;
        break;
      case _CellState.missed:
        bg = AppColors.amber.withValues(alpha: 0.30);
        border = AppColors.amber;
        break;
      case _CellState.plain:
        bg = intensity > 0
            ? AppColors.teal.withValues(alpha: 0.10 + 0.55 * intensity)
            : surface;
        border = outline;
        break;
    }
    return SizedBox(
      width: size,
      height: size.clamp(26.0, 54.0),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: text,
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
