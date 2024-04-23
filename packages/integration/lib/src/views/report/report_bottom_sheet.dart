import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedReportBottomSheet extends StatefulWidget {
  final String entityId; // post, comment, reply id
  final String entityCreatorId;
  final int entityType;
  final LMFeedBottomSheetStyle? style;
  final String? successMessage;

  final LMFeedContextWidgetBuilder? loadingBuilder;
  final Function(BuildContext, LMFeedText)? titleBuilder;
  final Function(BuildContext, LMFeedText)? subTitleBuilder;
  final LMFeedContextButtonBuilder? reportButtonBuilder;
  final Function(BuildContext, LMDeleteReasonViewData)? reportReasonTileBuilder;

  const LMFeedReportBottomSheet({
    super.key,
    required this.entityId,
    required this.entityCreatorId,
    required this.entityType,
    this.style,
    this.successMessage,
    this.loadingBuilder,
    this.titleBuilder,
    this.subTitleBuilder,
    this.reportButtonBuilder,
    this.reportReasonTileBuilder,
  });

  /// copyWith method to create a new instance of [LMFeedReportBottomSheet] with the provided parameters
  /// if the parameter is not provided then the default value is used
  LMFeedReportBottomSheet copyWith({
    Key? key,
    String? entityId,
    String? entityCreatorId,
    int? entityType,
    LMFeedBottomSheetStyle? style,
    String? successMessage,
    LMFeedContextWidgetBuilder? loadingBuilder,
    Function(BuildContext, LMFeedText)? titleBuilder,
    Function(BuildContext, LMFeedText)? subTitleBuilder,
    LMFeedContextButtonBuilder? reportButtonBuilder,
    Function(BuildContext, LMDeleteReasonViewData)? reportReasonTileBuilder,
  }) {
    return LMFeedReportBottomSheet(
      key: key ?? this.key,
      entityId: entityId ?? this.entityId,
      entityCreatorId: entityCreatorId ?? this.entityCreatorId,
      entityType: entityType ?? this.entityType,
      style: style ?? this.style,
      successMessage: successMessage ?? this.successMessage,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      titleBuilder: titleBuilder ?? this.titleBuilder,
      subTitleBuilder: subTitleBuilder ?? this.subTitleBuilder,
      reportButtonBuilder: reportButtonBuilder ?? this.reportButtonBuilder,
      reportReasonTileBuilder:
          reportReasonTileBuilder ?? this.reportReasonTileBuilder,
    );
  }

  @override
  State<LMFeedReportBottomSheet> createState() =>
      _LMFeedReportBottomSheetState();
}

class _LMFeedReportBottomSheetState extends State<LMFeedReportBottomSheet> {
  LMFeedModerationBloc reportBloc = LMFeedModerationBloc();
  LMFeedThemeData? feedTheme;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.reportScreen;

  @override
  void initState() {
    super.initState();
    reportBloc.add(LMFeedReportReasonFetchEvent());
  }

  @override
  void dispose() {
    reportBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    feedTheme = LMFeedCore.theme;
    LMFeedBottomSheetStyle? bottomSheetStyle =
        widget.style ?? feedTheme?.bottomSheetStyle;
    return Padding(
      padding: bottomSheetStyle?.padding ??
          EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: BlocConsumer<LMFeedModerationBloc, LMFeedModerationState>(
          bloc: reportBloc,
          listener: (context, state) {
            if (state is LMFeedReportSubmitFailedState) {
              LMFeedCore.showSnackBar(
                context,
                state.error,
                widgetSource,
              );
            } else if (state is LMFeedReportSubmittedState) {
              Navigator.of(context).pop();
              LMFeedCore.showSnackBar(
                  context,
                  'Reported! Thanks for making our community a safe place',
                  widgetSource);
            }
          },
          builder: (context, state) {
            if (state is LMFeedReportLoadingState) {
              return widget.loadingBuilder?.call(context) ??
                  _defLoader(context);
            } else if (state is LMFeedReportSuccessState) {
              return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.titleBuilder?.call(context, _defTitle()) ??
                          _defTitle(),
                      const SizedBox(
                        height: 16,
                      ),
                      widget.subTitleBuilder?.call(context, _defSubTitle()) ??
                          _defSubTitle(),
                      const SizedBox(
                        height: 24,
                      ),
                      if (state.reasons.isNotEmpty)
                        ...state.reasons
                            .map(
                              (e) =>
                                  widget.reportReasonTileBuilder
                                      ?.call(context, e) ??
                                  _defReasonTile(e),
                            )
                            .toList(),
                    ]),
              );
            } else if (state is LMFeedReportReasonSelectedState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LMFeedText(
                    text: 'Report for : ${state.reason.name} ?',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  widget.subTitleBuilder?.call(context, _defSubTitle()) ??
                      _defSubTitle(),
                  const SizedBox(
                    height: 24,
                  ),
                  _defReportButton(context, state),
                ],
              );
            } else {
              return const SizedBox(
                height: 0,
                width: double.infinity,
              );
            }
          }),
    );
  }

  GestureDetector _defReasonTile(LMDeleteReasonViewData e) {
    return GestureDetector(
      onTap: () {
        reportBloc.add(LMFeedReportReasonSelectEvent(reason: e));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LMFeedText(
              text: e.name,
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(
            thickness: 1,
          ),
        ],
      ),
    );
  }

  LMFeedText _defSubTitle() {
    return LMFeedText(
        text:
            'You can report this chat to Us if you think that it goes against our Community Guidelines. We won’t notify this user that you submitted the report',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: Color(0xff5A6068),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.visible,
        ));
  }

  LMFeedText _defTitle() {
    return LMFeedText(
        text: 'Select a problem to report',
        style: LMFeedTextStyle(
          textStyle: feedTheme?.contentStyle.headingStyle?.copyWith(
            fontSize: 20,
          ),
          overflow: TextOverflow.visible,
        ));
  }

  SizedBox _defLoader(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      child: LMFeedLoader(),
    );
  }

  Widget _defReportButton(
    BuildContext context,
    LMFeedReportReasonSelectedState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: widget.reportButtonBuilder
              ?.call(context, _defReportButtonBuilder(state)) ??
          _defReportButtonBuilder(state),
    );
  }

  LMFeedButton _defReportButtonBuilder(LMFeedReportReasonSelectedState state) {
    return LMFeedButton(
      style: LMFeedButtonStyle(
        height: 48,
        backgroundColor: Color(0xff0E1226),
        borderRadius: 100,
      ),
      text: LMFeedText(
        text: 'Report',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
              color: Color(0xffFDFDFD),
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
      onTap: () async {
        reportBloc.add(LMFeedReportSubmitEvent(
          entityCreatorId: widget.entityCreatorId,
          entityId: widget.entityId,
          entityType: widget.entityType,
          reason: state.reason.name,
          tagId: state.reason.id,
        ));
      },
    );
  }
}
