part of 'profile_bloc.dart';

abstract class LMProfileEvent extends Equatable {
  const LMProfileEvent();

  @override
  List<Object> get props => [];
}

class LMProfileEventInit extends LMProfileEvent {}

class LMRouteToUserProfile extends LMProfileEvent {
  final String userUniqueId;

  const LMRouteToUserProfile({required this.userUniqueId});
}

class LMRouteToCompanyProfile extends LMProfileEvent {
  final String companyId;

  const LMRouteToCompanyProfile({required this.companyId});
}

class LMLoginRequired extends LMProfileEvent {}

class LMLogout extends LMProfileEvent {}
