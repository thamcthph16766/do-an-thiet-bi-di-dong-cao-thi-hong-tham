import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/main_shell.dart';
import 'pages/onboarding_page.dart';
import 'store/habit_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN'); // ngày tháng tiếng Việt
  await store.load(); // đọc dữ liệu đã lưu trên máy
  runApp(const HabitApp());
}

class HabitApp extends StatefulWidget {
  const HabitApp({super.key});

  @override
  State<HabitApp> createState() => _HabitAppState();
}

class _HabitAppState extends State<HabitApp> {
  // Màn hình đầu tiên chỉ quyết định 1 lần khi mở app.
  late final Widget _home =
      store.seenOnboarding ? const MainShell() : const OnboardingPage();

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F7DF3),
        brightness: b,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'Thói quen',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: _home,
      ),
    );
  }
}
