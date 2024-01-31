import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Screens/add_to_cart_dialog.dart';
import 'package:provider/provider.dart';

class FeaturedProducts extends StatelessWidget {
  final bool open;
  FeaturedProducts(this.open, {Key? key}) : super(key: key);
  final formatCurrency = NumberFormat.simpleCurrency();

  void addToCart(product, context) {
    showDialog(
        context: context,
        builder: (context) {
          return AddToCartDialog(product);
        });
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
    final product = Provider.of<List<Products>>(context);

    if (product.isEmpty) {
      return Container();
    }

    if (MediaQuery.of(context).size.width < 700) {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: product.length,
          controller: productScrollController,
          itemBuilder: ((context, i) {
            double totalCost = 0;
            List ingredients = product[i].ingredients!;
            if (ingredients.isNotEmpty) {
              for (int x = 0; x < ingredients.length; x++) {
                if (ingredients[x]['Supply Cost'] != null &&
                    ingredients[x]['Supply Quantity'] != null &&
                    ingredients[x]['Quantity'] != null &&
                    ingredients[x]['Yield'] != null) {
                  double ingredientTotal = ((ingredients[x]['Supply Cost'] /
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: SizedBox(
                height: double.infinity,
                width: 400,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.white70;
                          }
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed)) {
                            return Colors.white54;
                          }
                          return Colors.black; // Defer to the widget's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      if (open) {
                        addToCart(product[i], context);
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
                            child: (product[i].image != '')
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        color: Colors.grey[100],
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(product[i].image),
                                            fit: BoxFit.cover)))
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12)),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Center(
                                      child: Text(
                                        product[i].product.substring(0, 2),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                          ),
                          const SizedBox(width: 15),
                          //Description
                          Expanded(
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //product
                                  Text(
                                    product[i].product,
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
                                    (product[i].description != '')
                                        ? product[i].description
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
                                    (product[i].controlStock! &&
                                            product[i].currentStock! < 1)
                                        ? 'Fuera de Stock'
                                        : (product[i].priceType ==
                                                'Precio por margen')
                                            ? "\$${(totalCost + (totalCost * (product[i].price / 100))).toStringAsFixed(2)}"
                                            : formatCurrency
                                                .format(product[i].price),
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
                                addToCart(product[i], context);
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
          }));
    } else {
      return Stack(children: [
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: product.length,
          controller: productScrollController,
          itemBuilder: ((context, i) {
            double totalCost = 0;
            List ingredients = product[i].ingredients!;
            if (ingredients.isNotEmpty) {
              for (int x = 0; x < ingredients.length; x++) {
                if (ingredients[x]['Supply Cost'] != null &&
                    ingredients[x]['Supply Quantity'] != null &&
                    ingredients[x]['Quantity'] != null &&
                    ingredients[x]['Yield'] != null) {
                  double ingredientTotal = ((ingredients[x]['Supply Cost'] /
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: SizedBox(
                height: double.infinity,
                width: 400,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.white70;
                          }
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed)) {
                            return Colors.white54;
                          }
                          return Colors.black; // Defer to the widget's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      if (open) {
                        addToCart(product[i], context);
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //Fotos
                          Expanded(
                            child: (product[i].image != '')
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        color: Colors.grey[100],
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(product[i].image),
                                            fit: BoxFit.cover)))
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12)),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Center(
                                      child: Text(
                                        product[i].product.substring(0, 2),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                          ),
                          const SizedBox(width: 15),
                          //Description
                          Expanded(
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //product
                                  Text(
                                    product[i].product,
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
                                    (product[i].description != '')
                                        ? product[i].description
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
                                    (product[i].controlStock! &&
                                            product[i].currentStock! < 1)
                                        ? 'Fuera de Stock'
                                        : (product[i].priceType ==
                                                'Precio por margen')
                                            ? "\$${(totalCost + (totalCost * (product[i].price / 100))).toStringAsFixed(2)}"
                                            : formatCurrency
                                                .format(product[i].price),
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
                                addToCart(product[i], context);
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
                    fixedSize: const Size(50, 50),
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black45.withOpacity(0.25)),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 21),
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
                    fixedSize: const Size(50, 50),
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black45.withOpacity(0.25)),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 21),
              )),
        ),
      ]);
    }
  }
}
