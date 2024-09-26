import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';

part 'saved_post_event.dart';
part 'saved_post_state.dart';
part 'handler/get_saved_post_event_handler.dart';

class LMFeedSavedPostBloc
    extends Bloc<LMFeedSavedPostEvent, LMFeedSavedPostState> {
  static LMFeedSavedPostBloc? _instance;
  static LMFeedSavedPostBloc get instance =>
      _instance == null || _instance!.isClosed
          ? _instance = LMFeedSavedPostBloc._()
          : _instance!;
  LMFeedSavedPostBloc._() : super(LMFeedSavedPostInitialState()) {
    on<LMFeedGetSavedPostEvent>(getSavedPostEventHandler);
  }
}
