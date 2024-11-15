library expandable_text;

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/linkify/linkify.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';

import './text_parser.dart';

typedef StringCallback = void Function(String value);

class LMFeedExpandableText extends StatefulWidget {
  const LMFeedExpandableText(
    this.text, {
    Key? key,
    required this.expandText,
    this.collapseText,
    this.expanded = false,
    this.onExpandedChanged,
    this.onLinkTap,
    this.linkColor,
    this.linkEllipsis = true,
    this.linkStyle,
    this.prefixText,
    this.prefixStyle,
    this.onPrefixTap,
    this.urlStyle,
    this.onUrlTap,
    this.hashtagStyle,
    this.onHashtagTap,
    this.mentionStyle,
    this.onMentionTap,
    this.expandOnTextTap = false,
    this.collapseOnTextTap = false,
    this.style,
    this.textDirection,
    this.textAlign,
    this.textScaleFactor,
    this.maxLines = 3,
    this.animation = false,
    this.animationDuration,
    this.animationCurve,
    this.semanticsLabel,
    required this.onTagTap,
    this.onTextTap,
  })  : assert(maxLines > 0),
        super(key: key);

  final String text;
  final String expandText;
  final String? collapseText;
  final bool expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final VoidCallback? onLinkTap;
  final Color? linkColor;
  final bool linkEllipsis;
  final TextStyle? linkStyle;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final VoidCallback? onPrefixTap;
  final TextStyle? urlStyle;
  final StringCallback? onUrlTap;
  final TextStyle? hashtagStyle;
  final StringCallback? onHashtagTap;
  final TextStyle? mentionStyle;
  final StringCallback? onMentionTap;
  final bool expandOnTextTap;
  final bool collapseOnTextTap;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final double? textScaleFactor;
  final int maxLines;
  final bool animation;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final String? semanticsLabel;
  final Function(String) onTagTap;
  final VoidCallback? onTextTap;

  LMFeedExpandableText copyWith({
    String? text,
    String? expandText,
    String? collapseText,
    bool? expanded,
    ValueChanged<bool>? onExpandedChanged,
    VoidCallback? onLinkTap,
    Color? linkColor,
    bool? linkEllipsis,
    TextStyle? linkStyle,
    String? prefixText,
    TextStyle? prefixStyle,
    VoidCallback? onPrefixTap,
    TextStyle? urlStyle,
    StringCallback? onUrlTap,
    TextStyle? hashtagStyle,
    StringCallback? onHashtagTap,
    TextStyle? mentionStyle,
    StringCallback? onMentionTap,
    bool? expandOnTextTap,
    bool? collapseOnTextTap,
    TextStyle? style,
    TextDirection? textDirection,
    TextAlign? textAlign,
    double? textScaleFactor,
    int? maxLines,
    bool? animation,
    Duration? animationDuration,
    Curve? animationCurve,
    String? semanticsLabel,
    Function(String)? onTagTap,
    VoidCallback? onTextTap,
  }) {
    return LMFeedExpandableText(
      text ?? this.text,
      expandText: expandText ?? this.expandText,
      collapseText: collapseText ?? this.collapseText,
      expanded: expanded ?? this.expanded,
      onExpandedChanged: onExpandedChanged ?? this.onExpandedChanged,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      linkColor: linkColor ?? this.linkColor,
      linkEllipsis: linkEllipsis ?? this.linkEllipsis,
      linkStyle: linkStyle ?? this.linkStyle,
      prefixText: prefixText ?? this.prefixText,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      onPrefixTap: onPrefixTap ?? this.onPrefixTap,
      urlStyle: urlStyle ?? this.urlStyle,
      onUrlTap: onUrlTap ?? this.onUrlTap,
      hashtagStyle: hashtagStyle ?? this.hashtagStyle,
      onHashtagTap: onHashtagTap ?? this.onHashtagTap,
      mentionStyle: mentionStyle ?? this.mentionStyle,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      expandOnTextTap: expandOnTextTap ?? this.expandOnTextTap,
      collapseOnTextTap: collapseOnTextTap ?? this.collapseOnTextTap,
      style: style ?? this.style,
      textDirection: textDirection ?? this.textDirection,
      textAlign: textAlign ?? this.textAlign,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      maxLines: maxLines ?? this.maxLines,
      animation: animation ?? this.animation,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      onTagTap: onTagTap ?? this.onTagTap,
      onTextTap: onTextTap ?? this.onTextTap,
    );
  }

  @override
  LMFeedExpandableTextState createState() => LMFeedExpandableTextState();
}

