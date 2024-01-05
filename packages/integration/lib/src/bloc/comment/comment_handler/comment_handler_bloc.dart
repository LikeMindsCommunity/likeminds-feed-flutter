import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
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

/// {@template lm_comment_handler_bloc}
/// [LMCommentHandlerBloc] handle all the comment related actions
/// like add, edit, delete, etc.
/// [LMCommentHandlerEvent] defines the events which are handled by this bloc.
/// [LMCommentHandlerState] defines the states which are emitted by this bloc
/// {@endtemplate}
class LMCommentHandlerBloc
    extends Bloc<LMCommentHandlerEvent, LMCommentHandlerState> {
  static LMCommentHandlerBloc? _lmCommentHandlerBloc;

  static LMCommentHandlerBloc get instance =>
      _lmCommentHandlerBloc ??= LMCommentHandlerBloc._();

  /// {@macro lm_comment_handler_bloc}
  LMCommentHandlerBloc._() : super(LMCommentInitialState()) {
    // @{macro lm_comment_action_event}
    on<LMCommentActionEvent>(
      (event, emit) async {
        switch (event.commentMetaData.commentActionType) {
          // Add comment or reply to comment
          case (LMCommentActionType.add || LMCommentActionType.replying):
            // @{macro add_comment_event_handler}
            await handleAddActionEvent(event, emit);
            break;
          // Delete comment
          case LMCommentActionType.delete:
            // @{macro delete_comment_event_handler}
            await handleDeleteActionEvent(event, emit);
            break;
          // Edit comment
          case LMCommentActionType.edit:
            // @{macro edit_comment_event_handler}
            await handleEditActionEvent(event, emit);
            break;
          default:
            break;
        }
      },
    );
    // @{macro lm_ongoing_comment_event}
    on<LMCommentOngoingEvent>(
        // @{macro ongoing_comment_event_handler}
        (event, emit) => handleOngoingCommentEvent(event, emit));
    // @{macro lm_cancel_comment_event}
    on<LMCommentCancelEvent>(
        // @{macro cancel_comment_event_handler}
        (event, emit) => handleCancelCommentEvent(event, emit));
  }
}
