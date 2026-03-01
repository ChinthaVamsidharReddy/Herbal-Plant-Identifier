// import 'package:flutter/material.dart';

// class ChatBubble extends StatelessWidget {
//   final String text;
//   final bool isUser;
//   final VoidCallback? onSpeak;

//   const ChatBubble({
//     super.key,
//     required this.text,
//     required this.isUser,
//     this.onSpeak,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment:
//           isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ⭐ BOT AVATAR
//         if (!isUser)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               backgroundImage: const AssetImage('assets/images/bot.png'),
//               radius: 18,
//             ),
//           ),

//         // ⭐ BUBBLE
//         Flexible(
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: isUser ? Colors.green : Colors.grey.shade200,
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(18),
//                 topRight: const Radius.circular(18),
//                 bottomLeft: Radius.circular(isUser ? 18 : 0),
//                 bottomRight: Radius.circular(isUser ? 0 : 18),
//               ),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 4,
//                 )
//               ],
//             ),

//             // ⭐ CONTENT + SPEAK
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: isUser ? Colors.white : Colors.black87,
//                   ),
//                 ),

//                 // ⭐ SPEAK BUTTON ONLY FOR BOT
//                 if (!isUser && onSpeak != null)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: IconButton(
//                       icon: const Icon(Icons.volume_up, size: 18),
//                       onPressed: onSpeak,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final VoidCallback? onSpeak;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ Bot avatar (ONLY for bot)
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/bot.png'),
                radius: 18,
              ),
            ),

          // ⭐ Bubble
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),

                  // ⭐ Speak icon (clean placement)
                  if (!isUser && onSpeak != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.volume_up,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: onSpeak,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}