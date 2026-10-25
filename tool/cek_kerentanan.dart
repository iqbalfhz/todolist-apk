// Cek semua paket Dart di pubspec.lock terhadap database kerentanan OSV (osv.dev).
//
//   dart run tool/cek_kerentanan.dart
//
// Keluar dengan kode 1 kalau ada paket yang terdampak. SDK Flutter dan Dart sendiri tidak
// tercakup; pantau advisory keamanan Flutter dan Dart secara terpisah.

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final packages = _hostedPackages(File('pubspec.lock').readAsLinesSync());

  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('https://api.osv.dev/v1/querybatch'));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'queries': [
          for (final package in packages)
            {
              'package': {'name': package.name, 'ecosystem': 'Pub'},
              'version': package.version,
            },
        ],
      }),
    );
    final response = await request.close();
    final body = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>).cast<Map<String, dynamic>>();

    var affected = 0;
    for (var i = 0; i < results.length; i++) {
      final vulns = (results[i]['vulns'] as List<dynamic>?) ?? const [];
      if (vulns.isEmpty) continue;
      affected++;
      final ids = [for (final vuln in vulns.cast<Map<String, dynamic>>()) vuln['id']];
      stdout.writeln('${packages[i].name} ${packages[i].version}: ${ids.join(', ')}');
    }

    stdout.writeln('Diperiksa ${packages.length} paket, $affected terdampak.');
    if (affected > 0) exitCode = 1;
  } finally {
    client.close();
  }
}

/// Paket dari pub.dev (bukan SDK atau path) beserta versinya.
List<({String name, String version})> _hostedPackages(List<String> lines) {
  final result = <({String name, String version})>[];
  String? name;
  String? source;

  for (final line in lines) {
    final header = RegExp(r'^  ([a-z0-9_]+):$').firstMatch(line);
    if (header != null) {
      name = header.group(1);
      source = null;
      continue;
    }
    final sourceMatch = RegExp(r'^    source: (\w+)').firstMatch(line);
    if (sourceMatch != null) source = sourceMatch.group(1);

    final version = RegExp(r'^    version: "(.+)"').firstMatch(line);
    if (version != null && name != null) {
      if (source == 'hosted') result.add((name: name, version: version.group(1)!));
      name = null;
    }
  }
  return result;
}
