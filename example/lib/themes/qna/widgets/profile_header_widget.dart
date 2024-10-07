import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/edit_profile_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LMQnAProfileHeaderWidget extends StatefulWidget {
  const LMQnAProfileHeaderWidget({
    super.key,
    required this.uuid,
    this.showEditButton = true,
    this.shouldReload = true,
  });
  final String uuid;
  final bool showEditButton;
  final bool shouldReload;

  @override
  State<LMQnAProfileHeaderWidget> createState() =>
      _LMQnAProfileHeaderWidgetState();
}

class _LMQnAProfileHeaderWidgetState extends State<LMQnAProfileHeaderWidget> {
  String postTitleFirstCapPlural = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String postTitleFirstCapSingular = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);

  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  final LMFeedUserMetaBloc _userMetaBloc = LMFeedUserMetaBloc.instance;
  @override
  void initState() {
    super.initState();
    _userMetaBloc.add(
      LMFeedUserMetaGetEvent(uuid: widget.uuid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: _userMetaBloc,
        listener: (context, state) {
          if (state is LMFeedUserMetaErrorState) {
            LMFeedCore.showSnackBar(
              context,
              state.message,
              LMFeedWidgetSource.searchScreen,
            );
          }
        },
        buildWhen: (previous, current) {
          if (previous is LMFeedUserMetaLoadedState &&
              current is LMFeedUserMetaLoadingState) {
            if (previous.user.sdkClientInfo.uuid == current.uuid) {
              return false;
            }
          } else if (current is LMFeedUserMetaLoadedState) {
            if (current.user.sdkClientInfo.uuid == widget.uuid) {
              return true;
            }
          } else if (current is LMFeedUserMetaLoadingState) {
            if (current.uuid == widget.uuid) {
              return true;
            }
          }
          return widget.shouldReload;
        },
        builder: (context, state) {
          if (state is LMFeedUserMetaLoadingState) {
            return const SizedBox(height: 200, child: LMFeedLoader());
          }
          if (state is LMFeedUserMetaLoadedState) {
            final userViewData = state.user;
            final String? userDescription =
                userViewData.widget?.metadata['description'];
            final String? userBio = userViewData.widget?.metadata['bio'];
            return Container(
              color: feedThemeData.backgroundColor,
              child: Column(
                children: [
                  Container(
                    color: feedThemeData.container,
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: const BoxDecoration(
                                gradient: qNaProfileGradient,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            )
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 20),
                          child: LMFeedProfilePicture(
                            onTap: () {},
                            imageUrl: userViewData.imageUrl,
                            fallbackText: userViewData.name,
                            style: LMFeedProfilePictureStyle.basic().copyWith(
                              size: 80,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // user details section
                  Container(
                    color: feedThemeData.container,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LMFeedText(
                              text: userViewData.name,
                              style: const LMFeedTextStyle(
                                textStyle: TextStyle(
                                  color: Color.fromRGBO(20, 25, 31, 1),
                                  fontSize: 20,
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            if (widget.showEditButton &&
                                userViewData.sdkClientInfo.uuid ==
                                    LMFeedLocalPreference.instance
                                        .fetchUserData()
                                        ?.sdkClientInfo
                                        .uuid)
                              LMFeedButton(
                                style: const LMFeedButtonStyle(
                                  icon: LMFeedIcon(
                                    type: LMFeedIconType.svg,
                                    assetPath: qnAEditProfileIcon,
                                    style: LMFeedIconStyle(size: 16),
                                  ),
                                  height: 30,
                                  width: 30,
                                ),
                                // text:
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LMQnAEditProfileScreen(
                                                user: state.user,
                                              )));
                                },
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (userDescription != null &&
                            userDescription.isNotEmpty)
                          LMFeedText(
                            text: userDescription,
                            style: const LMFeedTextStyle(
                              maxLines: 40,
                              textStyle: TextStyle(
                                color: Color.fromRGBO(20, 25, 31, 1),
                                fontSize: 12,
                                height: 1.66,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        if (userBio != null && userBio.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Uri? uri = Uri.tryParse(userBio);
                              if (uri != null) {
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: LMFeedIcon(
                                      type: LMFeedIconType.svg,
                                      assetPath: qnALink,
                                      style: LMFeedIconStyle(
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  LMFeedText(
                                    text: userBio,
                                    style: const LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        color: Color.fromRGBO(0, 158, 130, 1),
                                        fontSize: 12,
                                        height: 1.66,
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // if (userViewData.widget?.metadata['tag'] != null)
                        //   Container(
                        //     decoration: BoxDecoration(
                        //         color: const Color.fromRGBO(230, 238, 255, 1),
                        //         borderRadius: BorderRadius.circular(5)),
                        //     padding: const EdgeInsets.all(5),
                        //     margin: const EdgeInsets.only(top: 10, bottom: 5),
                        //     child: LMFeedText(
                        //       text: userViewData.widget?.metadata['tag'],
                        //       style: const LMFeedTextStyle(
                        //         textStyle: TextStyle(
                        //           color: Color.fromRGBO(19, 56, 126, 1),
                        //           fontSize: 12,
                        //           letterSpacing: 0.2,
                        //           fontWeight: FontWeight.w400,
                        //           fontFamily: 'Inter',
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  Container(
                    color: feedThemeData.container,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Row(children: [
                          LMFeedText(
                            text: state.postsCount.toString(),
                            style: LMFeedTextStyle.basic().copyWith(
                              textStyle: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          LMFeedText(
                            text: state.postsCount == 1
                                ? postTitleFirstCapSingular
                                : postTitleFirstCapPlural,
                            style: LMFeedTextStyle.basic().copyWith(
                              textStyle: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(width: 20),
                        Row(children: [
                          LMFeedText(
                            text: state.commentsCount.toString(),
                            style: LMFeedTextStyle.basic().copyWith(
                              textStyle: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          LMFeedText(
                            text: state.commentsCount == 1
                                ? commentTitleFirstCapSingular
                                : commentTitleFirstCapPlural,
                            style: LMFeedTextStyle.basic().copyWith(
                              textStyle: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        });
  }
}
