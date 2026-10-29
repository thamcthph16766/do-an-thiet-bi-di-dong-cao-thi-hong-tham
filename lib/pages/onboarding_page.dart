import 'package:flutter/material.dart';

import '../store/habit_store.dart';
import 'main_shell.dart';

class _Item {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _Item(this.icon, this.title, this.desc, this.color);
}

const _items = [
  _Item(Icons.track_changes, 'Xây dựng thói quen tốt',
      'Tạo thói quen mới chỉ trong vài giây: uống nước, đọc sách, tập thể dục...',
      Color(0xFF4F7DF3)),
  _Item(Icons.check_circle, 'Đánh dấu mỗi ngày',
      'Chạm để hoàn thành, giữ chuỗi ngày liên tiếp 🔥 để có thêm động lực.',
      Color(0xFF2EAD8B)),
  _Item(Icons.insights, 'Xem lại tiến độ',
      'Lịch tháng và biểu đồ cho bạn thấy mình đã tiến bộ thế nào.',
      Color(0xFFF2994A)),
];

/// Slider giới thiệu (PageView). [replay] = true khi mở lại từ Cài đặt.
class OnboardingPage extends StatefulWidget {
  final bool replay;
  const OnboardingPage({super.key, this.replay = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _items.length - 1;

  Future<void> _finish() async {
    await store.setSeenOnboarding(true);
    if (!mounted) return;
    if (widget.replay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Bỏ qua')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final it = _items[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: it.color.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(it.icon, size: 90, color: it.color),
                        ),
                        const SizedBox(height: 40),
                        Text(it.title,
                            textAlign: TextAlign.center,
                            style: text.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(it.desc,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Chấm tròn chỉ vị trí trang
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (_isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  child: Text(_isLast ? 'Bắt đầu' : 'Tiếp theo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
