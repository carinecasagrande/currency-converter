import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() async {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response =
      await http.get(Uri.parse("https://api.hgbrasil.com/finance"));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    text = text.replaceAll(RegExp(","), ".");

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    text = text.replaceAll(RegExp(","), ".");

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    text = text.replaceAll(RegExp(","), ".");

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), onPressed: _clearAll)
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text('Carregando Dados!',
                      style: TextStyle(color: Colors.amber, fontSize: 25)),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar os dados.',
                        style: TextStyle(color: Colors.amber, fontSize: 25)),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: buildTextField(
                              "Real", "R\$", realController, _realChanged),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: buildTextField(
                              "Dólar", "US\$", dolarController, _dolarChanged),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: buildTextField(
                              "Euro", "€", euroController, _euroChanged),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: Text(
                            "${now.day}/${now.month.toString().padLeft(2, '0')}/${now.year} às ${now.hour}:${now.minute}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 15),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "US\$1 = R\$${dolar.toStringAsFixed(2)}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.amber, fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "€1 = R\$${euro.toStringAsFixed(2)}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.amber, fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController controller, Function function) {
    return TextField(
      controller: controller,
      onChanged: (String value) {
        function(value);
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 0),
          ),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.amber, fontSize: 25)),
      style: const TextStyle(color: Colors.amber, fontSize: 25),
    );
  }
}
