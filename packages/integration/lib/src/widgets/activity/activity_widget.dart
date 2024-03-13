import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:video_player/video_player.dart';

class LMFeedActivityWidget extends StatefulWidget {
  const LMFeedActivityWidget({
    super.key,
    required this.uuid,
    this.postWidgetBuilder,
    this.commentWidgetBuilder,
    this.appBarBuilder,
  });
  final String uuid;

  final LMFeedPostWidgetBuilder? postWidgetBuilder;
  final LMFeedPostCommentBuilder? commentWidgetBuilder;
  final LMFeedPostAppBarBuilder? appBarBuilder;

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

  void loadActivity() async {
    final activityRequest = (GetUserActivityRequestBuilder()
          ..uuid(widget.uuid)
          ..page(1)
          ..pageSize(10))
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
                return SizedBox(
                  child: LMFeedText(
                      text:
                          activityResponse.errorMessage ?? "An error occurred"),
                );
              }
              return activityResponse.activities!.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      color: feedTheme.container,
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activityResponse.activities!.length <= 3
                                ? activityResponse.activities?.length
                                : 3,
                            itemBuilder: (context, index) {
                              final activity =
                                  activityResponse.activities![index];
                              final LMPostViewData postData =
                                  LMFeedPostUtils.postViewDataFromActivity(
                                activity,
                                activityResponse.widgets,
                                activityResponse.users,
                                activityResponse.topics,
                              );
                              late final VideoPlayerController controller;
                              late final Future<void> futureValue;
                              if (postData.attachments!.isNotEmpty &&
                                  mapIntToMediaType(postData
                                          .attachments![0].attachmentType) ==
                                      LMMediaType.video) {
                                controller = VideoPlayerController.networkUrl(
                                    Uri.parse(postData
                                        .attachments![0].attachmentMeta.url!));
                                futureValue = controller.initialize();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    LMFeedActivityTileWidget(
                                      boxDecoration: BoxDecoration(
                                        color: feedTheme.container,
                                      ),
                                      title: Row(
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                            ),
                                            child: RichText(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                children: LMFeedPostUtils
                                                    .extractNotificationTags(
                                                        snapshot
                                                            .data!.activities!
                                                            .elementAt(index)
                                                            .activityText,
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
                                        child: LMFeedExpandableText(
                                            postData.text,
                                            expandText: 'Read More',
                                            maxLines: 2, onTagTap: (tag) {
                                          debugPrint(tag);
                                        }, onLinkTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LMFeedPostDetailScreen(
                                                postId: postData.id,
                                                postBuilder:
                                                    widget.postWidgetBuilder,
                                                commentBuilder:
                                                    widget.commentWidgetBuilder,
                                                appBarBuilder:
                                                    widget.appBarBuilder,
                                              ),
                                            ),
                                          );
                                        },
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            )),
                                      ),
                                      trailing: postData
                                                  .attachments!.isNotEmpty &&
                                              mapIntToMediaType(postData
                                                      .attachments![0]
                                                      .attachmentType) ==
                                                  LMMediaType.image
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LMFeedImage(
                                                imageUrl: postData
                                                    .attachments![0]
                                                    .attachmentMeta
                                                    .url,
                                                style:
                                                    const LMFeedPostImageStyle(
                                                  height: 64,
                                                  width: 64,
                                                  // borderRadius: 24,
                                                  boxFit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : postData.attachments!.isNotEmpty &&
                                                  mapIntToMediaType(postData
                                                          .attachments![0]
                                                          .attachmentType) ==
                                                      LMMediaType.video
                                              ? FutureBuilder(
                                                  future: futureValue,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
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
                                                        child:
                                                            LMPostMediaShimmer(),
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
                                            builder: (context) =>
                                                LMFeedPostDetailScreen(
                                              postId: postData.id,
                                              postBuilder:
                                                  widget.postWidgetBuilder,
                                              commentBuilder:
                                                  widget.commentWidgetBuilder,
                                              appBarBuilder:
                                                  widget.appBarBuilder,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (index !=
                                        (activityResponse.activities!.length <=
                                                3
                                            ? (activityResponse
                                                    .activities!.length -
                                                1)
                                            : 2))
                                      Divider(
                                          color: feedTheme.onContainer
                                              .withOpacity(0.15)),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(
                              color: feedTheme.onContainer.withOpacity(0.15)),
                          if (activityResponse.activities!.isNotEmpty)
                            LMFeedButton(
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
                                      commentBuilder:
                                          widget.commentWidgetBuilder,
                                      postBuilder: widget.postWidgetBuilder,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
            } else {
              return const Center(child: LMFeedLoader());
            }
          }),
    );
  }
}
