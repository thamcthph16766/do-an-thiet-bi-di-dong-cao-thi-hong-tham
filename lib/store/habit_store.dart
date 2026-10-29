import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

/// Kho dữ liệu dùng chung cho toàn app.
final store = HabitStore();

/// Quản lý danh sách thói quen + cài đặt, lưu bằng shared_preferences.
/// Mỗi khi dữ liệu đổi: notifyListeners() để giao diện vẽ lại, rồi lưu xuống máy.
class HabitStore extends ChangeNotifier {
  static const _kHabits = 'habits';
  static const _kSeen = 'seen_onboarding';
  static const _kDark = 'dark_mode';

  SharedPreferences? _prefs;
  final List<Habit> habits = [];
  bool seenOnboarding = false;
  bool darkMode = false;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    seenOnboarding = _prefs!.getBool(_kSeen) ?? false;
    darkMode = _prefs!.getBool(_kDark) ?? false;

    habits.clear();
    final raw = _prefs!.getString(_kHabits);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        habits.addAll(
            list.map((e) => Habit.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // Dữ liệu hỏng thì bỏ qua, bắt đầu danh sách trống.
      }
    }
  }

  void _commit() {
    notifyListeners();
    _prefs?.setString(
        _kHabits, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  void add(Habit h) {
    habits.add(h);
    _commit();
  }

  void insertAt(int index, Habit h) {
    habits.insert(min(index, habits.length), h);
    _commit();
  }

  void update(Habit h) => _commit();

  void remove(Habit h) {
    habits.remove(h);
    _commit();
  }

  void toggle(Habit h, DateTime day) {
    h.toggle(day);
    _commit();
  }

  Future<void> setSeenOnboarding(bool value) async {
    seenOnboarding = value;
    await _prefs?.setBool(_kSeen, value);
  }

  void setDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
    _prefs?.setBool(_kDark, value);
  }

  void clearAll() {
    habits.clear();
    _commit();
  }

  /// Tạo dữ liệu mẫu 60 ngày để demo khi bảo vệ.
  void loadSample() {
    final rnd = Random(7);
    final today = dateOnly(DateTime.now());
    final stamp = DateTime.now().microsecondsSinceEpoch;

    Habit make(String name, int icon, int color, int target, double p,
        [String note = '']) {
      final h = Habit(
        id: '$stamp-$icon',
        name: name,
        note: note,
        iconIndex: icon,
        colorIndex: color,
        targetPerWeek: target,
        createdAt: addDays(today, -59),
      );
      for (var i = 59; i >= 1; i--) {
        if (rnd.nextDouble() < p) h.doneDates.add(dateKey(addDays(today, -i)));
      }
      return h;
    }

    habits
      ..clear()
      ..addAll([
        make('Uống 2 lít nước', 0, 5, 7, 0.85, 'Mang theo bình nước khi đi học'),
        make('Chạy bộ 20 phút', 1, 1, 4, 0.55),
        make('Đọc sách 15 trang', 2, 2, 5, 0.7, 'Đọc trước khi ngủ'),
        make('Thiền 10 phút', 3, 4, 7, 0.45),
      ]);
    // 5 ngày gần nhất uống nước đều đặn để thấy chuỗi 🔥.
    for (var i = 1; i <= 5; i++) {
      habits[0].doneDates.add(dateKey(addDays(today, -i)));
    }
    _commit();
  }
}
