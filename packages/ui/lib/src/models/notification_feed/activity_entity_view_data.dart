import 'package:likeminds_feed_flutter_ui/src/models/comment/comment_view_data.dart';
import 'package:likeminds_feed_flutter_ui/src/models/helper/attachment/attachment_view_data.dart';

class LMActivityEntityViewData {
  String id;
  List<LMAttachmentViewData>? attachments;
  int? chatroomId;
  int communityId;
  int createdAt;
  String? deleteReason;
  String? deleteBy;
  String? heading;
  int? level;
  String? postId;
  bool? isDeleted;
  bool? isPinned;
  bool? isEdited;
  String text;
  List<LMCommentViewData>? replies;
  int? updatedAt;
  String uuid;

  LMActivityEntityViewData._({
    required this.id,
    this.attachments,
    this.chatroomId,
    required this.communityId,
    required this.createdAt,
    this.deleteReason,
    this.deleteBy,
    this.heading,
    this.level,
    required this.postId,
    this.isDeleted,
    this.isPinned,
    this.isEdited,
    required this.text,
    this.replies,
    this.updatedAt,
    required this.uuid,
  });
}

class LMActivityEntityViewDataBuilder {
  String? _id;
  List<LMAttachmentViewData>? _attachments;
  int? _chatroomId;
  int? _communityId;
  int? _createdAt;
  String? _deleteReason;
  String? _deleteBy;
  String? _heading;
  int? _level;
  String? _postId;
  bool? _isDeleted;
  bool? _isPinned;
  bool? _isEdited;
  String? _text;

  List<LMCommentViewData>? _replies;
  int? _updatedAt;
  String? _uuid;

  void id(String id) {
    _id = id;
  }

  void attachments(List<LMAttachmentViewData> attachments) {
    _attachments = attachments;
  }

  void chatroomId(int chatroomId) {
    _chatroomId = chatroomId;
  }

  void communityId(int communityId) {
    _communityId = communityId;
  }

  void createdAt(int createdAt) {
    _createdAt = createdAt;
  }

  void deleteReason(String deleteReason) {
    _deleteReason = deleteReason;
  }

  void deleteBy(String deleteBy) {
    _deleteBy = deleteBy;
  }

  void heading(String heading) {
    _heading = heading;
  }

  void level(int level) {
    _level = level;
  }

  void postId(String postId) {
    _postId = postId;
  }

  void isDeleted(bool isDeleted) {
    _isDeleted = isDeleted;
  }

  void isPinned(bool isPinned) {
    _isPinned = isPinned;
  }

  void isEdited(bool isEdited) {
    _isEdited = isEdited;
  }

  void text(String text) {
    _text = text;
  }

  void replies(List<LMCommentViewData> replies) {
    _replies = replies;
  }

  void updatedAt(int updatedAt) {
    _updatedAt = updatedAt;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  LMActivityEntityViewData build() {
    return LMActivityEntityViewData._(
      id: _id!,
      attachments: _attachments,
      chatroomId: _chatroomId,
      communityId: _communityId!,
      createdAt: _createdAt!,
      deleteReason: _deleteReason,
      deleteBy: _deleteBy,
      heading: _heading,
      level: _level,
      postId: _postId,
      isDeleted: _isDeleted,
      isPinned: _isPinned,
      isEdited: _isEdited,
      text: _text!,
      replies: _replies,
      updatedAt: _updatedAt,
      uuid: _uuid!,
    );
  }
}
