/// Pantalla de experimento: **Predice → Simula → Explica** (decisión D1).
///
/// Los controles están bloqueados hasta registrar la predicción, y el
/// hallazgo no aparece hasta alcanzar el mínimo de repeticiones. La semilla
/// se muestra siempre: cualquier corrida es reproducible.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/math/combinatorics.dart';
import '../../../domain/math/rational.dart';
import '../../../domain/math/simulators.dart';
import '../../../domain/models/experiment.dart';
import '../../../domain/models/progress.dart';
import '../../painters/chart_painters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../lesson/lesson_screen.dart';
import 'lab_engines.dart';

class ExperimentScreen extends ConsumerStatefulWidget {
  final String experimentId;

  const ExperimentScreen({super.key, required this.experimentId});

  @override
  ConsumerState<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends ConsumerState<ExperimentScreen> {
  bool _predicted = false;
  bool _predictionCorrect = false;
  double _percentPrediction = 50;
  int? _optionPrediction;
  int _maxTrialsRun = 0;
  int _seed = 20260101;

  @override
  Widget build(BuildContext context) {
    final content = ref.read(contentProvider);
    final experiment = content.experiment(widget.experimentId);
    if (experiment == null) {
      return const Scaffold(
        body: Center(child: Text('Experimento no encontrado')),
      );
    }
    final lab = content.lab(experiment.labId)!;
    final module = content.module(lab.moduleId)!;
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;
    final unlocked = _maxTrialsRun >= experiment.minTrials;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: experiment.title,
            subtitle: '${lab.name} · ${experiment.manipulates}',
            color: color,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                // --- 1. Predicción ---------------------------------
                _PredictionCard(
                  question: experiment.prediction,
                  answered: _predicted,
                  percent: _percentPrediction,
                  option: _optionPrediction,
                  color: color,
                  onPercent: (v) => setState(() => _percentPrediction = v),
                  onOption: (i) => setState(() => _optionPrediction = i),
                  onSubmit: _submitPrediction,
                ),

                if (_predicted) ...[
                  const SizedBox(height: 16),
                  LabEngineBody(
                    experiment: experiment,
                    engine: lab.engine,
                    color: color,
                    seed: _seed,
                    onSeedChange: (s) => setState(() => _seed = s),
                    onTrialsRun: (n) {
                      if (n > _maxTrialsRun) {
                        setState(() => _maxTrialsRun = n);
                      }
                      _persist(experiment, n);
                    },
                  ),
                  const SizedBox(height: 18),

                  // --- 3. Hallazgo --------------------------------
                  AppCard(
                    accent: unlocked ? AppColors.success : null,
                    background: unlocked
                        ? AppColors.success.withValues(alpha: 0.06)
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              unlocked
                                  ? Icons.lightbulb
                                  : Icons.lock_outline,
                              size: 18,
                              color: unlocked
                                  ? AppColors.success
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                unlocked
                                    ? 'Qué acabas de ver'
                                    : 'Hallazgo bloqueado',
                                style: t.titleSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        if (unlocked)
                          Text(experiment.finding, style: t.bodyMedium)
                        else
                          Text(
                            'Simula al menos ${Fmt.int0(experiment.minTrials)} '
                            'repeticiones para desbloquear la conclusión. '
                            'Llevas ${Fmt.int0(_maxTrialsRun)}.\n\n'
                            'No es un capricho: con pocas repeticiones la '
                            'frecuencia relativa oscila tanto que cualquier '
                            'conclusión sería ruido.',
                            style: t.bodyMedium,
                          ),
                        if (unlocked && experiment.lessonId != null) ...[
                          const SizedBox(height: 13),
                          GhostButton(
                            'Leer la lección que lo formaliza',
                            icon: Icons.menu_book_outlined,
                            color: color,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LessonScreen(
                                  lessonId: experiment.lessonId!,
                                ),
                              ),
                            ),
                          ),
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

  void _submitPrediction() {
    final content = ref.read(contentProvider);
    final experiment = content.experiment(widget.experimentId)!;
    final q = experiment.prediction;
    bool ok;
    if (q.kind == PredictionKind.porcentaje) {
      ok = _percentPrediction >= (q.correctMin ?? 0) &&
          _percentPrediction <= (q.correctMax ?? 100);
    } else {
      ok = _optionPrediction != null && _optionPrediction == q.correctOption;
    }
    setState(() {
      _predicted = true;
      _predictionCorrect = ok;
    });
    _persist(experiment, 0);
  }

  void _persist(Experiment experiment, int trials) {
    ref.read(progressProvider.notifier).recordExperiment(
          ExperimentRecord(
            experimentId: experiment.id,
            labId: experiment.labId,
            predictionRecorded: true,
            predictionCorrect: _predictionCorrect,
            trialsRun: trials,
            seed: _seed,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionQuestion question;
  final bool answered;
  final double percent;
  final int? option;
  final Color color;
  final ValueChanged<double> onPercent;
  final ValueChanged<int> onOption;
  final VoidCallback onSubmit;

  const _PredictionCard({
    required this.question,
    required this.answered,
    required this.percent,
    required this.option,
    required this.color,
    required this.onPercent,
    required this.onOption,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final canSubmit = question.kind == PredictionKind.porcentaje
        ? true
        : option != null;

    return AppCard(
      accent: AppColors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Pill('Paso 1 · Predice',
                  color: AppColors.amber, icon: Icons.visibility_outlined),
              const Spacer(),
              if (answered)
                Text(
                  'Registrada',
                  style: t.bodySmall?.copyWith(color: AppColors.success),
                ),
            ],
          ),
          const SizedBox(height: 11),
          Text(question.question, style: t.titleSmall),
          const SizedBox(height: 13),
          if (question.kind == PredictionKind.porcentaje) ...[
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: percent,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: AppColors.amber,
                    label: '${percent.round()} %',
                    onChanged: answered ? null : onPercent,
                  ),
                ),
                SizedBox(
                  width: 54,
                  child: Text(
                    '${percent.round()} %',
                    textAlign: TextAlign.right,
                    style: t.titleMedium,
                  ),
                ),
              ],
            ),
          ] else ...[
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Material(
                  color: option == i
                      ? AppColors.amber.withValues(alpha: 0.14)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: answered ? null : () => onOption(i),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: option == i
                              ? AppColors.amber
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option == i
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: option == i
                                ? AppColors.amber
                                : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(question.options[i],
                                style: t.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          if (!answered)
            PrimaryButton(
              'Registrar predicción y desbloquear controles',
              icon: Icons.lock_open,
              color: AppColors.amber,
              onPressed: canSubmit ? onSubmit : null,
            )
          else
            Text(
              'Tu predicción queda guardada. Acertar o fallar no afecta tu '
              'nota: se registra como «intuición inicial», y fallar aquí es '
              'exactamente lo que hace que la simulación sirva.',
              style: t.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Casillas de resultado compartidas por varios laboratorios.
class SimulationStats extends StatelessWidget {
  final SimulationRun run;
  final Color color;
  final String observedLabel;

  const SimulationStats({
    super.key,
    required this.run,
    required this.color,
    this.observedLabel = 'Frecuencia observada',
  });

  @override
  Widget build(BuildContext context) {
    return TileGrid(
      minTileWidth: 142,
      children: [
        StatTile(
          label: observedLabel,
          value: Fmt.percent(run.observed, digits: 2),
          color: AppColors.observed,
          hint: '${Fmt.int0(run.successes)} de ${Fmt.int0(run.trials)}',
        ),
        StatTile(
          label: 'Probabilidad teórica',
          value: run.theoretical.asPercent(digits: 2),
          color: AppColors.theoretical,
          hint: run.theoretical.asFraction,
        ),
        StatTile(
          label: 'Diferencia',
          value: Fmt.percent(run.absoluteError, digits: 2),
          color: run.absoluteError < 0.02
              ? AppColors.success
              : AppColors.warning,
          hint: 'observada − teórica',
        ),
        StatTile(
          label: 'Semilla',
          value: '${run.seed}',
          color: color,
          hint: 'Repite la corrida con el mismo valor',
        ),
      ],
    );
  }
}

/// Selector de repeticiones, compartido por los laboratorios.
class TrialsSelector extends StatelessWidget {
  final int value;
  final List<int> options;
  final Color color;
  final ValueChanged<int> onChanged;

  const TrialsSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.color,
    this.options = const [20, 100, 500, 2000, 10000, 50000],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeticiones',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final o in options)
              Material(
                color: o == value
                    ? color
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onChanged(o),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: o == value
                            ? color
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      Fmt.int0(o),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: o == value
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Utilidades compartidas por los cuerpos de laboratorio.
List<Offset> trajectoryToOffsets(List<TrajectoryPoint> points) =>
    [for (final p in points) Offset(p.trials.toDouble(), p.relativeFrequency)];

List<BarDatum> categoryBars(
  Map<String, int> counts,
  int total,
  Map<String, Rational> theoretical,
) {
  final bars = <BarDatum>[];
  var i = 0;
  counts.forEach((label, value) {
    bars.add(BarDatum(
      label,
      total == 0 ? 0 : value / total,
      AppColors.seriesAt(i),
      reference: theoretical[label]?.toDouble(),
    ));
    i++;
  });
  return bars;
}

String formatBigCount(BigInt v) => Combinatorics.formatBig(v);
