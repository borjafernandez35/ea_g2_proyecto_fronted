// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/snackbar/snackbar.dart';
// import 'package:spotfinder/Models/ActivityModel.dart';
// import 'package:spotfinder/Models/CommentModel.dart';
// import 'package:spotfinder/Models/UserModel.dart';
// import 'package:spotfinder/Resources/pallete.dart';
// import 'package:spotfinder/Services/ActivityService.dart';
// import 'package:spotfinder/Services/CommentService.dart';
// import 'package:spotfinder/Widgets/comment_card.dart';

// late ActivityService activityService;
// late CommentService commentService;

// class MyCommentsScreen extends StatefulWidget {
//   final User user;
//   final VoidCallback onUpdate;
//   const MyCommentsScreen(this.user, {super.key, required this.onUpdate});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MyCommentsScreen createState() => _MyCommentsScreen();
// }

// class _MyCommentsScreen extends State<MyCommentsScreen> {
//   // ignore: non_constant_identifier_names
//   late List<Comment> lista_comments;
//   late List<Activity> lista_activities;

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     activityService = ActivityService();
//     commentService = CommentService();
//     lista_comments = widget.user.comments!;
//     getData();
//   }

//   void getData() async {
//     List<Activity> fetchedActivities = [];
//     for (var comment in lista_comments) {
//       Activity activity = await activityService.getActivity(comment.activity);
//       fetchedActivities.add(activity);
//     }

//     setState(() {
//       lista_activities = fetchedActivities;
//       isLoading = false;
//     });
//   }

//   void confirmDeleteComment(BuildContext context, String id, int index) async {
//     // Añadido async
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Deletion'),
//           content: const Text('Are you sure you want to delete your review?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Añadido async
//                 Navigator.of(context).pop();
//                 await commentService.deleteComment(id);
//                 widget.onUpdate;
//                 setState(() {
//                   lista_comments.removeAt(index);
//                   isLoading = true;
//                 });
//                 getData();
//               },
//               child: const Text('Delete review'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void updateComment(Comment updatedComment, int index) {
//     if (updatedComment.title.isEmpty || updatedComment.content.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Empty fields',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } else {
//       commentService.updateComment(updatedComment).then((statusCode) {
//         Get.snackbar(
//           'Review edited!',
//           'Review edited successfully',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         widget.onUpdate();
//         setState(() {
//           lista_comments[index] = updatedComment;
//           isLoading = true;
//         });
//         getData();
//       }).catchError((error) {
//         Get.snackbar(
//           'Error',
//           'Error sending review to backend: $error',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Center(child: CircularProgressIndicator());
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Pallete.whiteColor,
//           iconTheme: IconThemeData(color: Pallete.backgroundColor),
//           title: const Text(
//             'My reviews',
//             style: TextStyle(
//                 color: Pallete.backgroundColor), // Color del texto del app bar
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemBuilder: (BuildContext context, int index) {
//               return Card(
//                 color: Pallete.backgroundColor,
//                 child: CommentCard(
//                   activity: lista_activities[index],
//                   comment: lista_comments[index],
//                   onDelete: confirmDeleteComment,
//                   onUpdate: updateComment,
//                   index: index,
//                 ),
//               );
//             },
//             itemCount: lista_comments.length,
//           ),
//         ),
//       );
//     }
//   }
// }
