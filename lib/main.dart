import 'dart:async';

import 'package:chat_2022/Pages/chat_page.dart';
import 'package:chat_2022/widgets/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //Cria e inicializa uma instância do aplicativo Firebase.
  runApp(MyApp());
  //listen, toda vez que algum dado for alterado ele chama o metodo implementado em listen, Receber atualizações em tempo real
/*
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> snapshot = FirebaseFirestore.instance.collection('mensagens').doc('5eqZJpPBGEch3KDDVsMR').snapshots().listen((event) {
    print(event.data());
  });
  */
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat 2022",
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700
        )
      ),
      home: ChatPage(),
    );
  }
}
