import 'dart:math';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

class LMFeedReportScreen extends StatefulWidget {
  final Widget Function(BuildContext, LMDeleteReasonViewData)?
      reportChipBuilder;
  final Widget Function(BuildContext, LMReportContentWidget)?
      reportContentBuilder;

  final String entityId; // post, comment, reply id
  final String entityCreatorId;
  final int entityType;

  const LMFeedReportScreen({
    Key? key,
    required this.entityId,
    required this.entityCreatorId,
    required this.entityType,
    this.reportChipBuilder,
    this.reportContentBuilder,
  }) : super(key: key);

  @override
  State<LMFeedReportScreen> createState() => _LMFeedReportScreenState();
}

class _LMFeedReportScreenState extends State<LMFeedReportScreen> {
  late Size screenSize;
  // Get the post title in first letter capital singular form
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the post title in all small singular form
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  // Get the post title in all small singular form
  String postTitleSmallCapPlural =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural);
  // Get the post title in all small singular form
  String postTitleFirstCapPlural = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);

  // Get the comment title in first letter capital plural form
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  // Get the comment title in all small plural form
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  // Get the comment title in first letter capital singular form
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the comment title in all small singular form
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedReportScreenBuilderDelegate _widgetBuilder =
      LMFeedCore.config.reportScreenConfig.builder;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.reportScreen;
  LMFeedThemeData theme = LMFeedCore.theme;

  Future<LMResponse<List<LMDeleteReasonViewData>>>? getReportTagsFuture;
  TextEditingController reportReasonController = TextEditingController();
  Set<int> selectedTags = {};
  bool isIos = LMFeedPlatform.instance.isIOS();
  LMDeleteReasonViewData? deleteReason;
  final ValueNotifier<LMFeedReportState> reportListener =
      ValueNotifier<LMFeedReportState>(LMFeedReportState.initial);

  @override
  void initState() {
    super.initState();
    getReportTagsFuture = getReportTags();
  }

  Future<LMResponse<List<LMDeleteReasonViewData>>> getReportTags() async {
    try {
      GetDeleteReasonRequest request =
          (GetDeleteReasonRequestBuilder()..type(3)).build();
      GetDeleteReasonResponse response =
          await LMFeedCore.client.getReportTags(request);

      if (response.success) {
        List<DeleteReason> reportTags = response.reportTags ?? [];

        List<LMDeleteReasonViewData> reportViewDataTags = reportTags
            .map((e) => (LMDeleteReasonViewDataBuilder()
                  ..id(e.id)
                  ..name(e.name))
                .build())
            .toList();
        return LMResponse(success: true, data: reportViewDataTags);
      } else {
        return LMResponse(success: false, errorMessage: response.errorMessage);
      }
    } on Exception catch (e) {
      return LMResponse(success: false, errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    reportReasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    return _widgetBuilder.scaffold(
      backgroundColor: theme.container,
      source: _widgetSource,
      appBar: _widgetBuilder.appBarBuilder(
        context,
        _defAppBar(context),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: min(
                screenSize.width, LMFeedCore.config.webConfiguration.maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ValueListenableBuilder(
                valueListenable: reportListener,
                builder: (context, state, child) {
                  if (state == LMFeedReportState.loading) {
                    return _defLoader();
                  } else if (state == LMFeedReportState.success) {
                    return _defSuccessStateUI();
                  }
                  return _defInitialStateUI(context);
                }),
          ),
        ),
      ),
    );
  }

  Column _defSuccessStateUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.report_outlined,
          style: LMFeedIconStyle(
            color: theme.errorColor,
            size: 28,
            backgroundColor: theme.errorColor.withOpacity(0.1),
            boxBorderRadius: 100,
            boxSize: 40,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        LMFeedText(
          text: 'Thank you for submitting a report',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.onContainer,
            ),
          ),
        ),
        LMFeedText(
          text:
              'We take reports seriously and after a through review, will take appropriate action.',
          style: LMFeedTextStyle(
            maxLines: 4,
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: theme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  LMFeedLoader _defLoader() {
    return LMFeedLoader(
      style: LMFeedLoaderStyle(
        color: theme.secondaryColor,
        height: 30,
        width: 30,
        strokeWidth: 2.0,
      ),
    );
  }

  Column _defInitialStateUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                widget.reportContentBuilder
                        ?.call(context, _defReportContentWidget()) ??
                    _defReportContentWidget(),
                const SizedBox(
                  height: 24,
                ),
                FutureBuilder<LMResponse<List<LMDeleteReasonViewData>>>(
                    future: getReportTagsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LMFeedLoader(
                          style: LMFeedLoaderStyle(
                            color: theme.secondaryColor,
                            height: 30,
                            width: 30,
                            strokeWidth: 2.0,
                          ),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data!.success == true) {
                        List<LMDeleteReasonViewData> reportTags =
                            snapshot.data?.data ?? [];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Wrap(
                              spacing: 10.0,
                              runSpacing: 10.0,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: reportTags.isNotEmpty
                                  ? reportTags
                                      .map(
                                        (e) => InkWell(
                                          splashFactory:
                                              InkRipple.splashFactory,
                                          onTap: () {
                                            setState(
                                              () {
                                                if (selectedTags
                                                    .contains(e.id)) {
                                                  selectedTags.remove(e.id);
                                                  deleteReason = null;
                                                } else {
                                                  selectedTags = {e.id};
                                                  deleteReason = e;
                                                }
                                              },
                                            );
                                          },
                                          child: Chip(
                                            side: BorderSide.none,
                                            label: LMFeedText(
                                              text: e.name,
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedTags
                                                          .contains(e.id)
                                                      ? theme.errorColor
                                                      : theme.secondaryColor,
                                                ),
                                              ),
                                            ),
                                            backgroundColor:
                                                selectedTags.contains(e.id)
                                                    ? theme.errorColor
                                                        .withOpacity(0.2)
                                                    : theme.secondaryColor
                                                        .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 4,
                                            ),
                                            labelPadding:
                                                const EdgeInsets.all(4),
                                            elevation: 0,
                                          ),
                                        ),
                                      )
                                      .toList()
                                  : []),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                if (deleteReason != null &&
                    (deleteReason!.name.toLowerCase() == 'others' ||
                        deleteReason!.name.toLowerCase() == 'other'))
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LMFeedText(
                          text: "Reason",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.onContainer,
                            ),
                          ),
                        ),
                        LMFeedText(
                          text: "Help us understand the problem.",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: theme.onContainer,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          minLines: 3,
                          maxLines: 5,
                          controller: reportReasonController,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: theme.secondaryColor.withOpacity(0.1),
                            focusColor: theme.primaryColor,
                            hintText: 'Write a message',
                            labelStyle: theme.contentStyle.textStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: LMFeedButton(
            style: LMFeedButtonStyle(
              width: double.infinity,
              height: 42,
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              backgroundColor: selectedTags.isEmpty
                  ? theme.disabledColor
                  : theme.primaryColor,
              borderRadius: 12,
            ),
            text: LMFeedText(
              text: 'Submit report',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                    color: theme.container,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            onTap: () async {
              String? reason = reportReasonController.text.trim();
              if (deleteReason == null) {
                showReasonNotSelectedSnackbar();
                return;
              }

              String deleteReasonLowerCase = deleteReason!.name.toLowerCase();
              if ((deleteReasonLowerCase == 'others' ||
                  deleteReasonLowerCase == 'other')) {
                if (reason.isEmpty) {
                  LMFeedCore.showSnackBar(
                      context,
                      'Please specify a reason for reporting',
                      LMFeedWidgetSource.reportScreen);
                  return;
                }
              }

              if (selectedTags.isNotEmpty) {
                reportListener.value = LMFeedReportState.loading;
                PostReportRequest postReportRequest =
                    (PostReportRequestBuilder()
                          ..entityCreatorId(widget.entityCreatorId)
                          ..entityId(widget.entityId)
                          ..entityType(widget.entityType)
                          ..reason(reason.isEmpty ? deleteReason!.name : reason)
                          ..tagId(deleteReason!.id))
                        .build();
                PostReportResponse response =
                    await LMFeedCore.client.postReport(postReportRequest);

                if (!response.success) {
                  LMFeedCore.showSnackBar(
                      context,
                      response.errorMessage ?? 'An error occured',
                      LMFeedWidgetSource.reportScreen);
                } else {
                  reportListener.value = LMFeedReportState.success;
                }
              } else {
                showReasonNotSelectedSnackbar();
                return;
              }
            },
          ),
        ),
      ],
    );
  }

  LMFeedAppBar _defAppBar(BuildContext context) {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: theme.container,
        shadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 0.5),
          ),
        ],
        centerTitle: isIos,
      ),
      leading: LMFeedIcon(
        type: LMFeedIconType.icon,
        icon: Icons.report_outlined,
        style: LMFeedIconStyle(
          color: theme.secondaryColor,
        ),
      ),
      trailing: [
        LMFeedButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          style: LMFeedButtonStyle(
            height: 48,
            backgroundColor: Colors.transparent,
            borderRadius: 0,
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.close,
              style: LMFeedIconStyle(
                color: theme.onContainer,
              ),
            ),
          ),
        )
      ],
      title: LMFeedText(
        text: 'Report Abuse',
        style: LMFeedTextStyle(
          margin: EdgeInsets.only(left: 8),
          textStyle: TextStyle(
            fontSize: 18,
            color: theme.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void showReasonNotSelectedSnackbar() {
    LMFeedCore.showSnackBar(
        context, 'Please select a reason', LMFeedWidgetSource.reportScreen);
  }

  String getEntityTitleFirstCap({bool smallCap = true, bool singular = false}) {
    String title;
    switch (widget.entityType) {
      case postEntityId:
        if (singular) {
          title = postTitleFirstCap;
        } else {
          title = postTitleFirstCapPlural;
        }
        return smallCap ? title.toLowerCase() : title;
      case commentEntityId:
        if (singular) {
          title = commentTitleFirstCapSingular;
        } else {
          title = commentTitleFirstCapPlural;
        }
        return smallCap ? title.toLowerCase() : title;
      case replyEntityId:
        if (singular) {
          title = 'reply';
        } else {
          title = 'replies';
        }
        return smallCap ? title.toLowerCase() : title;
      default:
        return title = '';
    }
  }

  LMReportContentWidget _defReportContentWidget() {
    return LMReportContentWidget(
      title: 'Please specify the problem to continue',
      description:
          'You would be able to report this ${getEntityTitleFirstCap(singular: true, smallCap: true)} after selecting a problem.',
      style: LMReportContentWidgetStyle(
        titleStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.onContainer,
          ),
        ),
        descriptionStyle: LMFeedTextStyle(
          overflow: TextOverflow.visible,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: theme.secondaryColor,
          ),
        ),
      ),
    );
  }
}

