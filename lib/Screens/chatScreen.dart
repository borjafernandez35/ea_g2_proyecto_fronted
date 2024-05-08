import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = Color(0xFF6c5ce7);
  Color black = Color(0xFF191919);
  TextEditingController msgInputController=TextEditingController();


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(flex: 9, 
            child:  Container(
              child: ListView.builder(itemBuilder: (context, index){
                return MessageItem(sentByMe: true,);
              }),
            )),
            Expanded(child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.red,
              child: TextField(
                style: TextStyle(
                  color: Colors.white),
                  cursorColor: purple,
                controller: msgInputController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),

                      color: purple,
                    ),
                    child: IconButton(onPressed: (){sendMessage(msgInputController.text);
                    msgInputController.text = "";
                    }, icon: Icon(Icons.send) ),
                  )
                ),
              ),

            )),
          ],
        ),
      ),
     
    );
  }
  
  void sendMessage(String text) {}
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe});
  const bool sentByMe;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
