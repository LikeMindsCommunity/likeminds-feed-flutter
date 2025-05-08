import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:video_player/video_player.dart';

/// {@template lm_feed_activity_widget}
/// A widget that displays the activity feed of a user.
/// It displays the activities of a user in a list.
/// The widget can be customized using the provided builders.
/// {@endtemplate}
class LMFeedActivityWidget extends StatefulWidget {
  const LMFeedActivityWidget({
    super.key,
    required this.uuid,
    this.postWidgetBuilder,
    this.commentWidgetBuilder,
    this.appBarBuilder,
    this.maxActivityCount = 3,
    this.activityContainerBuilder,
    this.loaderBuilder,
    this.errorBuilder,
    this.emptyActivityBuilder,
    this.activityTileBuilder,
    this.moreActivityButtonBuilder,
  });

  /// The unique identifier of the user.
  final String uuid;

  /// Builder for the post widget.
  final LMFeedPostWidgetBuilder? postWidgetBuilder;

  /// Builder for the comment widget.
  final LMFeedPostCommentBuilder? commentWidgetBuilder;

  /// Builder for the app bar.
  final LMFeedAppBarBuilder? appBarBuilder;

  /// Maximum number of activities to display.
  final int maxActivityCount;

  /// Builder for the activity container.
  final Widget Function(BuildContext, Container)? activityContainerBuilder;

  /// Builder for the loader widget.
  final Widget Function(BuildContext, LMFeedLoader)? loaderBuilder;

  /// Builder for the error widget.
  final Widget Function(BuildContext, String)? errorBuilder;

  /// Builder for the empty activity widget.
  final Widget Function(BuildContext)? emptyActivityBuilder;

  /// Builder for the activity tile widget.
  final Widget Function(BuildContext, LMFeedActivityTileWidget)?
      activityTileBuilder;

  /// Builder for the "More Activity" button.
  final LMFeedButtonBuilder? moreActivityButtonBuilder;

  /// Creates a copy of this widget but with the given fields replaced with the new values.
  LMFeedActivityWidget copyWith({
    Key? key,
    String? uuid,
    LMFeedPostWidgetBuilder? postWidgetBuilder,
    LMFeedPostCommentBuilder? commentWidgetBuilder,
    LMFeedAppBarBuilder? appBarBuilder,
    int? maxActivityCount,
  }) {
    return LMFeedActivityWidget(
      key: key ?? this.key,
      uuid: uuid ?? this.uuid,
      postWidgetBuilder: postWidgetBuilder ?? this.postWidgetBuilder,
      commentWidgetBuilder: commentWidgetBuilder ?? this.commentWidgetBuilder,
      appBarBuilder: appBarBuilder ?? this.appBarBuilder,
      maxActivityCount: maxActivityCount ?? this.maxActivityCount,
    );
  }

  @override
  State<LMFeedActivityWidget> createState() => _LMFeedActivityWidgetState();
}

class _LMFeedActivityWidgetState extends State<LMFeedActivityWidget> {
  late Future<GetUserActivityResponse> _activityResponse;
  Map<String, WidgetModel>? widgets;

  @override
  void initState() {
    loadActivity();
    super.initState();
  }

