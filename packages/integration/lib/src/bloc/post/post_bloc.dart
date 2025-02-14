import 'dart:async';

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:video_compress/video_compress.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'handler/new_post_event_handler.dart';
part 'handler/edit_post_event_handler.dart';
part 'handler/delete_post_event_handler.dart';
part 'handler/update_post_event_handler.dart';
part 'handler/get_post_event_handler.dart';
part 'handler/initial_event_handler.dart';
part 'handler/upload_media_event_handler.dart';
part 'handler/retry_post_upload_event_handler.dart';

/// {@template lm_post_bloc}
/// [LMFeedPostBloc] handle all the post related actions
/// like add, edit, delete, etc.
/// [LMFeedPostEvents] defines the events which are handled by this bloc.
/// [LMFeedPostState] defines the states which are emitted by this bloc
/// {@endtemplate}
class LMFeedPostBloc extends Bloc<LMFeedPostEvents, LMFeedPostState> {
  static LMFeedPostBloc? _lmPostBloc;

  static LMFeedPostBloc get instance =>
      _lmPostBloc == null || _lmPostBloc!.isClosed
          ? _lmPostBloc = LMFeedPostBloc._()
          : _lmPostBloc!;

  LMFeedPostBloc._() : super(LMFeedNewPostInitiateState()) {
    on<LMFeedPostInitiateEvent>(initialEventHandler);
    on<LMFeedCreateNewPostEvent>(newPostEventHandler);
    on<LMFeedEditPostEvent>(editPostEventHandler);
    on<LMFeedDeletePostEvent>(deletePostEventHandler);
    on<LMFeedUpdatePostEvent>(updatePostEventHandler);
    on<LMFeedGetPostEvent>(getPostEventHandler);
    on<LMFeedUploadMediaEvent>(uploadMediaEventHandler);
    // retry event
    on<LMFeedRetryPostUploadEvent>(retryPostUploadEventHandler);
    // fetch temporary post from db
    on<LMFeedFetchTempPostEvent>((LMFeedFetchTempPostEvent event, emit) {
      // check if temp post is present
      final postResponse = LMFeedCore.instance.lmFeedClient.getTemporaryPost();
      if (postResponse.success && postResponse.data != null) {
        emit(LMFeedMediaUploadErrorState(
            errorMessage: "", tempId: postResponse.data?.tempId ?? ""));
      }
    });
  }
}
