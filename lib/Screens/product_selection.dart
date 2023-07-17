import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Screens/add_to_cart_dialog.dart';
import 'package:menu_denario/Screens/add_to_cart_page.dart';
import 'package:provider/provider.dart';

class ProductSelection extends StatefulWidget {
  final bool open;
  const ProductSelection(this.open, {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ProductSelectionState createState() => _ProductSelectionState();
}

class _ProductSelectionState extends State<ProductSelection> {
  final formatCurrency = NumberFormat.simpleCurrency();
  bool productExists = false;
  final Key productListKey = const Key('productList');

  void addToCart(product) {
    showDialog(
        context: context,
        builder: (context) {
          return AddToCartDialog(product);
        });
  }

  void storeClosed() {
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

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<List<Products>>(context);

    if (product.isEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
        return const SizedBox();
      }, childCount: 1));
    } else if (MediaQuery.of(context).size.width < 600) {
      return SliverList(
          key: productListKey,
          delegate: SliverChildBuilderDelegate((context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: SizedBox(
                height: 200,
                width: double.infinity,
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
                      if (widget.open) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddToCartPage(product[i])));
                      } else {
                        storeClosed();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //Fotos
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    color: Colors.grey[100],
                                    image: DecorationImage(
                                        image: NetworkImage(product[i].image),
                                        fit: BoxFit.cover))),
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
                                    maxLines: 3,
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
                                    formatCurrency.format(product[i].price),
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
                              if (widget.open) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddToCartPage(product[i])));
                              } else {
                                storeClosed();
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
          }, childCount: product.length));
    } else {
      return SliverGrid(
        key: productListKey,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width > 1100) ? 3 : 2,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            return ElevatedButton(
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
                  if (widget.open) {
                    addToCart(product[i]);
                  } else {
                    storeClosed();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Fotos
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            color: Colors.grey[100],
                            image: DecorationImage(
                                image: NetworkImage(product[i].image),
                                fit: BoxFit.cover)),
                      )),
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
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        (MediaQuery.of(context).size.width <
                                                900)
                                            ? 15
                                            : 18,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: Text(
                                  (product[i].description != '')
                                      ? product[i].description
                                      : '',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize:
                                          (MediaQuery.of(context).size.width <
                                                  900)
                                              ? 12
                                              : 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(height: 5),

                              ///Price
                              Text(
                                formatCurrency.format(product[i].price),
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
                      const SizedBox(height: 5),
                      //Button
                      IconButton(
                        splashRadius: 15,
                        onPressed: () {
                          if (widget.open) {
                            addToCart(product[i]);
                          } else {
                            storeClosed();
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.black,
                        hoverColor: Colors.black54,
                        iconSize: 30,
                        splashColor: Colors.white70,
                      ),
                    ],
                  ),
                ));
          },
          childCount: product.length,
        ),
      );
    }
  }
}
