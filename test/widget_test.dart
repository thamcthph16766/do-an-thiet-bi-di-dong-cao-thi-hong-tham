// Kiểm thử logic tính chuỗi ngày và tỉ lệ hoàn thành.
// Chạy: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  final today = DateTime(2026, 10, 18); // Chủ nhật

  Habit habitWith(List<int> daysAgo) {
    final h = Habit(id: '1', name: 'Test', createdAt: addDays(today, -29));
    for (final d in daysAgo) {
      h.toggle(addDays(today, -d));
    }
    return h;
  }

  test('toggle bật rồi tắt một ngày', () {
    final h = habitWith([]);
    h.toggle(today);
    expect(h.isDoneOn(today), isTrue);
    h.toggle(today);
    expect(h.isDoneOn(today), isFalse);
  });

  test('chuỗi hiện tại tính cả hôm nay', () {
    expect(habitWith([0, 1, 2]).currentStreak(today), 3);
  });

  test('hôm nay chưa làm thì chuỗi tính từ hôm qua', () {
    expect(habitWith([1, 2]).currentStreak(today), 2);
  });

  test('chuỗi bị đứt', () {
    expect(habitWith([0, 2, 3]).currentStreak(today), 1);
  });

  test('chuỗi dài nhất', () {
    expect(habitWith([0, 1, 5, 6, 7, 8]).bestStreak, 4);
  });

  test('số ngày trong tuần (T2 → CN)', () {
    // today là CN → tuần gồm 0..6 ngày trước
    expect(habitWith([0, 3, 6, 7]).doneThisWeek(today), 3);
  });

  test('tỉ lệ 30 ngày', () {
    final h = habitWith(List.generate(15, (i) => i));
    expect(h.completionRate(30, today), closeTo(0.5, 0.001));
  });
}
