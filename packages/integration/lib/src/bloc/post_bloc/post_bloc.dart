import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
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

class LMPostBloc extends Bloc<LMPostEvents, LMPostState> {
  static LMPostBloc? _lmPostBloc;

  static LMPostBloc get instance => _lmPostBloc ??= LMPostBloc._();

  LMPostBloc._() : super(NewPostInitiate()) {
    on<CreateNewPost>(newPostEventHandler);
    on<EditPost>(editPostEventHandler);
    on<DeletePost>(deletePostEventHandler);
    on<UpdatePost>(updatePostEventHandler);
    on<TogglePinPost>(togglePinPostEventHandler);
  }
}
