part of '../profile_bloc.dart';

void handleLMRouteToCompanyProfileEvent(
    LMFeedRouteToCompanyProfileEvent event, Emitter<LMFeedProfileState> emit) {
  debugPrint("Company ID caught in callback : ${event.companyId}");
  emit(LMFeedRouteToCompanyProfileState(companyId: event.companyId));
}
