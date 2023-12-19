part of 'add_comment_bloc.dart';

abstract class AddCommentState extends Equatable {
  const AddCommentState();

  @override
  List<Object> get props => [];
}

class AddCommentInitial extends AddCommentState {}

class AddCommentLoading extends AddCommentState {}

class LMAddCommentSuccessState extends AddCommentState {
  final AddCommentResponse addCommentResponse;
  const LMAddCommentSuccessState({required this.addCommentResponse});
}

class LMAddCommentErrorState extends AddCommentState {
  final String message;
  const LMAddCommentErrorState({required this.message});
}
