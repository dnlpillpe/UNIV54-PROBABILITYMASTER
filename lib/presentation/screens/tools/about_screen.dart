/// Acerca de: qué contiene la app, cómo decide y qué NO hace.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../painters/brand_painter.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Acerca de',
            subtitle: '${AppInfo.name} ${AppInfo.version} · ${AppInfo.buildLabel}',
            color: AppColors.indigoDeep,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Center(
                  child: Column(
                    children: [
                      const BrandMark(size: 92),
                      const SizedBox(height: 12),
                      Text(AppInfo.name, style: t.headlineSmall),
                      const SizedBox(height: 4),
                      Text(AppInfo.tagline, style: t.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                AppCard(
                  accent: AppColors.indigo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qué promete', style: t.titleSmall),
                      const SizedBox(height: 7),
                      Text(AppInfo.promise, style: t.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SectionTitle('Contenido'),
                TileGrid(
                  minTileWidth: 145,
                  children: [
                    StatTile(
                      label: 'Módulos',
                      value: '${content.modules.length}',
                      color: AppColors.indigo,
                    ),
                    StatTile(
                      label: 'Lecciones',
                      value: '${content.lessonCount}',
                      color: AppColors.teal,
                      hint: '${content.cardCount} tarjetas',
                    ),
                    StatTile(
                      label: 'Experimentos',
                      value: '${content.experimentCount}',
                      color: AppColors.amber,
                      hint: '${content.labs.length} laboratorios',
                    ),
                    StatTile(
                      label: 'Ejercicios',
                      value: '${content.exerciseCount}',
                      color: AppColors.rose,
                      hint: '6 tipos',
                    ),
                    StatTile(
                      label: 'Casos',
                      value: '${content.caseCount}',
                      color: AppColors.indigo,
                      hint: '11 carreras',
                    ),
                    StatTile(
                      label: 'Confusiones',
                      value: '${content.misconceptionCount}',
                      color: AppColors.danger,
                      hint: 'catalogadas y detectables',
                    ),
                    StatTile(
                      label: 'Glosario',
                      value: '${content.glossaryCount}',
                      color: AppColors.teal,
                      hint: 'términos',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionTitle('Las decisiones que la definen'),
                const _Decision(
                  number: 'D1',
                  title: 'La predicción es obligatoria',
                  body: 'Los controles de cada laboratorio están bloqueados '
                      'hasta que registras tu predicción. Una creencia que no '
                      'se hace explícita no se corrige: el estudiante que ve '
                      'el resultado correcto reinterpreta su intuición previa '
                      'para que coincida.',
                ),
                const _Decision(
                  number: 'D2',
                  title: 'El espacio muestral se enumera antes de contarse',
                  body: 'Se construyen a mano espacios de 4, 6, 8, 36 y 52 '
                      'resultados. Cuando el módulo 3 dice «hay C(52,5) '
                      'manos», ya sabes qué objeto está siendo contado.',
                ),
                const _Decision(
                  number: 'D3',
                  title: 'Cada distractor declara su confusión',
                  body: 'Acertar no aporta información; fallar de una manera '
                      'concreta sí. El diagnóstico suma, resta y decae, para '
                      'que una confusión superada desaparezca sola.',
                ),
                const _Decision(
                  number: 'D4',
                  title: 'Regla 60/40 y umbral doble',
                  body: 'En los ítems de decisión, la elección vale 0,6 y la '
                      'justificación 0,4. «Competente» exige 70 % en el total '
                      'y también en la práctica.',
                ),
                const _Decision(
                  number: 'D5',
                  title: 'Ningún número está escrito a mano',
                  body: 'Todas las cifras del contenido se calculan con el '
                      'motor a través de un registro de funciones con nombre, '
                      'y un test las recalcula en cada compilación.',
                ),
                const _Decision(
                  number: 'D6',
                  title: 'Aritmética exacta',
                  body: 'Las probabilidades de espacios finitos se calculan '
                      'como fracciones exactas con BigInt: verás 11/36, no '
                      '0,3055555…',
                ),
                const SizedBox(height: 16),
                const SectionTitle('Sobre el tutor'),
                AppCard(
                  accent: AppColors.amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Determinista, por decisión', style: t.titleSmall),
                      const SizedBox(height: 7),
                      Text(
                        'El tutor diagnostica confusiones, clasifica '
                        'problemas y resuelve paso a paso. No conversa. En un '
                        'dominio donde un error tiene la misma forma que la '
                        'respuesta correcta —una fracción plausible—, un '
                        'modelo generativo que acierta el 97 % de las veces '
                        'es peor que no tener tutor: el estudiante no puede '
                        'detectar el 3 % restante.',
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El adaptador para un modelo de lenguaje está '
                        'preparado y no activado, con una regla fija: el '
                        'modelo redacta, el motor calcula. Nunca produce un '
                        'número ni toca el puntaje.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SectionTitle('Limitaciones declaradas'),
                const NoticeBox(
                  'No cubre variables aleatorias ni distribuciones como tema; '
                  'el tutor no responde preguntas abiertas; los casos '
                  'profesionales son verosímiles pero no auditados por un '
                  'especialista de cada carrera; y la app está en un solo '
                  'idioma.',
                  kind: NoticeKind.warning,
                  title: 'Qué NO hace esta app',
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Privacidad', style: t.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Todo el progreso se guarda solo en este dispositivo. '
                        'La app no tiene cuentas, no pide permisos y no se '
                        'conecta a ningún servidor.',
                        style: t.bodyMedium,
                      ),
                    ],
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

class _Decision extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _Decision({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.indigo,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, style: t.titleSmall)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
