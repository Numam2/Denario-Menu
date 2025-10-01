import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Screens/add_to_cart_dialog.dart';
import 'package:menu_denario/Screens/add_to_cart_page.dart';

class FeaturedProducts extends StatelessWidget {
  final bool open;
  final List<Products> productList;
  FeaturedProducts(this.open, this.productList, {super.key});
  final formatCurrency = NumberFormat.simpleCurrency();

  void addToCart(product, context) {
    if (MediaQuery.of(context).size.width < 700) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AddToCartPage(product)));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AddToCartDialog(product);
          });
    }
  }

  void storeClosed(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: SizedBox(
                  width: 400,
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Close
                        Container(
                          alignment: const Alignment(1.0, 0.0),
                          child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              iconSize: 20.0),
                        ),
                        const SizedBox(height: 20),
                        //Text
                        const Text(
                          'El local está cerrado en este momento',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  final ScrollController productScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (productList.isEmpty) {
      return Container();
    }

    if (MediaQuery.of(context).size.width < 700) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Destacados',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height: 240,
                width: double.infinity,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productList.length,
                    controller: productScrollController,
                    itemBuilder: ((context, i) {
                      double totalCost = 0;
                      List ingredients = productList[i].ingredients!;
                      if (ingredients.isNotEmpty) {
                        for (int x = 0; x < ingredients.length; x++) {
                          if (ingredients[x]['Supply Cost'] != null &&
                              ingredients[x]['Supply Quantity'] != null &&
                              ingredients[x]['Quantity'] != null &&
                              ingredients[x]['Yield'] != null) {
                            double ingredientTotal = ((ingredients[x]
                                            ['Supply Cost'] /
                                        ingredients[x]['Supply Quantity']) *
                                    ingredients[x]['Quantity']) /
                                ingredients[x]['Yield'];
                            if (!ingredientTotal.isNaN &&
                                !ingredientTotal.isInfinite &&
                                !ingredientTotal.isNegative) {
                              totalCost = totalCost + ingredientTotal;
                            }
                          }
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: SizedBox(
                          height: double.infinity,
                          width: 400,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.white70;
                                    }
                                    if (states.contains(WidgetState.focused) ||
                                        states.contains(WidgetState.pressed)) {
                                      return Colors.white54;
                                    }
                                    return Colors
                                        .black; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                if (open) {
                                  addToCart(productList[i], context);
                                } else {
                                  storeClosed(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Fotos
                                    Expanded(
                                      child: (productList[i].image != '')
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                  color: Colors.grey[100],
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          productList[i].image),
                                                      fit: BoxFit.cover)))
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(12)),
                                                color: Colors.grey.shade300,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  productList[i]
                                                      .product
                                                      .substring(0, 2),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )),
                                    ),
                                    const SizedBox(width: 15),
                                    //Description
                                    Expanded(
                                      child: SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //product
                                            Text(
                                              productList[i].product,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              (productList[i].description != '')
                                                  ? productList[i].description
                                                  : '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const Spacer(),

                                            ///Price
                                            Text(
                                              (productList[i].controlStock! &&
                                                      productList[i]
                                                              .currentStock! <
                                                          1)
                                                  ? 'Fuera de Stock'
                                                  : (productList[i].priceType ==
                                                          'Precio por margen')
                                                      ? "\$${(totalCost + (totalCost * (productList[i].price / 100))).toStringAsFixed(2)}"
                                                      : formatCurrency.format(
                                                          productList[i].price),
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //Button
                                    IconButton(
                                      onPressed: () {
                                        if (open) {
                                          addToCart(productList[i], context);
                                        } else {
                                          storeClosed(context);
                                        }
                                      },
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.black,
                                      hoverColor: Colors.black54,
                                      iconSize: 30,
                                      splashRadius: 15,
                                      splashColor: Colors.white70,
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      );
                    }))),
          ],
        ),
      );
    } else {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Destacados',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 240,
              child: Stack(children: [
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productList.length,
                  controller: productScrollController,
                  itemBuilder: ((context, i) {
                    double totalCost = 0;
                    List ingredients = productList[i].ingredients!;
                    if (ingredients.isNotEmpty) {
                      for (int x = 0; x < ingredients.length; x++) {
                        if (ingredients[x]['Supply Cost'] != null &&
                            ingredients[x]['Supply Quantity'] != null &&
                            ingredients[x]['Quantity'] != null &&
                            ingredients[x]['Yield'] != null) {
                          double ingredientTotal = ((ingredients[x]
                                          ['Supply Cost'] /
                                      ingredients[x]['Supply Quantity']) *
                                  ingredients[x]['Quantity']) /
                              ingredients[x]['Yield'];
                          if (!ingredientTotal.isNaN &&
                              !ingredientTotal.isInfinite &&
                              !ingredientTotal.isNegative) {
                            totalCost = totalCost + ingredientTotal;
                          }
                        }
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: SizedBox(
                        height: double.infinity,
                        width: 400,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.white70;
                                  }
                                  if (states.contains(WidgetState.focused) ||
                                      states.contains(WidgetState.pressed)) {
                                    return Colors.white54;
                                  }
                                  return Colors
                                      .black; // Defer to the widget's default.
                                },
                              ),
                            ),
                            onPressed: () {
                              if (open) {
                                addToCart(productList[i], context);
                              } else {
                                storeClosed(context);
                              }
                            },
                            child: Container(
                              // decoration: BoxDecoration(
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(12)),
                              //     border:
                              //         Border.all(color: Colors.grey.shade200)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  //Fotos
                                  Expanded(
                                    child: (productList[i].image != '')
                                        ? Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(12)),
                                                color: Colors.grey[100],
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        productList[i].image),
                                                    fit: BoxFit.cover)))
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12)),
                                              color: Colors.grey.shade300,
                                            ),
                                            child: Center(
                                              child: Text(
                                                productList[i]
                                                    .product
                                                    .substring(0, 2),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                  ),
                                  const SizedBox(width: 15),
                                  //Description
                                  Expanded(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //product
                                          Text(
                                            productList[i].product,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            (productList[i].description != '')
                                                ? productList[i].description
                                                : '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const Spacer(),

                                          //Price
                                          Text(
                                            (productList[i].controlStock! &&
                                                    productList[i]
                                                            .currentStock! <
                                                        1)
                                                ? 'Fuera de Stock'
                                                : (productList[i].priceType ==
                                                        'Precio por margen')
                                                    ? "\$${(totalCost + (totalCost * (productList[i].price / 100))).toStringAsFixed(2)}"
                                                    : formatCurrency.format(
                                                        productList[i].price),
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //Button
                                  IconButton(
                                    onPressed: () {
                                      if (open) {
                                        addToCart(productList[i], context);
                                      } else {
                                        storeClosed(context);
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle),
                                    color: Colors.black,
                                    hoverColor: Colors.black54,
                                    iconSize: 30,
                                    splashRadius: 15,
                                    splashColor: Colors.white70,
                                  ),
                                ],
                              ),
                            )),
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: ElevatedButton(
                        onPressed: (() {
                          productScrollController.animateTo(
                              productScrollController.offset - 400,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease);
                        }),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(40, 40),
                            shape: const CircleBorder(),
                            backgroundColor: Colors.black45.withValues(alpha:0.05)),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios,
                              size: 16, color: Colors.white),
                        ),
                      )),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: ElevatedButton(
                        onPressed: (() {
                          productScrollController.animateTo(
                              productScrollController.offset + 400,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease);
                        }),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(40, 40),
                            shape: const CircleBorder(),
                            backgroundColor: Colors.black45.withValues(alpha:0.05)),
                        child: const Center(
                          child: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.white),
                        ),
                      )),
                ),
              ]),
            ),
          ],
        ),
      );
    }
  }
}
