import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMLikeViewDataConvertor {
  static LMLikeViewData fromLike({required Like likeModel}) {
    LMLikeViewDataBuilder likeViewDataBuilder = LMLikeViewDataBuilder();
    likeViewDataBuilder
      ..id(likeModel.id)
      ..userId(likeModel.userId)
      ..createdAt(likeModel.createdAt)
      ..updatedAt(likeModel.updatedAt);
    return likeViewDataBuilder.build();
  }

  static Like toLike(LMLikeViewData likeViewData) {
    return Like(
      id: likeViewData.id,
      createdAt: likeViewData.createdAt,
      updatedAt: likeViewData.updatedAt,
      userId: likeViewData.userId,
    );
  }
}
