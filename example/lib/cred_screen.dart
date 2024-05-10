import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:likeminds_feed_sample/app.dart';
import 'package:likeminds_feed_sample/main.dart';
import 'package:likeminds_feed_sample/tab_screen.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_sample/utils/utils.dart';
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
  StreamSubscription? _streamSubscription;
  LMSampleApp? lmFeed;
  String? uuid;

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
    LMFeedThemeData feedTheme = LMFeedCore.theme;

    return Scaffold(
      backgroundColor: feedTheme.primaryColor,
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
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                "Enter your credentials",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                controller: _usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Colors.white,
                controller: _uuidController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'User ID',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    )),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () async {
                  String uuid = _uuidController.text;
                  String userName = _usernameController.text;

                  if (userName.isEmpty && uuid.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: LMFeedText(
                          text: "Username cannot be empty",
                          style: LMFeedTextStyle(
                              textStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    );
                    return;
                  }

                  String apiKey = dotenv.get('API_KEY');

                  // final (accessToken,refreshToken) = await initiateUser(uuid, userName);

                  // LMResponse response = await LMFeedCore.instance
                  //     .showFeedWithoutApiKey(accessToken, refreshToken,);
                  LMResponse response = await LMFeedCore.instance
                      .showFeedWithApiKey(apiKey, uuid, userName);

                  if (!response.success) {
                    LMFeedCore.showSnackBar(
                        context,
                        response.errorMessage ?? "An error occurred",
                        LMFeedWidgetSource.other);

                    return;
                  }

                  MaterialPageRoute route = MaterialPageRoute(
                    // INIT - Get the LMFeed instance and pass the credentials (if any)
                    builder: (context) => ExampleTabScreen(
                      feedWidget: const LMFeedScreen(),
                      uuid: uuid,
                    ),
                  );
                  Navigator.of(context).push(route);
                },
                child: Container(
                  width: 200,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Submit")),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Clear Data")),
                ),
              ),
              const SizedBox(height: 72),
              const Text(
                "If no credentials are provided, the app will run with the default credentials of Bot user in your community",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
