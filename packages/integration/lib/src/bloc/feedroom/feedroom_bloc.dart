import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'feedroom_event.dart';
part 'feedroom_state.dart';

class LMFeedRoomBloc extends Bloc<LMFeedRoomEvent, LMFeedRoomState> {
  // list of selected topics by the user
  List<LMTopicViewData> selectedTopics = [];
  // list of all the topics
  Map<String, LMTopicViewData> topics = {};
// list of all the users
  Map<String, LMUserViewData> users = {};
  // list of all the widgets
  Map<String, LMWidgetViewData> widgets = {};

  static LMFeedRoomBloc? _instance;

  static LMFeedRoomBloc get instance => _instance ??= LMFeedRoomBloc._();

  LMFeedRoomBloc._() : super(LMFeedRoomInitialState()) {
    on<LMFeedRoomEvent>((event, emit) async {
      if (event is LMFeedGetFeedRoomEvent) {
        await _mapLMGetFeedRoomToState(event: event, emit: emit);
      }
      if (event is LMFeedGetFeedRoomListEvent) {
        await _mapLMGetFeedRoomListToState(event: event, emit: emit);
      }
    });
  }

  FutureOr<void> _mapLMGetFeedRoomToState({
    required LMFeedGetFeedRoomEvent event,
    required Emitter<LMFeedRoomState> emit,
  }) async {
    Map<String, LMUserViewData> users = {};
    Map<String, LMTopicViewData> topics = {};
    Map<String, LMWidgetViewData> widgets = {};

    if (state is LMFeedRoomLoadedState) {
      LMFeedRoomLoadedState prevState = state as LMFeedRoomLoadedState;
      users = prevState.users;
      topics = prevState.topics;
      widgets = prevState.widgets;

      emit(LMFeedRoomPaginationLoadingState(
        posts: prevState.posts,
        users: prevState.users,
        widgets: prevState.widgets,
        topics: prevState.topics,
        feedRoom: prevState.feedRoom,
      ));
    } else {
      emit(LMFeedRoomLoadingState());
    }

    GetFeedOfFeedRoomResponse response =
        await LMFeedCore.client.getFeedOfFeedRoom(
      (GetFeedOfFeedRoomRequestBuilder()
            ..feedroomId(event.feedRoomId)
            ..topicIds(selectedTopics.map((e) => e.id).toList())
            ..page(event.offset)
            ..pageSize(10))
          .build(),
    );
    if (!response.success) {
      emit(
        LMFeedRoomErrorState(
          message: response.errorMessage ?? 'An error occurred',
        ),
      );
    }

    users.addAll(
      response.users.map(
        (key, value) => MapEntry(
          key,
          LMUserViewDataConvertor.fromUser(value),
        ),
      ),
    );

    topics.addAll(
      response.topics.map(
        (key, value) =>
            MapEntry(key, LMTopicViewDataConvertor.fromTopic(value)),
      ),
    );

    GetFeedRoomResponse feedRoomResponse = await LMFeedCore.client.getFeedRoom(
      (GetFeedRoomRequestBuilder()
            ..feedroomId(event.feedRoomId)
            ..page(event.offset))
          .build(),
    );
    if (!feedRoomResponse.success) {
      emit(
        LMFeedRoomErrorState(
          message: feedRoomResponse.errorMessage ?? 'An error occurred',
        ),
      );
    }

    // widgets.addAll(response.widgets.map((key, value) =>
    //         MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)),),);

    emit(
      LMFeedRoomLoadedState(
        feedRoom: LMFeedRoomViewDataConvertor.fromFeedRoomModel(
            feedRoomModel: feedRoomResponse.chatroom!),
        topics: topics,
        posts: response.posts
                ?.map((e) => LMPostViewDataConvertor.fromPost(
                      post: e,
                      // widgets: response.widgets,
                      // repostedPosts: response.repostedPosts,
                      users: response.users.map((key, value) => MapEntry(
                          key, LMUserViewDataConvertor.fromUser(value))),
                      topics: response.topics.map((key, value) => MapEntry(
                          key, LMTopicViewDataConvertor.fromTopic(value))),
                      // filteredComments: response.filteredComments,
                      // userTopics: response.userTopics,
                    ))
                .toList() ??
            [],
        users: users,
        widgets: widgets,
        pageKey: event.offset,
      ),
    );
  }
}