  /// Loads the user activity from the server.
  void loadActivity() async {
    final activityRequest = (GetUserActivityRequestBuilder()
          ..uuid(widget.uuid)
          ..page(1)
          ..pageSize(widget.maxActivityCount))
        .build();
    _activityResponse = LMFeedCore.client.getUserActivity(activityRequest);
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return Container(
      color: feedTheme.container,
      child: FutureBuilder<GetUserActivityResponse>(
          future: _activityResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final GetUserActivityResponse activityResponse = snapshot.data!;
              if (!activityResponse.success) {
                return widget.errorBuilder?.call(
                        context,
                        activityResponse.errorMessage ??
                            "Error in loading activities") ??
                    _defErrorView(activityResponse);
              }
              return activityResponse.activities!.isEmpty
                  ? widget.emptyActivityBuilder?.call(context) ??
                      _defEmptyActivityView()
                  : widget.activityContainerBuilder?.call(
                          context,
                          _defActivityContainer(feedTheme, activityResponse,
                              snapshot, context)) ??
                      _defActivityContainer(
                          feedTheme, activityResponse, snapshot, context);
            } else {
              return Center(child: _defLoader());
            }
          }),
    );
  }

  /// Default loader widget.
  LMFeedLoader _defLoader() => LMFeedLoader();

  /// Default error view widget.
  SizedBox _defErrorView(GetUserActivityResponse activityResponse) {
    return SizedBox(
      child: LMFeedText(
          text: activityResponse.errorMessage ?? "An error occurred"),
    );
  }

  /// Default activity container widget.
  Container _defActivityContainer(
      LMFeedThemeData feedTheme,
      GetUserActivityResponse activityResponse,
      AsyncSnapshot<GetUserActivityResponse> snapshot,
      BuildContext context) {
    return Container(
      color: feedTheme.container,
      child: Column(
        children: [
          _defListView(activityResponse, feedTheme, snapshot),
          _defDivider(feedTheme),
          if (activityResponse.activities!.isNotEmpty)
            widget.moreActivityButtonBuilder?.call(
                  _defMoreActivityButton(feedTheme, context),
                ) ??
                _defMoreActivityButton(feedTheme, context),
        ],
      ),
    );
  }

  /// Default empty activity view widget.
  SizedBox _defEmptyActivityView() => const SizedBox.shrink();

  /// Default "More Activity" button widget.
  LMFeedButton _defMoreActivityButton(
      LMFeedThemeData feedTheme, BuildContext context) {
    return LMFeedButton(
      text: LMFeedText(
        text: 'View More Activity',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: feedTheme.primaryColor,
          ),
        ),
      ),
      style: LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.arrow_forward,
          style: LMFeedIconStyle(
            color: feedTheme.primaryColor,
          ),
        ),
        placement: LMFeedIconButtonPlacement.end,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedActivityScreen(
              uuid: widget.uuid,
              commentBuilder: widget.commentWidgetBuilder,
              postBuilder: widget.postWidgetBuilder,
            ),
          ),
        );
      },
    );
  }

  /// Default divider widget.
  Divider _defDivider(LMFeedThemeData feedTheme) {
    return Divider(color: feedTheme.onContainer.withOpacity(0.15));
  }

  /// Default list view widget.
  ListView _defListView(
      GetUserActivityResponse activityResponse,
      LMFeedThemeData feedTheme,
      AsyncSnapshot<GetUserActivityResponse> snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activityResponse.activities?.length ?? 0,
      itemBuilder: (context, index) {
        final activity = activityResponse.activities![index];
        final LMPostViewData postData =
            convertPostData(activityResponse, activity);
        late final VideoPlayerController controller;
        late final Future<void> futureValue;
        try {
          if (postData.attachments!.isNotEmpty &&
              postData.attachments![0].attachmentType == LMMediaType.video) {
            controller = VideoPlayerController.networkUrl(
                Uri.parse(postData.attachments![0].attachmentMeta.url!));
            futureValue = controller.initialize();
          }
        } on Exception catch (e, stackTrace) {
          LMFeedPersistence.instance.handleException(e, stackTrace);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              widget.activityTileBuilder?.call(
                    context,
                    _defActivityTile(feedTheme, context, snapshot, index,
                        activityResponse, postData, futureValue, controller),
                  ) ??
                  _defActivityTile(feedTheme, context, snapshot, index,
                      activityResponse, postData, futureValue, controller),
              if (index !=
                  (activityResponse.activities!.length <= 3
                      ? (activityResponse.activities!.length - 1)
                      : 2))
                Divider(color: feedTheme.onContainer.withOpacity(0.15)),
            ],
          ),
        );
      },
    );
  }

  /// Default activity tile widget.
  LMFeedActivityTileWidget _defActivityTile(
      LMFeedThemeData feedTheme,
      BuildContext context,
      AsyncSnapshot<GetUserActivityResponse> snapshot,
      int index,
      GetUserActivityResponse activityResponse,
      LMPostViewData postData,
      Future<void> futureValue,
      VideoPlayerController controller) {
    return LMFeedActivityTileWidget(
      boxDecoration: BoxDecoration(
        color: feedTheme.container,
      ),
      title: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: LMFeedPostUtils.extractNotificationTags(
                    snapshot.data!.activities!.elementAt(index).activityText,
                    widget.uuid),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Colors.black,
            ),
          ),
          LMFeedText(
            text:
                '  ${LMFeedTimeAgo.instance.format(DateTime.fromMillisecondsSinceEpoch(activityResponse.activities![index].createdAt))}',
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2,
        ),
        child: LMFeedExpandableText(postData.text,
            expandText: 'Read More', maxLines: 2, onTagTap: (tag) {
          debugPrint(tag);
        }, onLinkTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: postData.id,
                postBuilder: widget.postWidgetBuilder,
                commentBuilder: widget.commentWidgetBuilder,
                appBarBuilder: widget.appBarBuilder,
              ),
            ),
          );
        },
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            )),
      ),
      trailing: postData.attachments!.isNotEmpty &&
              postData.attachments![0].attachmentType == LMMediaType.image
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LMFeedImage(
                image: postData.attachments![0],
                style: const LMFeedPostImageStyle(
                  height: 64,
                  width: 64,
                  // borderRadius: 24,
                  boxFit: BoxFit.cover,
                ),
              ),
            )
          : postData.attachments!.isNotEmpty &&
                  postData.attachments![0].attachmentType == LMMediaType.video
              ? FutureBuilder(
                  future: futureValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 64,
                          width: 64,
                          child: VideoPlayer(
                            controller,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 64,
                        width: 64,
                        child: LMPostMediaShimmer(),
                      );
                    }
                  },
                )
              : const SizedBox.shrink(),
      onTap: () {
        debugPrint('Activity Tapped');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: postData.id,
              postBuilder: widget.postWidgetBuilder,
              commentBuilder: widget.commentWidgetBuilder,
              appBarBuilder: widget.appBarBuilder,
            ),
          ),
        );
      },
    );
  }

  /// Converts the post data from the activity response.
  LMPostViewData convertPostData(
      GetUserActivityResponse response, UserActivityItem activity) {
    Map<String, LMWidgetViewData> widgets =
        (response.widgets ?? <String, WidgetModel>{}).map((key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

    Map<String, LMTopicViewData> topics = (response.topics ?? <String, Topic>{})
        .map((key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

    Map<String, LMUserViewData> users =
        (response.users ?? <String, User>{}).map((key, value) => MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(
              value,
              topics: topics,
              widgets: widgets,
            )));

    return LMFeedPostUtils.postViewDataFromActivity(
      activity,
      widgets,
      users,
      topics,
    );
  }
}
