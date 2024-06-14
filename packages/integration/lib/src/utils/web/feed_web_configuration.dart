/// {@template lm_feed_web_configuration}
/// [LMFeedWebConfiguration] to configure the web feed
/// [maxWidth] to set the maximum width of the feed
/// [maxWidgetForDialog] to set the maximum width of the widget for dialog
/// [maxWidthForSnackBars] to set the maximum width of the snack bars
/// {@endtemplate}
class LMFeedWebConfiguration {
  final double maxWidth;
  final double maxWidgetForDialog;
  final double maxWidthForSnackBars;

  /// {@macro lm_feed_web_configuration}
  const LMFeedWebConfiguration({
    this.maxWidth = 600.0,
    this.maxWidgetForDialog = 400.0,
    this.maxWidthForSnackBars = 400.0,
  });

  /// {@template lm_feed_web_configuration_copywith}
  /// [copyWith] to create a new instance of [LMFeedWebConfiguration]
  /// with the provided values
  /// {@endtemplate}
  LMFeedWebConfiguration copyWith({
    double? maxWidth,
    double? maxWidgetForDialog,
    double? maxWidthForSnackBars,
  }) {
    return LMFeedWebConfiguration(
      maxWidth: maxWidth ?? this.maxWidth,
      maxWidgetForDialog: maxWidgetForDialog ?? this.maxWidgetForDialog,
      maxWidthForSnackBars: maxWidthForSnackBars ?? this.maxWidthForSnackBars,
    );
  }

  /// {@template lm_feed_web_configuration_basic}
  /// [basic] to create a new instance of [LMFeedWebConfiguration]
  /// with the provided values
  /// {@endtemplate}
  factory LMFeedWebConfiguration.basic(
      {double? maxWidth,
      double? maxWidgetForDialog,
      double? maxWidthForSnackBars}) {
    return LMFeedWebConfiguration(
      maxWidth: maxWidth ?? 600.0,
      maxWidgetForDialog: maxWidgetForDialog ?? 400.0,
      maxWidthForSnackBars: maxWidthForSnackBars ?? 400.0,
    );
  }
}
