import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMensagem extends StatelessWidget {
  const ChatMensagem(
      {Key? key, required this.dado, required this.estouenviando})
      : super(key: key);

  final Map<String, dynamic> dado;
  final bool estouenviando;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: estouenviando ? Colors.green.shade300 : Colors.white),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
        child: Row(
          children: [
            !estouenviando
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(dado['senderPerfilImage']),
                    ),
                  )
                : Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: estouenviando
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  dado['imgUrl'] != null
                      ? Image.network(
                          dado['imgUrl'],
                          width: 200,
                        )
                      : Text(
                          dado['texto'],
                          style: TextStyle(fontSize: 18),
                          textAlign:
                              estouenviando ? TextAlign.end : TextAlign.start,
                        ),
                  Text(
                    dado['senderNome'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            estouenviando
                ? Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(dado['senderPerfilImage']),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
