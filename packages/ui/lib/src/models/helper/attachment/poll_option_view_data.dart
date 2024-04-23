import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMPostOptionViewData {
  final String id;
  final String text;
  final int voteCount;
  final double percentage;
  final bool isSelected;
  final LMUserViewData userViewData;

  LMPostOptionViewData._({
    required this.id,
    required this.text,
    required this.voteCount,
    required this.percentage,
    required this.isSelected,
    required this.userViewData,
  });

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'LMPostOptionViewData(id: $id, text: $text, votes: $voteCount, percentage: $percentage, isSelected: $isSelected, userViewData: $userViewData)';
  }
}

class LMPostOptionViewDataBuilder {
  String? _id;
  String? _text;
  int? _votes;
  double? _percentage;
  bool? _isSelected;
  LMUserViewData? _userViewData;

  void id(String id) {
    _id = id;
  }

  void text(String text) {
    _text = text;
  }

  void votes(int votes) {
    _votes = votes;
  }

  void percentage(double percentage) {
    _percentage = percentage;
  }

  void isSelected(bool isSelected) {
    _isSelected = isSelected;
  }

  void userViewData(LMUserViewData userViewData) {
    _userViewData = userViewData;
  }

  LMPostOptionViewData build() {
    return LMPostOptionViewData._(
      id: _id??"",
      text: _text!,
      voteCount: _votes!,
      percentage: _percentage!,
      isSelected: _isSelected!,
      userViewData: _userViewData!,
    );
  }
}
