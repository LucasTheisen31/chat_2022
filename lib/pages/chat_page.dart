import 'dart:io';

import 'package:chat_2022/pages/loading_page.dart';
import 'package:chat_2022/widgets/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/chatMensagem.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _usuarioAtual;
  bool _enviandoImg = false;

  @override
  initState() {
    super.initState();
    //ouvir as alterações do estado de autenticação, usuario logado, desconectado=null
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _usuarioAtual = user;
      });
    }
    );
  }

  Future<User?> _pegarUsuario() async {
    //funcao responsavel pelo login com conta do google
    if (_usuarioAtual != null)
      return _usuarioAtual; //se ja tiver um usuario logado no firebase somente retorna ele
    //senao faz um novo login
    try {
      //pega a conta logada na conta do google
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      //pega os dados de autenticação
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      //credenciais necessarias p/fazer login no firebase com conta do google
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(
              authCredential); //faz login no firebase com conta do google
      final User? user = userCredential.user; //pega o ususario do firebase
      return user;
    } catch (er) {
      print(er);
      return null;
    }
  }

  void _enviarMensagem({String? text, XFile? imageFile}) async {
    final User? user =
        await _pegarUsuario(); //obtem o usuario logado ou faz o login
    if (user == null) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            "Não foi possivel fazer o login. Tenta novamente!",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    Map<String, dynamic> data = {
      'uid' : user!.uid,
      'senderNome' : user.displayName,
      'senderPerfilImage' : user.photoURL,
      'senderEmail': user.email,
      'time' : Timestamp.now(),
    };

    //verifica se a imagem é nula e a envia
    if (imageFile != null) {
      File file = File(imageFile
          .path); //converte o imageFile que vem em formato XFile para o formato File, para fazer upload
      //nome do arquivo vai ser a data atual para nao repetir os nomes
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("PastaImages")
          .child(user.uid)
          .child(
            DateTime.now().microsecondsSinceEpoch.toString(),
          )
          .putFile(file);

      setState(() {
        _enviandoImg = true;
      });

      TaskSnapshot taskSnapshot = await task;
      String url =
          await taskSnapshot.ref.getDownloadURL(); //url para baixar a imagem
      data['imgUrl'] =
          url; //adiciona um campo imgUrl ao mapa e adiciona a url da imagem

      setState(() {
        _enviandoImg = false;
      });
    }

    //verifica se o texto e nulo e o envia
    if (text != null) {
      data['texto'] = text; //adiciona um campo text ao mapa e adiciona o texto
    }

    FirebaseFirestore.instance
        .collection('mensagens')
        .add(data); //envia o mapa ao firebase na coleçao mensagens
  }

  void _deslogar() {
    //desloga do firebase
    FirebaseAuth.instance.signOut();
    //desloga do google
    googleSignIn.signOut();

    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Text("Você saiu com sucesso!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/perfil.jpg'),
          ),
        ),
        title: Text(_usuarioAtual != null
            ? 'Olá, ${_usuarioAtual!.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        actions: [
          _usuarioAtual != null
              ? IconButton(
                  onPressed: () {
                    _deslogar();
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                  ),
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //Widget que se constrói sempre que alguma coisa muda
              stream: FirebaseFirestore.instance
                  .collection('mensagens').orderBy('time')
                  .snapshots(),
              //retorna os dados sempre que ouver alguam modificação
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return LoadingPage();
                  default:
                    List<DocumentSnapshot> listaDocumentos =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                        //ListView.builder significa que vai carregando os dados conforme vai rolando a listView
                        itemCount: listaDocumentos.length,
                        reverse: true, //para carregar de baixo para cima
                        itemBuilder: (context, index) {
                          return ChatMensagem(
                            dado: listaDocumentos[index].data()
                                as Map<String, dynamic>,
                            estouenviando: listaDocumentos[index]['uid'] == _usuarioAtual?.uid,
                          ); //chama a classe chatMensagem passando o dado da mensagem
                        });
                }
              },
            ),
          ),
          _enviandoImg ? LinearProgressIndicator() : Container(),
          SizedBox(
            height: 55,
            child: TextComposer(_enviarMensagem),
          ),
        ],
      ),
    );
  }
}
