import 'package:flutter/material.dart';

//Importar bliblioteca http
import 'package:http/http.dart' as http;

//Fazer requisicoes e não esperar tanto tempo
import 'dart:async';
import 'dart:convert';

//URL requisicao API conversor moeda
const request = 'https://api.hgbrasil.com/finance?key=b7c4c09d';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    //Tema widget
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

//Funcao que retorna um dado futuro que retorna um mapa
Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //Declarando Controlador
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  //Declarando variaveis que serão inicializadas mais tarde
  late double dolar;
  late double euro;

  //Funcao alterar valor real
  void _realChanged(String text){
    //Verifica se o texto está vazio e limpa todos os campos
    if(text.isEmpty) {
      dolarController.text = '';
      euroController.text = '';
      return;
    }
    //Pegar valor real digitado
    double real = double.parse(text);
    //converter valor de rel para dolar ou euro
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);

  }

  //Funcao alterar valor dolar
  void _dolarChanged(String text){
    if(text.isEmpty){
      realController.text = '';
      euroController.text = '';
    }
    //Pegar valor dolar digitado
    double dolar = double.parse(text);
    //converter valor de dolar para real ou euro
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }

  //Funcao alterar valor euro
  void _euroChanged(String text){
    if(text.isEmpty){
      realController.text = '';
      dolarController.text = '';
    }
    //Pegar valor dolar digitado
    double euro = double.parse(text);
    //converter valor de euro para real ou dolar
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('\$ Conversor \$'),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      'Carregando Dados...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao Carregar Dados :(',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0,
                        ),
                      ),
                    );
                  } else {
                    //Retornando variaveis
                    dolar =
                        snapshot.data!['results']['currencies']['USD']['buy'];
                    euro =
                        snapshot.data!['results']['currencies']['EUR']['buy'];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        //Centraliar icone
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber,
                          ),
                          //Separando o TextFild
                          Divider(),
                          //Buscando funcao texto conversor de moedas
                          buildTextField('Reais', 'R\$', realController, _realChanged),

                          //Separando o TextFild
                          Divider(),
                          buildTextField('Dólares', 'US\$', dolarController, _dolarChanged),

                          //Separando o TextFild
                          Divider(),
                          buildTextField('Euros', '€', euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

//Funcao para criar texto conversor de moedas
Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function f){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: (texto){
      f(texto);
    },
    //Deixar teclado apenas com numero
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}