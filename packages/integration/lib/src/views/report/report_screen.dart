import 'dart:io';

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

  LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.reportScreen;
  LMFeedThemeData theme = LMFeedCore.theme;

  Future<LMResponse<List<LMDeleteReasonViewData>>>? getReportTagsFuture;
  TextEditingController reportReasonController = TextEditingController();
  Set<int> selectedTags = {};
  bool isIos = LMFeedPlatform.instance.isIOS();
  LMDeleteReasonViewData? deleteReason;

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
    return _widgetBuilder.scaffold(
      backgroundColor: theme.container,
      source: _widgetSource,
      appBar: AppBar(
        backgroundColor: theme.container,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: isIos,
        actions: [
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
                style: LMFeedIconStyle(color: theme.disabledColor),
              ),
            ),
          )
        ],
        title: LMFeedText(
          text: 'Report Abuse',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 18,
              color: theme.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LMFeedLoader();
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData &&
                                snapshot.data!.success == true) {
                              List<LMDeleteReasonViewData> reportTags =
                                  snapshot.data?.data ?? [];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Wrap(
                                    spacing: 10.0,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
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
                                                        selectedTags
                                                            .remove(e.id);
                                                        deleteReason = null;
                                                      } else {
                                                        selectedTags = {e.id};
                                                        deleteReason = e;
                                                      }
                                                    },
                                                  );
                                                },
                                                child: Chip(
                                                  label: LMFeedText(
                                                    text: e.name,
                                                    style: LMFeedTextStyle(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ).copyWith(
                                                        fontSize: 14,
                                                        color: selectedTags
                                                                .contains(e.id)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  backgroundColor: selectedTags
                                                          .contains(e.id)
                                                      ? theme.primaryColor
                                                      : theme.container,
                                                  // color:
                                                  //     MaterialStateProperty.all(
                                                  //         Colors.transparent),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    side: BorderSide(
                                                      color: selectedTags
                                                              .contains(e.id)
                                                          ? theme.primaryColor
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  labelPadding: EdgeInsets.zero,
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
                      // kVerticalPaddingLarge,
                      deleteReason != null &&
                              (deleteReason!.name.toLowerCase() == 'others' ||
                                  deleteReason!.name.toLowerCase() == 'other')
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: TextField(
                                cursorColor: Colors.black,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                controller: reportReasonController,
                                decoration: theme.textFieldStyle.decoration
                                        ?.copyWith(
                                      hintText: 'Reason',
                                      hintStyle: theme.contentStyle.textStyle,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.disabledColor,
                                          width: 1,
                                        ),
                                      ),
                                    ) ??
                                    InputDecoration(
                                      border: InputBorder.none,
                                      fillColor: theme.primaryColor,
                                      focusColor: theme.primaryColor,
                                      labelText: 'Reason',
                                      labelStyle: theme.contentStyle.textStyle,
                                    ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: LMFeedButton(
                  style: LMFeedButtonStyle(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    backgroundColor: selectedTags.isEmpty
                        ? theme.disabledColor
                        : theme.primaryColor,
                    borderRadius: 50,
                  ),
                  text: LMFeedText(
                    text:
                        'Report ${getEntityTitleFirstCap(singular: true, smallCap: false)}',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                          color: theme.container,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () async {
                    String? reason = reportReasonController.text.trim();
                    if (deleteReason != null &&
                        (deleteReason!.name.toLowerCase() == 'others' ||
                            deleteReason!.name.toLowerCase() == 'other')) {
                      if (reason.isEmpty) {
                        LMFeedCore.showSnackBar(
                            context,
                            'Please specify a reason for reporting',
                            LMFeedWidgetSource.reportScreen);
                        return;
                      }
                    }
                    Navigator.of(context).pop();
                    if (selectedTags.isNotEmpty) {
                      PostReportRequest postReportRequest =
                          (PostReportRequestBuilder()
                                ..entityCreatorId(widget.entityCreatorId)
                                ..entityId(widget.entityId)
                                ..entityType(widget.entityType)
                                ..reason(reason.isEmpty
                                    ? deleteReason!.name
                                    : reason)
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
                        LMFeedCore.showSnackBar(
                            context,
                            '${getEntityTitleFirstCap(singular: true, smallCap: false)} reported',
                            LMFeedWidgetSource.reportScreen);
                      }
                    } else {
                      LMFeedCore.showSnackBar(context, 'Please select a reason',
                          LMFeedWidgetSource.reportScreen);
                      return;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Chip _defReportChip(LMDeleteReasonViewData deleteReasonViewData) {
    return Chip(
      label: LMFeedText(
        text: deleteReasonViewData.name,
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
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
            color: theme.onContainer,
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
