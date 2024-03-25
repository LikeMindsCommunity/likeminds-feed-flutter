// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:likeminds_feed/likeminds_feed.dart';
// import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

// class LMFeedReportScreen extends StatefulWidget {
//   final String entityId; // post, comment, reply id
//   final String entityCreatorId;
//   final int entityType;

//   const LMFeedReportScreen({
//     Key? key,
//     required this.entityId,
//     required this.entityCreatorId,
//     required this.entityType,
//   }) : super(key: key);

//   @override
//   State<LMFeedReportScreen> createState() => _LMFeedReportScreenState();
// }

// class _LMFeedReportScreenState extends State<LMFeedReportScreen> {
//   Future<GetDeleteReasonResponse>? getReportTagsFuture;
//   TextEditingController reportReasonController = TextEditingController();
//   Set<int> selectedTags = {};
//   DeleteReason? deleteReason;

//   @override
//   void initState() {
//     GetDeleteReasonRequest request =
//         (GetDeleteReasonRequestBuilder()..type(3)).build();
//     super.initState();
//     getReportTagsFuture = LMFeedCore.client.getReportTags(request);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     reportReasonController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = LMFeedCore.theme;
//     return Scaffold(
//       appBar: LMFeedAppBar(
//         style: LMFeedAppBarStyle(
//           backgroundColor: theme.container,
//           centerTitle: Platform.isAndroid ? false : true,
//           height: 50,
//         ),
//         title: const LMFeedText(
//           text: 'Report',
//           style: LMFeedTextStyle(
//             textStyle: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     const SizedBox(
//                       height: 24,
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.0),
//                       child: LMFeedText(
//                           text:
//                               'Thank you for looking out for yourself and your fellow Suraasa users by reporting what violates the rules. Let us know what’s happening, and we’ll look into it.',
//                           style: LMFeedTextStyle(
//                             textStyle: TextStyle(
//                               fontSize: 16,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w400,
//                             ),
//                             overflow: TextOverflow.visible,
//                           )),
//                     ),
//                     const SizedBox(
//                       height: 24,
//                     ),
//                     FutureBuilder<GetDeleteReasonResponse>(
//                         future: getReportTagsFuture,
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return CircularProgressIndicator(
//                               color: theme.primaryColor,
//                             );
//                           } else if (snapshot.connectionState ==
//                                   ConnectionState.done &&
//                               snapshot.hasData &&
//                               snapshot.data!.success == true) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16.0, vertical: 4),
//                               child: Wrap(
//                                   spacing: 24.0,
//                                   alignment: WrapAlignment.start,
//                                   runAlignment: WrapAlignment.start,
//                                   crossAxisAlignment: WrapCrossAlignment.start,
//                                   children: snapshot.data!.reportTags != null &&
//                                           snapshot.data!.reportTags!.isNotEmpty
//                                       ? snapshot.data!.reportTags!
//                                           .map(
//                                             (e) => GestureDetector(
//                                               onTap: () {
//                                                 setState(
//                                                   () {
//                                                     if (selectedTags
//                                                         .contains(e.id)) {
//                                                       selectedTags.remove(e.id);
//                                                       deleteReason = null;
//                                                     } else {
//                                                       selectedTags = {e.id};
//                                                       deleteReason = e;
//                                                     }
//                                                   },
//                                                 );
//                                               },
//                                               child: Chip(
//                                                 label: LMFeedText(
//                                                   text: e.name,
//                                                   style: LMFeedTextStyle(
//                                                     textStyle: const TextStyle(
//                                                       fontSize: 16,
//                                                       fontFamily: 'Inter',
//                                                       fontWeight:
//                                                           FontWeight.w400,
//                                                     ).copyWith(
//                                                       fontSize: 14,
//                                                       color: selectedTags
//                                                               .contains(e.id)
//                                                           ? Colors.white
//                                                           : Colors.black,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 backgroundColor:
//                                                     selectedTags.contains(e.id)
//                                                         ? theme.primaryColor
//                                                         : theme.container,
//                                                 // color:
//                                                 //     MaterialStateProperty.all(
//                                                 //         Colors.transparent),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           12.0),
//                                                   side: BorderSide(
//                                                     color: selectedTags
//                                                             .contains(e.id)
//                                                         ? theme.primaryColor
//                                                         : Colors.black,
//                                                   ),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 16.0),
//                                                 labelPadding: EdgeInsets.zero,
//                                                 elevation: 0,
//                                               ),
//                                             ),
//                                           )
//                                           .toList()
//                                       : []),
//                             );
//                           } else {
//                             return const SizedBox();
//                           }
//                         }),
//                     // kVerticalPaddingLarge,
//                     deleteReason != null &&
//                             (deleteReason!.name.toLowerCase() == 'others' ||
//                                 deleteReason!.name.toLowerCase() == 'other')
//                         ? Container(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 24.0, vertical: 16),
//                             child: TextField(
//                               cursorColor: Colors.black,
//                               style: const TextStyle(
//                                 color: Colors.black,
//                               ),
//                               controller: reportReasonController,
//                               decoration: InputDecoration(
//                                 fillColor: theme.primaryColor,
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide(
//                                     color: theme.primaryColor,
//                                   ),
//                                 ),
//                                 focusColor: theme.primaryColor,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide(
//                                     color: theme.primaryColor,
//                                   ),
//                                 ),
//                                 labelText: 'Reason',
//                                 labelStyle: theme.contentStyle.textStyle,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide(
//                                     color: theme.primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : const SizedBox()
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//               child: LMFeedButton(
//                 style: LMFeedButtonStyle(
//                   height: 48,
//                   backgroundColor: selectedTags.isEmpty
//                       ? theme.primaryColor.withOpacity(0.2)
//                       : theme.primaryColor,
//                   borderRadius: 12,
//                 ),
//                 text: LMFeedText(
//                   text: 'Submit',
//                   style: LMFeedTextStyle(
//                     textStyle: TextStyle(
//                         color: selectedTags.isEmpty
//                             ? theme.primaryColor
//                             : theme.container,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 onTap: () async {
//                   String? reason = reportReasonController.text.trim();
//                   if (deleteReason != null &&
//                       (deleteReason!.name.toLowerCase() == 'others' ||
//                           deleteReason!.name.toLowerCase() == 'other')) {
//                     if (reason.isEmpty) {
//                       toast('Please specify a reason for reporting');
//                       return;
//                     }
//                   }
//                   if (selectedTags.isNotEmpty) {
//                     Navigator.of(context).pop();
//                     PostReportRequest postReportRequest =
//                         (PostReportRequestBuilder()
//                               ..entityCreatorId(widget.entityCreatorId)
//                               ..entityId(widget.entityId)
//                               ..entityType(widget.entityType)
//                               ..reason(
//                                   reason.isEmpty ? deleteReason!.name : reason)
//                               ..tagId(deleteReason!.id))
//                             .build();
//                     PostReportResponse response =
//                         await LMFeedCore.client.postReport(postReportRequest);
//                     if (!response.success) {
//                       toast(response.errorMessage ?? 'An error occured');
//                     } else {
//                       toast(
//                           '${widget.entityType == 5 ? 'Post' : widget.entityType == 6 ? 'Comment' : 'Reply'} reported');
//                     }
//                   } else {
//                     toast('Please select a reason');
//                     return;
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
