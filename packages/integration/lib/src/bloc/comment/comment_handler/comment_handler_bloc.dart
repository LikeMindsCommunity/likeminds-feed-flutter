import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/constants/analytics/keys.dart';
import 'package:overlay_support/overlay_support.dart';

part 'comment_handler_event.dart';
part 'comment_handler_state.dart';
part 'helper/comment_meta.dart';
part 'handler/add_comment_event_handler.dart';
part 'handler/edit_comment_event_handler.dart';
part 'handler/delete_comment_event_handler.dart';

/// [LMCommentHandlerBloc] handle all the comment related actions
/// like add, edit, delete, etc.
/// [LMCommentHandlerEvent] defines the events which are handled by this bloc.
/// [LMCommentHandlerState] defines the states which are emitted by this bloc
class LMCommentHandlerBloc
    extends Bloc<LMCommentHandlerEvent, LMCommentHandlerState> {
  static LMFeedBloc lmFeedBloc = LMFeedBloc.get();
  LMCommentHandlerBloc() : super(LMCommentInitialState()) {
    on<LMCommentActionEvent>(
      (event, emit) async {
        switch (event.commentMetaData.commentActionType) {
          // Add comment
          case LMCommentActionType.add:
            handleAddActionEvent(event, emit);
            break;
          // Delete comment
          case LMCommentActionType.delete:
            handleDeleteActionEvent(event, emit);
            break;
          // Edit comment
          case LMCommentActionType.edit:
            handleEditActionEvent(event, emit);
            break;
        }
      },
    );
  }
}
