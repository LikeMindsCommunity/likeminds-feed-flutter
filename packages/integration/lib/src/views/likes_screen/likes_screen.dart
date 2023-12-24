import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/views/likes_screen/handler/likes_screen_handler.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LikesScreen extends StatefulWidget {
  static const String route = "/likes_screen";
  final String postId;
  final bool isCommentLikes;
  final String? commentId;

  const LikesScreen({
    super.key,
    this.isCommentLikes = false,
    required this.postId,
    this.commentId,
  });

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  Map<String, UserViewData> userData = {};
  late LikesScreenHandler handler;

  @override
  void initState() {
    super.initState();
    handler = LikesScreenHandler.instance;
    handler.initialise(postId: widget.postId, commentId: widget.commentId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        return Future(() => false);
      },
      child: Scaffold(body: getLikesLoadedView()),
    );
  }

  Widget getAppBar(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          LMThemeData.kHorizontalPaddingSmall,
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          LMThemeData.kHorizontalPaddingSmall,
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget getLikesLoadedView() {
    return SafeArea(
      child: Column(
        children: [
          getAppBar(
            "${handler.totalLikesCount ?? '--'} Likes",
          ),
          LMThemeData.kVerticalPaddingLarge,
          Expanded(
            child: PagedListView<int, LikeViewData>(
              padding: EdgeInsets.zero,
              pagingController: handler.pagingController,
              builderDelegate: PagedChildBuilderDelegate<LikeViewData>(
                noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                  height: 20,
                ),
                noItemsFoundIndicatorBuilder: (context) => const Scaffold(
                  backgroundColor: LMThemeData.kWhiteColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("No likes to show",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: 12),
                        Text("Be the first one to like this post",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: LMThemeData.kGrey2Color)),
                        SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                itemBuilder: (context, item, index) =>
                    LikesTile(user: userData[item.userId]),
                firstPageProgressIndicatorBuilder: (context) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const UserTileShimmer()),
                  ),
                ),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LikesTile extends StatelessWidget {
  final UserViewData? user;
  const LikesTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(bottom: 20.0),
        child: user!.isDeleted != null && user!.isDeleted!
            ? const DeletedLikesTile()
            : LMUserTile(
                user: user!,
                onTap: () {},
                titleText: LMTextView(
                  text: user!.name,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subText: LMTextView(
                  text: "@${user!.name.toLowerCase().split(" ").join("")}",
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: LMThemeData.kGreyColor,
                  ),
                ),
              ),
      );
    } else {
      return const Center(
        child: LMTextView(text: "No likes yet"),
      );
    }
  }
}

class DeletedLikesTile extends StatelessWidget {
  const DeletedLikesTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: LMThemeData.kGreyBGColor),
          height: 54,
          width: 54,
        ),
        LMThemeData.kHorizontalPaddingSmall,
        LMThemeData.kHorizontalPaddingMedium,
        LMTextView(
          text: 'Deleted User',
          textStyle: TextStyle(
            fontSize: LMThemeData.kFontMedium,
            color: LMThemeData.suraasaTheme.colorScheme.onSecondary,
          ),
        )
      ],
    );
  }
}
