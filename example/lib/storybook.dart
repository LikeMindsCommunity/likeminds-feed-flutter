import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:overlay_support/overlay_support.dart';

class StoryBookApp extends StatefulWidget {
  const StoryBookApp({super.key});

  @override
  State<StoryBookApp> createState() => _StoryBookAppState();
}

class _StoryBookAppState extends State<StoryBookApp> {
  @override
  Widget build(BuildContext context) {
    return const OverlaySupport.global(
      child: MaterialApp(
        home: StoryBookPage(),
      ),
    );
  }
}

class StoryBookPage extends StatefulWidget {
  const StoryBookPage({super.key});

  @override
  State<StoryBookPage> createState() => _StoryBookPageState();
}

class _StoryBookPageState extends State<StoryBookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: userTileStory(),
      ),
    );
  }

  buttonStory() {
    return LMFeedButton(
      onTap: () {},
      style: LMFeedButtonStyle(
        border: Border.all(
          color: Colors.blue,
        ),
      ),
    );
  }

  tileStory() {
    return const LMFeedTile();
  }

  userTileStory() {
    return LMFeedUserTile(user: storyUser);
  }
}

final storyUser = (LMUserViewDataBuilder()
      ..name("Divu")
      ..id(123456)
      ..imageUrl("https://picsum.photos/200")
      ..uuid("sdbi13i42iciw2"))
    .build();
