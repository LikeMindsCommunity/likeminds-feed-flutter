import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'feedroom_event.dart';
part 'feedroom_state.dart';
part 'handler/get_feedroom_event_handler.dart';
part 'handler/get_feedroom_list_event_handler.dart';

class LMFeedRoomBloc extends Bloc<LMFeedRoomEvent, LMFeedRoomState> {
  // list of selected topics by the user
  List<LMTopicViewData> selectedTopics = [];
  // list of all the topics
  Map<String, LMTopicViewData> topics = {};
// list of all the users
  Map<String, LMUserViewData> users = {};
  // list of all the widgets
  Map<String, LMWidgetViewData> widgets = {};

  static LMFeedRoomBloc? _instance;

  static LMFeedRoomBloc get instance => _instance ??= LMFeedRoomBloc._();

  LMFeedRoomBloc._() : super(LMFeedRoomInitialState()) {
    on<LMFeedRoomEvent>((event, emit) async {
      if (event is LMFeedGetFeedRoomEvent) {
        await _mapLMGetFeedRoomToState(event: event, emit: emit);
      }
      if (event is LMFeedGetFeedRoomListEvent) {
        await _mapLMGetFeedRoomListToState(event: event, emit: emit);
      }
    });
  }
}
