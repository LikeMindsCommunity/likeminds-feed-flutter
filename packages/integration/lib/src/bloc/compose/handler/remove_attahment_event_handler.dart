import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

removeAttachmentEventHandler(LMFeedComposeRemoveAttachmentEvent event,
    Emitter<LMFeedComposeState> emitter) {
  LMFeedComposeBloc.instance.postMedia.removeAt(event.index);

  emitter(LMFeedComposeRemovedAttachmentState());
}
