import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TripFormPage extends StatefulWidget {
  const TripFormPage({super.key});

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _origenController = TextEditingController();
  final List<TextEditingController> _paisControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _nochesControllers =
      List.generate(3, (_) => TextEditingController());
  String _tipoViaje = 'económico';
  bool _enviando = false;

  Future<Map<String, dynamic>> consultarViaje(Map<String, dynamic> viaje) async {
    final url = Uri.parse('https://mi-backend.onrender.com/multi_estimate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(viaje),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al consultar el backend: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador de Viajes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _origenController,
                decoration: const InputDecoration(labelText: 'País de origen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el país de origen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Destinos (máx 3)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(3, (i) {
                return Column(
                  children: [
                    TextFormField(
                      controller: _paisControllers[i],
                      decoration: InputDecoration(labelText: 'Destino ${i + 1}'),
                    ),
                    TextFormField(
                      controller: _nochesControllers[i],
                      decoration: InputDecoration(labelText: 'Noches en destino ${i + 1}'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _tipoViaje,
                items: ['económico', 'moderado', 'generoso']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoViaje = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de viaje'),
              ),
              const SizedBox(height: 30),
              _enviando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        List<Map<String, dynamic>> destinos = [];
                        for (int i = 0; i < 3; i++) {
                          if (_paisControllers[i].text.isNotEmpty &&
                              _nochesControllers[i].text.isNotEmpty) {
                            destinos.add({
                              "pais": _paisControllers[i].text,
                              "noches": int.tryParse(_nochesControllers[i].text) ?? 1,
                            });
                          }
                        }

                        if (destinos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Agrega al menos un destino')));
                          return;
                        }

                        final viaje = {
                          "origen": _origenController.text,
                          "destinos": destinos,
                          "tipo": _tipoViaje
                        };

                        setState(() {
                          _enviando = true;
                        });

                        try {
                          final resultado = await consultarViaje(viaje);

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Resultado'),
                              content: Text(
                                  "Total estimado: ${resultado['total']} USD\nRecomendación: ${resultado['recomendacion']}"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                )
                              ],
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        } finally {
                          setState(() {
                            _enviando = false;
                          });
                        }
                      },
                      child: const Text('Consultar viaje'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
