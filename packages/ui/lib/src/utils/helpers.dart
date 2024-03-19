import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/linkify/linkify.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';

class LMFeedTaggingHelper {
  static final RegExp tagRegExp = RegExp(r'@([^<>~]+)~');
  static const String notificationTagRoute =
      r'<<([^<>]+)\|route://([^<>]+)/([a-zA-Z-0-9_]+)>>';
  static const String tagRoute =
      r'<<([^<>]+)\|route://user_profile/([a-zA-Z-0-9_]+)>>';
  static const String linkRoute =
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+|(\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b)';

  /// Encodes the string with the user tags and returns the encoded string
  static String encodeString(String string, List<LMUserTagViewData> userTags) {
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final LMUserTagViewData? userTag =
          userTags.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        string = string.replaceAll('@$tag~',
            '<<${userTag.name}|route://user_profile/${userTag.sdkClientInfo?.uuid ?? userTag.uuid}>>');
      }
    }
    return string;
  }

  /// Decodes the string with the user tags and returns the decoded string
  static Map<String, String> decodeString(String string) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String id = match.group(3)!;
      string = string.replaceAll('<<$tag|route://user_profile/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  static Map<String, String> decodeNotificationString(String string) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      string = string.replaceAll('<<$tag|route://$mid/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  /// Matches the tags in the string and returns the list of matched tags
  static List<LMUserTagViewData> matchTags(
      String text, List<LMUserTagViewData> items) {
    final List<LMUserTagViewData> tags = [];
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(text);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final LMUserTagViewData? userTag =
          items.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        tags.add(userTag);
      }
    }
    return tags;
  }

  static void routeToProfile(String uuid) {
    debugPrint(uuid);
  }

  static String convertRouteToTag(String text, {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);

    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll(
          '<<$tag|route://$mid/$id>>', withTilde ? '@$tag~' : '@$tag');
    }
    return text;
  }

  static String convertNotificationRouteToTag(String text,
      {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);

    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll('<<$tag|route://$mid/$id>>', '@$tag~');
    }
    return text;
  }

  static Map<String, dynamic> convertRouteToTagAndUserMap(String text,
      {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);
    List<LMUserTagViewData> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll(
          '<<$tag|route://$mid/$id>>', withTilde ? '@$tag~' : '@$tag');

      LMUserTagViewDataBuilder userTagViewDataBuilder =
          LMUserTagViewDataBuilder();

      userTagViewDataBuilder
        ..name(tag)
        ..uuid(id);

      userTags.add(userTagViewDataBuilder.build());
    }
    return {'text': text, 'userTags': userTags};
  }

  static List<LMUserTagViewData> addUserTagsIfMatched(String input) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(input);
    List<LMUserTagViewData> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1)!;
      //final String mid = match.group(2)!;
      final String id = match.group(3)!;

      LMUserTagViewDataBuilder userTagViewDataBuilder =
          LMUserTagViewDataBuilder();

      userTagViewDataBuilder
        ..name(tag)
        ..uuid(id);

      userTags.add(userTagViewDataBuilder.build());
    }
    return userTags;
  }

  static List<TextSpan> extractNotificationTags(
    String text, {
    TextStyle? normalTextStyle,
    TextStyle? tagTextStyle,
  }) {
    List<TextSpan> textSpans = [];
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);
    int lastIndex = 0;
    for (Match match in matches) {
      int startIndex = match.start;
      int endIndex = match.end;
      String? link = match.group(0);

      if (lastIndex != startIndex) {
        // Add a TextSpan for the preceding text
        textSpans.add(
          TextSpan(
            text: text.substring(lastIndex, startIndex),
            style: normalTextStyle ??
                const TextStyle(
                  wordSpacing: 1.5,
                  color: Colors.grey,
                ),
          ),
        );
      }
      // Add a TextSpan for the URL
      textSpans.add(
        TextSpan(
          text: LMFeedTaggingHelper.decodeNotificationString(link!).keys.first,
          style: tagTextStyle ??
              const TextStyle(
                wordSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
        ),
      );

      lastIndex = endIndex;
    }

    if (lastIndex != text.length) {
      // Add a TextSpan for the remaining text
      textSpans.add(TextSpan(
        text: text.substring(lastIndex),
        style: normalTextStyle ??
            const TextStyle(wordSpacing: 1.5, color: Colors.grey),
      ));
    }

    return textSpans;
  }
}

List<String> extractLinkFromString(String text) {
  RegExp exp = RegExp(LMFeedTaggingHelper.linkRoute);
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  List<String> links = [];
  for (var match in matches) {
    String link = text.substring(match.start, match.end);
    if (link.isNotEmpty && match.group(1) == null) {
      links.add(link);
    }
  }
  if (links.isNotEmpty) {
    return links;
  } else {
    return [];
  }
}

String getFirstValidLinkFromString(String text) {
  try {
    List<String> links = extractLinkFromString(text);
    List<String> validLinks = [];
    String validLink = '';
    if (links.isNotEmpty) {
      for (String link in links) {
        if (Uri.parse(link).isAbsolute) {
          validLinks.add(link);
        } else {
          link = "https://$link";
          if (Uri.parse(link).isAbsolute) {
            validLinks.add(link);
          }
        }
      }
    }
    if (validLinks.isNotEmpty) {
      validLink = validLinks.first;
    }
    return validLink;
  } on Exception catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: stacktrace);
    return '';
  }
}

LinkifyElement? extractLinkAndEmailFromString(String text) {
  final urls = linkify(text, linkifiers: [
    const EmailLinkifier(),
    const UrlLinkifier(),
  ]);
  if (urls.isNotEmpty) {
    if (urls.first is EmailElement || urls.first is UrlElement) {
      return urls.first;
    }
  }
  final links = linkify(text,
      options: const LinkifyOptions(
        looseUrl: true,
      ),
      linkifiers: [
        const EmailLinkifier(),
        const UrlLinkifier(),
      ]);
  if (links.isNotEmpty) {
    if (links.first is EmailElement || links.first is UrlElement) {
      return links.first;
    }
  }
  return null;
}

class PostHelper {
  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

// Returns file size in double in MBs
  static double getFileSizeInDouble(int bytes) {
    return (bytes / pow(1024, 2));
  }
}
