import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'handler/compose_topic_event_handler.dart';

part 'compose_event.dart';
part 'compose_state.dart';

class LMFeedComposeBloc extends Bloc<LMFeedComposeEvent, LMFeedComposeState> {
  static LMFeedComposeBloc? _bloc;

  static LMFeedComposeBloc get instance => _bloc ??= LMFeedComposeBloc._();

  LMFeedComposeBloc._() : super(LMFeedComposeInitialState()) {
    on<LMFeedComposeFetchTopicsEvent>(
        (event, emitter) => composeFetchTopicHandler(event, emitter));
  }
}
