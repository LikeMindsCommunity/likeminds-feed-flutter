import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/globals.dart';

Future<(String?, String?)> initiateUser(String uuid, String userName) async {
  String host = dotenv.get('HOST');
  Dio dio = Dio();
  var response = await dio.post('$host/sdk/initiate',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'x-api-key': globalApiKey,
        'x-sdk-source': "feed",
        'x-platform-code': "fl",
      }),
      data: {
        'uuid': uuid,
        'user_name': userName,
        "token_expiry_beta": 1, // minutes
        "rtm_token_expiry_beta": 2 // minutes
      });

  if (response.data['success']) {
    return (
      response.data['data']['access_token'] as String,
      response.data['data']['refresh_token'] as String
    );
  } else {
    rootScaffoldMessengerKey.currentState?.showSnackBar(LMFeedSnackBar(
        content: LMFeedText(
      text: response.data["error_message"],
    )));
  }

  return (null, null);
}
