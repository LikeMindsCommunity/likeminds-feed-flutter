import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

import 'package:meta/meta.dart';

part 'lm_comment_event.dart';
part 'lm_comment_state.dart';
part 'handler/get_comment_handler.dart';
part 'handler/add_comment_handler.dart';
part 'handler/edit_comment_handler.dart';
part 'handler/delete_comment_handler.dart';
part 'handler/reply_comment_handler.dart';
part 'handler/get_reply_handler.dart';

class LMCommentBloc extends Bloc<LMCommentEvent, LMCommentState> {
  static final LMCommentBloc _instance = LMCommentBloc._();

  factory LMCommentBloc.instance() {
    return _instance;
  }
  LMCommentBloc._() : super(LMCommentInitial()) {
    on<LMGetCommentsEvent>(_getCommentHandler);
    on<LMAddCommentEvent>(_addCommentHandler);

    on<LMEditingCommentEvent>(_editingCommentHandler);
    on<LMEditCommentCancelEvent>(_cancelEditingCommentHandler);
    on<LMEditCommentEvent>(_editCommentHandler);

    on<LMDeleteComment>(_deleteCommentHandler);

    on<LMReplyingCommentEvent>(_replyingCommentHandler);
    on<LMReplyCommentEvent>(_replyCommentHandler);
    on<LMReplyCancelEvent>(_cancelReplyCommentHandler);

    on<LMGetReplyEvent>(_getReplyHandler);
    on<LMCloseReplyEvent>((event, emit) {
      emit(LMCloseReplyState(commentId: event.commentId));
    });

    on<LMEditingReplyEvent>((event, emit) {
      emit(LMEditingReplyState(
        commentId: event.commentId,
        replyId: event.replyId,
        postId: event.postId,
        replyText: event.replyText,
      ));
    });
    on<LMEditReply>(_editReplyHandler);

    on<LMEditReplyCancelEvent>((event, emit) {});

    on<LMDeleteReplyEvent>((LMDeleteReplyEvent event, emit) async {
      emit(LMDeleteReplyLoading());
      DeleteCommentRequest deleteCommentRequest = (DeleteCommentRequestBuilder()
            ..postId(event.postId)
            ..commentId(event.replyId)
            ..reason(event.reason))
          .build();
      final DeleteCommentResponse response =
          await LMFeedCore.client.deleteComment(deleteCommentRequest);
      if (response.success) {
        emit(LMDeleteReplySuccess(
          commentId: event.commentId,
          replyId: event.replyId,
        ));
      } else {
        emit(LMDeleteReplyError(
            error: response.errorMessage ?? 'Failed to delete reply'));
      }
    });
  }

  Future<FutureOr<void>> _editReplyHandler(LMEditReply event, emit) async {
    EditCommentReplyRequest editCommentReplyRequest =
        (EditCommentReplyRequestBuilder()
              ..commentId(event.commentId)
              ..postId(event.postId)
              ..replyId(event.replyId)
              ..text(event.replyText))
            .build();

    EditCommentReplyResponse response =
        await LMFeedCore.client.editCommentReply(editCommentReplyRequest);

    if (response.success) {
      final Map<String, LMTopicViewData> topics = {};
      final Map<String, LMWidgetViewData> widgets = {};
      final Map<String, LMUserViewData> users = {};

      widgets.addAll((response.widgets ?? {})
          .map((key, value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)))
          .cast<String, LMWidgetViewData>());

      topics.addAll((response.topics ?? {})
          .map((key, value) => MapEntry(
              key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)))
          .cast<String, LMTopicViewData>());

      users.addAll(response.users?.map((key, value) => MapEntry(
              key,
              LMUserViewDataConvertor.fromUser(
                value,
                topics: topics,
                widgets: widgets,
                userTopics: response.userTopics,
              ))) ??
          {});

      LMCommentViewData reply =
          LMCommentViewDataConvertor.fromComment(response.reply!, users);

      emit(LMEditReplySuccess(
        commentId: event.commentId,
        replyId: event.replyId,
        reply: reply,
      ));
    } else {
      emit(LMEditReplyError(
          error: response.errorMessage ?? 'Failed to edit reply'));
    }
  }
}
