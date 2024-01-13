import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class StoryBookApp extends StatefulWidget {
  const StoryBookApp({super.key});

  @override
  State<StoryBookApp> createState() => _StoryBookAppState();
}

class _StoryBookAppState extends State<StoryBookApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StoryBookPage(),
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
      ..userUniqueId("sdbi13i42iciw2"))
    .build();
