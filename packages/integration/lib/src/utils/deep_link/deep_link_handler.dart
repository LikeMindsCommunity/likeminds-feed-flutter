import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:share_plus/share_plus.dart';

part 'deep_link_path.dart';
part 'deep_link_request.dart';
part 'deep_link_response.dart';

class LMFeedDeepLinkHandler {
  // below function creates a link from domain and post id
  String createLink(String postId) {
    String? domain = LMFeedCore.domain;
    if (domain != null) {
      return '';
    }
    int length = LMFeedCore.domain!.length;
    if (domain![length - 1] == '/') {
      return "${domain}post?post_id=$postId";
    } else {
      return "$domain/post?post_id=$postId";
    }
  }

  // Below functions takes the user outside of the application
  // using the domain provided at the time of initialization
  void sharePost(String postId) {
    String postUrl = createLink(postId);
    if (postUrl.isEmpty) {
      LMFeedCore.showSnackBar(
        LMFeedSnackBar(
          content: LMFeedText(text: "The post sharing feature is unavailable"),
        ),
      );
    } else {
      Share.share(postUrl);
    }
  }

  @deprecated
  Future<LMFeedDeepLinkResponse> parseDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    switch (request.path) {
      case LMFeedDeepLinkPath.OPEN_POST:
        return handleOpenPostDeepLink(request, navigatorKey);
      case LMFeedDeepLinkPath.CREATE_POST:
        return handleCreatePostDeepLink(request, navigatorKey);
      case LMFeedDeepLinkPath.OPEN_COMMENT:
        return handleOpenCommentDeepLink(request, navigatorKey);
      default:
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: 'Invalid path',
        );
    }
  }

  @deprecated
  Future<LMFeedDeepLinkResponse> handleOpenPostDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final String? postId = request.data?['post_id'];
    if (request.data == null || postId == null) {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage: 'Invalid request, post id should not be null',
      );
    } else {
      InitiateUserResponse response =
          await LMFeedCore.instance.initiateUser((InitiateUserRequestBuilder()
                ..uuid(request.uuid)
                ..userName(request.userName))
              .build());
      if (response.success) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(postId: postId),
          ),
        );
        return LMFeedDeepLinkResponse(
          success: true,
        );
      } else {
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: "URI parsing failed. Please try after some time.",
        );
      }
    }
  }

  @deprecated
  Future<LMFeedDeepLinkResponse> handleCreatePostDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    InitiateUserResponse response =
        await LMFeedCore.instance.initiateUser((InitiateUserRequestBuilder()
              ..uuid(request.uuid)
              ..userName(request.userName))
            .build());
    if (response.success) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const LMFeedComposeScreen(),
        ),
      );
      return LMFeedDeepLinkResponse(
        success: true,
      );
    } else {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage: "URI parsing failed. Please try after some time.",
      );
    }
  }

  @deprecated
  Future<LMFeedDeepLinkResponse> handleOpenCommentDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final String? postId = request.data?['post_id'];
    final String? commentId = request.data?['comment_id'];
    if (request.data == null || postId == null || commentId == null) {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage:
            'Invalid request, post id and comment id should not be null',
      );
    } else {
      InitiateUserResponse response =
          await LMFeedCore.instance.initiateUser((InitiateUserRequestBuilder()
                ..uuid(request.uuid)
                ..userName(request.userName))
              .build());
      if (response.success) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) =>
                LMFeedPostDetailScreen(postId: request.data!['post_id']),
          ),
        );
        return LMFeedDeepLinkResponse(
          success: true,
        );
      } else {
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: "URI parsing failed. Please try after some time.",
        );
      }
    }
  }
}
