# Core package of LikeMinds Feed Flutter SDK, provides access to screens, BLoCs, and other utilities.

## Quick Links
- [LikeMinds dashboard](https://dashboard.likeminds.community/)
- [Detailed Documentation](https://docs.likeminds.community/feed/Flutter/getting-started)



# Getting Started

LikeMinds Flutter Feed SDK provides you with a wrapper layer around the built in functionalities to provide a seamless integration experience within a single sitting without much configuration needed out of the box.

**Although,** we do provide a high level customisation of all the widgets, screens, and flows being used to power the experience that can be tuned according to the look and feel of your existing apps.

There are two main steps, with a few sub-steps, to get it up and running.

## Setup the environment

- Generate API key from [LikeMinds dashboard](https://dashboard.likeminds.community/). Follow this [link](https://docs.likeminds.community/#generate-api-key) for tutorial.
- You need only one dependency in your application project to get started without any customizations, namely `likeminds_feed_flutter_core`, which can be found [here](https://pub.dev/packages/likeminds_feed_flutter_core).

## Integrate the SDK

- Add `likeminds_feed_flutter_core` dependency to your project’s `pubspec.yaml` by adding these lines under `dependencies` section

```yaml
likeminds_feed_flutter_core: <latest> #fetches automatically from pub.dev
```

When integrating the LikeMinds Feed SDK into your application, you have the option to initiate a user session using one of two approaches:

### 1. With API Key

This approach should used when you want to manage LikeMinds authentication tokens on frontend.
In this case you provide API Key directly to LikeMinds Feed SDK, which will be used to initiate a user session by calling **showFeedWithApiKey()** method from `LMFeedCore`.

1. Setup the `LMFeedCore` package in the main function with the following code.

```dart
main(){
// Call setup function before the runApp() function
await LMFeedCore.instance.initialize();
...
runApp(YourApp());
}
```

2. Use the snippet of code below to be able to show feed using your API key, this is also used to login using passed user credentials.

```dart
// initiate user session, use the response to check for any errors
 LMResponse<void> response = await LMFeedCore.instance.showFeedWithApiKey(
  apiKey : "YOUR_API_KEY",
  uuid : "USER_ID",
  userName : "USER_NAME",
);

```

3. On successful response of the above snippet you can simply navigate to the `LMFeedScreen`, and start using Feed in your app

```dart

if (response.success) {
  MaterialPageRoute route = MaterialPageRoute(
    builder: (context) => const LMFeedScreen(),
  );

  Navigator.pushReplacement(context, route);
}

```

### 2. Without API Key

This approach should be used when you want to manage LikeMinds authentication tokens on your backend server.
In this case you eliminate the need to expose your API Key to your client app and your backend server is responsible for calling the [initiate API](https://docs.likeminds.community/rest-api/#/operations/sdkInitate) to obtain the `accessToken` and `refreshToken` which is passed to **showFeedWithoutApiKey()** from `LMFeedCore` to validate the user session.

1. Create a function to get `accessToken` and `refreshToken` from your backend using [initiate API](https://docs.likeminds.community/rest-api/#/operations/sdkInitate)

```dart
Future<(String, String)> getTokens() async {
...
// implementation
...
return (accessToken, refreshToken);
}
```

2. Set up the `LMFeedCore` package in the main function with the following code and pass `LMFeedCoreCallback`, which will be invoked when the `accessToken` and `refreshToken` expire.

:::info
`LMFeedCoreCallback` has two callbacks:

1. **onAccessTokenExpiredAndRefreshed:** This callback is triggered when the provided `accessToken` expires and is refreshed internally using the `refreshToken`.
2. **onRefreshTokenExpired:** This callback is triggered when the provided `refreshToken` expires. In this case, you need to provide a new `accessToken` and `refreshToken` from your backend function using our [initiate API](https://docs.likeminds.community/rest-api/#/operations/sdkInitate).
:::

```dart
main(){
// Call setup function before the runApp() function
await LMFeedCore.instance.initialize(
  lmFeedCallback: LMFeedCoreCallback(
    onAccessTokenExpiredAndRefreshed: (accessToken, refreshToken) {
      debugPrint("Access token expired and refreshed");
    },
    onRefreshTokenExpired: () async {
      // get accessToken, refreshToken from your backend
      final (accessToken, refreshToken) = await getTokens();
      // return `LMAuthToken` with `accessToken` and `refreshToken` received from your backend
      return (LMAuthTokenBuilder()
            ..accessToken(accessToken!)
            ..refreshToken(refreshToken!))
          .build();
    },
  ),
);
...
runApp(YourApp());
}
```

3. Use the `getTokens()` function, to fetch the tokens to login without API Key. Upon receiving the `accessToken` and `refreshToken`, call `LMFeedCore.instance.showFeedWithoutApiKey()` function with these tokens.

```dart
// get accessToken, refreshToken from your backend
final (accessToken, refreshToken) = await getTokens();
LMResponse response =
    await LMFeedCore.instance.showFeedWithoutApiKey(
      accessToken : "YOUR_ACCESS_TOKEN",
      refreshToken : "YOUR_REFRESH_TOKEN",
    );

```

4. On successful response of the above snippet you can simply navigate to the `LMFeedScreen`, and start using Feed in your app

```dart

if (response.success) {
  MaterialPageRoute route = MaterialPageRoute(
    builder: (context) => const LMFeedScreen(),
  );

  Navigator.pushReplacement(context, route);
}

```

Now build the app, and call the above navigation function using a button or tab to experience LMFeed.

:::tip
By choosing the appropriate method based on your backend infrastructure and security preferences, you can seamlessly integrate the Feed SDK into your application while ensuring secure and efficient session management.
:::

### Congratulations! Your integration is now complete.

#### Welcome to the future of digital communities and social networks.

<br></br>

<p align="center">
  <img src="https://media0.giphy.com/media/11sBLVxNs7v6WA/giphy.gif?cid=7941fdc63p4lr2sp2zpav78j0zt0jrfvfo7ys4kbrvci4ee4&ep=v1_gifs_search&rid=giphy.gif&ct=g" alt="LMFeedAppbar"></img>
</p>

## 3. Extra steps for features

Some features are **optional** and require extra configuration, you can find it here

- To start uploading media to feed (release mode) - Add Proguard rules using the [guide](#proguard-setup) below

### Proguard setup

This is required only for Android, when you are building for release mode.

To enable uploading of media in the release build of Android, add these lines in your app/build.gradle

```gradle
  minifyEnabled true
  useProguard true
  proguardFiles getDefaultProguardFile('proguard-android.txt'),
          'proguard-aws-2.1.5.pro'

  //EXAMPLE
  buildTypes {
    release {
    signingConfig signingConfigs.release
    minifyEnabled true
    useProguard true
    proguardFiles getDefaultProguardFile('proguard-android.txt'),
                  'proguard-aws-2.1.5.pro'
    }
  }
```

Now create a new file with name "proguard-aws-2.1.5.pro" at the same location as app/build.gradle and paste the copied contents into this file. Paste the content below into this file.

```pro
# These options are the minimal options for a functioning application
# using Proguard and the AWS SDK 2.1.5 for Android
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class org.apache.commons.logging.**               { *; }
-keep class com.amazonaws.org.apache.commons.logging.** { *; }
-keep class com.amazonaws.services.sqs.QueueUrlHandler  { *; }
-keep class com.amazonaws.javax.xml.transform.sax.*     { public *; }
-keep class com.amazonaws.javax.xml.stream.**           { *; }
-keep class com.amazonaws.services.**.model.*Exception* { *; }
-keep class com.amazonaws.internal.**                   { *; }
-keep class org.codehaus.**                             { *; }
-keep class org.joda.time.tz.Provider                   { *; }
-keep class org.joda.time.tz.NameProvider               { *; }
-keepattributes Signature,*Annotation*,EnclosingMethod
-keepnames class com.fasterxml.jackson.** { *; }
-keepnames class com.amazonaws.** { *; }

-dontwarn com.fasterxml.jackson.databind.**
-dontwarn javax.xml.stream.events.**
-dontwarn org.codehaus.jackson.**
-dontwarn org.apache.commons.logging.impl.**
-dontwarn org.apache.http.conn.scheme.**
-dontwarn org.apache.http.annotation.**
-dontwarn org.ietf.jgss.**
-dontwarn org.joda.convert.**
-dontwarn com.amazonaws.org.joda.convert.**
-dontwarn org.w3c.dom.bootstrap.**

#SDK split into multiple jars so certain classes may be referenced but not used
-dontwarn com.amazonaws.services.s3.**
-dontwarn com.amazonaws.services.sqs.**

-dontnote com.amazonaws.services.sqs.QueueUrlHandler
```

Your release mode APK should work now.
