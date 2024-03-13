import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMLikeViewDataConvertor {
  static LMLikeViewData fromLike({required Like likeModel}) {
    LMLikeViewDataBuilder likeViewDataBuilder = LMLikeViewDataBuilder();
    likeViewDataBuilder
      ..id(likeModel.id)
      ..uuid(likeModel.uuid)
      ..createdAt(likeModel.createdAt)
      ..updatedAt(likeModel.updatedAt);
    return likeViewDataBuilder.build();
  }

  static Like toLike(LMLikeViewData likeViewData) {
    return Like(
      id: likeViewData.id,
      createdAt: likeViewData.createdAt,
      updatedAt: likeViewData.updatedAt,
      uuid: likeViewData.uuid,
    );
  }
}
