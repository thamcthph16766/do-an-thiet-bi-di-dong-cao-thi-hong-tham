import 'package:flutter/material.dart';

/// Bộ biểu tượng và màu cho thói quen.
/// Lưu theo chỉ số (index) để dữ liệu gọn và an toàn khi build release.
class HabitStyle {
  static const List<IconData> icons = [
    Icons.water_drop,
    Icons.directions_run,
    Icons.menu_book,
    Icons.self_improvement,
    Icons.bedtime,
    Icons.restaurant,
    Icons.code,
    Icons.music_note,
    Icons.fitness_center,
    Icons.savings,
    Icons.language,
    Icons.cleaning_services,
  ];

  static const List<Color> colors = [
    Color(0xFF4F7DF3),
    Color(0xFF2EAD8B),
    Color(0xFFF2994A),
    Color(0xFFE5566E),
    Color(0xFF9B6CF2),
    Color(0xFF1FA7C9),
    Color(0xFFD4A017),
    Color(0xFF6D7A8C),
  ];
}

/// Chuyển ngày thành khoá dạng yyyy-MM-dd (không phụ thuộc giờ, múi giờ).
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Bỏ phần giờ phút, chỉ giữ ngày (giờ địa phương).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Cộng/trừ số ngày an toàn.
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

class Habit {
  final String id;
  String name;
  String note;
  int iconIndex;
  int colorIndex;

  /// Mục tiêu số ngày mỗi tuần (1–7), chọn bằng Slider.
  int targetPerWeek;
  final DateTime createdAt;

  /// Tập các ngày đã hoàn thành, dạng yyyy-MM-dd.
  final Set<String> doneDates;

  Habit({
    required this.id,
    required this.name,
    this.note = '',
    this.iconIndex = 0,
    this.colorIndex = 0,
    this.targetPerWeek = 7,
    DateTime? createdAt,
    Set<String>? doneDates,
  })  : createdAt = createdAt ?? DateTime.now(),
        doneDates = doneDates ?? <String>{};

  IconData get icon => HabitStyle.icons[iconIndex % HabitStyle.icons.length];
  Color get color => HabitStyle.colors[colorIndex % HabitStyle.colors.length];

  bool isDoneOn(DateTime d) => doneDates.contains(dateKey(d));

  /// Đánh dấu / bỏ đánh dấu một ngày.
  void toggle(DateTime d) {
    final k = dateKey(d);
    if (!doneDates.remove(k)) doneDates.add(k);
  }

  /// Chuỗi ngày liên tiếp hiện tại.
  /// Nếu hôm nay chưa làm thì tính từ hôm qua (chuỗi chưa bị đứt).
  int currentStreak([DateTime? now]) {
    var day = dateOnly(now ?? DateTime.now());
    if (!isDoneOn(day)) day = addDays(day, -1);
    var count = 0;
    while (isDoneOn(day)) {
      count++;
      day = addDays(day, -1);
    }
    return count;
  }

  /// Chuỗi ngày liên tiếp dài nhất từ trước đến nay.
  int get bestStreak {
    if (doneDates.isEmpty) return 0;
    final days = doneDates.map(DateTime.parse).toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i] == addDays(days[i - 1], 1)) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
    }
    return best;
  }

  /// Số ngày đã hoàn thành trong tuần hiện tại (Thứ 2 → Chủ nhật).
  int doneThisWeek([DateTime? now]) {
    final today = dateOnly(now ?? DateTime.now());
    final monday = addDays(today, -(today.weekday - 1));
    var c = 0;
    for (var i = 0; i < 7; i++) {
      if (isDoneOn(addDays(monday, i))) c++;
    }
    return c;
  }

  /// Tỉ lệ hoàn thành trong [days] ngày gần nhất (0.0 – 1.0),
  /// chỉ tính từ ngày bắt đầu theo dõi.
  double completionRate(int days, [DateTime? now]) {
    final today = dateOnly(now ?? DateTime.now());
    var start = addDays(today, -(days - 1));

    var firstDay = dateOnly(createdAt);
    for (final k in doneDates) {
      final d = DateTime.parse(k);
      if (d.isBefore(firstDay)) firstDay = d;
    }
    if (firstDay.isAfter(start)) start = firstDay;

    final span = (today.difference(start).inHours / 24).round() + 1;
    if (span <= 0) return 0;
    var done = 0;
    for (var i = 0; i < span; i++) {
      if (isDoneOn(addDays(start, i))) done++;
    }
    return done / span;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'note': note,
        'icon': iconIndex,
        'color': colorIndex,
        'target': targetPerWeek,
        'createdAt': createdAt.toIso8601String(),
        'done': doneDates.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'] as String,
        name: j['name'] as String,
        note: (j['note'] ?? '') as String,
        iconIndex: (j['icon'] ?? 0) as int,
        colorIndex: (j['color'] ?? 0) as int,
        targetPerWeek: (j['target'] ?? 7) as int,
        createdAt:
            DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
        doneDates: ((j['done'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toSet(),
      );
}
