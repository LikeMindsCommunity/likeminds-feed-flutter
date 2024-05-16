import 'dart:async';

import 'package:likeminds_feed_sample/app.dart';
import 'package:likeminds_feed_sample/main.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/feed/lm_qna_feed.dart';
import 'package:likeminds_feed_sample/themes/qna/lm_feed_qna.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/index.dart';
import 'package:likeminds_feed_sample/themes/social/screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_sample/themes/social_dark/likeminds_feed_nova_fl.dart';
import 'package:uni_links/uni_links.dart';

bool initialURILinkHandled = false;
const _isProd = !bool.fromEnvironment('DEBUG');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integration App for UI + SDK package',
      debugShowCheckedModeBanner: _isProd,
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: LMFeedBlocListener(
        analyticsListener: (BuildContext context, LMFeedAnalyticsState state) {
          if (state is LMFeedAnalyticsEventFired) {
            debugPrint("Bloc Listened for event, - ${state.eventName}");
            debugPrint("////////////////");
            debugPrint("With properties - ${state.eventProperties}");
          }
        },
        profileListener: (BuildContext context, LMFeedProfileState state) {},
        routingListener: (BuildContext context, LMFeedRoutingState state) {},
        child: const CredScreen(),
      ),
    );
  }
}

class CredScreen extends StatefulWidget {
  const CredScreen({super.key});

  @override
  State<CredScreen> createState() => _CredScreenState();
}

class _CredScreenState extends State<CredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _uuidController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  StreamSubscription? _streamSubscription;
  LMSampleApp? lmFeed;
  String? uuid;
  int selectedTheme = 0;

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
              DropdownButtonFormField<int>(
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
                    value: 0,
                    child: Text("Social Theme"),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("Social FeedRoom Theme"),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text("QnA Feed Theme"),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text("Social Dark Theme"),
                  ),
                ],
                onChanged: (value) {
                  selectedTheme = value ?? selectedTheme;
                },
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () async {
                  String uuid = _uuidController.text;
                  String userName = _usernameController.text;
                  String apiKey = "f24b9522-a612-4f1e-8551-ffce88a52c76";
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
                  LMResponse response =
                      await LMFeedCore.instance.showFeedWithApiKey(
                    apiKey: apiKey,
                    uuid: uuid,
                    userName: userName,
                  );
                  if (!response.success) {
                    _showSnackBar(response.errorMessage ?? "An error occurred");
                    return;
                  }
                  // define the route
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => _getNavigationWidget(selectedTheme),
                  );

                  // dismiss the loader dialog
                  Navigator.of(context).pop();

                  // navigate to the feed screen
                  Navigator.of(context).pushReplacement(route);
                },
                child: Container(
                  width: 200,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  LMFeedLocalPreference.instance.clearCache();
                },
                child: Container(
                  width: 200,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Text(
                    "Clear Data",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              const SizedBox(height: 72),
              const Text(
                "If no credentials are provided, the app will run with the default credentials of Bot user in your community",
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNavigationWidget(int selectedTheme) {
    switch (selectedTheme) {
      case 0:
        {
          return const ExampleTabScreen(
            uuid: "",
            feedWidget: LMFeedScreen(),
          );
        }
      case 1:
        {
          return const ExampleTabScreen(
            uuid: "",
            feedWidget: LMFeedScreen(),
          );
        }
      case 2:
        {
          const LMFeedQnA();
        }
      case 3:
        {
          const LMFeedNova();
        }
      default:
        {
          return const LMFeedScreen();
        }
    }
    return const LMFeedScreen();
  }

  Future<void> _setUpFeed(int selectedTheme) async {
    switch (selectedTheme) {
      case 0:
        {
          LMFeedCore.instance.initialize();
          break;
        }

      case 1:
        {
          LMFeedCore.instance.initialize();
          break;
        }
      case 2:
        {
          await LMFeedQnA.setupFeed();
        }
        break;
      case 3:
        {
          await LMFeedCore.instance.initialize(
            theme: novaTheme1,
          );
          break;
        }
      default:
        {
          LMFeedCore.instance.initialize();
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
