import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../convertors/helper/attachment/attachment_convertor.dart';
import '../../convertors/post/post_convertor.dart';
import '../../convertors/post/topic_convertor.dart';
import '../../convertors/user/user_convertor.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'handler/new_post_event_handler.dart';
part 'handler/edit_post_event_handler.dart';
part 'handler/delete_post_event_handler.dart';
part 'handler/update_post_event_handler.dart';
part 'handler/toggle_pin_post_event_handler.dart';

class LMFeedPostBloc extends Bloc<LMFeedPostEvents, LMFeedPostState> {
  static LMFeedPostBloc? _lmPostBloc;

  static LMFeedPostBloc get instance => _lmPostBloc ??= LMFeedPostBloc._();

  LMFeedPostBloc._() : super(LMFeedNewPostInitiateState()) {
    on<LMFeedCreateNewPostEvent>(newPostEventHandler);
    on<LMFeedEditPostEvent>(editPostEventHandler);
    on<LMFeedDeletePostEvent>(deletePostEventHandler);
    on<LMFeedUpdatePostEvent>(updatePostEventHandler);
    on<LMFeedTogglePinPostEvent>(togglePinPostEventHandler);
  }
}
