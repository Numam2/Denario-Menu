// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_denario/Database/ticket.dart';
import 'package:menu_denario/Models/products.dart';

class AddToCartDialog extends StatefulWidget {
  final Products product;
  const AddToCartDialog(this.product, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddToCartDialogState createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  int quantity = 1;
  double selectedPrice = 0;
  double basePrice = 0;
  List selectedTags = [];
  final formatCurrency = NumberFormat.simpleCurrency();

  double totalAmount(
    double basePrice,
    List selectedTags,
  ) {
    double total = 0;
    List<double> additionalsList = [];
    double additionalAmount = 0;

    //Serch for base price
    for (var x in widget.product.productOptions) {
      if (x.priceStructure == 'Aditional') {
        for (var i = 0; i < x.priceOptions.length; i++) {
          if (selectedTags.contains(x.priceOptions[i]['Option'])) {
            additionalsList.add(x.priceOptions[i]['Price']);
          }
        }
      }
    }

    //Add up
    for (var y in additionalsList) {
      additionalAmount = additionalAmount + y;
    }

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
    return Center(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: SizedBox(
          width: (MediaQuery.of(context).size.width > 900)
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.width * 0.9,
          height: (MediaQuery.of(context).size.width > 900)
              ? MediaQuery.of(context).size.height * 0.8
              : MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              Container(
                width: double.infinity,
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Text
                    Text(
                      widget.product.product,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    //Close
                    Container(
                      alignment: const Alignment(1.0, 0.0),
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          iconSize: 20.0),
                    ),
                  ],
                ),
              ),
              const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  indent: 15,
                  endIndent: 15),
              const SizedBox(height: 15),
              //Details
              Expanded(
                  child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: (MediaQuery.of(context).size.width > 900)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Image
                            (widget.product.image != '')
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        color: Colors.grey[100],
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                widget.product.image),
                                            fit: BoxFit.cover)))
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        color: Colors.grey),
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
                            const SizedBox(width: 20),
                            //Details
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Price
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      formatCurrency.format(
                                          totalAmount(basePrice, selectedTags)),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  //Description
                                  (widget.product.description == '')
                                      ? Container()
                                      : SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            widget.product.description,
                                            textAlign: TextAlign.left,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )),
                                  SizedBox(
                                      height: (widget.product.description == '')
                                          ? 0
                                          : 20),
                                  //Options
                                  (widget.product.productOptions.isEmpty)
                                      ? Container()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: widget
                                              .product.productOptions.length,
                                          itemBuilder: (context, i) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget
                                                            .product
                                                            .productOptions[i]
                                                            .title,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        (widget
                                                                .product
                                                                .productOptions[
                                                                    i]
                                                                .mandatory)
                                                            ? '(Obligatorio)'
                                                            : '(Opcional)',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          5.0),
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
                                                                              .productOptions[i]
                                                                              .priceOptions[x]['Option'],
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 14,
                                                                              color: Colors.black),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        (widget.product.productOptions[i].priceStructure ==
                                                                                'Complete')
                                                                            ? Text(
                                                                                '(\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black),
                                                                              )
                                                                            : (widget.product.productOptions[i].priceStructure == 'Aditional')
                                                                                ? Text(
                                                                                    '( +\$${widget.product.productOptions[i].priceOptions[x]['Price']})',
                                                                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black),
                                                                                  )
                                                                                : const SizedBox(),
                                                                        const Spacer(),
                                                                        //Button
                                                                        (widget.product.productOptions[i].multipleOptions)
                                                                            ? IconButton(
                                                                                onPressed: () {
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
                                                                                    for (var x in widget.product.productOptions[i].priceOptions) {
                                                                                      if (selectedTags.contains(x['Option'])) {
                                                                                        selectedTags.remove(x['Option']);
                                                                                      }
                                                                                    }

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
                                                                    thickness:
                                                                        0.5,
                                                                    color: Colors
                                                                        .grey,
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          })),
                                                ],
                                              ),
                                            );
                                          }),

                                  SizedBox(
                                      height: (widget
                                              .product.productOptions.isEmpty)
                                          ? 0
                                          : 30),
                                ],
                              ),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Image
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height:
                                    MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    color: Colors.grey[100],
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(widget.product.image),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                            const SizedBox(height: 25),
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
                                : ListView.builder(
                                    shrinkWrap: true,
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
                                                  widget.product
                                                      .productOptions[i].title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                        padding:
                                                            const EdgeInsets
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
                                                                              for (var x in widget.product.productOptions[i].priceOptions) {
                                                                                if (selectedTags.contains(x['Option'])) {
                                                                                  selectedTags.remove(x['Option']);
                                                                                }
                                                                              }

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

                            SizedBox(
                                height: (widget.product.productOptions.isEmpty)
                                    ? 0
                                    : 30),
                          ],
                        ),
                ),
              )),
              const SizedBox(height: 15),
              //Action
              const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  indent: 15,
                  endIndent: 15),
              Container(
                height: (MediaQuery.of(context).size.width > 450) ? 100 : 125,
                width: double.infinity,
                padding: (MediaQuery.of(context).size.width > 900)
                    ? const EdgeInsets.all(20)
                    : (MediaQuery.of(context).size.width > 450)
                        ? const EdgeInsets.all(12)
                        : const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                child: (MediaQuery.of(context).size.width > 900)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Add/Substract items
                          Row(
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
                              const SizedBox(width: 15),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 18),
                              ), //'${cartList[i]['Quantity']}'),
                              const SizedBox(width: 15),
                              //Add
                              IconButton(
                                onPressed: () {
                                  if(widget.product.controlStock!){
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
                          ),
                          const Spacer(),
                          //Add to order button
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: (mandatoryOptionsCompleted())
                                      ? MaterialStateProperty.all<Color>(
                                          Colors.black)
                                      : MaterialStateProperty.all<Color>(
                                          Colors.grey.shade300),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered)) {
                                        return Colors.grey.shade300;
                                      }

                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states.contains(
                                              MaterialState.pressed)) {
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
                                        'Price': totalAmount(
                                            basePrice, selectedTags),
                                        'Quantity': quantity,
                                        'Total Price': totalAmount(
                                                basePrice, selectedTags) *
                                            quantity,
                                        'Options': selectedTags,
                                        'Image': widget.product.image,
                                        'Supplies': widget.product.ingredients,
                                        'Control Stock':
                                            widget.product.controlStock,
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
                                        : ' Agregar  |  ${formatCurrency.format(totalAmount(basePrice, selectedTags) * quantity)}',
                                    style: TextStyle(
                                        color: (mandatoryOptionsCompleted())
                                            ? Colors.white
                                            : Colors.black),
                                  )),
                                )),
                          ),
                        ],
                      )
                    : (MediaQuery.of(context).size.width > 450)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Add/Substract items
                              Expanded(
                                flex: 2,
                                child: Row(
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
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
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
                                        if(widget.product.controlStock!){
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
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      iconSize: 24,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              //Add to order button
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            (mandatoryOptionsCompleted())
                                                ? MaterialStateProperty.all<
                                                    Color>(Colors.black)
                                                : MaterialStateProperty.all<
                                                        Color>(
                                                    Colors.grey.shade300),
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.grey.shade300;
                                            }

                                            if (states.contains(
                                                    MaterialState.focused) ||
                                                states.contains(
                                                    MaterialState.pressed)) {
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
                                              'Category':
                                                  widget.product.category,
                                              'Price': totalAmount(
                                                  basePrice, selectedTags),
                                              'Quantity': quantity,
                                              'Total Price': totalAmount(
                                                      basePrice, selectedTags) *
                                                  quantity,
                                              'Options': selectedTags,
                                              'Image': widget.product.image,
                                              'Supplies':
                                                  widget.product.ingredients,
                                              'Control Stock':
                                                  widget.product.controlStock,
                                              'Product ID':
                                                  widget.product.productID,
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
                                                  widget.product.currentStock! <
                                                      1)
                                              ? 'Fuera de Stock'
                                              : 'Agregar  |  ${formatCurrency.format(totalAmount(basePrice, selectedTags) * quantity)}',
                                          style: TextStyle(
                                              color:
                                                  (mandatoryOptionsCompleted())
                                                      ? Colors.white
                                                      : Colors.black),
                                        )),
                                      )),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Add/Substract items
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
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
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
                                          if(widget.product.controlStock!){
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
                                        icon: const Icon(
                                            Icons.add_circle_outline),
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
                                      backgroundColor:
                                          (mandatoryOptionsCompleted())
                                              ? MaterialStateProperty.all<
                                                  Color>(Colors.black)
                                              : MaterialStateProperty.all<
                                                  Color>(Colors.grey.shade300),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.hovered)) {
                                            return Colors.grey.shade300;
                                          }
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed)) {
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
                                            'Price': totalAmount(
                                                basePrice, selectedTags),
                                            'Quantity': quantity,
                                            'Total Price': totalAmount(
                                                    basePrice, selectedTags) *
                                                quantity,
                                            'Options': selectedTags,
                                            'Image': widget.product.image,
                                            'Supplies':
                                                widget.product.ingredients,
                                            'Control Stock':
                                                widget.product.controlStock,
                                            'Product ID':
                                                widget.product.productID,
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
                                                widget.product.currentStock! <
                                                    1)
                                            ? 'Fuera de Stock'
                                            : 'Agregar  |  ${formatCurrency.format(totalAmount(basePrice, selectedTags) * quantity)}',
                                        style: TextStyle(
                                            color: (mandatoryOptionsCompleted())
                                                ? Colors.white
                                                : Colors.black),
                                      )),
                                    )),
                              ),
                            ],
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
