/// Cuerpos de los cinco laboratorios.
///
/// Cada uno recibe el experimento y decide qué controles mostrar. Todos
/// comparten la misma promesa: en pantalla aparecen siempre **el valor
/// observado y el teórico juntos**, porque el mecanismo educativo de la app
/// no es ilustrar la fórmula sino auditarla.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/content/sample_space_catalog.dart';
import '../../../domain/math/combinatorics.dart';
import '../../../domain/math/probability_engine.dart';
import '../../../domain/math/rational.dart';
import '../../../domain/math/sample_space.dart';
import '../../../domain/math/simulators.dart';
import '../../../domain/models/experiment.dart';
import '../../painters/chart_painters.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/charts.dart';
import '../../widgets/sample_space_grid.dart';
import 'experiment_screen.dart';

class LabEngineBody extends StatelessWidget {
  final Experiment experiment;
  final LabEngine engine;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const LabEngineBody({
    super.key,
    required this.experiment,
    required this.engine,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  Widget build(BuildContext context) {
    switch (engine) {
      case LabEngine.granNumeros:
        return BigNumbersLab(
          experiment: experiment,
          color: color,
          seed: seed,
          onSeedChange: onSeedChange,
          onTrialsRun: onTrialsRun,
        );
      case LabEngine.espacioMuestral:
        return SampleSpaceLab(
          experiment: experiment,
          color: color,
          seed: seed,
          onSeedChange: onSeedChange,
          onTrialsRun: onTrialsRun,
        );
      case LabEngine.dosEventos:
        return TwoEventsLab(
          experiment: experiment,
          color: color,
          seed: seed,
          onSeedChange: onSeedChange,
          onTrialsRun: onTrialsRun,
        );
      case LabEngine.urnaYEvidencia:
        return experiment.defaults.containsKey('prev')
            ? ScreeningLab(
                experiment: experiment,
                color: color,
                seed: seed,
                onSeedChange: onSeedChange,
                onTrialsRun: onTrialsRun,
              )
            : UrnLab(
                experiment: experiment,
                color: color,
                seed: seed,
                onSeedChange: onSeedChange,
                onTrialsRun: onTrialsRun,
              );
      case LabEngine.conteo:
        return CountingLab(
          experiment: experiment,
          color: color,
          seed: seed,
          onSeedChange: onSeedChange,
          onTrialsRun: onTrialsRun,
        );
    }
  }
}

/// Encabezado común de la zona de simulación.
class _SimHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SimHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pill('Paso 2 · Simula',
            color: color, icon: Icons.play_circle_outline),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Laboratorio 1 — Ley de los grandes números
// =====================================================================
class BigNumbersLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const BigNumbersLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<BigNumbersLab> createState() => _BigNumbersLabState();
}

class _BigNumbersLabState extends State<BigNumbersLab> {
  late int _pPercent;
  late int _trials;
  int _runLength = 4;
  SimulationRun? _run;
  GamblerFallacyResult? _fallacy;

  bool get _isFallacy => widget.experiment.id == 'x3_falacia';
  bool get _isImbalance => widget.experiment.id == 'x4_desbalance';

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    final pNum = d['pNum'] ?? 1;
    final pDen = d['pDen'] ?? 2;
    _pPercent = ((pNum / pDen) * 100).round();
    _trials = d['trials'] ?? 500;
    _runLength = d['runLength'] ?? 4;
  }

