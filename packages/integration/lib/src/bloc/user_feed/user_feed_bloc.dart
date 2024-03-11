import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_feed_event.dart';
part 'user_feed_state.dart';

class UserFeedBloc extends Bloc<UserFeedEvent, UserFeedState> {
  UserFeedBloc() : super(UserFeedInitial()) {
    on<UserFeedEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
