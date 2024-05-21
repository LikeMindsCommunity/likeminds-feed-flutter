import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

Future<void> submitVote(
  BuildContext context,
  LMAttachmentMetaViewData attachmentMeta,
  List<String> options,
  String postId,
  Map<String, bool> isVoteEditing,
  LMAttachmentMetaViewData previousValue,
  ValueNotifier<bool> rebuildPostWidget,
  LMFeedWidgetSource source,
) async {
  try {
    if (hasPollEnded(attachmentMeta.expiryTime!)) {
      LMFeedCore.showSnackBar(
        context,
        "Poll ended. Vote can not be submitted now.",
        source,
      );
      resetOptions(attachmentMeta, previousValue);
      return;
    }
    if (isPollSubmitted(attachmentMeta.options!) &&
        isInstantPoll(attachmentMeta.pollType!)) {
      resetOptions(attachmentMeta, previousValue);
      return;
    } else {
      if (isMultiChoicePoll(
          attachmentMeta.multiSelectNo!, attachmentMeta.multiSelectState!)) {
        if (attachmentMeta.multiSelectState! == PollMultiSelectState.exactly &&
            options.length != attachmentMeta.multiSelectNo) {
          LMFeedCore.showSnackBar(
            context,
            "Please select exactly ${attachmentMeta.multiSelectNo} options",
            source,
          );
          rebuildPostWidget.value = !rebuildPostWidget.value;
          return;
        } else if (attachmentMeta.multiSelectState! ==
                PollMultiSelectState.atLeast &&
            options.length < attachmentMeta.multiSelectNo!) {
          LMFeedCore.showSnackBar(
            context,
            "Please select at least ${attachmentMeta.multiSelectNo} options",
            source,
          );
          return;
        } else if (attachmentMeta.multiSelectState! ==
                PollMultiSelectState.atMax &&
            options.length > attachmentMeta.multiSelectNo!) {
          LMFeedCore.showSnackBar(
            context,
            "Please select at most ${attachmentMeta.multiSelectNo} options",
            source,
          );
          return;
        }
      }
      isVoteEditing["value"] = false;
      int totalVotes = attachmentMeta.options?.fold(0,
              (previousValue, element) => previousValue! + element.voteCount) ??
          0;
      for (int i = 0; i < attachmentMeta.options!.length; i++) {
        if (options.contains(attachmentMeta.options![i].id)) {
          attachmentMeta.options![i].isSelected = true;
          attachmentMeta.options![i].voteCount++;
          totalVotes++;
          attachmentMeta.options![i].percentage =
              (attachmentMeta.options![i].voteCount / totalVotes) * 100;
        } else if (previousValue.options![i].isSelected) {
          attachmentMeta.options![i].isSelected = false;
          attachmentMeta.options![i].voteCount--;
          totalVotes--;
          attachmentMeta.options![i].percentage =
              (attachmentMeta.options![i].voteCount / totalVotes) * 100;
        }
      }
      rebuildPostWidget.value = !rebuildPostWidget.value;
      SubmitPollVoteRequest request = (SubmitPollVoteRequestBuilder()
            ..pollId(attachmentMeta.id ?? '')
            ..votes([...options]))
          .build();
      final response = await LMFeedCore.client.submitPollVote(request);
      if (!response.success) {
        for (int i = 0; i < options.length; i++) {
          int index = attachmentMeta.options!
              .indexWhere((element) => element.id == options[i]);
          if (index != -1) {
            attachmentMeta.options![index].isSelected = false;
            attachmentMeta.options![index].voteCount--;
            attachmentMeta.options![index].percentage =
                (attachmentMeta.options![index].voteCount / totalVotes) * 100;
          }
        }

        attachmentMeta = previousValue;
        resetOptions(attachmentMeta, previousValue);
        LMFeedCore.showSnackBar(
          context,
          response.errorMessage ?? "",
          source,
        );
      } else {
        LMFeedCore.showSnackBar(
          context,
          "Vote submitted successfully",
          source,
        );
        PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
              ..postId(postId)
              ..pageSize(10)
              ..page(1))
            .build();
        final postResponse =
            await LMFeedCore.client.getPostDetails(postDetailRequest);

        final Map<String, LMWidgetViewData> widgets = postResponse.widgets?.map(
                (key, value) => MapEntry(
                    key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
            {};

        final Map<String, LMTopicViewData> topics =
            postResponse.topics?.map((key, value) => MapEntry(
                    key,
                    LMTopicViewDataConvertor.fromTopic(
                      value,
                      widgets: widgets,
                    ))) ??
                {};

        final Map<String, LMUserViewData> users =
            postResponse.users?.map((key, value) => MapEntry(
                    key,
                    LMUserViewDataConvertor.fromUser(
                      value,
                      widgets: widgets,
                    ))) ??
                {};

        final Map<String, LMPostViewData> repostedPosts =
            postResponse.repostedPosts?.map((key, value) => MapEntry(
                    key,
                    LMPostViewDataConvertor.fromPost(
                      post: value,
                      users: users,
                      widgets: widgets,
                      topics: topics,
                      userTopics: postResponse.userTopics,
                    ))) ??
                {};

        final postViewData = LMPostViewDataConvertor.fromPost(
          post: postResponse.post!,
          users: users,
          widgets: widgets,
          repostedPosts: repostedPosts,
          topics: topics,
          userTopics: postResponse.userTopics,
        );

        LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
          post: postViewData,
          actionType: LMFeedPostActionType.pollSubmit,
          postId: postId,
        ));
      }
    }
  } on Exception catch (e) {
    int totalVotes = attachmentMeta.options?.fold(0,
            (previousValue, element) => previousValue! + element.voteCount) ??
        0;
    for (int i = 0; i < options.length; i++) {
      int index = attachmentMeta.options!
          .indexWhere((element) => element.id == options[i]);
      if (index != -1) {
        attachmentMeta.options![index].isSelected = false;
        attachmentMeta.options![index].voteCount--;
        attachmentMeta.options![index].percentage =
            (attachmentMeta.options![index].voteCount / totalVotes) * 100;
      }
    }

    attachmentMeta = previousValue;
    resetOptions(attachmentMeta, previousValue);
    LMFeedCore.showSnackBar(
      context,
      e.toString(),
      source,
    );
  }
}

