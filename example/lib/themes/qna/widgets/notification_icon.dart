import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  Future<GetUnreadNotificationCountResponse>? getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // This function fetches the unread notification count
  // and updates the respective future
  void updateUnreadNotificationCount() async {
    getUnreadNotificationCount = LMFeedCore.client.getUnreadNotificationCount();
    await getUnreadNotificationCount;
    _rebuildAppBar.value = !_rebuildAppBar.value;
  }

  @override
  void initState() {
    super.initState();
    updateUnreadNotificationCount();
  }

  @override
  void didUpdateWidget(NotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedCore.theme;
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LMFeedNotificationScreen(),
          ),
        );

        updateUnreadNotificationCount();
      },
      child: ValueListenableBuilder(
        valueListenable: _rebuildAppBar,
        builder: (context, _, __) {
          return FutureBuilder<GetUnreadNotificationCountResponse>(
            future: getUnreadNotificationCount,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.success) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    snapshot.data!.count! > 0
                        ? Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: theme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                snapshot.data!.count.toString(),
                                style: TextStyle(
                                    color: theme.onPrimary, fontSize: 8),
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                );
              }
              return const Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [Icon(Icons.notifications_outlined)],
              );
            },
          );
        },
      ),
    );
  }
}
