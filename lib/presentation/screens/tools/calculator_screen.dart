/// Calculadora de probabilidad y conteo, con pasos e interpretación.
///
/// Si el problema del estudiante es interpretar, evaluar aritmética es
/// evaluar lo que ya sabe hacer. Por eso la calculadora vive en la app y no
/// se esconde: lo que se practica en los ejercicios es decidir, no dividir.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/tutor/problem_classifier.dart';
import '../../../domain/tutor/step_solver.dart';
import '../../widgets/app_widgets.dart';

class CalculatorScreen extends StatefulWidget {
  final TutorMethod? initialMethod;

  const CalculatorScreen({super.key, this.initialMethod});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late TutorMethod _method;
  final Map<String, double> _values = {};
  final Map<String, TextEditingController> _controllers = {};
  SolverOutput? _output;
  String? _error;

  @override
  void initState() {
    super.initState();
    _method = widget.initialMethod ?? TutorMethod.enumerarLaplace;
    if (!StepSolver.supports(_method)) {
      _method = TutorMethod.enumerarLaplace;
    }
    _loadDefaults();
  }

  void _loadDefaults() {
    _values.clear();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    final recipe = StepSolver.recipes[_method]!;
    for (final f in recipe.fields) {
      _values[f.key] = f.defaultValue;
      _controllers[f.key] = TextEditingController(
        text: f.type == FieldType.count
            ? f.defaultValue.round().toString()
            : f.defaultValue.toString().replaceAll('.', ','),
      );
    }
    _output = null;
    _error = null;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _compute() {
    final recipe = StepSolver.recipes[_method]!;
    for (final f in recipe.fields) {
      final raw =
          _controllers[f.key]!.text.trim().replaceAll(',', '.');
      final v = double.tryParse(raw);
      if (v == null) {
        setState(() {
          _error = 'El campo «${f.label}» no es un número válido.';
          _output = null;
        });
        return;
      }
      if (f.type == FieldType.probability && (v < 0 || v > 1)) {
        setState(() {
          _error = 'El campo «${f.label}» debe estar entre 0 y 1. '
              'Una probabilidad fuera de ese rango señala un error de '
              'método, no de tecleo.';
          _output = null;
        });
        return;
      }
      _values[f.key] = v;
    }
    try {
      final out = StepSolver.solve(_method, _values);
      setState(() {
        _output = out;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo calcular con esos datos: $e';
        _output = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final recipe = StepSolver.recipes[_method]!;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Calculadora',
            subtitle: 'Con pasos, condición de uso y advertencias',
            color: AppColors.teal,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Método', style: t.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButton<TutorMethod>(
                        isExpanded: true,
                        value: _method,
                        items: [
                          for (final m in StepSolver.recipes.keys)
                            DropdownMenuItem(
                              value: m,
                              child: Text(
                                m.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (m) {
                          if (m == null) return;
                          setState(() {
                            _method = m;
                            _loadDefaults();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      NoticeBox(
                        _method.condition,
                        kind: NoticeKind.warning,
                        title: 'Condición de uso',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  accent: AppColors.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Datos', style: t.titleSmall),
                      const SizedBox(height: 10),
                      for (final f in recipe.fields)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _controllers[f.key],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: f.label,
                              helperText: f.hint.isEmpty ? null : f.hint,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      PrimaryButton(
                        'Calcular',
                        icon: Icons.calculate_outlined,
                        color: AppColors.teal,
                        onPressed: _compute,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  NoticeBox(_error!, kind: NoticeKind.danger),
                ],
                if (_output != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    accent: AppColors.indigo,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resultado', style: t.titleSmall),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _output!.headline,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: AppColors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Pasos', style: t.titleSmall),
                        const SizedBox(height: 8),
                        for (var i = 0; i < _output!.steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.indigo
                                        .withValues(alpha: 0.13),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.indigo,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_output!.steps[i].title,
                                          style: t.titleSmall),
                                      const SizedBox(height: 3),
                                      Text(
                                        _output!.steps[i].expression,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontFamilyFallback: const [
                                            'Courier',
                                            'monospace'
                                          ],
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      if (_output!.steps[i].value != null)
                                        Text(
                                          '= ${_output!.steps[i].value!.triple}',
                                          style: t.bodySmall?.copyWith(
                                            color: AppColors.teal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      if (_output!.steps[i].note != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _output!.steps[i].note!,
                                          style: t.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        for (final w in _output!.warnings) ...[
                          const SizedBox(height: 6),
                          NoticeBox(w, kind: NoticeKind.warning),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
