import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/CommentModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Screens/activity_list_page.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/CommentService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/comment_card2.dart';
import 'package:spotfinder/Widgets/user_card.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:share_plus/share_plus.dart';

late ActivityService activityService;
late CommentService commentService;
late UserService userService;
late List<User> users = [];
late List<User> commentUser = [];
late List<Comment> comments = [];
late User user;
late Activity activity;
late VoidCallback? onUpdate;

class ActivityDetail extends StatefulWidget {
  const ActivityDetail({Key? key}) : super(key: key);

  @override
  _ActivityDetail createState() => _ActivityDetail();
}

class _ActivityDetail extends State<ActivityDetail> {
  final ActivityDetailController controllerActivityDetail =
      Get.put(ActivityDetailController());

  bool isLoading = true;
  bool showReviewForm = false;
  bool alreadyCommented = false;
  late String activityId;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    alreadyCommented = false;
    userService = UserService();
    activityService = ActivityService();
    commentService = CommentService();
    activityId = Get.parameters['id']!;
    onUpdate = Get.arguments?['onUpdate'];
    getActivity();
  }

  Future<void> getActivity() async {
    try {
      activity = await activityService.getActivity(activityId);
      await getData(activity.listUsers?.length ?? 0);
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se han podido obtener los datos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print('Error al comunicarse con el backend: $error');
      }
    }
  }

  Future<void> getData(int length) async {
    List<User> fetchedUsers = [];
    try {
      if (userService.getToken() != null) {
        setState(() {
          isLoggedIn = true;
        });
      }

      for (var i = 0; i < length; i++) {
        final user = await userService.getAnotherUser(activity.listUsers?[i]);
        fetchedUsers.add(user);
      }
      await getComments();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se han podido obtener los datos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print('Error al comunicarse con el backend: $error');
      }
    }
  }

  Future<void> getComments() async {
    List<Comment> fetchedComments = [];
    List<User> fetchedUsers = [];

    for (var com in activity.comments!) {
      Comment comment = await commentService.getComment(com);
      fetchedComments.add(comment);
      User user = await userService.getAnotherUser(comment.user);
      fetchedUsers.add(user);

      if (comment.user == userService.getId()) {
        setState(() {
          alreadyCommented = true;
        });
      }
    }
    setState(() {
      comments = fetchedComments;
      commentUser = fetchedUsers;
    });
    await getUsers();
  }

  Future<void> getUsers() async {
    List<User> fetchedUsers = [];

    for (var com in comments) {
      User user = await userService.getAnotherUser(com.user);
      fetchedUsers.add(user);
    }
    setState(() {
      commentUser = fetchedUsers;
    });
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
                await commentService.deleteComment(id);
                setState(() {
                  comments.removeAt(index);
                  alreadyCommented = false;
                });
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
        setState(() {
          comments[index] = updatedComment;
        });
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: isLoggedIn
              ? Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Pallete.textColor,
                    ),
                    onPressed: () {
                      Get.to(const ActivityListPage());
                    },
                  ),
                )
              : null,
          title: Row(
            children: [
              Text(
                activity.name,
                style: TextStyle(
                  color: Pallete.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                iconSize: 30,
                color: Pallete.salmonColor,
                onPressed: () {
                  final formattedDate =
                      '${activity.date.day}/${activity.date.month}/${activity.date.year}';
                  final message =
                      'Echa un vistazo a este evento: *${activity.name}*\n'
                      'Fecha: 📅 $formattedDate\n'
                      'Más información: 🔗 ${Uri.base} ';
                  Share.share(message);
                },
                tooltip: 'Share',
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all( 30),
                  child: Column(
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: Pallete.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        activity.description,
                        style: TextStyle(
                          color: Pallete.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${activity.rate} ⭐',
                        style: TextStyle(
                          color: Pallete.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Pallete.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            if (isLoggedIn)
                              Column(
                                children: [
                                  Text(
                                    'Users participating',
                                    style: TextStyle(
                                      color: Pallete.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: activity.listUsers?.length ?? 0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        color: Pallete.paleBlueColor,
                                        child: UserCard(users[index].name, users[index].image),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SignUpButton(
                                    onPressed: () {
                                      controllerActivityDetail
                                          .joinActivity(activity.id);
                                      Get.to(const ActivityDetail());
                                    },
                                    text: 'Join',
                                  ),
                                ],
                              )
                            else
                              // Contenido alternativo si el usuario no ha iniciado sesión
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Sign in or register to participate!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.toNamed('/',
                                            arguments: {'id': activityId});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Pallete.salmonColor,
                                      ),
                                      child: const Text('Sign In/Register'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        'Reviews:',
                        style: TextStyle(
                          color: Pallete.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!alreadyCommented && isLoggedIn)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showReviewForm = !showReviewForm;
                                });
                              },
                              child: Card(
                                color: Pallete.primaryColor,
                                surfaceTintColor: Pallete.primaryColor,
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                                child: Card(
                                  color: Pallete.backgroundColor,
                                  child: Text(
                                    ' + Add ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Pallete.paleBlueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Visibility(
                            visible: showReviewForm,
                            child: Card(
                              color: Pallete.accentColor,
                              surfaceTintColor: Pallete.primaryColor,
                              elevation: 5,
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo de título
                                   Text(
                                      'Title:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: controllerActivityDetail.titleController,
                                      style: TextStyle(
                                          color: Pallete.textColor),
                                      decoration: InputDecoration(
                                        hintText: 'Enter title',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Campo de contenido
                                    Text(
                                      'Content:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: controllerActivityDetail
                                          .contentController,
                                      maxLines: 5,
                                      style: TextStyle(
                                          color: Pallete.backgroundColor),
                                      decoration: InputDecoration(
                                        hintText: 'Enter content',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Campo de revisión
                                    Text(
                                      'Review:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    RatingBar.builder(
                                      initialRating: 0.0,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 25.0,
                                      direction: Axis.horizontal,
                                      unratedColor:
                                          Colors.blueAccent.withAlpha(50),
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 25.0,
                                      ),
                                      onRatingUpdate: (rating) {
                                        setState(() {
                                          controllerActivityDetail.ratingValue =
                                              rating;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    // Botones de enviar y cancelar
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Botón de enviar
                                        ElevatedButton(
                                          onPressed: () {
                                            controllerActivityDetail
                                                .activityId = activity.id!;
                                            controllerActivityDetail
                                                .addComment()
                                                .then((success) {
                                              if (success) {
                                                setState(() {
                                                  alreadyCommented = true;
                                                  getUsers();
                                                  showReviewForm =
                                                      !showReviewForm;
                                                  controllerActivityDetail
                                                      .contentController
                                                      .clear();
                                                  controllerActivityDetail
                                                      .titleController
                                                      .clear();
                                                  controllerActivityDetail
                                                      .ratingValue = 0;
                                                });
                                                onUpdate!();
                                              }
                                            });
                                          },
                                          child: const Text('Submit'),
                                        ),
                                        const SizedBox(width: 16),
                                        // Botón de cancelar
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              showReviewForm = !showReviewForm;
                                            });
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Pallete.salmonColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= comments.length ||
                                  index >= commentUser.length) {
                                return const SizedBox.shrink();
                              }
                              bool isOwner =
                                  comments[index].user == userService.getId();
                              return Card(
                                color: Pallete.backgroundColor,
                                child: CommentCard(
                                  comment: comments[index],
                                  onDelete: confirmDeleteComment,
                                  onUpdate: updateComment,
                                  index: index,
                                  isOwner: isOwner,
                                  user: commentUser[index],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Position: ${activity.location?.latitude}, ${activity.location?.longitude}',
                  style: TextStyle(
                    color: Pallete.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class ActivityDetailController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String activityId = '';
  double ratingValue = 0.0;

  void joinActivity(String? id) {
    activityService.joinActivity(id);
  }

  Future<bool> addComment() async {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        ratingValue == 0.0) {
      Get.snackbar(
        'Error',
        'Campos vacíos',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } else {
      Comment newComment = Comment(
        title: titleController.text,
        content: contentController.text,
        user: userService.getId()!,
        activity: activityId,
        review: ratingValue,
      );
      try {
        final comment = await commentService.createComment(newComment);
        comments.add(comment!);
        return true;
      } catch (error) {
        Get.snackbar(
          'Error',
          'Los datos introducidos son incorrectos. Prueba otra vez.',
          snackPosition: SnackPosition.BOTTOM,
        );
        if (kDebugMode) {
          print('Error al enviar create in al backend: $error');
        }
        return false;
      }
    }
  }
}
