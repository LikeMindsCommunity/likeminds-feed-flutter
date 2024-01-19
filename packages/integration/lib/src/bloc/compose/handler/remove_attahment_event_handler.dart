import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

removeAttachmentEventHandler(LMFeedComposeRemoveAttachmentEvent event,
    Emitter<LMFeedComposeState> emitter) {
  LMMediaModel mediaModel = LMFeedComposeBloc.instance.postMedia[event.index];

  switch (mediaModel.mediaType) {
    case LMMediaType.image:
      LMFeedComposeBloc.instance.imageCount--;
      break;
    case LMMediaType.video:
      LMFeedComposeBloc.instance.videoCount--;
      break;
    case LMMediaType.document:
      LMFeedComposeBloc.instance.documentCount--;
      break;
    default:
  }

  LMFeedComposeBloc.instance.postMedia.removeAt(event.index);

  emitter(LMFeedComposeRemovedAttachmentState());
}
