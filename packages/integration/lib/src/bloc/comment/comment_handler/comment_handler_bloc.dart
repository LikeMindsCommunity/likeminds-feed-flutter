import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/analytics/keys.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

part 'comment_handler_event.dart';
part 'comment_handler_state.dart';
part 'helper/comment_meta.dart';
part 'handler/add_comment_event_handler.dart';
part 'handler/edit_comment_event_handler.dart';
part 'handler/delete_comment_event_handler.dart';
part 'handler/ongoing_comment_event.dart';
part 'handler/cancel_comment_event_handler.dart';

/// [LMCommentHandlerBloc] handle all the comment related actions
/// like add, edit, delete, etc.
/// [LMCommentHandlerEvent] defines the events which are handled by this bloc.
/// [LMCommentHandlerState] defines the states which are emitted by this bloc
class LMCommentHandlerBloc
    extends Bloc<LMCommentHandlerEvent, LMCommentHandlerState> {
  static LMCommentHandlerBloc? _lmCommentHandlerBloc;

  static LMCommentHandlerBloc get instance =>
      _lmCommentHandlerBloc ??= LMCommentHandlerBloc._();

  LMCommentHandlerBloc._() : super(LMCommentInitialState()) {
    on<LMCommentActionEvent>(
      (event, emit) async {
        switch (event.commentMetaData.commentActionType) {
          // Add comment
          case (LMCommentActionType.add || LMCommentActionType.replying):
            await handleAddActionEvent(event, emit);
            break;
          // Delete comment
          case LMCommentActionType.delete:
            await handleDeleteActionEvent(event, emit);
            break;
          // Edit comment
          case LMCommentActionType.edit:
            await handleEditActionEvent(event, emit);
            break;
          default:
            break;
        }
      },
    );
    on<LMCommentOngoingEvent>(
        (event, emit) => handleOngoingCommentEvent(event, emit));
    on<LMCommentCancelEvent>(
        (event, emit) => handleCancelCommentEvent(event, emit));
  }
}
