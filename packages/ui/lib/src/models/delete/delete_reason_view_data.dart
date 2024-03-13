/// {@template lm_delete_reason_view_data}
/// A data class to hold the delete reason data.
/// {@endtemplate}
class LMDeleteReasonViewData {
  /// The id of the delete reason.
  final int id;

  /// The reason for the delete.
  final String name;

  /// {@macro lm_delete_reason_view_data}
  const LMDeleteReasonViewData._({
    required this.id,
    required this.name,
  });
}

/// {@template lm_delete_reason_view_data_builder}
/// A builder class to build [LMDeleteReasonViewData]
/// {@endtemplate}

class LMDeleteReasonViewDataBuilder {
  int? _id;
  String? _name;

  void id(int id) {
    _id = id;
  }

  void name(String name) {
    _name = name;
  }

  LMDeleteReasonViewData build() {
    return LMDeleteReasonViewData._(
      id: _id!,
      name: _name!,
    );
  }
}
