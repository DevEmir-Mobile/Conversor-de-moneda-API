import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConversorAmount extends StatefulWidget {
  const ConversorAmount({super.key});

  @override
  State<ConversorAmount> createState() => _ConversorAmountState();
}

class _ConversorAmountState extends State<ConversorAmount> {
  TextEditingController controller = TextEditingController();
  double convertedAmount = 0.0;
  double? exchangeRate;
  Map<String, dynamic>? currencies;
  bool isLoading = true;
  String? selectedCurrency;
  String? selectedCurrencyTo;

  @override
  void initState() {
    super.initState();
    selectedCurrency = 'USD';
    selectedCurrencyTo = 'EUR';
    fetchCurrencies();
    fetchCurrencyFlags();
  }

Future<void> fetchCurrencies() async {
  final response = await http.get(
    Uri.parse('https://openexchangerates.org/api/latest.json?app_id=f299c960f2ab4856831d4a9df432d94d'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Datos recibidos: $data'); // Depuración
    setState(() {
      currencies = data['rates']; // Asignamos solo el mapa de tasas
      isLoading = false;
    });
  } else {
    throw Exception('Error al cargar las monedas');
  }
}

  void convertCurrency() {
    if (exchangeRate == null || controller.text.isEmpty) return;

    double amount = double.tryParse(controller.text) ?? 0.0;
    setState(() {

    
      convertedAmount = (amount * exchangeRate!);
      convertedAmount = (convertedAmount * 100);
    });
  }

  Map<String, String> currencyFlagMap = {};



// Función que consulta la REST Countries API y construye el mapa
Future<void> fetchCurrencyFlags() async {
  final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    for (var country in data) {
      // Verificamos que el país tenga información de monedas
      if (country['currencies'] != null && country['flags'] != null) {
        // La estructura de 'currencies' puede variar; para la API v3.1 se maneja como un mapa
        // Ejemplo: "currencies": { "USD": {"name": "United States dollar", "symbol": "\$"} }
        (country['currencies'] as Map<String, dynamic>).forEach((code, details) {
          // Si existe la bandera (por ejemplo, en country['flags']['png'])
          if (country['flags'] != null && country['flags']['png'] != null) {
            // Si aún no tenemos una bandera para este código, la asignamos
            if (!currencyFlagMap.containsKey(code)) {
              currencyFlagMap[code] = country['flags']['png'];
            }
          }
        });
      }
    }
     print('Mapa de banderas cargado: $currencyFlagMap'); 
     setState(() {});
  } else {
    throw Exception('Error al obtener datos de la REST Countries API');
  }
}

String getFlagUrl(String currencyCode) {
  return currencyFlagMap[currencyCode] ??
      'https://flagcdn.com/24x18/${currencyCode.substring(0, 2).toLowerCase()}.png';
}


Future<void> fetchExchangeRate() async {
  if (selectedCurrency == null || selectedCurrencyTo == null) return;

  final response = await http.get(
    Uri.parse('https://openexchangerates.org/api/latest.json?app_id=f299c960f2ab4856831d4a9df432d94d'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final rates = data['rates'];

    print('Tasas de cambio recibidas: $rates');

    if (rates.containsKey(selectedCurrency) && rates.containsKey(selectedCurrencyTo)) {
      setState(() {
        // Conversión real: se divide la tasa de la moneda destino por la tasa de la moneda origen
        exchangeRate = (rates[selectedCurrencyTo] as num).toDouble() / (rates[selectedCurrency] as num).toDouble();
        print('Tasa de cambio calculada (real): $exchangeRate');
      });
    } else {
      print('No se encontró una tasa para las monedas seleccionadas');
    }
  } else {
    throw Exception('Error al obtener la tasa de cambio');
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [

                Row(
                  children: [
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : DropdownButton<String>(
                              value: selectedCurrency,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text("Seleccionar Moneda",
                                  style: TextStyle(fontSize: 10)),
                              items: currencies?.entries.map((entry) {
                                print('Añadiendo moneda: ${entry.key}');
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        getFlagUrl(entry.key),
                                        width: 16,
                                        height: 12,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const SizedBox(
                                              width: 16, height: 12);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${entry.key}',
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrency = value;
                                });
                              },
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF3C3C3C),
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botón de conversión
                FloatingActionButton(
                  onPressed: () async {
                    await fetchExchangeRate();
                    convertCurrency();
                  },
                  child: const Icon(Icons.swap_vert),
                ),

                const SizedBox(height: 20),

                // Segunda fila: Moneda destino y resultado
                Row(
                  children: [
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : DropdownButton<String>(
                              value: selectedCurrencyTo,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text("Seleccionar Moneda",
                                  style: TextStyle(fontSize: 10)),
                              items: currencies?.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        getFlagUrl(entry.key),
                                        width: 16,
                                        height: 12,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const SizedBox(
                                              width: 16, height: 12);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${entry.key}',
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrencyTo = value;
                                });
                              },
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEEEEEE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        child: Text(
                          convertedAmount.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Color(0xFF3C3C3C),
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tasa de cambio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Indicative Exchange Rate',
                      style: TextStyle(
                        color: Color(0xFFA1A1A1),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${selectedCurrency ?? '$selectedCurrency'} = ${convertedAmount.toStringAsFixed(2) ?? '0.7367'} ${selectedCurrencyTo ?? 'USD'}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
