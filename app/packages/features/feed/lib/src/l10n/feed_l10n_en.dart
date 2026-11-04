// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FeedL10nEn extends FeedL10n {
  FeedL10nEn([String locale = 'en']) : super(locale);

  @override
  String get commentsOff => 'Comments are turned off for this post.';

  @override
  String get commentNotAllowed =>
      'You can\'t comment on this post right now. You can leave an emoji reaction.';

  @override
  String get blocked => 'You can\'t interact with this account.';

  @override
  String get commentRate =>
      'You\'ve commented a lot in a short time. Wait a bit and try again.';

  @override
  String get muted =>
      'You\'re muted in this group, so you can\'t comment right now.';

  @override
  String get likeRate =>
      'You\'ve liked a lot in a short time. Wait a bit and try again.';

  @override
  String get replyGone => 'The comment you replied to no longer exists.';

  @override
  String get storyRate =>
      'You\'ve shared a lot of stories today. Try again tomorrow.';

  @override
  String get highlightLimit => 'You can create up to 100 highlights.';

  @override
  String get highlightFull => 'A highlight can hold up to 100 stories.';

  @override
  String get duplicate => 'This has already been done.';

  @override
  String get fileTooLarge =>
      'The file is too large. Photos can be up to 10 MB and videos up to 50 MB.';

  @override
  String get unsupportedMedia =>
      'Only JPEG, PNG, WebP photos and MP4, MOV videos can be shared.';

  @override
  String get commentLength => 'A comment must be 1–2,200 characters.';

  @override
  String get highlightTitleLength => 'The title must be 1–30 characters.';

  @override
  String get pickStory => 'Choose at least one story.';

  @override
  String get aspectOriginal => 'Original';

  @override
  String get agoNow => 'now';

  @override
  String agoMinutes(int n) {
    return '${n}m';
  }

  @override
  String agoHours(int n) {
    return '${n}h';
  }

  @override
  String agoDays(int n) {
    return '${n}d';
  }

  @override
  String agoWeeks(int n) {
    return '${n}w';
  }

  @override
  String get photoLimit => 'Photos can be up to 10 MB.';

  @override
  String get videoSizeLimit => 'Videos can be up to 50 MB.';

  @override
  String get videoLengthLimit => 'Videos can be up to 60 seconds.';

  @override
  String get captionLimit => 'The caption can be up to 2,200 characters.';

  @override
  String get hashtagLimit => 'A post can have up to 30 hashtags.';

  @override
  String get mediaCount => 'A post can have 1–10 photos or videos.';

  @override
  String get comments => 'Comments';

  @override
  String get noCommentsEmojiOnly =>
      'No comments yet. You can react to this post with an emoji.';

  @override
  String get noCommentsFirst => 'No comments yet. Be the first to comment.';

  @override
  String get goBack => 'Go back';

  @override
  String get writeComment => 'Write a comment';

  @override
  String replyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get cancelReply => 'Cancel reply';

  @override
  String get addComment => 'Add a comment…';

  @override
  String get share => 'Share';

  @override
  String get deleteCommentTitle => 'Delete comment?';

  @override
  String get deleteCommentBody =>
      'The comment and its replies are deleted permanently.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Reply';

  @override
  String get report => 'Report';

  @override
  String get unlike => 'Unlike';

  @override
  String get likeComment => 'Like comment';

  @override
  String get cantComment =>
      'You can\'t comment on this post right now. You can leave an emoji reaction.';

  @override
  String get tooManyMedia => 'A post can have up to 10 photos or videos.';

  @override
  String get cantOpenFile =>
      'The selected file couldn\'t be opened. Try another photo or video.';

  @override
  String get preparingPhotos => 'Preparing photos…';

  @override
  String get photosFailed => 'Couldn\'t prepare the photos. Try another photo.';

  @override
  String uploading(int done, int total) {
    return 'Uploading: $done/$total';
  }

  @override
  String get sharing => 'Sharing…';

  @override
  String get postShared => 'Your post has been shared.';

  @override
  String get newPost => 'New post';

  @override
  String get memoryNotice =>
      'This post will also appear among the event\'s memories. Only share your own photos and people who gave permission.';

  @override
  String get pickMediaHint => 'Choose up to 10 photos or videos to share.';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get cropHint =>
      'Pinch to zoom and drag to frame. The ratio applies to all photos.';

  @override
  String get caption => 'Caption';

  @override
  String get captionHint =>
      'Write something… You can add #hashtags and @usernames.';

  @override
  String get postAs => 'Post as';

  @override
  String get myProfile => 'My profile';

  @override
  String groupOption(String name) {
    return '$name (group)';
  }

  @override
  String get turnOffComments => 'Turn off comments';

  @override
  String get hideLikes => 'Hide like count';

  @override
  String get onlyYouSee => 'Only you see the number.';

  @override
  String mediaN(int n) {
    return 'Media $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Remove';

  @override
  String get cantShare => 'Can\'t be shared';

  @override
  String get addMedia => 'Add media';

  @override
  String get editPost => 'Edit post';

  @override
  String get save => 'Save';

  @override
  String get noEditPermission =>
      'You don\'t have permission to edit this post.';

  @override
  String get photoToCrop => 'Photo to crop';

  @override
  String get stories => 'Stories';

  @override
  String get feed => 'Feed';

  @override
  String get feedHint => 'From your groups and people you follow';

  @override
  String get feedEmpty =>
      'Your feed is empty. Posts from people and groups you follow appear here.';

  @override
  String get explore => 'Explore';

  @override
  String get searchHint => 'Search people or #hashtags';

  @override
  String get clear => 'Clear';

  @override
  String get exploreEmpty => 'Nothing new to explore. Check back a bit later.';

  @override
  String get refresh => 'Refresh';

  @override
  String get accounts => 'Accounts';

  @override
  String get hashtags => 'Hashtags';

  @override
  String noTagMatch(String query) {
    return 'No hashtags start with \"$query\".';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'There are no posts with #$tag that you can see.';
  }

  @override
  String get backToExplore => 'Back to Explore';

  @override
  String get saved => 'Saved';

  @override
  String get savedEmpty => 'Posts you save appear here, visible only to you.';

  @override
  String get post => 'Post';

  @override
  String get postGone =>
      'This post was deleted or you don\'t have permission to see it.';

  @override
  String get backToFeed => 'Back to feed';

  @override
  String get unmute => 'Unmute';

  @override
  String get mute => 'Mute';

  @override
  String get addedToSaved => 'Added to saved.';

  @override
  String get linkCopied => 'Post link copied.';

  @override
  String get deletePostTitle => 'Delete post?';

  @override
  String get deletePostBody =>
      'The post is deleted permanently, with its photos, videos and comments.';

  @override
  String get postDeleted => 'Post deleted.';

  @override
  String get likesHidden => 'Only you can see the like count.';

  @override
  String memoryOf(String title) {
    return 'Memory · $title';
  }

  @override
  String get deletedAccount => 'Deleted account';

  @override
  String get groupPost => 'Group post';

  @override
  String get edited => 'edited';

  @override
  String get moreOptions => 'More options';

  @override
  String get copyLink => 'Copy link';

  @override
  String get edit => 'Edit';

  @override
  String get like => 'Like';

  @override
  String get commentAction => 'Comment';

  @override
  String get unsave => 'Remove from saved';

  @override
  String reactionLabel(String emoji, int count) {
    return '$emoji reaction, $count';
  }

  @override
  String get more => 'more';

  @override
  String postWithCaption(String caption) {
    return 'Post: $caption';
  }

  @override
  String get showMore => 'Show more';

  @override
  String get addStory => 'Add story';

  @override
  String get yourStory => 'Your story';

  @override
  String get noStoriesLeft => 'There are no more stories for you here.';

  @override
  String get close => 'Close';

  @override
  String get removeFromHighlight => 'Remove from highlight';

  @override
  String get removedFromHighlight => 'Removed from highlight.';

  @override
  String get addToHighlights => 'Add to highlights';

  @override
  String get deleteStory => 'Delete story';

  @override
  String get storyDeleted => 'Story deleted.';

  @override
  String get options => 'Options';

  @override
  String get viewers => 'Viewers';

  @override
  String get noViewers =>
      'No one has seen it yet. Viewers appear here, visible only to you.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen by $count people',
      one: 'Seen by 1 person',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'Couldn\'t prepare the photo. Try another one.';

  @override
  String get storyShared =>
      'Your story is shared. It stays visible for 24 hours.';

  @override
  String get newStory => 'New story';

  @override
  String get addToStory => 'Add to your story';

  @override
  String get storyPickHint =>
      'Choose a photo or a video up to 60 seconds for your story.';

  @override
  String get pickAnother => 'Choose another';

  @override
  String get newHighlight => 'New highlight';

  @override
  String highlightCreated(String title) {
    return '\"$title\" created.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Added to \"$title\".';
  }

  @override
  String get highlightTitle => 'Highlight title';

  @override
  String get highlightExample => 'E.g. Camping 2026';

  @override
  String get addHighlight => 'Add highlight';

  @override
  String get renameHighlight => 'Rename';

  @override
  String get deleteHighlight => 'Delete highlight';

  @override
  String get staysInArchive => 'The stories stay in your archive.';

  @override
  String get storyArchive => 'Story archive';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories selected',
      one: '1 story selected',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Highlight';

  @override
  String get archiveEmpty =>
      'Stories you share are kept here after 24 hours, visible only to you.';

  @override
  String get shareStory => 'Share a story';

  @override
  String get archiveHint =>
      'Select stories to create a highlight or add to one.';

  @override
  String storyOn(String date) {
    return 'Story, $date';
  }

  @override
  String get live => 'Live';
}
