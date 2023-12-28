part of '../profile_bloc.dart';

void handleLMRouteToCompanyProfileEvent(
    LMRouteToCompanyProfile event, Emitter<LMProfileState> emit) {
  debugPrint("Company ID caught in callback : ${event.companyId}");
  emit(LMRouteToCompanyProfileState(companyId: event.companyId));
}
