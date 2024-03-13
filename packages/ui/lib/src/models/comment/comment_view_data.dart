import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMCommentViewData {
  String id;
  String uuid;
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
  String? tempId;
  LMUserViewData user;

  LMCommentViewData._({
    required this.id,
    required this.uuid,
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
    this.tempId,
    this.replies,
    required this.user,
  });
}

class LMCommentViewDataBuilder {
  String? _id;
  String? _uuid;
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
  String? _tempId;
  List<LMCommentViewData>? _replies;
  LMUserViewData? _user;

  void id(String id) {
    _id = id;
  }

  void uuid(String uuid) {
    _uuid = uuid;
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

  void tempId(String tempId) {
    _tempId = tempId;
  }

  void replies(List<LMCommentViewData> replies) {
    _replies = replies;
  }

  void user(LMUserViewData user) {
    _user = user;
  }

  LMCommentViewData build() {
    return LMCommentViewData._(
      id: _id!,
      uuid: _uuid!,
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
      tempId: _tempId,
      replies: _replies,
      user: _user!,
    );
  }
}
