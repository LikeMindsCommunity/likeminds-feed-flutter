import 'dart:async';

import 'package:likeminds_feed_sample/globals.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/widgets_builder.dart';
import 'package:likeminds_feed_sample/themes/qna/lm_feed_qna.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/index.dart';
import 'package:likeminds_feed_sample/themes/social/screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_sample/themes/social_dark/likeminds_feed_nova_fl.dart';
import 'package:likeminds_feed_sample/themes/social_feedroom/koshiqa_theme.dart';
import 'package:likeminds_feed_sample/themes/social_feedroom/likeminds_feed_flutter_koshiqa.dart';
import 'package:uni_links/uni_links.dart';

bool initialURILinkHandled = false;

class CredScreen extends StatefulWidget {
  const CredScreen({super.key});

  @override
  State<CredScreen> createState() => _CredScreenState();
}

class _CredScreenState extends State<CredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _uuidController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _feedRoomController = TextEditingController();
  final ValueNotifier<bool> _isFeedRoomTheme = ValueNotifier(false);
  StreamSubscription? _streamSubscription;
  String? uuid;
  LMFeedFlavor selectedTheme = LMFeedFlavor.social;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks(context);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _uuidController.dispose();
    _apiKeyController.dispose();
    _feedRoomController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future initUniLinks(BuildContext context) async {
    // Get the initial deep link if the app was launched with one
    final initialLink = await getInitialLink();

    // Handle the deep link
    if (initialLink != null) {
      initialURILinkHandled = true;
      // You can extract any parameters from the initialLink object here
      // and use them to navigate to a specific screen in your app
      debugPrint('Received initial deep link: $initialLink');

      // TODO: add api key to the DeepLinkRequest
      // TODO: add user id and user name of logged in user
      final uriLink = Uri.parse(initialLink);
      if (uriLink.isAbsolute) {
        final deepLinkRequestBuilder = LMFeedDeepLinkRequestBuilder()
          ..uuid(uuid ?? "Test-User-Id")
          ..userName("Test User");
        if (uriLink.path == '/post') {
          List secondPathSegment = initialLink.split('post_id=');
          if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
            String postId = secondPathSegment[1];
            LMFeedDeepLinkHandler().parseDeepLink(
                (deepLinkRequestBuilder
                      ..path(LMFeedDeepLinkPath.OPEN_POST)
                      ..data({
                        "post_id": postId,
                      }))
                    .build(),
                rootNavigatorKey);
          }
        } else if (uriLink.path == '/post/create') {
          LMFeedDeepLinkHandler().parseDeepLink(
              (deepLinkRequestBuilder..path(LMFeedDeepLinkPath.CREATE_POST))
                  .build(),
              rootNavigatorKey);
        }
      }
    }

    // Subscribe to link changes
    _streamSubscription = linkStream.listen((String? link) async {
      if (link != null) {
        initialURILinkHandled = true;
        // Handle the deep link
        // You can extract any parameters from the uri object here
        // and use them to navigate to a specific screen in your app
        debugPrint('Received deep link: $link');
        // TODO: add api key to the DeepLinkRequest
        // TODO: add user id and user name of logged in user

        final uriLink = Uri.parse(link);
        if (uriLink.isAbsolute) {
          final deepLinkRequestBuilder = LMFeedDeepLinkRequestBuilder()
            ..uuid(uuid ?? "Test-User-Id")
            ..userName("Test User");

          if (uriLink.path == '/post') {
            List secondPathSegment = link.split('post_id=');
            if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
              String postId = secondPathSegment[1];
              LMFeedDeepLinkHandler().parseDeepLink(
                  (deepLinkRequestBuilder
                        ..path(LMFeedDeepLinkPath.OPEN_POST)
                        ..data({
                          "post_id": postId,
                        }))
                      .build(),
                  rootNavigatorKey);
            }
          } else if (uriLink.path == '/post/create') {
            LMFeedDeepLinkHandler().parseDeepLink(
              (deepLinkRequestBuilder..path(LMFeedDeepLinkPath.CREATE_POST))
                  .build(),
              rootNavigatorKey,
            );
          }
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(height: 72),
              const Text(
                "LikeMinds Feed\nSample App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                "Enter your credentials",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'API Key',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _uuidController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'User ID',
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                  valueListenable: _isFeedRoomTheme,
                  builder: (context, value, child) {
                    return value
                        ? Column(
                            children: [
                              TextField(
                                controller: _feedRoomController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelText: 'Feed Room ID',
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink();
                  }),
              const SizedBox(height: 12),
              DropdownButtonFormField<LMFeedFlavor>(
                isExpanded: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: selectedTheme,
                items: const [
                  DropdownMenuItem(
                    value: LMFeedFlavor.social,
                    child: Text("Social Theme"),
                  ),
                  DropdownMenuItem(
                    value: LMFeedFlavor.socialFeedRoom,
                    child: Text("Social FeedRoom Theme"),
                  ),
                  DropdownMenuItem(
                    value: LMFeedFlavor.qna,
                    child: Text("QnA Feed Theme"),
                  ),
                  DropdownMenuItem(
                    value: LMFeedFlavor.socialDark,
                    child: Text("Social Dark Theme"),
                  ),
                ],
                onChanged: (value) {
                  selectedTheme = value ?? selectedTheme;
                  if (value == LMFeedFlavor.socialFeedRoom) {
                    _isFeedRoomTheme.value = true;
                  } else {
                    _isFeedRoomTheme.value = false;
                  }
                },
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fixedSize: const Size(200, 45),
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    LMFeedLocalPreference.instance.clearCache();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fixedSize: const Size(200, 45),
                  ),
                  child: const Text("Clear Data")),
              const SizedBox(height: 72),
              const Text(
                "Please consider using clear data to log in with your new credentials.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    String uuid = _uuidController.text;
    String userName = _usernameController.text;
    String apiKey = _apiKeyController.text;
    globalApiKey = apiKey;
    if (apiKey.isEmpty) {
      _showSnackBar("API Key cannot be empty");
      return;
    }
    if ((userName.isEmpty && uuid.isEmpty)) {
      _showSnackBar("Username and User ID both cannot be empty");
      return;
    }
    // show the loader dialog
    _showLoader(context);

    // initialize the LMFeedCore instance
    // await LMFeedCore.instance.initialize();
    await _setUpFeed(selectedTheme);

    // initiate the user
    LMResponse response = await LMFeedCore.instance.showFeedWithApiKey(
      apiKey: apiKey,
      uuid: uuid,
      userName: userName,
    );
    if (!response.success) {
      _showSnackBar(response.errorMessage ?? "An error occurred");
      return;
    }
    // define the route
    Widget? navigationWidget = _getNavigationWidget(selectedTheme);
    if (navigationWidget == null) {
      Navigator.pop(context);
      return;
    }
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => navigationWidget,
    );

    // dismiss the loader dialog
    Navigator.of(context).pop();

    // navigate to the feed screen
    Navigator.of(context).push(route);
  }

  Widget? _getNavigationWidget(LMFeedFlavor selectedTheme) {
    switch (selectedTheme) {
      case LMFeedFlavor.social:
        {
          return const ExampleTabScreen(
            uuid: "",
            feedWidget: LMFeedScreen(),
          );
        }
      case LMFeedFlavor.socialFeedRoom:
        {
          if (!LMFeedUserUtils.checkIfCurrentUserIsCM() &&
              _feedRoomController.text.isEmpty) {
            _showSnackBar(
                "You need to provide an LM FeedRoom ID if the user being logged in is not a community manager");
            return null;
          }
          int? feedRoomId;
          if (_feedRoomController.text.isNotEmpty) {
            feedRoomId = int.parse(_feedRoomController.text);
          }
          return LMFeedKoshiqa(
            feedRoomId: feedRoomId,
          );
        }
      case LMFeedFlavor.qna:
        {
          return const LMFeedQnA();
        }
      case LMFeedFlavor.socialDark:
        {
          return const LMFeedNova();
        }
    }
  }

  Future<void> _setUpFeed(LMFeedFlavor selectedTheme) async {
    switch (selectedTheme) {
      case LMFeedFlavor.social:
        {
          LMFeedCore.theme = LMFeedThemeData.light();
          LMFeedCore.widgetUtility = LMFeedWidgetUtility.instance;
          LMFeedCore.config = LMFeedConfig();
          break;
        }

      case LMFeedFlavor.socialFeedRoom:
        {
          LMFeedCore.theme = koshiqaTheme;
          LMFeedCore.widgetUtility = LMFeedWidgetUtility.instance;
          LMFeedCore.config = LMFeedConfig();
          break;
        }
      case LMFeedFlavor.qna:
        {
          LMFeedCore.theme = qNaTheme;
          LMFeedCore.config = LMFeedConfig(
            composeConfig: const LMFeedComposeScreenConfig(
              topicRequiredToCreatePost: true,
              showMediaCount: false,
              enableTagging: false,
              enableDocuments: false,
              enableHeading: true,
              headingRequiredToCreatePost: true,
              userDisplayType: LMFeedComposeUserDisplayType.tile,
              composeHint: "Mention details here to make the post rich",
            ),
            feedScreenConfig: const LMFeedScreenConfig(
              enableTopicFiltering: false,
            ),
            postDetailConfig: const LMPostDetailScreenConfig(
                commentTextFieldHint: "Write your response"),
          );
          LMFeedCore.widgetUtility = LMFeedQnAWidgets.instance;
          LMFeedTimeAgo.instance.setDefaultTimeFormat(LMQnACustomTimeStamps());
        }
        break;
      case LMFeedFlavor.socialDark:
        {
          LMFeedCore.theme = darkTheme;
          LMFeedCore.widgetUtility = LMFeedWidgetUtility.instance;
          LMFeedCore.config = LMFeedConfig();
          break;
        }
    }
  }

  Future<dynamic> _showLoader(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AlertDialog(
          content: SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

enum LMFeedFlavor {
  social,
  socialFeedRoom,
  qna,
  socialDark,
}
