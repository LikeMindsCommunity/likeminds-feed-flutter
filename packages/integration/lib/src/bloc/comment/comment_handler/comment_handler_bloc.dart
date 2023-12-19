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

class LMCommentHandlerBloc
    extends Bloc<LMCommentHandlerEvent, LMCommentHandlerState> {
  static LMFeedBloc lmFeedBloc = LMFeedBloc.get();
  LMCommentHandlerBloc() : super(LMCommentInitialState()) {
    on<LMCommentActionEvent>(
      (event, emit) async {
        switch (event.commentMetaData.commentActionType) {
          case LMCommentActionType.add:
            {
              handleAddActionEvent(event, emit);
              break;
            }
          case LMCommentActionType.delete:
            {
              break;
            }
          case LMCommentActionType.edit:
            {
              handleEditActionEvent(event, emit);
              break;
            }
        }
      },
    );
  }
}
