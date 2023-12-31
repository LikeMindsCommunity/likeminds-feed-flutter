import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:meta/meta.dart';
import 'handler/compose_topic_event_handler.dart';

part 'compose_event.dart';
part 'compose_state.dart';

class LMComposeBloc extends Bloc<LMComposeEvent, LMComposeState> {
  static LMComposeBloc? _bloc;

  static LMComposeBloc get instance => _bloc ??= LMComposeBloc._();

  LMComposeBloc._() : super(LMComposeInitial()) {
    on<LMComposeFetchTopics>(composeFetchTopicHandler);
  }
}