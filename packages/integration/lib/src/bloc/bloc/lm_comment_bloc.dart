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
    on<LMEditReply>((event, emit) {});

    on<LMEditReplyCancelEvent>((event, emit) {});

    on<LMDeleteReplyEvent>((event, emit) {});
  }

  FutureOr<void> _getReplyHandler(LMGetReplyEvent event, emit) async {
    final GetCommentRequest request = (GetCommentRequestBuilder()
          ..commentId(event.commentId)
          ..postId(event.postId)
          ..page(event.page)
          ..pageSize(10))
        .build();

    GetCommentResponse response = await LMFeedCore.client.getComment(request);
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
      LMCommentViewData commentViewData =
          LMCommentViewDataConvertor.fromComment(response.postReplies!, users);
      emit(LMGetReplyCommentSuccess(
          replies: commentViewData.replies ?? [], page: event.page));
    }
  }
}