FutureOr<void> _mapLMGetFeedRoomListToState({
  required LMFeedGetFeedRoomListEvent event,
  required Emitter<LMFeedRoomState> emit,
}) async {
  try {
    GetFeedRoomResponse response = await LMFeedCore.client.getFeedRoom(
      (GetFeedRoomRequestBuilder()..page(event.offset)).build(),
    );

    if (response.success) {
      final List<LMFeedRoomViewData> feedList = response.chatrooms!
          .map((e) =>
              LMFeedRoomViewDataConvertor.fromFeedRoomModel(feedRoomModel: e))
          .toList();
      emit(
        LMFeedRoomListLoadedState(
          feedList: feedList,
          size: feedList.length,
        ),
      );
    } else {
      emit(
        LMFeedRoomListErrorState(
            message:
                response.errorMessage ?? "An error occured, please try again"),
      );
    }
  } catch (e) {
    emit(
      LMFeedRoomListErrorState(message: "${e.toString()} No data found"),
    );
  }
  try {
    GetFeedRoomResponse response = await LMFeedCore.client.getFeedRoom(
      (GetFeedRoomRequestBuilder()..page(event.offset)).build(),
    );

    if (response.success) {
      final List<LMFeedRoomViewData> feedList = response.chatrooms!
          .map(
            (e) => LMFeedRoomViewDataConvertor.fromFeedRoomModel(
              feedRoomModel: e,
            ),
          )
          .toList();
      emit(
        LMFeedRoomListLoadedState(
          feedList: feedList,
          size: feedList.length,
        ),
      );
    } else {
      emit(
        LMFeedRoomListErrorState(
            message:
                response.errorMessage ?? "An error occured, please try again"),
      );
    }
  } catch (e) {
    emit(
      LMFeedRoomListErrorState(message: "${e.toString()} No data found"),
    );
  }
}

//   LMFeedRoomBloc._() : super(LMFeedRoomInitialState()) {
//     on<LMFeedRoomEvent>((event, emit) async {
//       Map<String, LMUserViewData> users = {};
//       Map<String, LMTopicViewData> topics = {};
//       if (state is LMFeedRoomLoadedState) {
//         users = (state as LMFeedRoomLoadedState).users;
//         topics = (state as LMFeedRoomLoadedState).topics;
//       }
//       if (event is LMFeedGetFeedRoomEvent) {
//         event.isPaginationLoading
//             ? emit(LMFeedRoomPaginationLoadingState())
//             : emit(LMFeedRoomLoadingState());
//         try {
//           List<Topic> selectedTopics = [];
//           if (event.topics != null && event.topics!.isNotEmpty) {
//             selectedTopics = event.topics!
//                 .map((e) => LMTopicViewDataConvertor.toTopic(e))
//                 .toList();
//           }
//           GetFeedOfFeedRoomResponse response =
//               await LMFeedCore.client.getFeedOfFeedRoom(
//             (GetFeedOfFeedRoomRequestBuilder()
//                   ..feedroomId(event.feedRoomId)
//                   ..topicIds(selectedTopics.map((e) => e.id).toList())
//                   ..page(event.offset)
//                   ..pageSize(10))
//                 .build(),
//           );
//           if (!response.success) {
//             emit(
//               LMFeedRoomErrorState(
//                 message: response.errorMessage ?? 'An error occurred',
//               ),
//             );
//           }
          
//           );
//           if (!feedRoomResponse.success) {
//             emit(
//               LMFeedRoomErrorState(
//                 message: feedRoomResponse.errorMessage ?? 'An error occurred',
//               ),
//             );
//           }
//           response.users.addAll(users);
//           response.topics.addAll(topics);
//           if ((response.posts == null || response.posts!.isEmpty) &&
//               event.offset <= 1) {
//             emit(
//               LMFeedRoomEmptyState(
//                 feedRoom: feedRoomResponse.chatroom!,
//                 feed: response,
//               ),
//             );
//           } else {
//             emit(
//               LMFeedRoomLoadedState(
//                 feed: response,
//                 feedRoom: feedRoomResponse.chatroom!,
//               ),
//             );
//           }
//         } catch (e) {
//           emit(
//             const LMFeedRoomErrorState(
//               message: 'An error occurred',
//             ),
//           );
//         }
//       }

//       if (event is LMFeedGetFeedRoomListEvent) {
//         emit(LMFeedRoomListLoadingState());
        
//       }
//     });
//   }
// }
