// canteenPage.dart
import 'package:flutter/material.dart';
import 'canteen.dart';

class CanteenPage extends StatelessWidget {
  final List<Canteen> canteens = [
    Canteen(
      name: 'Lamduan Canteen 1',
      shops: [
        Shop(name: 'Fried Rice Shop', menuItems: ['Fried Rice']),
      ],
    ),
    Canteen(
      name: 'Lamduan Canteen 2',
      shops: [
        Shop(name: 'Salad Shop', menuItems: ['Salad']),
        Shop(name: 'Fried Rice Shop', menuItems: ['Fried Rice']),
        Shop(name: 'Rice Shop', menuItems: ['Rice']),
        Shop(name: 'Fruits Shop', menuItems: ['Fruits']),
        Shop(name: 'Snacks Shop', menuItems: ['Snacks']),
      ],
    ),
    Canteen(
      name: 'D1 Canteen',
      shops: List.generate(
        12,
        (index) => Shop(name: 'Shop ${index + 1}', menuItems: ['Mockup']),
      ),
    ),
    Canteen(
      name: 'E1 Canteen',
      shops: List.generate(
        10,
        (index) => Shop(name: 'Shop ${index + 1}', menuItems: ['Mockup']),
      ),
    ),
    Canteen(
      name: 'E2 Canteen',
      shops: List.generate(
        16,
        (index) => Shop(name: 'Shop ${index + 1}', menuItems: ['Mockup']),
      ),
    ),
    Canteen(
      name: 'C5 Canteen',
      shops: List.generate(
        5,
        (index) => Shop(name: 'Shop ${index + 1}', menuItems: ['Mockup']),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteens'),
      ),
      body: ListView.builder(
        itemCount: canteens.length,
        itemBuilder: (context, index) {
          final canteen = canteens[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 4.0,
            child: ExpansionTile(
              title: Text(canteen.name, style: TextStyle(fontWeight: FontWeight.bold)),
              children: canteen.shops.map((shop) {
                return ListTile(
                  title: Text(shop.name),
                  subtitle: Text('Menu: ${shop.menuItems.join(', ')}'),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
// canteen.dart
class Shop {
  final String name;
  final List<String> menuItems;

  Shop({required this.name, required this.menuItems});
}

class Canteen {
  final String name;
  final List<Shop> shops;

  Canteen({required this.name, required this.shops});
}
