import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'comment_event.dart';
part 'comment_state.dart';
part 'handler/get_comment_handler.dart';
part 'handler/add_comment_handler.dart';
part 'handler/edit_comment_handler.dart';
part 'handler/delete_comment_handler.dart';
part 'handler/reply_comment_handler.dart';
part 'handler/get_reply_handler.dart';
part 'handler/edit_reply_handler.dart';
part 'handler/delete_reply_handler.dart';
part 'handler/submit_comment_button_handler.dart';

class LMFeedCommentBloc extends Bloc<LMFeedCommentEvent, LMFeedCommentState> {
  static final LMFeedCommentBloc _instance = LMFeedCommentBloc._();

  static LMFeedCommentBloc get instance => _instance;
  final List<LMUserTagViewData> userTags = [];

  LMFeedCommentBloc._() : super(LMFeedCommentInitialState()) {
    on<LMFeedCommentRefreshEvent>((event, emit) {
      emit(LMFeedCommentRefreshState());
    });
    on<LMFeedGetCommentsEvent>(_getCommentHandler);
    on<LMFeedAddCommentEvent>(_addCommentHandler);

    on<LMFeedEditingCommentEvent>(_editingCommentHandler);
    on<LMFeedEditCommentCancelEvent>(_cancelEditingCommentHandler);
    on<LMFeedEditCommentEvent>(_editCommentHandler);

    on<LMFeedDeleteCommentEvent>(_deleteCommentHandler);

    on<LMFeedReplyingCommentEvent>(_replyingCommentHandler);
    on<LMFeedReplyCommentEvent>(_replyCommentHandler);
    on<LMFeedReplyCancelEvent>(_cancelReplyCommentHandler);

    on<LMFeedGetReplyEvent>(_getReplyHandler);
    on<LMFeedCloseReplyEvent>(_closeReplyHandler);

    on<LMFeedEditingReplyEvent>(_editingReplyHandler);
    on<LMFeedEditReplyEvent>(_editReplyHandler);

    on<LMFeedEditReplyCancelEvent>(_editReplyCancelHandler);

    on<LMDeleteReplyEvent>(_deleteReplyHandler);

    on<LMFeedSubmitCommentEvent>(_handleSubmitCommentButtonAction);
  }
}
