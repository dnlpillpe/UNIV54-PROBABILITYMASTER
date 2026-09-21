/// Formateo compartido.
library;

class Fmt {
  const Fmt._();

  /// Porcentaje con coma decimal, estilo hispano.
  static String percent(double v, {int digits = 1}) =>
      '${(v * 100).toStringAsFixed(digits).replaceAll('.', ',')} %';

  /// Decimal con coma.
  static String decimal(double v, {int digits = 3}) =>
      v.toStringAsFixed(digits).replaceAll('.', ',');

  /// Entero con separador de miles fino.
  static String int0(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return (v < 0 ? '-' : '') + buf.toString();
  }

  /// «1 de cada N», la forma que la gente entiende de verdad.
  static String oneIn(double p) {
    if (p <= 0) return 'nunca';
    final n = 1 / p;
    if (n < 1.5) return 'casi siempre';
    if (n >= 1000000) {
      return '1 de cada ${int0((n / 1000000).round())} millones';
    }
    return '1 de cada ${int0(n.round())}';
  }

  /// Sustituye las marcas `{{id}}` de un texto por valores ya calculados.
  static String fill(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('{{$k}}', v);
    });
    return out;
  }

  static String plural(int n, String singular, String pluralForm) =>
      n == 1 ? singular : pluralForm;
}
