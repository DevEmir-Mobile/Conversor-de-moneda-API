import 'package:conversordemonedas/widgets/convert_amount.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              TextDesing(),
              ConversorAmount(),
            ],
          ),
        ),
      ),
    );
  }
}

class TextDesing extends StatelessWidget {
  const TextDesing({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 100),
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Currency Converter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F2261),
                  fontSize: 25,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 320,
                child: Text(
                  'Check live rates, set rate alerts, receive notifications and more.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF7F7F7F),
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
