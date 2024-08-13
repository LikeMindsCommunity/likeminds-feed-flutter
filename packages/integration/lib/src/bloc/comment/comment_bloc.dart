import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

import 'package:meta/meta.dart';

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

class LMCommentBloc extends Bloc<LMCommentEvent, LMCommentState> {
  static final LMCommentBloc _instance = LMCommentBloc._();

  factory LMCommentBloc.instance() {
    return _instance;
  }
  LMCommentBloc._() : super(LMCommentInitial()) {
    on<LMCommentRefreshEvent>((event, emit) {
      emit(LMCommentRefreshState());
    });
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
    on<LMCloseReplyEvent>(_closeReplyHandler);

    on<LMEditingReplyEvent>(_editingReplyHandler);
    on<LMEditReply>(_editReplyHandler);

    on<LMEditReplyCancelEvent>(_editReplyCancelHandler);

    on<LMDeleteReplyEvent>(_deleteReplyHandler);
  }

}
