import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// export all the required files
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/widget/video_feed_list.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/widget/vertical_post.dart';

class LMFeedVideoFeedScreen extends StatefulWidget {
  const LMFeedVideoFeedScreen({super.key});

  @override
  State<LMFeedVideoFeedScreen> createState() => LMFeedVideoFeedScreenState();
}

class LMFeedVideoFeedScreenState extends State<LMFeedVideoFeedScreen> {
  final _theme = LMFeedCore.theme;
  final _screenBuilder = LMFeedCore.config.videoFeedScreenConfig.builder;
  bool _isPostUploading = false;
  bool _isPostEditing = false;
  final _userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  final _postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  @override
  void initState() {
    super.initState();
    _addPostBlocListener();
  }

  void _addPostBlocListener() {
    LMFeedPostBloc.instance.stream.listen((state) {
      switch (state.runtimeType) {
        case LMFeedNewPostUploadingState:
          _isPostUploading = true;
          break;
        case LMFeedNewPostUploadedState:
          _isPostUploading = false;
          break;
        case LMFeedNewPostErrorState:
          _isPostUploading = false;
          break;
        case LMFeedEditPostUploadingState:
          _isPostEditing = true;
          break;
        case LMFeedEditPostUploadedState:
          _isPostEditing = false;
          break;
        case LMFeedEditPostErrorState:
          _isPostEditing = false;
          break;
        case LMFeedMediaUploadErrorState:
          _isPostUploading = true;
          break;
        case LMFeedNewPostInitiateState:
          _isPostUploading = false;
          _isPostEditing = false;
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _screenBuilder.scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            LMFeedVideoFeedListView(),
            _screenBuilder.appBarBuilder(context, _defAppBar()),
          ],
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      title: _screenBuilder.titleTextBuilder(context, _defTitleText()),
      leading: SizedBox(),
      style: LMFeedAppBarStyle(
        height: 56,
        backgroundColor: Colors.transparent,
        border: Border(),
      ),
      trailing: [
        BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
          bloc: LMFeedComposeBloc.instance,
          listener: (context, state) {
            // if state is added video
            // navigate to create short video screen
            if (state is LMFeedComposeAddedReelState) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LMFeedCreateShortVideoScreen();
              }));
            }
          },
          child: _screenBuilder.createPostButtonBuilder(
            context,
            _defNewPostButton(),
          ),
        )
      ],
    );
  }

  LMFeedText _defTitleText() {
    return LMFeedText(
      text: 'Reels',
      onTap: () {},
      style: LMFeedTextStyle(
        margin: EdgeInsets.only(
          left: 16,
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  LMFeedButton _defNewPostButton() {
    return LMFeedButton(
      onTap: () {
        // check if the user have posting rights
        if (_userPostingRights) {
          // check if the user is a guest user
          if (LMFeedUserUtils.isGuestUser()) {
            LMFeedCore.instance.lmFeedCoreCallback?.loginRequired
                ?.call(context);
            return;
          }
          // check if a post failed to upload
          // and stored in the cache as temporary post
          final value = LMFeedCore.client.getTemporaryPost();
          if (value.success) {
            LMFeedCore.showSnackBar(
              context,
              'A $_postTitleSmallCap is already uploading.',
              LMFeedWidgetSource.videoFeed,
            );
            return;
          }
          // if no post is uploading then emit add reel event
          if (!_isPostUploading && !_isPostEditing) {
            LMFeedComposeBloc.instance.add(
              LMFeedComposeAddReelEvent(),
            );
          } else {
            LMFeedCore.showSnackBar(
              context,
              'A $_postTitleSmallCap is already uploading.',
              LMFeedWidgetSource.videoFeed,
            );
          }
        } else {
          LMFeedCore.showSnackBar(
            context,
            "You do not have permission to create a $_postTitleSmallCap",
            LMFeedWidgetSource.videoFeed,
          );
        }
      },
      text: LMFeedText(
        text: 'New post',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _theme.container,
          ),
        ),
      ),
      style: LMFeedButtonStyle(
        backgroundColor: _theme.onContainer.withOpacity(0.1),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        borderRadius: 50,
        gap: 4,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmCreateReelSvg,
          style: LMFeedIconStyle(
            color: _theme.container,
            size: 16,
          ),
        ),
        margin: EdgeInsets.only(
          right: 9,
        ),
      ),
    );
  }
}
