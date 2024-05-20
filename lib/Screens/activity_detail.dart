import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/CommentModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/CommentService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/comment_card2.dart';
import 'package:spotfinder/Widgets/user_card.dart';
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;
late CommentService commentService;
late UserService userService;
late List<User> users = [];
late List<User> commentUser = [];
late List<Comment> comments = [];
late User user;

class ActivityDetail extends StatefulWidget {
  final Activity activity;
  const ActivityDetail(this.activity, {Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivityDetail createState() => _ActivityDetail();
}

class _ActivityDetail extends State<ActivityDetail> {
  final ActivityDetailController controllerActivityDetail =
      Get.put(ActivityDetailController());
  // ignore: non_constant_identifier_names

  bool isLoading = true;
  bool showReviewForm = false;
  bool alreadyCommented = false;

  @override
  void initState() {
    super.initState();
    alreadyCommented = false;
    userService = UserService();
    activityService = ActivityService();
    commentService = CommentService();
    final listLength = widget.activity.listUsers?.length ?? 0;
    user =
        User(name: '', email: '', phone_number: '', gender: '', password: '');
    getData(listLength);
  }

  void getData(int length) async {
    try {
      for (var i = 0; i < length; i++) {
        user = await userService.getAnotherUser(widget.activity.listUsers?[i]);
        users.add(user);
      }
      await getComments();
      setState(() {
        isLoading =
            false; // Cambiar el estado de carga cuando los datos están disponibles
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

    for (var com in widget.activity.comments!) {
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
    // Añadido async
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
                // Añadido async
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
      // Muestra un indicador de carga mientras se cargan los datos
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.whiteColor,
          title: Center(
            widthFactor: 5,
            child: Text(
              widget.activity.name,
              style: const TextStyle(
                color: Pallete.backgroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Pallete.backgroundColor,
              ),
              onPressed: () {
                Get.to(() => HomePage());
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: Column(
                    children: [
                      const Text(
                        'Description:',
                        style: TextStyle(
                          color: Pallete.backgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.activity.name,
                        style: const TextStyle(
                          color: Pallete.backgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.activity.rate} ⭐',
                        style: const TextStyle(
                          color: Pallete.backgroundColor,
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
                            const Text(
                              'Users participating',
                              style: TextStyle(
                                color: Pallete.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.activity.listUsers?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  color: Pallete.whiteColor,
                                  child: UserCard(users[index].name),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SignUpButton(
                              onPressed: () => controllerActivityDetail
                                  .joinActivity(widget.activity.id),
                              text: 'Join',
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Reviews:',
                        style: TextStyle(
                          color: Pallete.backgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!alreadyCommented)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showReviewForm = !showReviewForm;
                                });
                              },
                              child: const Card(
                                color: Pallete.backgroundColor,
                                surfaceTintColor: Pallete.accentColor,
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                                child: Card(
                                  color: Pallete.paleBlueColor,
                                  child: Text(
                                    ' + Add ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Pallete.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          Visibility(
                            visible: showReviewForm,
                            child: Card(
                              color: Pallete.primaryColor,
                              surfaceTintColor: Pallete.accentColor,
                              elevation: 5,
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo de título
                                    const Text(
                                      'Title:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: controllerActivityDetail
                                          .titleController,
                                      style: const TextStyle(
                                          color: Pallete.backgroundColor),
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
                                    SizedBox(height: 16),
                                    // Campo de contenido
                                    const Text(
                                      'Content:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: controllerActivityDetail
                                          .contentController,
                                      maxLines: 5,
                                      style: const TextStyle(
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
                                    SizedBox(height: 16),
                                    // Campo de revisión
                                    const Text(
                                      'Review:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Pallete.paleBlueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    RatingBar.builder(
                                      initialRating: 0,
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
                                          controllerActivityDetail.ratingValue = rating;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    // Botones de enviar y cancelar
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Botón de enviar
                                        ElevatedButton(
                                          onPressed: () {
                                            controllerActivityDetail.activityId = widget.activity.id!;
                                            controllerActivityDetail.addComment().then((_) {
                                              setState(() {
                                                alreadyCommented = true;
                                                getUsers();
                                                showReviewForm = !showReviewForm;
                                              });
                                            });
                                          },
                                          child: Text('Submit'),
                                        ),
                                        SizedBox(width: 16),
                                        // Botón de cancelar
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              showReviewForm = !showReviewForm;
                                            });
                                          },
                                          child: const Text(
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
                                return SizedBox.shrink();
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

  Future<void> addComment() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacíos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Comment newComment = Comment(
        title: titleController.text,
        content: contentController.text,
        user: userService.getId()!,
        activity: activityId,
        review: ratingValue,
      );
      await commentService.createComment(newComment).then((comment) {
        comments.add(comment!);
        print(comments);
      }).catchError((error) {
        Get.snackbar(
          'Error',
          'Los datos introducidos son incorrectos. Prueba otra vez.',
          snackPosition: SnackPosition.BOTTOM,
        );
        if (kDebugMode) {
          print('Error al enviar create in al backend: $error');
        }
      });
    }
  }
}
