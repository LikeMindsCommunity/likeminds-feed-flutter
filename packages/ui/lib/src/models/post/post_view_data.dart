import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template post_view_data}
/// A data class to hold the post data.
/// {@endtemplate}
class LMPostViewData {
  /// unique indentifier of the post
  /// [required]
  final String id;

  /// content of the post [nullable]
  /// might contain tags and mentions>
  String text;

  /// post heading [nullable]
  /// might contain tags and mentions
  String? heading;

  /// topics of the post [nullable]
  List<LMTopicViewData> topics;

  /// attachments of the post [nullable]
  /// can be of type image, video, file
  List<LMAttachmentViewData>? attachments;

  /// community id of the community to which the post belongs
  final int communityId;

  bool isPinned;

  /// user id of the user who created the post
  final String uuid;

  /// user data of the user who created the post
  final LMUserViewData user;

  int likeCount;

  int commentCount;
  bool isSaved;
  bool isLiked;

  /// menu items to be displayed in the post menu
  List<LMPopUpMenuItemViewData> menuItems;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isEdited;

  List<LMCommentViewData> replies;

  List<String>? commentIds;

  bool isRepost;
  bool isRepostedByUser;
  int repostCount;
  bool? isDeleted;
  bool isPendingPost;
  LMPostReviewStatus postStatus;

  /// widget map to hold custom widget data
  Map<String, LMWidgetViewData>? widgets;

  List<LMCommentViewData>? topComments;

  String? tempId;

  /// {@macro post_view_data}
  LMPostViewData._({
    required this.id,
    required this.text,
    required this.attachments,
    required this.communityId,
    required this.isPinned,
    required this.uuid,
    required this.user,
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
    required this.isRepost,
    required this.isRepostedByUser,
    required this.repostCount,
    required this.isPendingPost,
    required this.postStatus,
    this.isDeleted = false,
    this.widgets,
    this.commentIds,
    this.heading,
    this.topComments,
    this.tempId,
  });

  LMPostViewData copyWith() {
    return LMPostViewData._(
      id: id,
      text: text,
      attachments: attachments,
      communityId: communityId,
      isPinned: isPinned,
      uuid: uuid,
      user: user,
      likeCount: likeCount,
      isSaved: isSaved,
      topics: topics,
      menuItems: menuItems,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isLiked: isLiked,
      commentCount: commentCount,
      isEdited: isEdited,
      replies: replies,
      isRepost: isRepost,
      isRepostedByUser: isRepostedByUser,
      repostCount: repostCount,
      isDeleted: isDeleted,
      widgets: widgets,
      commentIds: commentIds,
      heading: heading,
      topComments: topComments,
      tempId: tempId,
      isPendingPost: isPendingPost,
      postStatus: postStatus,
    );
  }
}

class LMPostViewDataBuilder {
  String? _id;
  String? _text;
  List<LMTopicViewData>? _topics;
  List<LMAttachmentViewData>? _attachments;
  int? _communityId;
  bool? _isPinned;
  String? _uuid;
  LMUserViewData? _user;
  int? _likeCount;
  int? _commentCount;
  bool? _isSaved;
  bool? _isLiked;
  List<LMPopUpMenuItemViewData>? _menuItems;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool? _isEdited;
  List<LMCommentViewData>? _replies;
  bool? _isReposted;
  bool? _isRepostedByUser;
  int? _repostCount;
  bool? _isDeleted;
  Map<String, LMWidgetViewData>? _widgets;
  String? _heading;
  List<String>? _commentIds;
  List<LMCommentViewData>? _topComments;
  String? _tempId;
  bool? _isPendingPost;
  LMPostReviewStatus? _postStatus;

  void id(String id) {
    _id = id;
  }

  void text(String text) {
    _text = text;
  }

  void topics(List<LMTopicViewData>? topics) {
    _topics = topics;
  }

  void attachments(List<LMAttachmentViewData> attachments) {
    _attachments = attachments;
  }

  void communityId(int? communityId) {
    _communityId = communityId;
  }

  void isPinned(bool isPinned) {
    _isPinned = isPinned;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  void user(LMUserViewData user) {
    _user = user;
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

  void menuItems(List<LMPopUpMenuItemViewData> menuItems) {
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

  void replies(List<LMCommentViewData> replies) {
    _replies = replies;
  }

  void isReposted(bool isReposted) {
    _isReposted = isReposted;
  }

  void isRepostedByUser(bool isRepostedByUser) {
    _isRepostedByUser = isRepostedByUser;
  }

  void repostCount(int repostCount) {
    _repostCount = repostCount;
  }

  void isDeleted([bool isDeleted = false]) {
    _isDeleted = isDeleted;
  }

  void widgets(Map<String, LMWidgetViewData> widgets) {
    _widgets = widgets;
  }

  void heading(String heading) {
    _heading = heading;
  }

  void commentIds(List<String> commentIds) {
    _commentIds = commentIds;
  }

  void topComments(List<LMCommentViewData> topComments) {
    _topComments = topComments;
  }

  void tempId(String tempId) {
    _tempId = tempId;
  }

  void isPendingPost(bool isPendingPost) {
    _isPendingPost = isPendingPost;
  }

  void postStatus(LMPostReviewStatus postStatus) {
    _postStatus = postStatus;
  }

  LMPostViewData build() {
    return LMPostViewData._(
      id: _id!,
      text: _text!,
      topics: _topics!,
      attachments: _attachments,
      communityId: _communityId!,
      isPinned: _isPinned!,
      uuid: _uuid!,
      user: _user!,
      likeCount: _likeCount!,
      commentCount: _commentCount!,
      isSaved: _isSaved!,
      isLiked: _isLiked!,
      menuItems: _menuItems!,
      createdAt: _createdAt!,
      updatedAt: _updatedAt!,
      isEdited: _isEdited!,
      replies: _replies!,
      isDeleted: _isDeleted ?? false,
      isRepost: _isReposted!,
      isRepostedByUser: _isRepostedByUser!,
      repostCount: _repostCount!,
      widgets: _widgets,
      heading: _heading,
      commentIds: _commentIds,
      topComments: _topComments,
      tempId: _tempId,
      isPendingPost: _isPendingPost!,
      postStatus: _postStatus!,
    );
  }
}
