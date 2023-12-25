import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class PopupMenuItemConvertor {
  static LMPopUpMenuItemViewData fromPopUpMenuItemModel({
    required PopupMenuItemModel item,
  }) {
    LMPopUpMenuItemViewDataBuilder popUpMenuItemViewDataBuilder =
        LMPopUpMenuItemViewDataBuilder();
    popUpMenuItemViewDataBuilder
      ..title(item.title)
      ..id(item.id);
    return popUpMenuItemViewDataBuilder.build();
  }

  static PopupMenuItemModel toPopUpMenuItemModel(
      LMPopUpMenuItemViewData popUpMenuItemViewData) {
    return PopupMenuItemModel(
      title: popUpMenuItemViewData.title,
      id: popUpMenuItemViewData.id,
    );
  }
}
