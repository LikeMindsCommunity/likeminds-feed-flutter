import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/models/commons/popup_menu_view_data.dart';
import 'package:likeminds_feed_ui_fl/src/models/helper/attachment/attachment_view_data.dart';

/// {@template post_view_data}
/// A data class to hold the post data.
/// {@endtemplate}
class PostViewData {
  /// unique indentifier of the post
  /// [required]
  final String id;

  /// content of the post [nullable]
  /// might contain tags and mentions
  String text;

  /// topics of the post [nullable]
  List<String> topics;

  /// attachments of the post [nullable]
  /// can be of type image, video, file
  List<AttachmentViewData>? attachments;

  /// community id of the community to which the post belongs
  final int communityId;

  bool isPinned;

  /// user id of the user who created the post
  final String userId;

  int likeCount;

  int commentCount;
  bool isSaved;
  bool isLiked;

  /// menu items to be displayed in the post menu
  List<PopUpMenuItemViewData> menuItems;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isEdited;

  List<CommentViewData> replies;

  /// {@macro post_view_data}
  PostViewData._({
    required this.id,
    required this.text,
    required this.attachments,
    required this.communityId,
    required this.isPinned,
    required this.userId,
    required this.likeCount,
    required this.isSaved,
    required this.topics,
    required this.menuItems,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.commentCount,
    required this.isEdited,
    required this.replies,
  });
}

class PostViewDataBuilder {
  String? _id;
  String? _text;
  List<String>? _topics;
  List<AttachmentViewData>? _attachments;
  int? _communityId;
  bool? _isPinned;
  String? _userId;
  int? _likeCount;
  int? _commentCount;
  bool? _isSaved;
  bool? _isLiked;
  List<PopUpMenuItemViewData>? _menuItems;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool? _isEdited;
  List<CommentViewData>? _replies;

  void id(String id) {
    _id = id;
  }

  void text(String text) {
    _text = text;
  }

  void topics(List<String> topics) {
    _topics = topics;
  }

  void attachments(List<AttachmentViewData> attachments) {
    _attachments = attachments;
  }

  void communityId(int communityId) {
    _communityId = communityId;
  }

  void isPinned(bool isPinned) {
    _isPinned = isPinned;
  }

  void userId(String userId) {
    _userId = userId;
  }

  void likeCount(int likeCount) {
    _likeCount = likeCount;
  }

  void commentCount(int commentCount) {
    _commentCount = commentCount;
  }

  void isSaved(bool isSaved) {
    _isSaved = isSaved;
  }

  void isLiked(bool isLiked) {
    _isLiked = isLiked;
  }

  void menuItems(List<PopUpMenuItemViewData> menuItems) {
    _menuItems = menuItems;
  }

  void createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  void updatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
  }

  void isEdited(bool isEdited) {
    _isEdited = isEdited;
  }

  void replies(List<CommentViewData> replies) {
    _replies = replies;
  }

  PostViewData build() {
    return PostViewData._(
      id: _id!,
      text: _text!,
      topics: _topics!,
      attachments: _attachments,
      communityId: _communityId!,
      isPinned: _isPinned!,
      userId: _userId!,
      likeCount: _likeCount!,
      commentCount: _commentCount!,
      isSaved: _isSaved!,
      isLiked: _isLiked!,
      menuItems: _menuItems!,
      createdAt: _createdAt!,
      updatedAt: _updatedAt!,
      isEdited: _isEdited!,
      replies: _replies!,
    );
  }
}
