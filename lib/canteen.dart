import 'package:flutter/material.dart';

class CanteenPage extends StatelessWidget {
  final List<Canteen> canteens = [
    Canteen(
      name: 'Lamduan Canteen 1',
      shops: [
        Shop(name: 'Noodle Shop', menuItems: ['Pad Thai', 'Boat Noodles']),
        Shop(name: 'Grilled Shop', menuItems: ['Grilled Pork', 'Chicken Satay']),
        Shop(name: 'Dessert Shop', menuItems: ['Mango Sticky Rice', 'Coconut Jelly']),
        Shop(name: 'Beverage Shop', menuItems: ['Thai Iced Tea', 'Herbal Drinks']),
      ],
    ),
    Canteen(
      name: 'Lamduan Canteen 2',
      shops: [
        Shop(name: 'Salad Shop', menuItems: ['Som Tum (Papaya Salad)']),
        Shop(name: 'Fried Rice Shop', menuItems: ['Thai Basil Fried Rice']),
        Shop(name: 'Rice Shop', menuItems: ['Chicken Rice', 'Pork Rice']),
        Shop(name: 'Fruits Shop', menuItems: ['Fresh Mango', 'Watermelon']),
        Shop(name: 'Snacks Shop', menuItems: ['Spring Rolls', 'Fish Cakes']),
      ],
    ),
    Canteen(
      name: 'D1 Canteen',
      shops: [
        Shop(name: 'Noodle Shop', menuItems: ['Tom Yum Noodles', 'Egg Noodles']),
        Shop(name: 'Curry Shop', menuItems: ['Green Curry', 'Massaman Curry']),
        Shop(name: 'Fried Shop', menuItems: ['Fried Chicken', 'Fried Banana']),
        Shop(name: 'Dessert Shop', menuItems: ['Thai Custard', 'Banana in Coconut Milk']),
        Shop(name: 'Grilled Shop', menuItems: ['Grilled Squid', 'Grilled Fish']),
      ],
    ),
    Canteen(
      name: 'E1 Canteen',
      shops: [
        Shop(name: 'Seafood Shop', menuItems: ['Shrimp Pad Thai', 'Crispy Fish']),
        Shop(name: 'Rice & Curry Shop', menuItems: ['Red Curry', 'Yellow Curry']),
        Shop(name: 'Vegetarian Shop', menuItems: ['Vegetable Stir-fry', 'Tofu Curry']),
        Shop(name: 'Soup Shop', menuItems: ['Tom Yum Soup', 'Tom Kha Gai']),
        Shop(name: 'Drink Shop', menuItems: ['Thai Coffee', 'Lemongrass Tea']),
      ],
    ),
    Canteen(
      name: 'E2 Canteen',
      shops: [
        Shop(name: 'Noodle Shop', menuItems: ['Glass Noodles', 'Yen Ta Fo']),
        Shop(name: 'Grilled Shop', menuItems: ['Grilled Chicken', 'Isaan Sausage']),
        Shop(name: 'Snack Shop', menuItems: ['Pandan Waffles', 'Crispy Pancakes']),
        Shop(name: 'Rice Shop', menuItems: ['Fried Rice', 'Crispy Pork Rice']),
        Shop(name: 'Dessert Shop', menuItems: ['Pumpkin Custard', 'Lod Chong']),
      ],
    ),
    Canteen(
      name: 'C5 Canteen',
      shops: [
        Shop(name: 'Salad Shop', menuItems: ['Som Tum Thai', 'Som Tum with Crab']),
        Shop(name: 'Curry Shop', menuItems: ['Panang Curry', 'Jungle Curry']),
        Shop(name: 'Fried Shop', menuItems: ['Fried Spring Rolls', 'Fried Fish Cakes']),
        Shop(name: 'Fruit Shop', menuItems: ['Papaya', 'Longan']),
        Shop(name: 'Beverage Shop', menuItems: ['Thai Milk Tea', 'Butterfly Pea Tea']),
      ],
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

// canteen.dart (unchanged)
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
