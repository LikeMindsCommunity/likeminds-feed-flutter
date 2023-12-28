part of 'profile_bloc.dart';

abstract class LMProfileState extends Equatable {
  const LMProfileState();

  @override
  List<Object> get props => [];
}

class LMProfileStateInit extends LMProfileState {}

class LMRouteToUserProfileState extends LMProfileState {
  final String userUniqueId;

  const LMRouteToUserProfileState({required this.userUniqueId});

  @override
  List<Object> get props => [userUniqueId];
}

class LMLoginRequiredState extends LMProfileState {}

class LMLogoutState extends LMProfileState {}

class LMRouteToCompanyProfileState extends LMProfileState {
  final String companyId;

  const LMRouteToCompanyProfileState({required this.companyId});

  @override
  List<Object> get props => [companyId];
}