class LMFeedExpandableTextState extends State<LMFeedExpandableText>
    with TickerProviderStateMixin {
  bool _expanded = false;
  RegExp regExp = RegExp(kRegexLinksAndTags);
  late TapGestureRecognizer _linkTapGestureRecognizer;
  late TapGestureRecognizer _prefixTapGestureRecognizer;

  List<TextSegment> _textSegments = [];
  final List<TapGestureRecognizer> _textSegmentsTapGestureRecognizers = [];

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded;
    _linkTapGestureRecognizer = TapGestureRecognizer()..onTap = _linkTapped;
    _prefixTapGestureRecognizer = TapGestureRecognizer()..onTap = _prefixTapped;

    _updateText();
  }

  @override
  void didUpdateWidget(LMFeedExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text ||
        oldWidget.onUrlTap != widget.onUrlTap ||
        oldWidget.onHashtagTap != widget.onHashtagTap ||
        oldWidget.onMentionTap != widget.onMentionTap) {
      _expanded = widget.expanded;
      _updateText();
    }
  }

  @override
  void dispose() {
    _linkTapGestureRecognizer.dispose();
    _prefixTapGestureRecognizer.dispose();
    for (var recognizer in _textSegmentsTapGestureRecognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  void _linkTapped() {
    if (widget.onLinkTap != null) {
      widget.onLinkTap!();
      return;
    }

    final toggledExpanded = !_expanded;

    setState(() => _expanded = toggledExpanded);

    widget.onExpandedChanged?.call(toggledExpanded);
  }

  void _prefixTapped() {
    widget.onPrefixTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = widget.style;
    if (widget.style == null || widget.style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final linkText =
        (_expanded ? widget.collapseText : widget.expandText) ?? '';
    final linkColor = widget.linkColor ??
        widget.prefixStyle?.color ??
        const Color(0xFF4666F6);
    final linkTextStyle = effectiveTextStyle!
        .merge(widget.prefixStyle)
        .copyWith(color: linkColor);

    final prefixText =
        widget.prefixText != null && widget.prefixText!.isNotEmpty
            ? '${widget.prefixText} '
            : '';

    final link = TextSpan(
      children: [
        if (!_expanded)
          TextSpan(
            text: '\u2026 ',
            style: widget.linkEllipsis ? linkTextStyle : effectiveTextStyle,
            recognizer: widget.linkEllipsis ? _linkTapGestureRecognizer : null,
          ),
        if (linkText.isNotEmpty)
          TextSpan(
            style: effectiveTextStyle,
            children: <TextSpan>[
              if (_expanded)
                const TextSpan(
                  text: ' ',
                ),
              TextSpan(
                text: linkText,
                style: linkTextStyle,
                recognizer: _linkTapGestureRecognizer,
              ),
            ],
          ),
      ],
    );

    final prefix = extractLinksAndTags(prefixText);
    final text = extractLinksAndTags(widget.text);

    final content = TextSpan(
      children: <TextSpan>[...prefix, ...text],
      style: effectiveTextStyle,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        final textAlign =
            widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
        final textDirection =
            widget.textDirection ?? Directionality.of(context);
        final textScaleFactor =
            widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
        final locale = Localizations.maybeLocaleOf(context);

        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.maxLines,
          locale: locale,
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        textPainter.text = content;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        TextSpan textSpan;
        if (textPainter.didExceedMaxLines) {
          final position = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          final endOffset =
              (textPainter.getOffsetBefore(position.offset) ?? 0) -
                  prefixText.length;

          final recognizer =
              (_expanded ? widget.collapseOnTextTap : widget.expandOnTextTap)
                  ? _linkTapGestureRecognizer
                  : null;
          String resultText;
          if (!_expanded) {
            var response =
                LMFeedTaggingHelper.convertRouteToTagAndUserMap(widget.text);
            List<LMUserTagViewData> userTags = response['userTags'];
            resultText = response['text'];
            // final lineCount = textPainter.computeLineMetrics().length;
            final nCount = '\n'.allMatches(resultText).length + 1;
            if (resultText.length > 300 && nCount <= 4) {
              resultText = resultText.substring(0, max(endOffset, 0));
            } else {
              resultText = resultText.substring(0, max(endOffset, 0));
            }

            resultText = LMFeedTaggingHelper.encodeString(resultText, userTags);
          } else {
            resultText = widget.text;
          }

          final text = _textSegments.isNotEmpty
              ? TextSpan(
                  children: _buildTextSpans(
                      _expanded ? _textSegments : parseText(resultText),
                      effectiveTextStyle!,
                      recognizer),
                )
              : TextSpan(
                  children: extractLinksAndTags(resultText),
                );

          textSpan = TextSpan(
            style: effectiveTextStyle,
            children: <TextSpan>[
              ...prefix,
              text,
              link,
            ],
          );
        } else {
          textSpan = content;
        }

        final richText = SelectableText.rich(
          textSpan,
          textDirection: textDirection,
          textAlign: textAlign,
          textScaleFactor: textScaleFactor,
          style: widget.style,
        );

        if (widget.animation) {
          return AnimatedSize(
              duration:
                  widget.animationDuration ?? const Duration(milliseconds: 200),
              curve: widget.animationCurve ?? Curves.fastLinearToSlowEaseIn,
              alignment: Alignment.topLeft,
              child: richText);
        }

        return richText;
      },
    );

    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }

    return result;
  }

  void _updateText() {
    for (var recognizer in _textSegmentsTapGestureRecognizers) {
      recognizer.dispose();
    }
    _textSegmentsTapGestureRecognizers.clear();

    if (widget.onUrlTap == null &&
        widget.onHashtagTap == null &&
        widget.onMentionTap == null) {
      _textSegments.clear();
      return;
    }

    _textSegments = parseText(widget.text);

    for (var element in _textSegments) {
      if (element.isUrl && widget.onUrlTap != null) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            widget.onUrlTap!(element.name!);
          };

        _textSegmentsTapGestureRecognizers.add(recognizer);
      } else if (element.isHashtag && widget.onHashtagTap != null) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            widget.onHashtagTap!(element.name!);
          };

        _textSegmentsTapGestureRecognizers.add(recognizer);
      } else if (element.isMention && widget.onMentionTap != null) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            widget.onMentionTap!(element.name!);
          };

        _textSegmentsTapGestureRecognizers.add(recognizer);
      }
    }
  }

  List<TextSpan> _buildTextSpans(List<TextSegment> segments,
      TextStyle textStyle, TapGestureRecognizer? textTapRecognizer) {
    final spans = <TextSpan>[];

    var index = 0;
    for (var segment in segments) {
      TextStyle? style;
      TapGestureRecognizer? recognizer;

      if (segment.isUrl && widget.onUrlTap != null) {
        style = textStyle.merge(widget.urlStyle);
        recognizer = _textSegmentsTapGestureRecognizers[index++];
      } else if (segment.isMention && widget.onMentionTap != null) {
        style = textStyle.merge(widget.mentionStyle);
        recognizer = _textSegmentsTapGestureRecognizers[index++];
      } else if (segment.isHashtag && widget.onHashtagTap != null) {
        style = textStyle.merge(widget.hashtagStyle);
        recognizer = _textSegmentsTapGestureRecognizers[index++];
      }

      final span = TextSpan(
        text: segment.text,
        style: style,
        recognizer: recognizer ?? textTapRecognizer,
      );

      spans.add(span);
    }

    return spans;
  }

  List<TextSpan> extractLinksAndTags(String text) {
    List<TextSpan> textSpans = [];
    int lastIndex = 0;
    for (Match match in regExp.allMatches(text)) {
      int startIndex = match.start;
      int endIndex = match.end;
      String? link = match.group(0);

      if (lastIndex != startIndex) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastIndex, startIndex),
            style: widget.style,
            recognizer: TapGestureRecognizer()
              ..onTap = () => widget.onTextTap?.call(),
          ),
        );
      }

      if (link != null && link.isNotEmpty && link[0] == '#') {
        // Handle hashtags with its own recognizer if provided
        textSpans.add(TextSpan(
          text: link,
          style: widget.hashtagStyle ?? const TextStyle(color: Colors.blue),
          recognizer: widget.onHashtagTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => widget.onHashtagTap!(link))
              : null,
        ));
      } else {
        bool isTag = link != null && link[0] == '<';

        if (!isTag && extractLinkAndEmailFromString(link ?? '') == null) {
          // Add a TextSpan for non-link text with no recognizer
          textSpans.add(TextSpan(
            text: text.substring(startIndex, endIndex),
            style: widget.style,
          ));
          lastIndex = endIndex;
          continue;
        }

        // Add a TextSpan for the URL or tag with a recognizer
        textSpans.add(TextSpan(
          text:
              isTag ? LMFeedTaggingHelper.decodeString(link).keys.first : link,
          style: widget.linkStyle ?? const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (!isTag) {
                final checkLink = extractLinkAndEmailFromString(link ?? '');
                if (checkLink is UrlElement &&
                    Uri.parse(checkLink.url).isAbsolute) {
                  launchUrl(
                    Uri.parse(checkLink.url),
                    mode: LaunchMode.externalApplication,
                  );
                } else if (checkLink is EmailElement) {
                  launchUrl(
                    Uri.parse('mailto:${checkLink.emailAddress}'),
                    mode: LaunchMode.externalApplication,
                  );
                }
              } else {
                widget.onTagTap(
                  LMFeedTaggingHelper.decodeString(link).values.first,
                );
              }
            },
        ));
      }

      lastIndex = endIndex;
    }

    if (lastIndex != text.length) {
      // Add remaining normal text with no recognizer
      textSpans.add(TextSpan(
        text: text.substring(lastIndex),
        style: widget.style,
        recognizer: TapGestureRecognizer()
          ..onTap = () => widget.onTextTap?.call(),
      ));
    }

    return textSpans;
  }
}
