import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against a silently missing translation.
///
/// When a key is absent from both maps, GetX falls through and prints the key
/// itself — which for English-sentence keys looks almost right, so it is easy
/// to ship. This test scans every `.tr` / `.trParams` call in `lib/` and fails
/// if the key is not in both locales.
void main() {
  test('every .tr key exists in both en_US and km_KH', () {
    final String lang = File('lib/util/languages.dart').readAsStringSync();
    final String en = lang.substring(
      lang.indexOf("'en_US'"),
      lang.indexOf("'km_KH'"),
    );
    final String km = lang.substring(lang.indexOf("'km_KH'"));

    final RegExp single = RegExp(r"'([^'\n]+)'\s*\.tr(?:Params)?\b");
    final RegExp double = RegExp(r'"([^"\n]+)"\s*\.tr(?:Params)?\b');

    final Set<String> used = <String>{};
    for (final FileSystemEntity f in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('languages.dart')) continue;
      final String src = f.readAsStringSync();
      used.addAll(single.allMatches(src).map((RegExpMatch m) => m.group(1)!));
      used.addAll(double.allMatches(src).map((RegExpMatch m) => m.group(1)!));
    }

    expect(
      used,
      isNotEmpty,
      reason: 'no .tr calls found — did the scan break?',
    );

    bool has(String block, String key) =>
        block.contains("'$key':") || block.contains('"$key":');

    final List<String> missingEn =
        used.where((String k) => !has(en, k)).toList()..sort();
    final List<String> missingKm =
        used.where((String k) => !has(km, k)).toList()..sort();

    expect(missingEn, isEmpty, reason: 'missing from en_US: $missingEn');
    expect(missingKm, isEmpty, reason: 'missing from km_KH: $missingKm');
  });
}
