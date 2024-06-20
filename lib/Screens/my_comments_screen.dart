import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/CommentService.dart';
import 'package:spotfinder/Widgets/comment_card.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/CommentModel.dart';

late ActivityService activityService;
late CommentService commentService;

class MyCommentsScreen extends StatefulWidget {
  final User user;
  final VoidCallback onUpdate;

  const MyCommentsScreen(this.user, {Key? key, required this.onUpdate})
      : super(key: key);

  @override
  _MyCommentsScreenState createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends State<MyCommentsScreen>
    with SingleTickerProviderStateMixin {
  late List<Comment> lista_comments = [];
  late List<Activity> lista_activities = [];
  late List<String> comments_id = [];
  late AnimationController _controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    activityService = ActivityService();
    commentService = CommentService();
    comments_id = widget.user.comments ?? [];
    getData();
  }

  void getData() async {
    try {
      List<Comment> fetchedComments = [];
      for (var com in comments_id) {
        Comment comment = await commentService.getComment(com);
        fetchedComments.add(comment);
      }
      if (mounted) {
        setState(() {
          lista_comments = fetchedComments;
        });
      }
      await getActivities();
    } catch (error) {
      // Handle error
      print('Error fetching comments: $error');
    }
  }

  Future<void> getActivities() async {
    try {
      List<Activity> fetchedActivities = [];
      for (var comment in lista_comments) {
        Activity activity = await activityService.getActivity(comment.activity);
        fetchedActivities.add(activity);
      }
      if (mounted) {
        setState(() {
          lista_activities = fetchedActivities;
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle error
      print('Error fetching activities: $error');
    }
  }

  void confirmDeleteComment(BuildContext context, String id, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete your review?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await commentService.deleteComment(id);
                  if (mounted) {
                    setState(() {
                      lista_comments.removeAt(index);
                      isLoading = true;
                    });
                  }
                  await getActivities();
                  widget.onUpdate();
                } catch (error) {
                  print('Error deleting comment: $error');
                  // Handle error
                }
              },
              child: const Text('Delete review'),
            ),
          ],
        );
      },
    );
  }

  void updateComment(Comment updatedComment, int index) {
    if (updatedComment.title.isEmpty || updatedComment.content.isEmpty) {
      Get.snackbar(
        'Error',
        'Empty fields',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      commentService.updateComment(updatedComment).then((statusCode) {
        Get.snackbar(
          'Review edited!',
          'Review edited successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        widget.onUpdate();
        if (mounted) {
          setState(() {
            lista_comments[index] = updatedComment;
            isLoading = true;
          });
        }
        getActivities();
      }).catchError((error) {
        Get.snackbar(
          'Error',
          'Error sending review to backend: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Container(
          color: Pallete.backgroundColor,
          child: RotationTransition(
            turns: _controller,
            child: Image.asset(
              'assets/spotfinder.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.backgroundColor,
          iconTheme: IconThemeData(color: Pallete.textColor),
          title: Text(
            'My reviews',
            style: TextStyle(color: Pallete.textColor),
          ),
        ),
        body: lista_comments.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You have not written any reviews yet',
                    style: TextStyle(
                      color: Pallete.textColor.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Pallete.backgroundColor,
                      child: CommentCard(
                        activity: lista_activities[index],
                        comment: lista_comments[index],
                        onDelete: confirmDeleteComment,
                        onUpdate: updateComment,
                        index: index,
                      ),
                    );
                  },
                  itemCount: lista_comments.length,
                ),
              ),
      );
    }
  }
}

