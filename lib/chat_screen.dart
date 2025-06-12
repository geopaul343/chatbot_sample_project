import 'dart:convert';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chatbot_sample_project/message.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

// ChatScreen widget to display a chatbot interface
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controllers for text input and scrolling
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  // List to store chat messages
  List<Message> msgs = [];

  // Tracks if the bot is typing
  bool isTyping = false;

  // Function to send a message and get a response from Gemini API
  void sendMsg() async {
    String text = controller.text;
    String apiKey =
        "AIzaSyDriyxqH16j2oqAHZ6fPkbzZ4_sOQ1fHKo"; // User's Gemini API key
    controller.clear();

    try {
      if (text.isNotEmpty) {
        // Add user message to the list and show typing indicator
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });

        // Scroll to the top of the chat
        scrollController.animateTo(
          0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );

        // Send the message to Gemini API
        var response = await http.post(
          Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": text},
                ],
              },
            ],
          }),
        );

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          print(response.body);
          setState(() {
            isTyping = false;
            msgs.insert(
              0,
              Message(
                false,
                json["candidates"][0]["content"]["parts"][0]["text"]
                    .toString()
                    .trim(),
              ),
            );
          });

          // Scroll to the top of the chat
          scrollController.animateTo(
            0.0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
          );
        } else {
          // Handle non-200 responses
          print('API Error: ${response.statusCode}');
          print('API Response: ${response.body}');
          setState(() {
            isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error from API: ${response.statusCode} ${response.body}",
              ),
            ),
          );
        }
      }
    } on Exception catch (e) {
      // Show error message if API call fails
      print(e);
      setState(() {
        isTyping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Some error occurred, please try again! Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini ChatBot"),
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Chat messages list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  final message = msgs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child:
                        isTyping && index == 0
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                BubbleNormal(
                                  text: message.msg,
                                  isSender: true,
                                  color: Colors.white,
                                  textStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Typing...",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : BubbleNormal(
                              text: message.msg,
                              isSender: message.isSender,
                              color:
                                  message.isSender
                                      ? Colors.white
                                      : Colors.indigo.shade700,
                              textStyle: TextStyle(
                                color:
                                    message.isSender
                                        ? Colors.black87
                                        : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                  );
                },
              ),
            ),
            // Input field and send button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (value) {
                            sendMsg();
                          },
                          textInputAction: TextInputAction.send,
                          showCursor: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter text",
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      sendMsg();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
