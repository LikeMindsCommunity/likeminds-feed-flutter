import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'personalised_feed_event.dart';
part 'personalised_feed_state.dart';
part 'handler/get_feed_handler.dart';
part 'handler/refresh_feed_handler.dart';

class LMFeedPersonalisedBloc
    extends Bloc<LMFeedPersonalisedEvent, LMFeedPersonalisedState> {
  static LMFeedPersonalisedBloc? _instance;

  static LMFeedPersonalisedBloc get instance =>
      _instance ??= LMFeedPersonalisedBloc._();

  LMFeedPersonalisedBloc._() : super(LMFeedPersonalisedInitialState()) {
    on<LMFeedPersonalisedGetEvent>(_getPersonalisedFeedHandler);
    on<LMFeedPersonalisedRefreshEvent>(_refreshPersonalisedFeedHandler);
  }
}
