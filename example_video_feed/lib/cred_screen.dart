import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMCredScreen extends StatefulWidget {
  const LMCredScreen({super.key});

  @override
  State<LMCredScreen> createState() => _LMCredScreenState();
}

class _LMCredScreenState extends State<LMCredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _uuidController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _postIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _uuidController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  _fetchUserData() {
    LMUserViewData? userViewData =
        LMFeedLocalPreference.instance.fetchUserData();

    if (userViewData != null) {
      _uuidController.text = userViewData.sdkClientInfo.uuid;
      _usernameController.text = userViewData.name;
    }

    LMResponse apiKeyCacheResponse =
        LMFeedCore.client.getCache(LMFeedStringConstants.apiKey);

    if (apiKeyCacheResponse.success) {
      _apiKeyController.text =
          (apiKeyCacheResponse.data as LMCache).value as String? ?? '';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  void _onSubmit() async {
    String uuid = _uuidController.text;
    String userName = _usernameController.text;
    String apiKey = _apiKeyController.text;
    List<String> postIds =
        _postIdController.text.split(',').map((e) => e.trim()).toList();
    if (apiKey.isEmpty) {
      _showSnackBar("API Key cannot be empty");
      return;
    }
    if (uuid.isEmpty) {
      _showSnackBar("User ID  cannot be empty");
      return;
    }
    // show the loader dialog
    _showLoader(context);

    // initiate the user
    LMResponse response = await LMFeedCore.instance.showFeedWithApiKey(
      apiKey: apiKey,
      uuid: uuid,
      userName: userName,
    );
    if (!response.success) {
      if (mounted) {
        // dismiss the loader dialog
        Navigator.pop(context);
      }
      _showSnackBar(response.errorMessage ?? "An error occurred");
      return;
    }

    // define the route
    Widget navigationWidget = LMFeedVideoFeedScreen(
      startFeedWithPostIds: postIds,
    );
    // create the route
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => navigationWidget,
    );

    if (mounted) {
      // dismiss the loader dialog
      Navigator.pop(context);

      // navigate to the feed screen
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(height: 72),
              const Text(
                "LikeMinds Video Feed\nSample App",
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
              TextField(
                controller: _postIdController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Post Ids to start feed with separated by comma',
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      // logout the user if already logged in
                      // if the user is not logged in,
                      // clear the cache manually
                      final response = await LMFeedCore.instance.logout();
                      if (!response.success) {
                        LMFeedLocalPreference.instance.clearCache();
                      }
                      _usernameController.clear();
                      _uuidController.clear();
                      _apiKeyController.clear();
                      _postIdController.clear();
                      _showSnackBar("Cleared all data");

                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(150, 45),
                    ),
                    child: const Text(
                      "Clear Data",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(0, 137, 123, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 137, 123, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(150, 45),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 72),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "Please clear the current data using the ",
                    ),
                    TextSpan(
                      text: "Clear Data",
                      style: TextStyle(
                        color: Color.fromRGBO(0, 137, 123, 1),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: " button before logging in with new credentials.",
                    ),
                  ],
                ),
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
}
