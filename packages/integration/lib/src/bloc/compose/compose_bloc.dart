import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'compose_event.dart';
part 'compose_state.dart';

class LMComposeBloc extends Bloc<LMComposeEvent, LMComposeState> {
  static LMComposeBloc? _bloc;

  static LMComposeBloc get instance => _bloc ??= LMComposeBloc._();

  LMComposeBloc._() : super(LMComposeInitial()) {
    on<LMComposeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
