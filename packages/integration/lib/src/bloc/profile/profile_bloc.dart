import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'profile_event.dart';

part 'profile_state.dart';

part 'event_handler/login_required_event_handler.dart';

part 'event_handler/logout_event_handler.dart';

part 'event_handler/route_to_company_profile_event_handler.dart';

part 'event_handler/route_to_user_profile_event_handler.dart';

class LMFeedProfileBloc extends Bloc<LMFeedProfileEvent, LMFeedProfileState> {
  static LMFeedProfileBloc? _lmProfileBloc;

  static LMFeedProfileBloc get instance =>
      _lmProfileBloc ??= LMFeedProfileBloc._();

  LMFeedProfileBloc._() : super(LMFeedProfileStateInitState()) {
    on<LMFeedLoginRequiredEvent>(handleLMLoginRequiredEvent);
    on<LMFeedLogoutEvent>(handleLMLogoutEvent);
    on<LMFeedRouteToCompanyProfileEvent>(handleLMRouteToCompanyProfileEvent);
    on<LMFeedRouteToUserProfileEvent>(handleLMRouteToUserProfileEvent);
  }
}