class LMReportScreenStyle {
  LMReportContentWidgetStyle? reportContentWidgetStyle;
  LMFeedButtonStyle? submitButtonStyle;

  LMReportScreenStyle({
    this.reportContentWidgetStyle,
    this.submitButtonStyle,
  });

  LMReportScreenStyle copyWith({
    LMReportContentWidgetStyle? reportContentWidgetStyle,
    LMFeedButtonStyle? submitButtonStyle,
  }) {
    return LMReportScreenStyle(
      reportContentWidgetStyle:
          reportContentWidgetStyle ?? this.reportContentWidgetStyle,
      submitButtonStyle: submitButtonStyle ?? this.submitButtonStyle,
    );
  }
}

class LMReportContentWidget extends StatelessWidget {
  final String title;
  final String description;

  final LMReportContentWidgetStyle? style;

  const LMReportContentWidget({
    super.key,
    required this.title,
    required this.description,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            style?.crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisAlignment: style?.mainAxisAlignment ?? MainAxisAlignment.start,
        children: <Widget>[
          LMFeedText(
            text: title,
            style: style?.titleStyle,
          ),
          SizedBox(
            height: style?.titleDescriptionSpacing ?? 8,
          ),
          LMFeedText(
            text: description,
            style: style?.descriptionStyle,
          ),
        ],
      ),
    );
  }
}

class LMReportContentWidgetStyle {
  final LMFeedTextStyle? titleStyle;
  final LMFeedTextStyle? descriptionStyle;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final double? titleDescriptionSpacing;

  const LMReportContentWidgetStyle({
    this.titleStyle,
    this.descriptionStyle,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.titleDescriptionSpacing,
  });
}

enum LMFeedReportState { initial, loading, success }
