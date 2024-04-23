import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/main.dart';

Future<(String?, String?)> initiateUser(String uuid, String userName) async {
  String apiKey = dotenv.get('API_KEY');
  String host = dotenv.get('HOST');
  Dio dio = Dio();
  var response = await dio.post('$host/sdk/initiate',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'x-sdk-source': "feed",
        'x-platform-code': "fl",
      }),
      data: {
        'uuid': uuid,
        'userName': userName,
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
