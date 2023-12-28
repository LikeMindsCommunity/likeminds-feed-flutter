part of 'compose_bloc.dart';

@immutable
sealed class LMComposeEvent {}

class LMComposeAddImage extends LMComposeEvent {}

class LMComposeAddVideo extends LMComposeEvent {}

class LMComposeAddDocument extends LMComposeEvent {}

class LMComposeRemoveImage extends LMComposeEvent {}

class LMComposeRemoveVideo extends LMComposeEvent {}

class LMComposeRemoveDocument extends LMComposeEvent {}
