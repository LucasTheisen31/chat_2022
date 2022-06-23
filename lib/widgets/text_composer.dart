import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this._enviarMensagem); //construtor

  final Function({String? text, XFile? imageFile}) _enviarMensagem; //funcao

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _digitando = false;
  TextEditingController _controllerTextFild = TextEditingController();

  void _resetarCampoDeTexto() {
    _controllerTextFild.clear();
    setState(() {
      _digitando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Material(
                  elevation: 2,
                  shape: StadiumBorder(),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _menuSelecaoCameraGaleria(context);
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.blueGrey,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controllerTextFild,
                            onChanged: (value) {
                              setState(() {
                                _digitando = value.isNotEmpty;
                              });
                            },
                            onSubmitted: (value) {
                              //Chamado quando o usuário indica que terminou de editar o texto no campo (enviar do teclado)
                              if(value.isNotEmpty){
                                widget._enviarMensagem(text: value);
                                _resetarCampoDeTexto();
                              }
                            },
                            decoration: InputDecoration.collapsed(
                                border: InputBorder.none,
                                hintText: 'Enviar uma Mensagem'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              ClipOval(
                child: Material(
                  color: Colors.teal.shade700,
                  child: InkWell(
                    onTap: _digitando
                        ? () {
                            widget._enviarMensagem(text: _controllerTextFild.text);
                            _resetarCampoDeTexto();
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.send,
                        color: _digitando ? Colors.white : Colors.white24,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _menuSelecaoCameraGaleria(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(//safe area por conta da area dos botoes do android em baixo
            child: Container(
              child: Wrap(
                //Um widget que exibe seus filhos em várias execuções horizontais ou verticais.
                children: [
                  ListTile(
                    title: Text('Camera'),
                    leading: Icon(Icons.camera_alt),
                    onTap: _pegarImageCamera,
                  ),
                  ListTile(
                    title: Text("Galeria"),
                    leading: Icon(Icons.photo_library),
                    onTap: _pegarImageGaleria,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _pegarImageCamera() async {
    ImagePicker().pickImage(source: ImageSource.camera).then(
          (value) {
        if (value == null) {
          return;
        } else {
          setState(() {
            widget._enviarMensagem(imageFile: value);
          });
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> _pegarImageGaleria() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then(
          (value) {
        if (value == null) {
          return;
        } else {
          setState(() {
            widget._enviarMensagem(imageFile: value);
          });
          Navigator.of(context).pop();
        }
      },
    );
  }
}
