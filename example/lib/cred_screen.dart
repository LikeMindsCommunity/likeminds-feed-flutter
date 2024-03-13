import 'dart:async';

import 'package:likeminds_feed_sample/app.dart';
import 'package:likeminds_feed_sample/main.dart';
import 'package:likeminds_feed_sample/tab_screen.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uni_links/uni_links.dart';

bool initialURILinkHandled = false;
const _isProd = !bool.fromEnvironment('DEBUG');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        background: Colors.black,
        textColor: Colors.white,
        alignment: Alignment.bottomCenter,
      ),
      child: LMFeedTheme(
        theme: LMFeedThemeData.light(
          primaryColor: Colors.red[300],
          tagColor: Colors.red[300],
          linkColor: Colors.red[300],
        ),
        child: MaterialApp(
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
            analyticsListener:
                (BuildContext context, LMFeedAnalyticsState state) {
              if (state is LMFeedAnalyticsEventFired) {
                debugPrint("Bloc Listened for event, - ${state.eventName}");
                debugPrint("////////////////");
                debugPrint("With properties - ${state.eventProperties}");
              }
            },
            profileListener:
                (BuildContext context, LMFeedProfileState state) {},
            routingListener:
                (BuildContext context, LMFeedRoutingState state) {},
            child: const CredScreen(),
          ),
        ),
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
  final TextEditingController _userIdController = TextEditingController();
  StreamSubscription? _streamSubscription;
  LMSampleApp? lmFeed;
  String? userId;

  @override
  void initState() {
    super.initState();
    // userId = UserLocalPreference.instance.fetchUserId();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks(context);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIdController.dispose();
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
          ..userId(userId ?? "Test-User-Id")
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
            ..userId(userId ?? "Test-User-Id")
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
      toast('An error occurred');
    });
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    // return lmFeed;
    userId = null; // UserLocalPreference.instance.fetchUserId();
    // If the local prefs have user id stored
    // Login using that user Id
    // otherwise show the cred screen for login
    if (userId != null && userId!.isNotEmpty) {
      return lmFeed = LMSampleApp(
        userId: userId,
        userName: 'Test User',
      );
    } else {
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
                  controller: _userIdController,
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
                  onTap: () {
                    String userId = _userIdController.text;
                    String userName = _usernameController.text;

                    if (userName.isEmpty && userId.isEmpty) {
                      toast("Username cannot be empty");
                      return;
                    }

                    lmFeed = LMSampleApp(
                      userId: _userIdController.text,
                      userName: _usernameController.text,
                    );

                    MaterialPageRoute route = MaterialPageRoute(
                      // INIT - Get the LMFeed instance and pass the credentials (if any)
                      builder: (context) => ExampleTabScreen(
                        feedWidget: lmFeed!,
                        userId: userId,
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
}
