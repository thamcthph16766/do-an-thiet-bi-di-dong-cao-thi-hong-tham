import 'package:flutter/material.dart';

import '../store/habit_store.dart';
import '../widgets/common.dart';
import 'onboarding_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: ListView(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Chế độ tối'),
              value: store.darkMode,
              onChanged: store.setDarkMode,
            ),
            ListTile(
              leading: const Icon(Icons.slideshow_outlined),
              title: const Text('Xem lại giới thiệu'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const OnboardingPage(replay: true))),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Tạo dữ liệu mẫu'),
              subtitle: const Text('4 thói quen với lịch sử 60 ngày để demo'),
              onTap: () async {
                final ok = await confirmDialog(context,
                    title: 'Tạo dữ liệu mẫu?',
                    message: 'Dữ liệu hiện tại sẽ được thay bằng dữ liệu mẫu.');
                if (!ok || !context.mounted) return;
                store.loadSample();
                _toast(context, 'Đã tạo dữ liệu mẫu');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined,
                  color: Colors.red.shade600),
              title: Text('Xoá toàn bộ dữ liệu',
                  style: TextStyle(color: Colors.red.shade600)),
              onTap: () async {
                final ok = await confirmDialog(context,
                    title: 'Xoá toàn bộ?',
                    message: 'Mọi thói quen và lịch sử sẽ bị xoá vĩnh viễn.',
                    ok: 'Xoá',
                    danger: true);
                if (!ok || !context.mounted) return;
                store.clearAll();
                _toast(context, 'Đã xoá toàn bộ dữ liệu');
              },
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Habit Tracker v1.0'),
              subtitle: Text(
                  'Đồ án môn Thiết bị di động\nCao Thị Hồng Thắm - 2410060019'),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }
}
