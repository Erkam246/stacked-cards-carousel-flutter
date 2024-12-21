import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stacked_cards_carousel/stacked_cards_carousel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stacked Cards Carousel Demo',
      home: MyHomePage(title: 'Stacked Cards Carousel Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color randomColorGenerator() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  double height = 300;
  double width = 200;
  int numberOfItems = 3;
  List<Widget> items = [];
  @override
  void initState() {
    for (int i = 0; i < numberOfItems; i++) {
      items.add(
        Container(
          height: height,
          width: width,
          color: randomColorGenerator(),
          child: Center(
            child: Text(
              'Item $i',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StackedCardsCarouselWidget(
          items: items,
        ),
      ),
    );
  }
}
