import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/services/media_service.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'handler/new_post_event_handler.dart';
part 'handler/edit_post_event_handler.dart';
part 'handler/delete_post_event_handler.dart';
part 'handler/update_post_event_handler.dart';
part 'handler/get_post_event_handler.dart';

/// {@template lm_post_bloc}
/// [LMFeedPostBloc] handle all the post related actions
/// like add, edit, delete, etc.
/// [LMFeedPostEvents] defines the events which are handled by this bloc.
/// [LMFeedPostState] defines the states which are emitted by this bloc
/// {@endtemplate}
class LMFeedPostBloc extends Bloc<LMFeedPostEvents, LMFeedPostState> {
  static LMFeedPostBloc? _lmPostBloc;

  static LMFeedPostBloc get instance => _lmPostBloc ??= LMFeedPostBloc._();

  LMFeedPostBloc._() : super(LMFeedNewPostInitiateState()) {
    // Create New Post Event
    on<LMFeedCreateNewPostEvent>(newPostEventHandler);
    // Edit Post Event
    on<LMFeedEditPostEvent>(editPostEventHandler);
    // Delete Post Event
    on<LMFeedDeletePostEvent>(deletePostEventHandler);
    // Update Post Event
    on<LMFeedUpdatePostEvent>(updatePostEventHandler);
    // Get Post Event
    on<LMFeedGetPostEvent>(getPostEventHandler);
  }
}
