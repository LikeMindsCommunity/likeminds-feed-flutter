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
  String? postId;

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
    this.postId,
  });

  // copyWith method
  LMCommentViewData copyWith({
    String? id,
    String? uuid,
    String? text,
    int? level,
    int? likesCount,
    int? repliesCount,
    List<LMPopUpMenuItemViewData>? menuItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    bool? isEdited,
    LMCommentViewData? parentComment,
    String? tempId,
    List<LMCommentViewData>? replies,
    LMUserViewData? user,
    String? postId,
  }) {
    return LMCommentViewData._(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      text: text ?? this.text,
      level: level ?? this.level,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      menuItems: menuItems ?? this.menuItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      isEdited: isEdited ?? this.isEdited,
      parentComment: parentComment ?? this.parentComment,
      tempId: tempId ?? this.tempId,
      replies: replies ?? this.replies,
      user: user ?? this.user,
      postId: postId ?? this.postId,
    );
  }
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
  String? _postId;

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

  void postId(String postId) {
    _postId = postId;
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
      postId: _postId,
    );
  }
}
