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
  final formatCurrency =  NumberFormat.simpleCurrency();

  double totalAmount(
    double basePrice,
    List selectedTags,
  ) {
    double total = 0;
    List<double> additionalsList = [];
    double additionalAmount = 0;

    //Serch for base price
    widget.product.productOptions.forEach((x) {
      if (x.priceStructure == 'Aditional') {
        for (var i = 0; i < x.priceOptions.length; i++) {
          if (selectedTags.contains(x.priceOptions[i]['Option'])) {
            additionalsList.add(x.priceOptions[i]['Price']);
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

  @override
  void initState() {
    selectedPrice = widget.product.price.toDouble();
    basePrice = widget.product.price.toDouble();

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
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            color: Colors.grey[100],
                            image: DecorationImage(
                                image: NetworkImage(widget.product.image),
                                fit: BoxFit.cover)),
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
                                                            width: double
                                                                .infinity,
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
                                                                      .priceOptions[x]['Option'],
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
                                                                    width:
                                                                        10),
                                                                (widget.product.productOptions[i].priceStructure ==
                                                                        'Complete')
                                                                    ? Text(
                                                                        '(\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 14,
                                                                            color: Colors.black),
                                                                      )
                                                                    : (widget.product.productOptions[i].priceStructure ==
                                                                            'Aditional')
                                                                        ? Text(
                                                                            '( +\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black),
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
                                                                        onPressed:
                                                                            () {
                                                                          if (!selectedTags.contains(widget.product.productOptions[i].priceOptions[x]['Option'])) {
                                                                            //Add new
                                                                            setState(() {
                                                                              selectedTags.add(widget.product.productOptions[i].priceOptions[x]['Option']);
                                                                            });
                                                                            //Add price
                                                                            if (widget.product.productOptions[i].priceStructure == 'Complete') {
                                                                              setState(() {
                                                                                basePrice = widget.product.productOptions[i].priceOptions[x]['Price'];
                                                                              });
                                                                            }
                                                                            if (widget.product.productOptions[i].mandatory) {
                                                                              setState(() {
                                                                                mandatoryOptions[widget.product.productOptions[i].title] = true;
                                                                              });
                                                                            }
                                                                          } else {
                                                                            setState(() {
                                                                              selectedTags.remove(widget.product.productOptions[i].priceOptions[x]['Option']);
                                                                            });
                                                                            //Add price
                                                                            if (widget.product.productOptions[i].priceStructure == 'Complete') {
                                                                              setState(() {
                                                                                basePrice = widget.product.price;
                                                                              });
                                                                            }
                                                                            //Mandatory
                                                                            if (widget.product.productOptions[i].mandatory) {
                                                                              bool remove = true;
                                                                              for (int y = 0; y < widget.product.productOptions[i].priceOptions.length; y++) {
                                                                                if (selectedTags.contains(widget.product.productOptions[i].priceOptions[y]['Option'])) {
                                                                                  setState(() {
                                                                                    remove = false;
                                                                                  });
                                                                                }
                                                                              }
                                                                              if (remove) {
                                                                                setState(() {
                                                                                  mandatoryOptions[widget.product.productOptions[i].title] = false;
                                                                                });
                                                                              }
                                                                            }
                                                                          }
                                                                        },
                                                                        icon: (selectedTags.contains(widget.product.productOptions[i].priceOptions[x]['Option']))
                                                                            ? Icon(
                                                                                Icons.check_box,
                                                                                color: Colors.greenAccent[400],
                                                                              )
                                                                            : const Icon(Icons.check_box_outline_blank))
                                                                    : IconButton(
                                                                        onPressed: () {
                                                                          if (!selectedTags.contains(widget.product.productOptions[i].priceOptions[x]['Option'])) {
                                                                            //IF SINGLE CHOICE, REMOVE OTHERS
                                                                            widget.product.productOptions[i].priceOptions.forEach((x) {
                                                                              if (selectedTags.contains(x['Option'])) {
                                                                                selectedTags.remove(x['Option']);
                                                                              }
                                                                            });

                                                                            //Add new
                                                                            setState(() {
                                                                              selectedTags.add(widget.product.productOptions[i].priceOptions[x]['Option']);
                                                                            });

                                                                            //Add price
                                                                            if (widget.product.productOptions[i].priceStructure == 'Complete') {
                                                                              setState(() {
                                                                                basePrice = widget.product.productOptions[i].priceOptions[x]['Price'];
                                                                              });
                                                                            }
                                                                            //Mandatory
                                                                            if (widget.product.productOptions[i].mandatory) {
                                                                              setState(() {
                                                                                mandatoryOptions[widget.product.productOptions[i].title] = true;
                                                                              });
                                                                            }
                                                                          } else {
                                                                            setState(() {
                                                                              selectedTags.remove(widget.product.productOptions[i].priceOptions[x]['Option']);
                                                                            });
                                                                            //Mandatory
                                                                            if (widget.product.productOptions[i].mandatory) {
                                                                              setState(() {
                                                                                mandatoryOptions[widget.product.productOptions[i].title] = false;
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                        icon: (selectedTags.contains(widget.product.productOptions[i].priceOptions[x]['Option']))
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
                                                            color:
                                                                Colors.grey,
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
            //Totle and Button
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
                              setState(() {
                                quantity = quantity + 1;
                              });
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
                          backgroundColor: (mandatoryOptionsCompleted())
                              ? MaterialStateProperty.all<Color>(Colors.black)
                              : MaterialStateProperty.all<Color>(
                                  Colors.grey.shade300),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)){
                                return Colors.grey.shade300;
                              }                                
                              if (states.contains(MaterialState.focused) ||
                                  states.contains(MaterialState.pressed)){
                                    return Colors.grey.shade200;
                                  }                                                                  
                              return Colors
                                  .black; // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () {
                          if (mandatoryOptionsCompleted()) {
                            if (quantity > 0) {
                              bloc.addToCart({
                                'Name': widget.product.product,
                                'Category': widget.product.category,
                                'Price': totalAmount(basePrice, selectedTags),
                                'Quantity': quantity,
                                'Total Price':
                                    totalAmount(basePrice, selectedTags) *
                                        quantity,
                                'Options': selectedTags,
                                'Image': widget.product.image
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
                            'Agregar  |  ${formatCurrency.format(totalAmount(basePrice, selectedTags) * quantity)}',
                            style: TextStyle(
                                color: (mandatoryOptionsCompleted())
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
