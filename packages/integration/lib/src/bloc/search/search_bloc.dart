import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
part 'search_event.dart';
part 'search_state.dart';
part 'handler/get_search_event_handler.dart';
part 'handler/clear_search_event_handler.dart';

class LMFeedSearchBloc extends Bloc<LMFeedSearchEvent, LMFeedSearchState> {
  LMFeedSearchBloc() : super(LMFeedInitialSearchState()) {
    on<LMFeedGetSearchEvent>(getSearchEventHandler);
    on<LMFeedClearSearchEvent>(clearSearchEventHandler);
  }

 }
