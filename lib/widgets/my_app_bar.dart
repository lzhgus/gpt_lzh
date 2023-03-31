import 'package:flutter/material.dart';
import 'package:gpt_lzh/widgets/theme_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_theme_provider.dart';
import '../providers/tts_provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'ChatGPT',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      actions: [
        Row(
          children: [
            Consumer(
              builder: (context, ref, child) => Icon(
                ref.watch(activeThemeProvider) == Themes.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
            SizedBox(width: 10),
            ThemeSwitch(),
            SizedBox(width: 10),
            Icon(Icons.speaker),
            SizedBox(width: 10),
            Consumer(builder: (context, ref, child) {
              final enableTts = ref.watch(enableTtsProvider);
              return Switch.adaptive(
                activeColor: Theme.of(context).colorScheme.secondary,
                value: enableTts,
                onChanged: (bool newValue) {
                  ref.read(enableTtsProvider.notifier).state = newValue;
                },
              );
            }),
          ],
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(60);
}
