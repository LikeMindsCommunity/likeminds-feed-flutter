import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedDeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  // Creater SDK Client Info UUID
  final String uuid;
  final Function(String) action;
  final String actionText;

  const LMFeedDeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.uuid,
    required this.action,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool boolVarLoading = false;
    ValueNotifier<bool> rebuildReasonBox = ValueNotifier(false);
    DeleteReason? reasonForDeletion;
    bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
    // User Data of the logged in user
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;
    LMFeedThemeData feedTheme = LMFeedCore.theme;

    return Dialog(
      backgroundColor: feedTheme.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      elevation: 5,
      child: Container(
        width: screenSize.width * 0.7,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMFeedText(
                text: title,
                style: LMFeedTextStyle(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold))),
            LikeMindsTheme.kVerticalPaddingLarge,
            LMFeedText(text: content),
            currentUser.sdkClientInfo.uuid == uuid
                ? const SizedBox.shrink()
                : isCm
                    ? LikeMindsTheme.kVerticalPaddingLarge
                    : const SizedBox.shrink(),
            currentUser.sdkClientInfo.uuid == uuid
                ? const SizedBox.shrink()
                : isCm
                    ? Builder(builder: (context) {
                        return ValueListenableBuilder(
                            valueListenable: rebuildReasonBox,
                            builder: (context, _, __) {
                              return GestureDetector(
                                onTap: boolVarLoading
                                    ? () {}
                                    : () async {
                                        boolVarLoading = true;
                                        rebuildReasonBox.value =
                                            !rebuildReasonBox.value;

                                        LMFeedCore.client
                                            .getReportTags(
                                                ((GetDeleteReasonRequestBuilder()
                                                      ..type(0))
                                                    .build()))
                                            .then((value) {
                                          if (value.success) {
                                            List<DeleteReason> reportTags =
                                                value.reportTags!;

                                            showModalBottomSheet(
                                                context: context,
                                                elevation: 5,
                                                enableDrag: true,
                                                clipBehavior: Clip.hardEdge,
                                                backgroundColor:
                                                    feedTheme.container,
                                                useSafeArea: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(16.0),
                                                    topRight:
                                                        Radius.circular(16.0),
                                                  ),
                                                ),
                                                builder: (context) {
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 30.0),
                                                    width: screenSize.width,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                          child: LMFeedText(
                                                            text:
                                                                'Reason for deletion',
                                                            style:
                                                                LMFeedTextStyle(
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              textStyle:
                                                                  TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    LikeMindsTheme
                                                                        .kFontMedium,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        LikeMindsTheme
                                                            .kVerticalPaddingXLarge,
                                                        Expanded(
                                                          child: SafeArea(
                                                            child: ListView
                                                                .separated(
                                                              separatorBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            50),
                                                                child:
                                                                    const Divider(
                                                                  thickness:
                                                                      0.5,
                                                                  color: LikeMindsTheme
                                                                      .greyColor,
                                                                ),
                                                              ),
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    reasonForDeletion =
                                                                        reportTags[
                                                                            index];
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          color:
                                                                              Colors.transparent,
                                                                          width:
                                                                              35,
                                                                          child: Radio(
                                                                              value: reportTags[index].id,
                                                                              groupValue: reasonForDeletion == null ? -1 : reasonForDeletion!.id,
                                                                              onChanged: (value) {}),
                                                                        ),
                                                                        LikeMindsTheme
                                                                            .kHorizontalPaddingLarge,
                                                                        LMFeedText(
                                                                          text:
                                                                              reportTags[index].name,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              itemCount:
                                                                  reportTags
                                                                      .length,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).then((value) {
                                              rebuildReasonBox.value =
                                                  !rebuildReasonBox.value;
                                            });
                                          } else {
                                            LMFeedCore.showSnackBar(
                                              LMFeedSnackBar(
                                                content: LMFeedText(
                                                  text: value.errorMessage ??
                                                      "An error occurred",
                                                ),
                                              ),
                                            );
                                          }
                                          boolVarLoading = false;
                                          rebuildReasonBox.value =
                                              !rebuildReasonBox.value;
                                        });
                                      },
                                child: Container(
                                    padding: const EdgeInsets.all(14.0),
                                    decoration: BoxDecoration(
                                        color: feedTheme.container,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                            offset: Offset(0, 2),
                                            color: Colors.black12,
                                          )
                                        ]),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        LMFeedText(
                                          text: reasonForDeletion == null
                                              ? 'Reason for deletion'
                                              : reasonForDeletion!.name,
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: feedTheme.onContainer,
                                        )
                                      ],
                                    )),
                              );
                            });
                      })
                    : const SizedBox.shrink(),
            LikeMindsTheme.kVerticalPaddingSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: LMFeedText(
                    text: 'Cancel',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: feedTheme.onContainer.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (currentUser.sdkClientInfo.uuid != uuid &&
                        isCm &&
                        reasonForDeletion == null) {
                      LMFeedCore.showSnackBar(
                        LMFeedSnackBar(
                          content: LMFeedText(
                            text: 'Please select a reason for deletion',
                          ),
                        ),
                      );
                      return;
                    }
                    action(reasonForDeletion == null
                        ? ''
                        : reasonForDeletion!.name);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero,
                    ),
                  ),
                  child: LMFeedText(
                    text: actionText,
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: feedTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
