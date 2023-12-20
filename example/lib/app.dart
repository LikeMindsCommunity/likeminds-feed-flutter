import 'package:flutter/material.dart';
import 'package:likeminds_feed_example/globals.dart';
import 'package:overlay_support/overlay_support.dart';

class LMSampleApp extends StatelessWidget {
  const LMSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        background: Colors.black,
        textColor: Colors.white,
        alignment: Alignment.bottomCenter,
      ),
      child: MaterialApp(
        title: 'Integration App for UI + SDK package',
        debugShowCheckedModeBanner: true,
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.deepPurple,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            outlineBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            activeIndicatorBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
        home: Container(),
      ),
    );
  }
}