void resetOptions(LMAttachmentMetaViewData attachmentMeta,
    LMAttachmentMetaViewData previousValue) {
  attachmentMeta = previousValue;
}

bool showTick(
    LMAttachmentMetaViewData attachmentMeta,
    LMPollOptionViewData option,
    List<String> selectedOption,
    bool isVoteEditing) {
  // if (isPollSubmitted(attachmentMeta.options!)) {
  //   return false;
  // }
  if (isVoteEditing) {
    return selectedOption.contains(option.id);
  }
  if ((isMultiChoicePoll(attachmentMeta.multiSelectNo!,
                  attachmentMeta.multiSelectState!) ==
              true ||
          isInstantPoll(attachmentMeta.pollType!) == false) &&
      option.isSelected == true) {
    return true;
  } else {
    return false;
  }
}

bool showAddOptionButton(LMAttachmentMetaViewData attachmentMeta) {
  bool isAddOptionAllowedForInstantPoll =
      isInstantPoll(attachmentMeta.pollType) &&
          !isPollSubmitted(attachmentMeta.options!);
  bool isAddOptionAllowedForDeferredPoll =
      !isInstantPoll(attachmentMeta.pollType);

  if (attachmentMeta.allowAddOption != null &&
      attachmentMeta.allowAddOption! &&
      !hasPollEnded(attachmentMeta.expiryTime) &&
      (isAddOptionAllowedForInstantPoll || isAddOptionAllowedForDeferredPoll)) {
    if (attachmentMeta.options!.length < 10) return true;
  }
  return false;
}

bool showSubmitButton(LMAttachmentMetaViewData attachmentMeta) {
  if (isPollSubmitted(attachmentMeta.options!)) {
    return false;
  }
  if ((attachmentMeta.pollType != null &&
          isInstantPoll(attachmentMeta.pollType!) &&
          isPollSubmitted(attachmentMeta.options!)) ||
      hasPollEnded(attachmentMeta.expiryTime)) {
    return false;
  } else if (!isMultiChoicePoll(
      attachmentMeta.multiSelectNo, attachmentMeta.multiSelectState)) {
    return false;
  } else
    return true;
}

