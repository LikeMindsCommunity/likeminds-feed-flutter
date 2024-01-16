import 'package:likeminds_feed_flutter_ui/src/models/commons/popup_menu_view_data.dart';

class LMCommentViewData {
  String id;
  String userId;
  String text;
  int level;
  int likesCount;
  bool isEdited;
  int repliesCount;
  LMCommentViewData? parentComment;
  List<LMPopUpMenuItemViewData> menuItems;
  DateTime createdAt;
  DateTime updatedAt;
  bool isLiked;
  List<LMCommentViewData>? replies;
  String uuid;
  String? tempId;

  LMCommentViewData._({
    required this.id,
    required this.userId,
    required this.text,
    required this.level,
    required this.likesCount,
    required this.repliesCount,
    required this.menuItems,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.isEdited,
    this.parentComment,
    required this.uuid,
    this.tempId,
    this.replies,
  });
}

class LMCommentViewDataBuilder {
  String? _id;
  String? _userId;
  String? _text;
  int? _level;
  int? _likesCount;
  bool? _isEdited;
  int? _repliesCount;
  LMCommentViewData? _parentComment;
  List<LMPopUpMenuItemViewData>? _menuItems;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool? _isLiked;
  String? _uuid;
  String? _tempId;
  List<LMCommentViewData>? _replies;

  void id(String id) {
    _id = id;
  }

  void userId(String userId) {
    _userId = userId;
  }

  void text(String text) {
    _text = text;
  }

  void level(int level) {
    _level = level;
  }

  void likesCount(int likesCount) {
    _likesCount = likesCount;
  }

  void isEdited(bool? isEdited) {
    _isEdited = isEdited;
  }

  void repliesCount(int repliesCount) {
    _repliesCount = repliesCount;
  }

  void parentComment(LMCommentViewData? parentComment) {
    _parentComment = parentComment;
  }

  void menuItems(List<LMPopUpMenuItemViewData> menuItems) {
    _menuItems = menuItems;
  }

  void createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  void updatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
  }

  void isLiked(bool isLiked) {
    _isLiked = isLiked;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  void tempId(String tempId) {
    _tempId = tempId;
  }

  void replies(List<LMCommentViewData> replies) {
    _replies = replies;
  }

  LMCommentViewData build() {
    return LMCommentViewData._(
      id: _id!,
      userId: _userId!,
      text: _text!,
      level: _level!,
      likesCount: _likesCount!,
      isEdited: _isEdited!,
      repliesCount: _repliesCount!,
      parentComment: _parentComment,
      menuItems: _menuItems!,
      createdAt: _createdAt!,
      updatedAt: _updatedAt!,
      isLiked: _isLiked!,
      uuid: _uuid!,
      tempId: _tempId,
      replies: _replies,
    );
  }
}
