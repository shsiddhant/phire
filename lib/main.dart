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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'memory.chat',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.1,
          fontFamily: 'AtkinsonHyperlegibleNext',
          fontFamilyFallback: ['NotoColorEmoji'],
        ),
        colorScheme: .fromSeed(
          seedColor: Color(0xFFBF0808),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.1,
          fontFamily: 'AtkinsonHyperlegibleNext',
          fontFamilyFallback: ['NotoColorEmoji'],
        ),
        colorScheme: .fromSeed(
          seedColor: Color(0xFFBF0808),
          brightness: Brightness.dark,
        ),
      ),
      // home: const WidgetPlayground(),
      home: const HomePage(),
    );
  }
}
