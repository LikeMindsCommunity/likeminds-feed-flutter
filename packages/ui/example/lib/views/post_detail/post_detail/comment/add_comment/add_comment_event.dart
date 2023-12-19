part of 'add_comment_bloc.dart';

abstract class AddCommentEvent extends Equatable {
  const AddCommentEvent();

  @override
  List<Object> get props => [];
}

// Add Comment events
class LMAddCommentEvent extends AddCommentEvent {
  final AddCommentRequest addCommentRequest;
  const LMAddCommentEvent({required this.addCommentRequest});

  @override
  List<Object> get props => [addCommentRequest];
}