  void _simulate() {
    final p = Rational.fromInts(_pPercent, 100);
    if (_isFallacy) {
      final r = Simulators.gamblerFallacy(
        p: p,
        runLength: _runLength,
        trials: _trials < 2000 ? 2000 : _trials,
        seed: widget.seed,
      );
      setState(() => _fallacy = r);
      widget.onTrialsRun(_trials < 2000 ? 2000 : _trials);
      return;
    }
    final r = Simulators.bernoulliTrials(
      p: p,
      trials: _trials,
      seed: widget.seed,
    );
    setState(() => _run = r);
    widget.onTrialsRun(_trials);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Ajusta y lanza', widget.color),
              const SizedBox(height: 14),
              Text('Probabilidad real de cara: $_pPercent %',
                  style: t.titleSmall),
              Slider(
                value: _pPercent.toDouble(),
                min: 5,
                max: 95,
                divisions: 18,
                activeColor: widget.color,
                label: '$_pPercent %',
                onChanged: (v) => setState(() => _pPercent = v.round()),
              ),
              if (_isFallacy) ...[
                Text('Largo de la racha observada: $_runLength caras',
                    style: t.titleSmall),
                Slider(
                  value: _runLength.toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  activeColor: AppColors.amber,
                  label: '$_runLength',
                  onChanged: (v) => setState(() => _runLength = v.round()),
                ),
              ],
              const SizedBox(height: 4),
              TrialsSelector(
                value: _trials,
                color: widget.color,
                onChanged: (v) => setState(() => _trials = v),
                options: _isFallacy
                    ? const [2000, 10000, 50000]
                    : const [20, 100, 500, 2000, 10000, 50000],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      'Lanzar',
                      icon: Icons.play_arrow_rounded,
                      color: widget.color,
                      onPressed: _simulate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GhostButton(
                    'Otra semilla',
                    icon: Icons.casino_outlined,
                    color: widget.color,
                    onPressed: () {
                      widget.onSeedChange(
                        DateTime.now().millisecondsSinceEpoch % 100000000,
                      );
                      setState(() {
                        _run = null;
                        _fallacy = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_fallacy != null) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Después de $_runLength caras seguidas',
                    style: t.titleSmall),
                const SizedBox(height: 12),
                TileGrid(
                  minTileWidth: 142,
                  children: [
                    StatTile(
                      label: 'Ocasiones encontradas',
                      value: Fmt.int0(_fallacy!.occasions),
                      color: widget.color,
                      hint: 'rachas de $_runLength o más',
                    ),
                    StatTile(
                      label: 'Siguió cara',
                      value: Fmt.percent(_fallacy!.observed, digits: 1),
                      color: AppColors.observed,
                      hint: '${Fmt.int0(_fallacy!.followedBySuccess)} veces',
                    ),
                    StatTile(
                      label: 'Teórico',
                      value: _fallacy!.theoretical.asPercent(),
                      color: AppColors.theoretical,
                      hint: 'la moneda no tiene memoria',
                    ),
                    StatTile(
                      label: 'Semilla',
                      value: '${_fallacy!.seed}',
                      color: widget.color,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NoticeBox(
                  'La probabilidad después de una racha coincide con la '
                  'probabilidad de siempre, dentro del ruido de muestreo. '
                  'Sube la racha a 8 y vuelve a mirar: el número sigue '
                  'clavado en ${_fallacy!.theoretical.asPercent()}.',
                  kind: NoticeKind.info,
                ),
              ],
            ),
          ),
        ],
        if (_run != null) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Convergencia', style: t.titleSmall),
                const SizedBox(height: 12),
                ConvergenceChart(
                  points: trajectoryToOffsets(_run!.trajectory),
                  theoretical: _run!.theoreticalValue,
                ),
                const SizedBox(height: 14),
                SimulationStats(run: _run!, color: widget.color),
                if (_isImbalance) ...[
                  const SizedBox(height: 14),
                  TileGrid(
                    minTileWidth: 142,
                    children: [
                      StatTile(
                        label: 'Diferencia absoluta',
                        value: Fmt.int0(_run!.absoluteImbalance.round()),
                        color: AppColors.rose,
                        hint: 'caras de más o de menos',
                      ),
                      StatTile(
                        label: 'Como proporción',
                        value: Fmt.percent(
                          _run!.trials == 0
                              ? 0
                              : _run!.absoluteImbalance / _run!.trials,
                          digits: 2,
                        ),
                        color: AppColors.teal,
                        hint: 'la misma diferencia, diluida',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const NoticeBox(
                    'Sube las repeticiones y observa las dos casillas a la '
                    'vez: la diferencia absoluta crece, la proporción cae. '
                    'Eso es la ley de los grandes números, y eso NO es la '
                    '«ley de los promedios».',
                    kind: NoticeKind.warning,
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  TileGrid(
                    minTileWidth: 142,
                    children: [
                      StatTile(
                        label: 'Racha más larga',
                        value: '${_run!.longestStreak}',
                        color: AppColors.amber,
                        hint: 'caras seguidas',
                      ),
                      StatTile(
                        label: 'Error esperado (±2 EE)',
                        value: Fmt.percent(
                          2 *
                              _standardError(
                                _run!.theoreticalValue,
                                _run!.trials,
                              ),
                          digits: 2,
                        ),
                        color: AppColors.indigo,
                        hint: 'se estrecha con √n',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  static double _standardError(double p, int n) {
    if (n <= 0) return 0;
    final v = p * (1 - p) / n;
    return v <= 0 ? 0 : _sqrt(v);
  }

  static double _sqrt(double v) {
    var x = v;
    for (var i = 0; i < 40; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}

// =====================================================================
// Laboratorio 2 — Fábrica de espacios muestrales
// =====================================================================
class SampleSpaceLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const SampleSpaceLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<SampleSpaceLab> createState() => _SampleSpaceLabState();
}

class _SampleSpaceLabState extends State<SampleSpaceLab> {
  late String _spaceId;
  final Set<int> _selected = {};
  int _trials = 600;
  Map<String, int>? _counts;

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    final code = d['space'] ?? 2;
    switch (code) {
      case 0:
        _spaceId = 'coins_${d['coins'] ?? 3}';
        break;
      case 3:
        _spaceId = 'card52';
        break;
      default:
        _spaceId = 'dice_2_6';
    }
    _trials = d['trials'] ?? 600;
  }

  SampleSpace get _space => SampleSpaceCatalog.byId(_spaceId);

  List<_Preset> get _presets {
    if (_spaceId.startsWith('dice_2')) {
      return const [
        _Preset('Suma 7', 'sumEquals', [7]),
        _Preset('Suma 12', 'sumEquals', [12]),
        _Preset('Suma 2', 'sumEquals', [2]),
        _Preset('Al menos un 6', 'anyEquals', [6]),
        _Preset('Dobles', 'doubles', []),
        _Preset('Suma ≥ 10', 'sumAtLeast', [10]),
      ];
    }
    if (_spaceId.startsWith('coins')) {
      return const [
        _Preset('Exactamente 2 caras', 'exactHeads', [2]),
        _Preset('Al menos 2 caras', 'atLeastHeads', [2]),
        _Preset('Todas caras', 'allHeads', []),
        _Preset('Exactamente 1 cara', 'exactHeads', [1]),
      ];
    }
    return const [
      _Preset('Es corazón', 'suitIs', [0]),
      _Preset('Es figura (J,Q,K)', 'rankAtLeast', [11]),
    ];
  }

  void _applyPreset(_Preset p) {
    final pred = SampleSpaceCatalog.predicate(p.fn, p.args);
    setState(() {
      _selected
        ..clear()
        ..addAll(_space.indicesWhere(pred));
    });
  }

  void _simulate() {
    final counts = Simulators.sampleSpaceCounts(
      space: _space,
      trials: _trials,
      seed: widget.seed,
    );
    setState(() => _counts = counts);
    widget.onTrialsRun(_trials);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final space = _space;
    final theoretical = space.probabilityOfIndices(_selected);
    final observed = _observedFrequency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader(space.experiment, widget.color),
              const SizedBox(height: 10),
              if (widget.experiment.id == 'x6_tres_monedas')
                Row(
                  children: [
                    Text('Monedas:', style: t.titleSmall),
                    const SizedBox(width: 10),
                    for (final n in [2, 3, 4])
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text('$n'),
                          selected: _spaceId == 'coins_$n',
                          onSelected: (_) => setState(() {
                            _spaceId = 'coins_$n';
                            _selected.clear();
                            _counts = null;
                          }),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Text('|Ω| = ${space.size} resultados', style: t.titleSmall),
              const SizedBox(height: 10),
              SampleSpaceGrid(
                space: space,
                selected: _selected,
                counts: _counts,
                maxCount: _maxCount(),
                onToggle: (i) => setState(() {
                  if (!_selected.remove(i)) _selected.add(i);
                }),
              ),
              const SizedBox(height: 12),
              Text('Eventos listos para marcar', style: t.titleSmall),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final p in _presets)
                    ActionChip(
                      label: Text(p.label),
                      onPressed: () => _applyPreset(p),
                    ),
                  ActionChip(
                    label: const Text('Limpiar'),
                    onPressed: () => setState(_selected.clear),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TrialsSelector(
                value: _trials,
                color: widget.color,
                onChanged: (v) => setState(() => _trials = v),
                options: const [100, 600, 3000, 20000],
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                'Muestrear el espacio',
                icon: Icons.play_arrow_rounded,
                color: widget.color,
                onPressed: _selected.isEmpty ? null : _simulate,
              ),
              if (_selected.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Marca primero los resultados que forman tu evento.',
                  style: t.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu evento', style: t.titleSmall),
                const SizedBox(height: 10),
                TileGrid(
                  minTileWidth: 142,
                  children: [
                    StatTile(
                      label: 'Casos favorables',
                      value: '${_selected.length}',
                      color: widget.color,
                      hint: 'de ${space.size} posibles',
                    ),
                    StatTile(
                      label: 'Probabilidad exacta',
                      value: theoretical.asFraction,
                      color: AppColors.theoretical,
                      hint: theoretical.asPercent(digits: 2),
                    ),
                    if (_counts != null)
                      StatTile(
                        label: 'Frecuencia observada',
                        value: Fmt.percent(observed, digits: 2),
                        color: AppColors.observed,
                        hint: 'con ${Fmt.int0(_trials)} repeticiones',
                      ),
                    if (_counts != null)
                      StatTile(
                        label: 'Diferencia',
                        value: Fmt.percent(
                          (observed - theoretical.toDouble()).abs(),
                          digits: 2,
                        ),
                        color: AppColors.warning,
                      ),
                  ],
                ),
                if (!space.isUniform) ...[
                  const SizedBox(height: 12),
                  const NoticeBox(
                    'Este espacio NO es equiprobable: no puedes dividir '
                    'favorables entre posibles.',
                    kind: NoticeKind.warning,
                  ),
                ],
                if (_counts != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Las celdas se tiñen según cuántas veces salió cada '
                    'resultado. Si el espacio es equiprobable, el tono es '
                    'parejo; si no lo es, se ve enseguida.',
                    style: t.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  int _maxCount() {
    if (_counts == null || _counts!.isEmpty) return 0;
    var m = 0;
    for (final v in _counts!.values) {
      if (v > m) m = v;
    }
    return m;
  }

  double _observedFrequency() {
    if (_counts == null) return 0;
    var hits = 0;
    for (final i in _selected) {
      hits += _counts![_space.outcomes[i].label] ?? 0;
    }
    return _trials == 0 ? 0 : hits / _trials;
  }
}

class _Preset {
  final String label;
  final String fn;
  final List<int> args;
  const _Preset(this.label, this.fn, this.args);
}

// =====================================================================
// Laboratorio 3 — Mesa de eventos
// =====================================================================
class TwoEventsLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const TwoEventsLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<TwoEventsLab> createState() => _TwoEventsLabState();
}

class _TwoEventsLabState extends State<TwoEventsLab> {
  late int _pA;
  late int _pB;
  late int _pAB;
  late int _population;
  TwoEventPopulation? _result;
  String _highlight = 'union';

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    _pA = d['pA'] ?? 40;
    _pB = d['pB'] ?? 30;
    _pAB = d['pAB'] ?? 12;
    _population = d['population'] ?? 1000;
  }

  int get _maxAB => _pA < _pB ? _pA : _pB;
  int get _minAB {
    final v = _pA + _pB - 100;
    return v < 0 ? 0 : v;
  }

  void _simulate() {
    final r = Simulators.twoEvents(
      population: _population,
      pA: _pA / 100,
      pB: _pB / 100,
      pAandB: _pAB / 100,
      seed: widget.seed,
    );
    setState(() => _result = r);
    widget.onTrialsRun(_population);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pa = Rational.fromInts(_pA, 100);
    final pb = Rational.fromInts(_pB, 100);
    final pab = Rational.fromInts(_pAB, 100);
    final union = ProbabilityEngine.unionGeneral(pa, pb, pab);
    final independent = ProbabilityEngine.areIndependent(pa, pb, pab);
    final product = pa * pb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Mueve las tres probabilidades', widget.color),
              const SizedBox(height: 12),
              _slider('P(A)', _pA, 5, 95, AppColors.indigo, (v) {
                setState(() {
                  _pA = v;
                  if (_pAB > _maxAB) _pAB = _maxAB;
                  if (_pAB < _minAB) _pAB = _minAB;
                });
              }),
              _slider('P(B)', _pB, 5, 95, AppColors.rose, (v) {
                setState(() {
                  _pB = v;
                  if (_pAB > _maxAB) _pAB = _maxAB;
                  if (_pAB < _minAB) _pAB = _minAB;
                });
              }),
              _slider('P(A ∩ B)', _pAB, _minAB, _maxAB, AppColors.amber, (v) {
                setState(() => _pAB = v);
              }),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final h in const [
                    ['union', 'A ∪ B'],
                    ['AB', 'A ∩ B'],
                    ['A', 'Solo A'],
                    ['B', 'Solo B'],
                    ['none', 'Ninguno'],
                  ])
                    ChoiceChip(
                      label: Text(h[1]),
                      selected: _highlight == h[0],
                      onSelected: (_) => setState(() => _highlight = h[0]),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                'Simular ${Fmt.int0(_population)} personas',
                icon: Icons.groups_outlined,
                color: widget.color,
                onPressed: _simulate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Las cuatro regiones', style: t.titleSmall),
              const SizedBox(height: 8),
              VennChart(
                onlyA: _result?.onlyA ?? (_pA - _pAB),
                both: _result?.both ?? _pAB,
                onlyB: _result?.onlyB ?? (_pB - _pAB),
                neither: _result?.neither ?? (100 - _pA - _pB + _pAB),
                highlight: _highlight,
              ),
              const SizedBox(height: 6),
              Text(
                _result == null
                    ? 'Valores en porcentaje. Simula para ver personas.'
                    : 'Personas simuladas de ${Fmt.int0(_result!.total)}.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 14),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'P(A ∪ B) exacta',
                    value: union.value.asPercent(),
                    color: AppColors.theoretical,
                    hint: 'P(A)+P(B)−P(A∩B)',
                  ),
                  StatTile(
                    label: 'Suma ingenua',
                    value: Fmt.percent((_pA + _pB) / 100),
                    color: AppColors.danger,
                    hint: 'sin restar la intersección',
                  ),
                  if (_result != null)
                    StatTile(
                      label: 'P(A ∪ B) observada',
                      value: Fmt.percent(_result!.pUnion),
                      color: AppColors.observed,
                    ),
                  StatTile(
                    label: 'P(A)·P(B)',
                    value: product.asPercent(),
                    color: AppColors.indigo,
                    hint: 'compáralo con P(A∩B)',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NoticeBox(
                independent
                    ? 'P(A∩B) = ${pab.asPercent()} coincide con '
                        'P(A)·P(B) = ${product.asPercent()}: A y B son '
                        'INDEPENDIENTES, y además se solapan. Independiente '
                        'no es excluyente.'
                    : _pAB == 0
                        ? 'A y B son EXCLUYENTES (no se tocan). Y por eso '
                            'mismo son dependientes: si ocurre A, sabes con '
                            'certeza que B no ocurrió. '
                            'P(B|A) = 0 frente a P(B) = ${pb.asPercent()}.'
                        : 'P(A∩B) = ${pab.asPercent()} no coincide con '
                            'P(A)·P(B) = ${product.asPercent()}: A y B son '
                            'DEPENDIENTES.',
                kind: independent ? NoticeKind.success : NoticeKind.info,
                title: 'Prueba de independencia',
              ),
              const SizedBox(height: 14),
              Text('Las dos condicionales', style: t.titleSmall),
              const SizedBox(height: 8),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'P(A | B)',
                    value: _pB == 0
                        ? '—'
                        : Fmt.percent(_pAB / _pB),
                    color: AppColors.indigo,
                    hint: 'divide entre P(B)',
                  ),
                  StatTile(
                    label: 'P(B | A)',
                    value: _pA == 0
                        ? '—'
                        : Fmt.percent(_pAB / _pA),
                    color: AppColors.rose,
                    hint: 'divide entre P(A)',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Misma intersección arriba, distinto denominador abajo. Esa '
                'es toda la diferencia entre P(A|B) y P(B|A).',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    int value,
    int min,
    int max,
    Color color,
    ValueChanged<int> onChanged,
  ) {
    final safeMax = max <= min ? min + 1 : max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label = $value %',
            style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: value.clamp(min, safeMax).toDouble(),
          min: min.toDouble(),
          max: safeMax.toDouble(),
          divisions: safeMax - min,
          activeColor: color,
          label: '$value %',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

// =====================================================================
// Laboratorio 4a — Urna
// =====================================================================
class UrnLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const UrnLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<UrnLab> createState() => _UrnLabState();
}

class _UrnLabState extends State<UrnLab> {
  late int _red;
  late int _blue;
  late int _draws;
  bool _replace = false;
  int _trials = 2000;
  SimulationRun? _run;

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    _red = d['rojas'] ?? 4;
    _blue = d['azules'] ?? 6;
    _draws = d['draws'] ?? 2;
    _replace = (d['replace'] ?? 0) == 1;
  }

  void _simulate() {
    final r = Simulators.urnDraws(
      counts: {'R': _red, 'A': _blue},
      targetColor: 'R',
      draws: _draws,
      withReplacement: _replace,
      trials: _trials,
      seed: widget.seed,
    );
    setState(() => _run = r);
    widget.onTrialsRun(_trials);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final total = _red + _blue;
    final withRep = Rational.fromInts(_red, total).pow(_draws);
    final noRep = Rational(
      Combinatorics.combinations(_red, _draws),
      Combinatorics.combinations(total, _draws),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Urna con $_red rojas y $_blue azules', widget.color),
              const SizedBox(height: 12),
              _intSlider('Bolas rojas', _red, 1, 12,
                  (v) => setState(() => _red = v)),
              _intSlider('Bolas azules', _blue, 1, 12,
                  (v) => setState(() => _blue = v)),
              _intSlider('Extracciones', _draws, 1, 4, (v) {
                setState(() => _draws = v);
              }),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _replace ? 'Con reposición' : 'Sin reposición',
                  style: t.titleSmall,
                ),
                subtitle: Text(
                  _replace
                      ? 'La bola vuelve a la urna: las extracciones son '
                          'independientes.'
                      : 'La bola no vuelve: la segunda extracción depende de '
                          'la primera.',
                  style: t.bodySmall,
                ),
                value: _replace,
                onChanged: (v) => setState(() {
                  _replace = v;
                  _run = null;
                }),
              ),
              const SizedBox(height: 6),
              TrialsSelector(
                value: _trials,
                color: widget.color,
                onChanged: (v) => setState(() => _trials = v),
                options: const [200, 800, 2000, 10000],
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                'Extraer $_draws bola(s), ${Fmt.int0(_trials)} veces',
                icon: Icons.play_arrow_rounded,
                color: widget.color,
                onPressed: _draws > total ? null : _simulate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Todas rojas: los dos modelos', style: t.titleSmall),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'Sin reposición',
                    value: noRep.asPercent(digits: 2),
                    color: AppColors.theoretical,
                    hint: noRep.asFraction,
                  ),
                  StatTile(
                    label: 'Con reposición',
                    value: withRep.asPercent(digits: 2),
                    color: AppColors.amber,
                    hint: withRep.asFraction,
                  ),
                  if (_run != null)
                    StatTile(
                      label: 'Observada',
                      value: Fmt.percent(_run!.observed, digits: 2),
                      color: AppColors.observed,
                      hint: '${Fmt.int0(_run!.successes)} de '
                          '${Fmt.int0(_run!.trials)}',
                    ),
                  StatTile(
                    label: 'Diferencia entre modelos',
                    value: Fmt.percent(
                      (withRep.toDouble() - noRep.toDouble()).abs(),
                      digits: 2,
                    ),
                    color: AppColors.rose,
                    hint: 'esto ES la dependencia',
                  ),
                ],
              ),
              if (_run != null) ...[
                const SizedBox(height: 16),
                ConvergenceChart(
                  points: trajectoryToOffsets(_run!.trajectory),
                  theoretical: _run!.theoreticalValue,
                ),
              ],
              const SizedBox(height: 14),
              _tree(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tree() {
    final total = _red + _blue;
    final pR = _red / total;
    final pA = _blue / total;
    final secondRedAfterRed =
        _replace ? pR : (total - 1 == 0 ? 0.0 : (_red - 1) / (total - 1));
    final secondRedAfterBlue =
        _replace ? pR : (total - 1 == 0 ? 0.0 : _red / (total - 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Árbol de las dos primeras extracciones',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TreeChart(
          height: 180,
          roots: [
            TreeNode(
              label: 'Roja',
              probability: pR,
              color: AppColors.danger,
              children: [
                TreeNode(
                  label: 'Roja',
                  probability: secondRedAfterRed,
                  color: AppColors.danger,
                ),
                TreeNode(
                  label: 'Azul',
                  probability: 1 - secondRedAfterRed,
                  color: AppColors.indigo,
                ),
              ],
            ),
            TreeNode(
              label: 'Azul',
              probability: pA,
              color: AppColors.indigo,
              children: [
                TreeNode(
                  label: 'Roja',
                  probability: secondRedAfterBlue,
                  color: AppColors.danger,
                ),
                TreeNode(
                  label: 'Azul',
                  probability: 1 - secondRedAfterBlue,
                  color: AppColors.indigo,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _replace
              ? 'Con reposición, las ramas del segundo nivel repiten las del '
                  'primero: eso es la independencia, dibujada.'
              : 'Sin reposición, las ramas del segundo nivel cambian según lo '
                  'que salió antes: eso es la dependencia, dibujada.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _intSlider(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value',
            style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: widget.color,
          label: '$value',
          onChanged: (v) {
            onChanged(v.round());
            setState(() => _run = null);
          },
        ),
      ],
    );
  }
}

// =====================================================================
// Laboratorio 4b — Tamizaje y evidencia
// =====================================================================
class ScreeningLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const ScreeningLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<ScreeningLab> createState() => _ScreeningLabState();
}

class _ScreeningLabState extends State<ScreeningLab> {
  late int _prevalence; // en por mil, para permitir valores pequeños
  late int _sensitivity;
  late int _specificity;
  late int _population;
  ScreeningResult? _result;

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    _prevalence = (d['prev'] ?? 1) * 10;
    _sensitivity = d['sens'] ?? 99;
    _specificity = d['spec'] ?? 95;
    _population = d['population'] ?? 100000;
  }

  double get _prevFraction => _prevalence / 1000.0;

  void _simulate() {
    final r = Simulators.screening(
      population: _population,
      prevalence: _prevFraction,
      sensitivity: _sensitivity / 100,
      specificity: _specificity / 100,
      seed: widget.seed,
    );
    setState(() => _result = r);
    widget.onTrialsRun(_population);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final exact = ProbabilityEngine.diagnosticTest(
      prevalence: Rational.fromInts(_prevalence, 1000),
      sensitivity: Rational.fromInts(_sensitivity, 100),
      specificity: Rational.fromInts(_specificity, 100),
    );
    final sick = (_population * _prevFraction).round();
    final healthy = _population - sick;
    final truePos = (sick * _sensitivity / 100).round();
    final falsePos = (healthy * (100 - _specificity) / 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Mueve la prevalencia y el test', widget.color),
              const SizedBox(height: 12),
              _sliderRow(
                'Prevalencia',
                '${(_prevFraction * 100).toStringAsFixed(1)} %',
                _prevalence.toDouble(),
                1,
                300,
                AppColors.rose,
                (v) => setState(() => _prevalence = v.round()),
              ),
              _sliderRow(
                'Sensibilidad',
                '$_sensitivity %',
                _sensitivity.toDouble(),
                50,
                100,
                AppColors.teal,
                (v) => setState(() => _sensitivity = v.round()),
              ),
              _sliderRow(
                'Especificidad',
                '$_specificity %',
                _specificity.toDouble(),
                50,
                100,
                AppColors.indigo,
                (v) => setState(() => _specificity = v.round()),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                'Simular ${Fmt.int0(_population)} personas',
                icon: Icons.groups_outlined,
                color: widget.color,
                onPressed: _simulate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cuenta personas, no porcentajes', style: t.titleSmall),
              const SizedBox(height: 10),
              _countTable(sick, healthy, truePos, falsePos),
              const SizedBox(height: 14),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'P(enfermo | +) exacta',
                    value: exact.value.asPercent(digits: 1),
                    color: AppColors.theoretical,
                    hint: 'valor predictivo positivo',
                  ),
                  StatTile(
                    label: 'Sensibilidad',
                    value: '$_sensitivity %',
                    color: AppColors.teal,
                    hint: 'P(+ | enfermo): NO es lo mismo',
                  ),
                  if (_result != null)
                    StatTile(
                      label: 'VPP simulado',
                      value: Fmt.percent(_result!.ppv, digits: 1),
                      color: AppColors.observed,
                      hint: '${Fmt.int0(_result!.truePositives)} de '
                          '${Fmt.int0(_result!.positives)} positivos',
                    ),
                  StatTile(
                    label: 'Falsos positivos por verdadero',
                    value: truePos == 0
                        ? '—'
                        : (falsePos / truePos).toStringAsFixed(1),
                    color: AppColors.danger,
                    hint: 'cuántos sanos por cada enfermo detectado',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CategoryChart(
                height: 150,
                bars: [
                  BarDatum('Verdaderos +', truePos.toDouble(),
                      AppColors.success),
                  BarDatum('Falsos +', falsePos.toDouble(), AppColors.danger),
                ],
                caption: 'Altura proporcional al número de personas. Con una '
                    'enfermedad rara, la barra roja aplasta a la verde.',
              ),
              const SizedBox(height: 14),
              NoticeBox(
                'Baja la prevalencia al 0,1 % sin tocar el test: el valor '
                'predictivo positivo se desploma. El test no cambió; cambió a '
                'quién se le aplica. El VPP no es una propiedad del test.',
                kind: NoticeKind.warning,
                title: 'La tasa base manda',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _countTable(int sick, int healthy, int truePos, int falsePos) {
    final scheme = Theme.of(context).colorScheme;
    final rows = [
      ['', 'Test +', 'Test −', 'Total'],
      [
        'Enfermos',
        Fmt.int0(truePos),
        Fmt.int0(sick - truePos),
        Fmt.int0(sick)
      ],
      [
        'Sanos',
        Fmt.int0(falsePos),
        Fmt.int0(healthy - falsePos),
        Fmt.int0(healthy)
      ],
      [
        'Total',
        Fmt.int0(truePos + falsePos),
        Fmt.int0((sick - truePos) + (healthy - falsePos)),
        Fmt.int0(sick + healthy)
      ],
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++)
            Container(
              decoration: BoxDecoration(
                color: r == 0
                    ? scheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                border: r == 0
                    ? null
                    : Border(top: BorderSide(color: scheme.outline)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (var c = 0; c < rows[r].length; c++)
                    Expanded(
                      flex: c == 0 ? 3 : 2,
                      child: Text(
                        rows[r][c],
                        textAlign:
                            c == 0 ? TextAlign.left : TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: (r == 0 || c == 0)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: (r == 1 && c == 1)
                              ? AppColors.success
                              : (r == 2 && c == 1)
                                  ? AppColors.danger
                                  : scheme.onSurface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sliderRow(
    String label,
    String display,
    double value,
    double min,
    double max,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $display',
            style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: color,
          onChanged: (v) {
            onChanged(v);
            setState(() => _result = null);
          },
        ),
      ],
    );
  }
}

// =====================================================================
// Laboratorio 5 — Máquina de conteo
// =====================================================================
class CountingLab extends StatefulWidget {
  final Experiment experiment;
  final Color color;
  final int seed;
  final ValueChanged<int> onSeedChange;
  final ValueChanged<int> onTrialsRun;

  const CountingLab({
    super.key,
    required this.experiment,
    required this.color,
    required this.seed,
    required this.onSeedChange,
    required this.onTrialsRun,
  });

  @override
  State<CountingLab> createState() => _CountingLabState();
}

class _CountingLabState extends State<CountingLab> {
  int _group = 23;
  int _trials = 2000;
  int _numbers = 49;
  int _picks = 6;
  int _n = 5;
  int _k = 3;
  SimulationRun? _birthday;
  LotteryResult? _lottery;

  @override
  void initState() {
    super.initState();
    final d = widget.experiment.defaults;
    _group = d['group'] ?? 23;
    _trials = d['trials'] ?? 2000;
    _numbers = d['numbers'] ?? 49;
    _picks = d['picks'] ?? 6;
    _n = d['n'] ?? 5;
    _k = d['k'] ?? 3;
  }

  String get _mode {
    switch (widget.experiment.id) {
      case 'x14_cumpleanos':
        return 'birthday';
      case 'x15_loteria':
        return 'lottery';
      default:
        return 'order';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case 'birthday':
        return _buildBirthday();
      case 'lottery':
        return _buildLottery();
      default:
        return _buildOrder();
    }
  }

  // --- Cumpleaños -----------------------------------------------------
  Widget _buildBirthday() {
    final t = Theme.of(context).textTheme;
    final exact = Combinatorics.birthdayCollision(_group);
    final pairs = Combinatorics.combinations(_group, 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Tamaño del grupo', widget.color),
              const SizedBox(height: 12),
              Text('Personas en la sala: $_group', style: t.titleSmall),
              Slider(
                value: _group.toDouble(),
                min: 2,
                max: 60,
                divisions: 58,
                activeColor: widget.color,
                label: '$_group',
                onChanged: (v) => setState(() {
                  _group = v.round();
                  _birthday = null;
                }),
              ),
              TrialsSelector(
                value: _trials,
                color: widget.color,
                onChanged: (v) => setState(() => _trials = v),
                options: const [500, 2000, 10000],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                'Simular ${Fmt.int0(_trials)} salas',
                icon: Icons.play_arrow_rounded,
                color: widget.color,
                onPressed: () {
                  final r = Simulators.birthdaySimulation(
                    groupSize: _group,
                    trials: _trials,
                    seed: widget.seed,
                  );
                  setState(() => _birthday = r);
                  widget.onTrialsRun(_trials);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coincidencia de cumpleaños', style: t.titleSmall),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'Probabilidad exacta',
                    value: exact.asPercent(digits: 1),
                    color: AppColors.theoretical,
                    hint: '1 − (365·364·…)/365^$_group',
                  ),
                  StatTile(
                    label: 'Parejas posibles',
                    value: Combinatorics.formatBig(pairs),
                    color: AppColors.amber,
                    hint: 'C($_group, 2): esto es lo que cuenta',
                  ),
                  if (_birthday != null)
                    StatTile(
                      label: 'Observada',
                      value: Fmt.percent(_birthday!.observed, digits: 1),
                      color: AppColors.observed,
                      hint: '${Fmt.int0(_birthday!.successes)} salas de '
                          '${Fmt.int0(_birthday!.trials)}',
                    ),
                  StatTile(
                    label: 'Semilla',
                    value: '${widget.seed}',
                    color: widget.color,
                  ),
                ],
              ),
              if (_birthday != null) ...[
                const SizedBox(height: 16),
                ConvergenceChart(
                  points: trajectoryToOffsets(_birthday!.trajectory),
                  theoretical: _birthday!.theoreticalValue,
                ),
              ],
              const SizedBox(height: 14),
              CategoryChart(
                height: 150,
                bars: [
                  for (final g in const [5, 10, 23, 30, 40, 50])
                    BarDatum(
                      '$g',
                      Combinatorics.birthdayCollision(g).toDouble(),
                      g == _group ? AppColors.amber : AppColors.indigo,
                    ),
                ],
                caption: 'Probabilidad exacta según el tamaño del grupo. La '
                    'curva sube mucho antes de lo que la intuición espera.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Lotería --------------------------------------------------------
  Widget _buildLottery() {
    final t = Theme.of(context).textTheme;
    final combos = Combinatorics.combinations(_numbers, _picks);
    final years = combos.toDouble() / 52.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Configura el sorteo', widget.color),
              const SizedBox(height: 12),
              Text('Números del bombo: $_numbers', style: t.titleSmall),
              Slider(
                value: _numbers.toDouble(),
                min: 10,
                max: 60,
                divisions: 50,
                activeColor: widget.color,
                label: '$_numbers',
                onChanged: (v) => setState(() {
                  _numbers = v.round();
                  if (_picks > _numbers) _picks = _numbers;
                  _lottery = null;
                }),
              ),
              Text('Números elegidos: $_picks', style: t.titleSmall),
              Slider(
                value: _picks.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                activeColor: AppColors.amber,
                label: '$_picks',
                onChanged: (v) => setState(() {
                  _picks = v.round();
                  _lottery = null;
                }),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                'Jugar 5 000 sorteos con el mismo boleto',
                icon: Icons.confirmation_num_outlined,
                color: widget.color,
                onPressed: () {
                  final r = Simulators.lottery(
                    numbers: _numbers,
                    picks: _picks,
                    ticketsPlayed: 5000,
                    seed: widget.seed,
                  );
                  setState(() => _lottery = r);
                  widget.onTrialsRun(5000);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('El tamaño del espacio muestral', style: t.titleSmall),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'Combinaciones',
                    value: Combinatorics.formatBig(combos),
                    color: AppColors.theoretical,
                    hint: 'C($_numbers, $_picks)',
                  ),
                  StatTile(
                    label: 'Probabilidad de acertar',
                    value: Rational(BigInt.one, combos).asDecimal(digits: 10),
                    color: AppColors.rose,
                    hint: Fmt.oneIn(1 / combos.toDouble()),
                  ),
                  StatTile(
                    label: 'Años, 1 boleto/semana',
                    value: Fmt.int0(years.round()),
                    color: AppColors.amber,
                    hint: 'espera media hasta acertar',
                  ),
                  if (_lottery != null)
                    StatTile(
                      label: 'Aciertos en 5 000 sorteos',
                      value: '${_lottery!.wins}',
                      color: AppColors.observed,
                      hint: 'casi siempre cero, y es lo esperable',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const NoticeBox(
                'La combinación 1-2-3-4-5-6 tiene exactamente la misma '
                'probabilidad que cualquier otra. Parece «menos probable» '
                'porque confundimos un resultado concreto con la descripción '
                '«números desordenados», que agrupa millones de resultados.',
                kind: NoticeKind.info,
                title: 'Un detalle que incomoda',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Orden ----------------------------------------------------------
  Widget _buildOrder() {
    final t = Theme.of(context).textTheme;
    final combos = Combinatorics.combinations(_n, _k);
    final vars = Combinatorics.variations(_n, _k);
    final varsRep = Combinatorics.variationsWithRepetition(_n, _k);
    final comboList = Combinatorics.listCombinations(_n, _k);
    final varList = Combinatorics.listVariations(_n, _k);
    const names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    String render(List<int> idx) => idx.map((i) => names[i]).join('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          accent: widget.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SimHeader('Elige n y k', widget.color),
              const SizedBox(height: 12),
              Text('Elementos disponibles (n): $_n', style: t.titleSmall),
              Slider(
                value: _n.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                activeColor: widget.color,
                label: '$_n',
                onChanged: (v) => setState(() {
                  _n = v.round();
                  if (_k > _n) _k = _n;
                }),
              ),
              Text('Elementos elegidos (k): $_k', style: t.titleSmall),
              Slider(
                value: _k.toDouble(),
                min: 1,
                max: _n.toDouble(),
                divisions: _n - 1 == 0 ? 1 : _n - 1,
                activeColor: AppColors.amber,
                label: '$_k',
                onChanged: (v) => setState(() => _k = v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tres conteos del mismo problema', style: t.titleSmall),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 142,
                children: [
                  StatTile(
                    label: 'Sin orden, sin repetir',
                    value: Combinatorics.formatBig(combos),
                    color: AppColors.teal,
                    hint: 'C($_n,$_k) — comités',
                  ),
                  StatTile(
                    label: 'Con orden, sin repetir',
                    value: Combinatorics.formatBig(vars),
                    color: AppColors.indigo,
                    hint: 'P($_n,$_k) — cargos',
                  ),
                  StatTile(
                    label: 'Con orden, repitiendo',
                    value: Combinatorics.formatBig(varsRep),
                    color: AppColors.amber,
                    hint: '$_n^$_k — contraseñas',
                  ),
                  StatTile(
                    label: 'Factor entre las dos primeras',
                    value: '${Combinatorics.formatBig(Combinatorics.factorial(_k))} = $_k!',
                    color: AppColors.rose,
                    hint: 'órdenes de cada grupo',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Las dos listas, enumeradas', style: t.titleSmall),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ListBox(
                      title: 'Combinaciones (${comboList.length})',
                      color: AppColors.teal,
                      items: [
                        for (final c in comboList.take(40)) render(c),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ListBox(
                      title: 'Variaciones (${varList.length})',
                      color: AppColors.indigo,
                      items: [
                        for (final v in varList.take(60)) render(v),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NoticeBox(
                'Mira las dos listas a la vez: cada combinación de la '
                'izquierda aparece $_k! veces en la derecha, una por cada '
                'orden. Esa es toda la razón por la que C(n,k) divide entre '
                'k!.',
                kind: NoticeKind.info,
                title: 'La prueba del intercambio',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListBox extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;

  const _ListBox({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final i in items)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    i,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
