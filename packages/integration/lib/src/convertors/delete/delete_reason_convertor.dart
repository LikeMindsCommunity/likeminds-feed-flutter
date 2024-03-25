import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMDeleteReasonConvertor {
  static LMDeleteReasonViewData fromDeleteReason(DeleteReason deleteReason) {
    LMDeleteReasonViewDataBuilder deleteReasonViewDataBuilder =
        LMDeleteReasonViewDataBuilder()
          ..id(deleteReason.id)
          ..name(deleteReason.name);
    return deleteReasonViewDataBuilder.build();
  }

  static DeleteReason toDeleteReason(
      LMDeleteReasonViewData deleteReasonViewData) {
    return DeleteReason(
      id: deleteReasonViewData.id,
      name: deleteReasonViewData.name,
    );
  }
}
