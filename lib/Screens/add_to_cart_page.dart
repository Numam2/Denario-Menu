// ignore_for_file: avoid_function_literals_in_foreach_calls, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_denario/Models/products.dart';

import '../Database/ticket.dart';

class AddToCartPage extends StatefulWidget {
  final Products product;
  const AddToCartPage(this.product, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  int quantity = 1;
  double selectedPrice = 0;
  double basePrice = 0;
  List selectedTags = [];
  final formatCurrency = NumberFormat.simpleCurrency();
  Map<String, dynamic> selectedProductOptions = {};
  List availableOptions = [];
  List<ProductOptions> productOptions = [];

  double totalAmount(
    double basePrice,
    Map selectedOptions,
  ) {
    double total = 0;
    List<double> additionalsList = [];
    double additionalAmount = 0;

    //Serch for base price
    productOptions.forEach((x) {
      if (x.priceStructure == 'Aditional') {
        for (var i = 0; i < x.priceOptions.length; i++) {
          if (selectedOptions.containsKey(x.title) &&
              selectedOptions[x.title].contains(x.priceOptions[i]['Option'])) {
            additionalsList.add(x.priceOptions[i]['Price'].toDouble());
          }
        }
      }
    });

    //Add up
    additionalsList.forEach((y) {
      additionalAmount = additionalAmount + y;
    });

    total = basePrice + additionalAmount;

    return total;
  }

  Map mandatoryOptions = {};

  bool mandatoryOptionsCompleted() {
    bool optionsCompleted = true;

    mandatoryOptions.forEach((key, value) {
      if (value == false) {
        setState(() {
          optionsCompleted = false;
        });
      }
    });

    return optionsCompleted;
  }

  double totalCost = 0;
  List ingredients = [];

  void addOption(int i, int x) {
    //If
    if (selectedProductOptions.containsKey(productOptions[i].title)) {
      //If the title option in not selected
      if (!selectedProductOptions[productOptions[i].title]
          .contains(productOptions[i].priceOptions[x]['Option'])) {
        //Add the option to the title's list if multiple choice
        if (productOptions[i].multipleOptions) {
          setState(() {
            selectedProductOptions[productOptions[i].title]
                .add(productOptions[i].priceOptions[x]['Option']);
          });
        } else {
          //Add and remove others
          setState(() {
            selectedProductOptions[productOptions[i].title] = [
              productOptions[i].priceOptions[x]['Option']
            ];
          });
          if (productOptions[i].priceStructure == 'Complete') {
            setState(() {
              basePrice = productOptions[i].priceOptions[x]['Price'];
            });
          }
        }
        if (widget.product.productOptions[i].mandatory) {
          setState(() {
            mandatoryOptions[widget.product.productOptions[i].title] = true;
          });
        }
      } else {
        //Remove the option from the title's list
        setState(() {
          selectedProductOptions[productOptions[i].title]
              .remove(productOptions[i].priceOptions[x]['Option']);
        });

        //Price config
        if (productOptions[i].priceStructure == 'Complete') {
          setState(() {
            basePrice = widget.product.price;
          });
        }

        if (widget.product.productOptions[i].mandatory) {
          setState(() {
            mandatoryOptions[widget.product.productOptions[i].title] = false;
          });
        }
      }
    } else {
      setState(() {
        selectedProductOptions[productOptions[i].title] = [
          productOptions[i].priceOptions[x]['Option']
        ];
      });
      if (productOptions[i].priceStructure == 'Complete') {
        setState(() {
          basePrice = productOptions[i].priceOptions[x]['Price'];
        });
      }
      if (widget.product.productOptions[i].mandatory) {
        setState(() {
          mandatoryOptions[widget.product.productOptions[i].title] = true;
        });
      }
    }
  }

  @override
  void initState() {
    ingredients = widget.product.ingredients!;
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

    productOptions = widget.product.productOptions;
    for (int i = 0; i < widget.product.productOptions.length; i++) {
      // List options = List.from(widget.product.productOptions![i].priceOptions);
      availableOptions.add({
        'Title': widget.product.productOptions[i].title,
        'Mandatory': widget.product.productOptions[i].mandatory,
        'Multiple Options': widget.product.productOptions[i].multipleOptions,
        'Price Structure': widget.product.productOptions[i].priceStructure,
        'Price Options': widget.product.productOptions[i].priceOptions,
      });
    }

    if (widget.product.priceType == 'Precio por margen') {
      selectedPrice = (totalCost + (totalCost * (widget.product.price / 100)));
      basePrice = (totalCost + (totalCost * (widget.product.price / 100)));
    } else {
      selectedPrice = widget.product.price.toDouble();
      basePrice = widget.product.price.toDouble();
    }

    for (var i = 0; i < widget.product.productOptions.length; i++) {
      if (widget.product.productOptions[i].mandatory) {
        mandatoryOptions[widget.product.productOptions[i].title] = false;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            iconSize: 20.0),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            //Content
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 70, 0, 120),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Image
                      (widget.product.image != '')
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  color: Colors.grey[100],
                                  image: DecorationImage(
                                      image: NetworkImage(widget.product.image),
                                      fit: BoxFit.cover)))
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                color: Colors.grey[300],
                              ),
                              child: Center(
                                child: Text(
                                  widget.product.product.substring(0, 2),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                      const SizedBox(height: 25),
                      //Price
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          formatCurrency.format(selectedPrice),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      //Details
                      (widget.product.description == '')
                          ? Container()
                          : SizedBox(
                              width: double.infinity,
                              child: Text(
                                widget.product.description,
                                textAlign: TextAlign.center,
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                      const SizedBox(height: 20),
                      //Options
                      (widget.product.productOptions.isEmpty)
                          ? Container()
                          : SizedBox(
                              width: double.infinity,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      widget.product.productOptions.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Title
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.product.productOptions[i]
                                                    .title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                              const Spacer(),
                                              Text(
                                                (widget
                                                        .product
                                                        .productOptions[i]
                                                        .mandatory)
                                                    ? '(Obligatorio)'
                                                    : '(Opcional)',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          //List
                                          SizedBox(
                                              width: double.infinity,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: widget
                                                      .product
                                                      .productOptions[i]
                                                      .priceOptions
                                                      .length,
                                                  itemBuilder:
                                                      (context, int x) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //iTEM
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                //Text/Price
                                                                Text(
                                                                  widget
                                                                          .product
                                                                          .productOptions[
                                                                              i]
                                                                          .priceOptions[x]
                                                                      [
                                                                      'Option'],
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                (widget
                                                                            .product
                                                                            .productOptions[
                                                                                i]
                                                                            .priceStructure ==
                                                                        'Complete')
                                                                    ? Text(
                                                                        '(\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .normal,
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.black),
                                                                      )
                                                                    : (widget.product.productOptions[i].priceStructure ==
                                                                            'Aditional')
                                                                        ? Text(
                                                                            '( +\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                            style: const TextStyle(
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 14,
                                                                                color: Colors.black),
                                                                          )
                                                                        : const SizedBox(),
                                                                const Spacer(),
                                                                //Button
                                                                (widget
                                                                        .product
                                                                        .productOptions[
                                                                            i]
                                                                        .multipleOptions)
                                                                    ? IconButton(
                                                                        onPressed: () => addOption(
                                                                            i,
                                                                            x),
                                                                        icon: (selectedProductOptions.containsKey(productOptions[i].title) &&
                                                                                selectedProductOptions[productOptions[i].title].contains(productOptions[i].priceOptions[x][
                                                                                    'Option']))
                                                                            ? Icon(
                                                                                Icons.check_box,
                                                                                color: Colors.greenAccent[400],
                                                                              )
                                                                            : const Icon(Icons
                                                                                .check_box_outline_blank))
                                                                    : IconButton(
                                                                        onPressed:
                                                                            () =>
                                                                                addOption(i, x),
                                                                        icon: (selectedProductOptions.containsKey(productOptions[i].title) && selectedProductOptions[productOptions[i].title].contains(productOptions[i].priceOptions[x]['Option']))
                                                                            ? Icon(
                                                                                Icons.circle_sharp,
                                                                                color: Colors.greenAccent[400],
                                                                              )
                                                                            : const Icon(Icons.circle_outlined))
                                                              ],
                                                            ),
                                                          ), //Divider
                                                          const Divider(
                                                            thickness: 0.5,
                                                            color: Colors.grey,
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  })),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                      const SizedBox(height: 15),
                      //Action
                      (widget.product.productOptions.isEmpty)
                          ? const Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                              indent: 15,
                              endIndent: 15)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            //Total and Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Title
                  Text(
                    widget.product.product,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 15,
                      endIndent: 15),
                  const Spacer(),
                  //Add/substract items
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Remove
                          IconButton(
                            onPressed: () {
                              if (quantity <= 1) {
                                //
                              } else {
                                setState(() {
                                  quantity = quantity - 1;
                                });
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 18),
                          ), //'${cartList[i]['Quantity']}'),
                          const SizedBox(width: 10),
                          //Add
                          IconButton(
                            onPressed: () {
                              if (widget.product.controlStock!) {
                                if (widget.product.currentStock! >=
                                    quantity + 1) {
                                  setState(() {
                                    quantity = quantity + 1;
                                  });
                                }
                              } else {
                                setState(() {
                                  quantity = quantity + 1;
                                });
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 24,
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 8,
                  ),
                  //Add to order button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: (mandatoryOptionsCompleted() &&
                                  !(widget.product.controlStock! &&
                                      widget.product.currentStock! < 1))
                              ? WidgetStateProperty.all<Color>(Colors.black)
                              : WidgetStateProperty.all<Color>(
                                  Colors.grey.shade300),
                          overlayColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey.shade300;
                              }
                              if (states.contains(WidgetState.focused) ||
                                  states.contains(WidgetState.pressed)) {
                                return Colors.grey.shade200;
                              }
                              return Colors
                                  .black; // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () {
                          if (mandatoryOptionsCompleted() &&
                              !(widget.product.controlStock! &&
                                  widget.product.currentStock! < 1)) {
                            if (quantity > 0) {
                              bloc.addToCart({
                                'Name': widget.product.product,
                                'Category': widget.product.category,
                                'Base Price': widget.product.price,
                                'Price': totalAmount(
                                    basePrice, selectedProductOptions),
                                'Quantity': quantity,
                                'Total Price': totalAmount(
                                        basePrice, selectedProductOptions) *
                                    quantity,
                                'Available Options': availableOptions,
                                'Selected Options': selectedProductOptions,
                                'Options': selectedTags,
                                'Image': widget.product.image,
                                'Supplies': widget.product.ingredients,
                                'Control Stock': widget.product.controlStock,
                                'Product ID': widget.product.productID,
                                'Stock Updated': true,
                              });
                            }

                            // Go Back
                            Navigator.of(context).pop();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            (widget.product.controlStock! &&
                                    widget.product.currentStock! < 1)
                                ? 'Fuera de Stock'
                                : 'Agregar  |  ${formatCurrency.format(totalAmount(basePrice, selectedProductOptions) * quantity)}',
                            style: TextStyle(
                                color: (mandatoryOptionsCompleted() &&
                                        !(widget.product.controlStock! &&
                                            widget.product.currentStock! < 1))
                                    ? Colors.white
                                    : Colors.black),
                          )),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
