import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'comment_handler_event.dart';
part 'comment_handler_state.dart';
part 'helper/comment_meta.dart';
part 'handler/add_comment_event_handler.dart';
part 'handler/edit_comment_event_handler.dart';
part 'handler/delete_comment_event_handler.dart';
part 'handler/ongoing_comment_event.dart';
part 'handler/cancel_comment_event_handler.dart';

/// {@template lm_comment_bloc}
/// [LMFeedCommentBloc] handle all the comment related actions
/// like add, edit, delete, etc.
/// [LMFeedCommentHandlerEvent] defines the events which are handled by this bloc.
/// [LMFeedCommentHandlerState] defines the states which are emitted by this bloc
/// {@endtemplate}
class LMFeedCommentBloc
    extends Bloc<LMFeedCommentHandlerEvent, LMFeedCommentHandlerState> {
  static LMFeedCommentBloc? _lmCommentHandlerBloc;

  static LMFeedCommentBloc get instance =>
      _lmCommentHandlerBloc ??= LMFeedCommentBloc._();

  /// {@macro lm_comment_bloc}
  LMFeedCommentBloc._() : super(LMFeedCommentInitialState()) {
    // @{macro lm_comment_action_event}
    on<LMFeedCommentActionEvent>(
      (event, emit) async {
        switch (event.commentMetaData.commentActionType) {
          // Add comment or reply to comment
          case LMFeedCommentActionType.add:
          case LMFeedCommentActionType.replying:
            // @{macro add_comment_event_handler}
            await handleAddActionEvent(event, emit);
            break;
          // Delete comment
          case LMFeedCommentActionType.delete:
            // @{macro delete_comment_event_handler}
            await handleDeleteActionEvent(event, emit);
            break;
          // Edit comment
          case LMFeedCommentActionType.edit:
            // @{macro edit_comment_event_handler}
            await handleEditActionEvent(event, emit);
            break;
          default:
            break;
        }
      },
    );
    // @{macro lm_ongoing_comment_event}
    on<LMFeedCommentOngoingEvent>(
        // @{macro ongoing_comment_event_handler}
        (event, emit) => handleOngoingCommentEvent(event, emit));
    // @{macro lm_cancel_comment_event}
    on<LMFeedCommentCancelEvent>(
        // @{macro cancel_comment_event_handler}
        (event, emit) => handleCancelCommentEvent(event, emit));
  }
}
