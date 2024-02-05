import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:overlay_support/overlay_support.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'handler/new_post_event_handler.dart';
part 'handler/edit_post_event_handler.dart';
part 'handler/delete_post_event_handler.dart';
part 'handler/update_post_event_handler.dart';

class LMFeedPostBloc extends Bloc<LMFeedPostEvents, LMFeedPostState> {
  static LMFeedPostBloc? _lmPostBloc;

  static LMFeedPostBloc get instance => _lmPostBloc ??= LMFeedPostBloc._();

  LMFeedPostBloc._() : super(LMFeedNewPostInitiateState()) {
    on<LMFeedCreateNewPostEvent>(newPostEventHandler);
    on<LMFeedEditPostEvent>(editPostEventHandler);
    on<LMFeedDeletePostEvent>(deletePostEventHandler);
    on<LMFeedUpdatePostEvent>(updatePostEventHandler);
  }
}
