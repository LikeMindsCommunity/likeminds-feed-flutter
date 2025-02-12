class LMFeedCreateShortVideoSettings {
  final bool textRequiredToCreatePost;
  final bool topicRequiredToCreatePost;
  final bool enableTagging;
  const LMFeedCreateShortVideoSettings({
    this.textRequiredToCreatePost = false,
    this.topicRequiredToCreatePost = false,
    this.enableTagging = true,
  });
}
