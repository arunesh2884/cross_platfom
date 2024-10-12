import 'package:badges/badges.dart' as badges;
import 'package:jayasudha/helper/db_helper.dart';
import 'package:jayasudha/model/cart_model.dart';
import 'package:jayasudha/provider/cartprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_screen.dart';

class JuiceList extends StatefulWidget {
  const JuiceList({super.key});

  @override
  State<JuiceList> createState() => _JuiceListState();
}

class _JuiceListState extends State<JuiceList> {
  List<String> productName = [
    'Black Berry Juice',
    'Rum-Berry Juice',
    'Vegan Mango Lassi',
    'Vanilla Strawberry Iced Juice',
  ];
  List<String> productUnit = [
    '200 ml',
    '200 ml',
    '200 ml',
    '200 ml',
  ];
  List<int> productPrice = [10, 20, 30, 40, 50, 60];
  List<String> productImage = [
    'assets/Blackberry.jpg',
    'assets/Rum-Berry.jpg',
    'assets/Vegan_Mango_Lassi.jpg',
    'assets/Vanilla_Strawberry_Iced_Juice.jpg',
  ];

  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Juice List'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CartScreen()));
            },
            child: Center(
              child: badges.Badge(
                showBadge: true,
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, child) {
                    return Text(value.getCounter().toString(),
                        style: TextStyle(color: Colors.white));
                  },
                ),
                child: Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          SizedBox(width: 20.0),
        ],
      ),
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20),
                  itemCount: productName.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Image(
                              image: AssetImage(productImage[index]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover, // Ensures the image fills the square
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productUnit[index] +
                                        " " +
                                        r"$" +
                                        productPrice[index].toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async {
                                        // Check if the product is already in the cart
                                        bool exists = await dbHelper!
                                            .checkProductExists(
                                            productName[index]);
                                        if (!exists) {
                                          dbHelper!
                                              .insert(Cart(
                                              id: index,
                                              productId: index.toString(),
                                              productName:
                                              productName[index],
                                              initialPrice:
                                              productPrice[index],
                                              productPrice:
                                              productPrice[index],
                                              quantity: 1,
                                              unitTag: productUnit[index],
                                              image: productImage[index]))
                                              .then((value) {
                                            cart.addTotalPrice(double.parse(
                                                productPrice[index].toString()));
                                            cart.addCounter();

                                            final snackBar = SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                  'Product is added to cart'),
                                              duration: Duration(seconds: 1),
                                            );

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }).onError((error, stackTrace) {
                                            print("error" + error.toString());
                                            final snackBar = SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    'Error adding product'),
                                                duration:
                                                Duration(seconds: 1));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          });
                                        } else {
                                          final snackBar = SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'Product is already added in cart'),
                                            duration: Duration(seconds: 1),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius.circular(5)),
                                        child: const Center(
                                          child: Text(
                                            'Add to cart',
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
