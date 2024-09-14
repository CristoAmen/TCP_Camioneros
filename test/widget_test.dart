// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tcp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Define un color principal para la prueba
    const Color colorPrincipal = Color.fromARGB(255, 1, 31, 10);

    // Construye la app y pasa el colorPrincipal
    await tester.pumpWidget(const MyApp(colorPrincipal: colorPrincipal));

    // Verifica que el contador empiece en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simula un toque en el icono '+' y actualiza el widget.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que el contador ha incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