Future<void> addOption(
    BuildContext context,
    LMAttachmentMetaViewData attachmentMeta,
    String option,
    String postId,
    LMUserViewData? currentUser,
    ValueNotifier<bool> rebuildPostWidget,
    LMFeedWidgetSource source) async {
  if ((attachmentMeta.options?.length ?? 0) > 10) {
    LMFeedCore.showSnackBar(
      context,
      "You can add up to 10 options",
      source,
    );
    return;
  }
  AddPollOptionRequest request = (AddPollOptionRequestBuilder()
        ..pollId(attachmentMeta.id ?? '')
        ..text(option))
      .build();

  final response = await LMFeedCore.client.addPollOption(request);
  if (response.success) {
    final poll = LMAttachmentMetaViewDataConvertor.fromWidgetModel(
        widget: response.data!.widget!,
        users: {
          currentUser!.uuid: currentUser,
        });
    attachmentMeta.options!.removeLast();
    attachmentMeta.options!.add(poll.options!.last);
    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        actionType: LMFeedPostActionType.addPollOption,
        postId: postId,
        pollOption: attachmentMeta.options));
    LMFeedCore.showSnackBar(
      context,
      "Option added successfully",
      source,
    );
  }
}

bool isPollSubmitted(List<LMPollOptionViewData> options) {
  return options.any((element) => element.isSelected);
}

bool hasPollEnded(int? expiryTime) {
  return expiryTime != null &&
      DateTime.now().millisecondsSinceEpoch > expiryTime;
}

String getTimeLeftInPoll(int? expiryTime) {
  if (expiryTime == null) {
    return "";
  }
  DateTime expiryTimeInDateTime =
      DateTime.fromMillisecondsSinceEpoch(expiryTime);
  DateTime now = DateTime.now();
  Duration difference = expiryTimeInDateTime.difference(now);
  if (difference.isNegative) {
    return "Poll Ended";
  }
  if (difference.inDays > 0) {
    return "${difference.inDays}d left";
  } else if (difference.inHours > 0) {
    return "${difference.inHours}h left";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes}m left";
  } else {
    return "Just Now";
  }
}

String? getPollSelectionText(
    PollMultiSelectState? pollMultiSelectState, int? pollMultiSelectNo) {
  if (pollMultiSelectNo == null || pollMultiSelectState == null) {
    return null;
  }
  switch (pollMultiSelectState) {
    case PollMultiSelectState.exactly:
      if (pollMultiSelectNo == 1) {
        return null;
      } else {
        return "*Select exactly $pollMultiSelectNo options";
      }
    case PollMultiSelectState.atMax:
      return "*Select at most $pollMultiSelectNo options";
    case PollMultiSelectState.atLeast:
      return "*Select at least $pollMultiSelectNo options";
    default:
      return null;
  }
}

bool isInstantPoll(PollType? pollType) {
  return pollType != null && pollType == PollType.instant;
}

bool isMultiChoicePoll(
    int? pollMultiSelectNo, PollMultiSelectState? pollMultiSelectState) {
  if (pollMultiSelectNo == null || pollMultiSelectState == null) {
    return false;
  }
  if (pollMultiSelectState == PollMultiSelectState.exactly &&
      pollMultiSelectNo == 1) {
    return false;
  }
  return true;
}

String getFormattedDateTime(int expiryTime) {
  DateTime expiryTimeInDateTime =
      DateTime.fromMillisecondsSinceEpoch(expiryTime);
  String formattedDateTime =
      DateFormat('d MMM y hh:mm a').format(expiryTimeInDateTime);
  return "Expires on $formattedDateTime";
}

void onVoteTextTap(BuildContext context,
    LMAttachmentMetaViewData attachmentMeta, LMFeedWidgetSource source,
    {LMPollOptionViewData? option}) {
  if (attachmentMeta.isAnonymous ?? false) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        surfaceTintColor: Colors.transparent,
        children: [
          LMFeedText(
            text:
                'This being an anonymous poll, the names of the voters can not be disclosed.',
            style: LMFeedTextStyle(
              maxLines: 3,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ],
        contentPadding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 8,
        ),
      ),
    );
  } else if (attachmentMeta.toShowResult! ||
      hasPollEnded(attachmentMeta.expiryTime!)) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LMFeedPollResultScreen(
          pollId: attachmentMeta.id ?? '',
          pollOptions: attachmentMeta.options ?? [],
          selectedOptionId: option?.id,
        ),
      ),
    );
  } else {
    LMFeedCore.showSnackBar(
      context,
      "The results will be visible after the poll has ended.",
      source,
    );
  }
}
