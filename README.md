# LikeMinds Feed SDK for Flutter

Drop-in social feed for Flutter apps, on mobile and web. Posts, comments, likes, polls and topics,
in social, Q&A or video form.

[![pub](https://img.shields.io/pub/v/likeminds_feed_flutter_core.svg)](https://pub.dev/packages/likeminds_feed_flutter_core)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

**Docs:** https://docs.likeminds.io/

## What you get

Universal and personalised feeds · posts with text, images, video, documents and PDFs, link previews,
polls and custom widgets · comments with nested replies · likes with liker lists · topics and
topic-filtered feeds · @-mentions · save, pin, hide, repost, share with deep links · search ·
activity feed · report and a pending-post moderation queue · background upload with retry ·
push notifications.

Beyond that: **feedrooms** with list, explore, join and leave, a **guest flow**, user connections and
block list, and **Flutter web support**.

## Install

```yaml
dependencies:
  likeminds_feed_flutter_core: ^1.17.1
```

This is a **Melos monorepo**. Two published packages live inside it:

| Package | Path | What it is |
|---|---|---|
| `likeminds_feed_flutter_core` | `packages/integration` | Screens, 17 BLoCs, deep-link handler, media and S3 services |
| `likeminds_feed_flutter_ui` | `packages/ui` | Widgets and theme |

The data layer is a separate package:

```yaml
  likeminds_feed: ^1.21.0
```

Source at [likeminds-feed-flutter-data](https://github.com/LikeMindsCommunity/likeminds-feed-flutter-data).

## Customising

Every screen takes `builder`, `style`, `settings` and `config` overrides, so you can change
appearance and behaviour without subclassing. Three worked examples:
[social-dark](https://github.com/LikeMindsCommunity/likeminds-feed-flutter-social-dark) (heaviest),
[surassa](https://github.com/LikeMindsCommunity/likeminds-feed-flutter-surassa),
[koshiqa](https://github.com/LikeMindsCommunity/likeminds-feed-flutter-koshiqa) (lightest).

## Samples

`example/` for the social feed, `example_video_feed/` for the reels-style feed.

## Requirements

Melos scripts test-build against Flutter 3.19, 3.22 and 3.24.

## Contributing

See the org-wide [contributing guide](https://github.com/LikeMindsCommunity/.github/blob/main/.github/CONTRIBUTING.md).
Security issues go to **natesh@likeminds.community**, not the issue tracker.

## License

Apache 2.0. See [LICENSE](LICENSE).
