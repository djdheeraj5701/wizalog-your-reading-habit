import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wizalog_your_reading_habit/providers/app_state_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(appStateProvider.notifier).loadState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final currentBookName = appState['currentBookName'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (currentBookName != null && currentBookName.isNotEmpty)
            IconButton(
              onPressed: null,
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Finish current book',
            ),
        ],
      ),
      body: Container(),
    );
  }
}
