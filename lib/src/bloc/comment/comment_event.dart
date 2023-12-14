part of 'comment_bloc.dart';

@immutable
sealed class CommentEvent {}

// Add Comment events
class AddComment extends CommentEvent {
  final AddCommentRequest addCommentRequest;
  AddComment({required this.addCommentRequest});

  @override
  List<Object> get props => [addCommentRequest];
}
