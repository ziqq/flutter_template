import 'pie_chart_test.dart' as pie_chart_test;
import 'component_contract_test.dart' as component_contract_test;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  pie_chart_test.main();
  component_contract_test.main();
  testWidgets('local image reads each XFile once and handles same-path replacements', (tester) async {
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
    );
    final first = _ImageFile(Future<Uint8List>.value(png));
    final second = _ImageFile(Future<Uint8List>.value(png));
    Widget build(XFile file) => Directionality(
      textDirection: TextDirection.ltr,
      child: UILocalImage(file: file, placeholder: const Text('loading')),
    );
    await tester.pumpWidget(build(first));
    await tester.pump();
    expect(first.reads, 1);
    await tester.pumpWidget(build(first));
    expect(first.reads, 1);
    await tester.pumpWidget(build(second));
    await tester.pump();
    expect(second.reads, 1);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('local image shows a placeholder when reading fails', (tester) async {
    final bytes = Completer<Uint8List>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: UILocalImage(file: _ImageFile(bytes.future), placeholder: const Text('unavailable')),
      ),
    );
    bytes.completeError(StateError('unreadable'));
    await tester.pump();
    expect(find.text('unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ImageFile extends XFile {
  _ImageFile(this.bytes) : super('same-path', name: 'image.png');
  final Future<Uint8List> bytes;
  int reads = 0;
  @override
  Future<Uint8List> readAsBytes() {
    reads++;
    return bytes;
  }
}
