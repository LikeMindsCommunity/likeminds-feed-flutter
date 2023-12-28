part of 'compose_bloc.dart';

@immutable
sealed class LMComposeState {}

final class LMComposeInitial extends LMComposeState {}

class LMComposeAddedImage extends LMComposeEvent {}

class LMComposeAddedVideo extends LMComposeEvent {}

class LMComposeAddedDocument extends LMComposeEvent {}

class LMComposeRemovedImage extends LMComposeEvent {}

class LMComposeRemovedVideo extends LMComposeEvent {}

class LMComposeRemovedDocument extends LMComposeEvent {}
