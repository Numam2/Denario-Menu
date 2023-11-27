// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_denario/Screens/checkout.dart';

import '../Database/ticket.dart';

class TicketView extends StatefulWidget {
  final String? businessID;
  final String businessPhone;
  final String? storeType;
  const TicketView(this.businessID, this.businessPhone, this.storeType,
      {super.key});

  @override
  _TicketViewState createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  final formatCurrency = NumberFormat.simpleCurrency();
  String orderName = '';
  final _controller = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  var orderDetail;
  Map<String, dynamic> orderCategories = {};
  Map currentValues = {};
  double subTotal = 0;
  double tax = 0;
  double discount = 0;
  double total = 0;
  Color color = Colors.white;
  String ticketConcept = '';

  @override
  void initState() {
    ticketConcept = 'Ticket';
    orderName = 'Sin Agregar';
    subTotal = 0;
    tax = 0;
    discount = 0;
    total = 0;

    super.initState();
  }

  void clearVariables() {
    bloc.removeAllFromCart();
    _controller.clear();

    setState(() {
      ticketConcept = 'Ticket';
      discount = 0;
      tax = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final categoriesProvider = Provider.of<CategoryList>(context);

    // if (categoriesProvider == null) {
    //   return Container();
    // }

    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            final data = snapshot.data as Map;

            subTotal = data['Subtotal'];
            tax = data['Tax'];
            discount = data["Discount"];
            total = data["Total"];
            orderName = data["Order Name"];
            color = data["Color"];

            for (var i = 0; i < bloc.ticketItems['Items'].length; i++) {
              subTotal += bloc.ticketItems['Items'][i]["Price"] *
                  bloc.ticketItems['Items'][i]["Quantity"];
            }

            total = (subTotal + ((subTotal * tax).round())) - discount;

            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Go Back
                      (MediaQuery.of(context).size.width < 900)
                          ? IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 20,
                              ))
                          : Container(),
                      //Title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(children: [
                          const Text(
                            'Mi pedido',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '(${data["Items"].length})',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                      ),
                      //List of Products
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: data["Items"].length,
                              itemBuilder: (context, i) {
                                final cartList = data["Items"];
                                orderDetail = cartList;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //Image
                                        (cartList[i]['Image'] != '')
                                            ? Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                    color: Colors.grey[100],
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            cartList[i]
                                                                ['Image']),
                                                        fit: BoxFit.cover)))
                                            : Container(
                                                width: 100,
                                                height: 100,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                  color: Colors.grey,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    cartList[i]['Name']
                                                        .substring(0, 2),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                        const SizedBox(width: 10),
                                        //Column Name + Qty
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //Name
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child:
                                                    Text(cartList[i]['Name']),
                                              ),
                                              //Options
                                              (cartList[i]['Options'].isEmpty)
                                                  ? const SizedBox()
                                                  // : SizedBox(),
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                          cartList[i]['Options']
                                                              .join(', '),
                                                          maxLines: 6,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12)),
                                                    ),
                                              //Quantity
                                              Row(
                                                children: [
                                                  //Remove
                                                  IconButton(
                                                    onPressed: () {
                                                      if (cartList[i]
                                                              ['Quantity'] >
                                                          0) {
                                                        setState(() {
                                                          bloc.removeQuantity(
                                                              i);
                                                        });
                                                      }
                                                    },
                                                    icon: const Icon(Icons
                                                        .remove_circle_outline),
                                                    iconSize: 16,
                                                  ),
                                                  Text(
                                                      '${cartList[i]['Quantity']}'),
                                                  //Add
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        bloc.addQuantity(i);
                                                      });
                                                    },
                                                    icon: const Icon(Icons
                                                        .add_circle_outline),
                                                    iconSize: 16,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        //Amount
                                        Text(formatCurrency.format(
                                            cartList[i]['Total Price'])),
                                        const SizedBox(width: 10),
                                        //Delete
                                        IconButton(
                                            onPressed: () => bloc
                                                .removeFromCart(cartList[i]),
                                            icon: const Icon(Icons.close),
                                            iconSize: 14)
                                      ]),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      //Actions (Save, Process)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Pagar
                          Expanded(
                              child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (data["Items"].length > 0)
                                    ? Colors.black
                                    : Colors.grey.shade300,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                if (data["Items"].length > 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => StoreCheckout(
                                              total,
                                              widget.businessID,
                                              widget.businessPhone,
                                              widget.storeType!)));
                                }
                              },
                              child: Center(
                                  child: Text(
                                      (ticketConcept == 'Ticket')
                                          ? 'Pagar ${formatCurrency.format(total)}'
                                          : 'Registrar',
                                      style: TextStyle(
                                          color: (data["Items"].length > 0)
                                              ? Colors.white
                                              : Colors.grey,
                                          fontWeight: FontWeight.w400))),
                            ),
                          )),
                        ],
                      )
                    ]));
          } else {
            return Container();
          }
        });
  }
}
