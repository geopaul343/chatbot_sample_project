class Message {
    // Indicates whether the message was sent by the user (true) or received (false).
    final bool isSender;
    
    // The content of the message as a string.
    final String msg;
    
    // Constructor to initialize the Message object with the sender status and message content.
    Message(this.isSender, this.msg);
}