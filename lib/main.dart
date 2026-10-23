import 'package:flutter/material.dart';
import 'app_dependencies_injection.dart';
// import 'dev/widget_playground.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _getTheme(ThemeData baseTheme, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFBF0808),
      brightness: brightness,
    );
    final customTextTheme = baseTheme.textTheme.apply(
      fontSizeFactor: 1.1,
      fontFamily: 'AtkinsonHyperlegibleNext',
      fontFamilyFallback: const ['NotoColorEmoji'],
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    return ThemeData(colorScheme: colorScheme, textTheme: customTextTheme);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return MaterialApp(
      title: 'Phire',
      theme: _getTheme(baseTheme, Brightness.light),
      darkTheme: _getTheme(baseTheme, Brightness.dark),
      // home: const WidgetPlayground(),
      home: const HomePage(),
    );
  }
}
