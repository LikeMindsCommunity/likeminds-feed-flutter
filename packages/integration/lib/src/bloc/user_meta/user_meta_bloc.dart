import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'user_meta_event.dart';
part 'user_meta_state.dart';
part 'handler/get_user_meta_event_handler.dart';
part 'handler/update_user_meta_event_handler.dart';

class LMFeedUserMetaBloc
    extends Bloc<LMFeedUserMetaEvent, LMFeedUserMetaState> {
  static LMFeedUserMetaBloc? _instance;
  static LMFeedUserMetaBloc get instance =>
      _instance ??= LMFeedUserMetaBloc._();
  LMFeedUserMetaBloc._() : super(LMFeedUserMetaInitialState()) {
    on<LMFeedUserMetaGetEvent>(getUserMetaEventHandler);
    on<LMFeedUserMetaUpdateEvent>(updateUserMetaEventHandler);
  }
  }
