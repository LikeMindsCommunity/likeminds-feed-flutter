import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'profile_event.dart';

part 'profile_state.dart';

part 'event_handler/login_required_event_handler.dart';

part 'event_handler/logout_event_handler.dart';

part 'event_handler/route_to_company_profile_event_handler.dart';

part 'event_handler/route_to_user_profile_event_handler.dart';

class LMProfileBloc extends Bloc<LMProfileEvent, LMProfileState> {
  static LMProfileBloc? _lmProfileBloc;

  static LMProfileBloc get instance => _lmProfileBloc ??= LMProfileBloc._();

  LMProfileBloc._() : super(LMProfileStateInit()) {
    on<LMLoginRequired>(handleLMLoginRequiredEvent);
    on<LMLogout>(handleLMLogoutEvent);
    on<LMRouteToCompanyProfile>(handleLMRouteToCompanyProfileEvent);
    on<LMRouteToUserProfile>(handleLMRouteToUserProfileEvent);
  }
}
