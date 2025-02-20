import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String apiUrl = "https://openexchangerates.org/api/latest.json";
  final String apiKey = "f299c960f2ab4856831d4a9df432d94d";

  Future<double> getExchangeRate(String baseCurrency, String targetCurrency) async {
    final url = Uri.parse(apiUrl).replace(queryParameters: {
      'app_id': apiKey,
      'base': baseCurrency,
      'symbols': targetCurrency
    });

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;
      
      return rates[targetCurrency].toDouble();
    } else {
      throw Exception('''Error ${response.statusCode}
Respuesta: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}''');
    }
  }
}

