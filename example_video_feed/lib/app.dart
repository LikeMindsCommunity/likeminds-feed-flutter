import 'package:flutter/material.dart';

import 'cred_screen.dart';

class LMVideoFeedSampleApp extends StatelessWidget {
  const LMVideoFeedSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
          colorScheme: const ColorScheme.light(
        primary: Color.fromRGBO(0, 137, 123, 1),
      )),
      home: const LMCredScreen(),
    );
  }
}
