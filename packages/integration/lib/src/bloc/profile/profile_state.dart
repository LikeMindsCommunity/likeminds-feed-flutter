part of 'profile_bloc.dart';

abstract class LMFeedProfileState extends Equatable {
  const LMFeedProfileState();

  @override
  List<Object> get props => [];
}

class LMFeedProfileStateInitState extends LMFeedProfileState {}

class LMFeedRouteToUserProfileState extends LMFeedProfileState {
  final String userUniqueId;

  const LMFeedRouteToUserProfileState({required this.userUniqueId});

  @override
  List<Object> get props => [userUniqueId];
}

class LMFeedLoginRequiredState extends LMFeedProfileState {}

class LMFeedLogoutState extends LMFeedProfileState {}

class LMFeedRouteToCompanyProfileState extends LMFeedProfileState {
  final String companyId;

  const LMFeedRouteToCompanyProfileState({required this.companyId});

  @override
  List<Object> get props => [companyId];
}
