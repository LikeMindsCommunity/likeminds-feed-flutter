import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LMFeedClient lmFeedClient =
      (LMFeedClientBuilder()..apiKey(env['API_KEY']!)).build();
  await UserLocalPreference.instance.initialize();
  LMFeedIntegration.instance.initialize(
    lmFeedClient: lmFeedClient,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<InitiateUserResponse>? initiateUser;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiateUser =
        LMFeedIntegration.instance.initiateUser((InitiateUserRequestBuilder()
              ..userId(env['USER_ID']!)
              ..userName("Flutter Faad Team Bot")
              ..apiKey(env['API_KEY']!))
            .build())
          ..then((value) async {
            if (value.success) {
              memberState = LMFeedIntegration.instance.getMemberState();
            }
          });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: FutureBuilder(
              future: initiateUser,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.success) {
                  return const LMPostDetailScreen(
                      postId: "653388f3068a0ec51a176827");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else {
                  return const Center(
                    child: Text("Nothing"),
                  );
                }
              }),
        ),
      ),
    );
  }
}
