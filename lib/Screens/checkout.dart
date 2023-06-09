// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menu_denario/Screens/orders_successful.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Database/database_service.dart';
import '../Database/ticket.dart';

class StoreCheckout extends StatefulWidget {
  final double total;
  final String? businessID;
  final String businessPhone;
  const StoreCheckout(this.total, this.businessID, this.businessPhone,
      {super.key});

  @override
  State<StoreCheckout> createState() => StoreCheckoutState();
}

class StoreCheckoutState extends State<StoreCheckout> {
  final formatCurrency = NumberFormat.simpleCurrency();
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String apt = '';
  int phone = 0;
  String paymentType = '';
  String orderMessage = '';
  String orderItems = '';
  late FocusNode nameNode;
  late FocusNode addressNode;
  late FocusNode aptNode;
  late FocusNode phoneNode;
  bool paymentTypeSelected = true;
  bool delivery = true;
  String orderType = 'Delivery';
  List takeawayPaymentMethods = [
    {'Image': 'Images/Cash.png', 'Type': 'Efectivo'},
    {'Image': 'Images/Bank.png', 'Type': 'Transferencia'},
    {'Image': 'Images/MP.png', 'Type': 'MercadoPago'},
  ];
  List deliveryPaymentMethods = [
    {'Image': 'Images/Bank.png', 'Type': 'Transferencia'},
    {'Image': 'Images/MP.png', 'Type': 'MercadoPago'},
  ];
  openWhatsapp(businessPhone) {
    var whatsapp = Uri.parse("https://wa.me/$businessPhone?text=$orderMessage");
    launchUrl(whatsapp);
  }

  @override
  void initState() {
    super.initState();

    nameNode = FocusNode();
    addressNode = FocusNode();
    aptNode = FocusNode();
    phoneNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            final data = snapshot.data as Map;
            if (MediaQuery.of(context).size.width > 750) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      iconSize: 24),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Text(
                            'Checkout',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // //Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Delivery info
                                Expanded(
                                  flex: 6,
                                  child: Form(
                                    key: _formKey,
                                    child: Container(
                                      padding: const EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: const Offset(0.0, 0.0),
                                            blurRadius: 10.0,
                                          )
                                        ],
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //Delivery
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 45,
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: delivery
                                                          ? Colors.white
                                                          : Colors
                                                              .greenAccent[400],
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        8)),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        delivery = false;
                                                        address = '';
                                                        apt = '';
                                                        orderType = 'Takeaway';
                                                      });
                                                    },
                                                    child: Center(
                                                        child: Text('Retiro',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: delivery
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .white,
                                                            ))),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 100,
                                                  height: 45,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: delivery
                                                          ? Colors
                                                              .greenAccent[400]
                                                          : Colors.white,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        8),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            8)),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        delivery = true;
                                                        orderType = 'Delivery';
                                                      });
                                                    },
                                                    child: Center(
                                                        child: Text('Delivery',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: delivery
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                            ))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            //Nombre
                                            const Text(
                                              'Nombre',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              focusNode: nameNode,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              autofocus: true,
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty) {
                                                  return "Agregá un nombre";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    45)
                                              ],
                                              cursorColor: Colors.grey,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                setState(() => name = val);
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                            //Direccion
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Dirección',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      TextFormField(
                                                        focusNode: addressNode,
                                                        enabled: delivery
                                                            ? true
                                                            : false,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                        autofocus: true,
                                                        validator: (val) {
                                                          if (delivery &&
                                                              (val == null ||
                                                                  val.isEmpty)) {
                                                            return "No olvides agregar una dirección";
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              45)
                                                        ],
                                                        cursorColor:
                                                            Colors.grey,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (val) {
                                                          setState(() =>
                                                              address = val);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                //Dpto (timbre)
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Nro de Timbre',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      TextFormField(
                                                        focusNode: aptNode,
                                                        enabled: delivery
                                                            ? true
                                                            : false,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                        autofocus: true,
                                                        validator: (val) {
                                                          if (delivery &&
                                                              (val == null ||
                                                                  val.isEmpty)) {
                                                            return "Agregá un timbre";
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              4)
                                                        ],
                                                        cursorColor:
                                                            Colors.grey,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (val) {
                                                          setState(
                                                              () => apt = val);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            //Nro celular
                                            const Text(
                                              'Nro Whatsapp',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              focusNode: phoneNode,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              autofocus: true,
                                              validator: (val) {
                                                if (val == null ||
                                                    val.isEmpty ||
                                                    val.length < 8) {
                                                  return "El número debe tener 8 caracteres (sin el 11)";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    8),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              cursorColor: Colors.grey,
                                              decoration: InputDecoration(
                                                prefixIcon: const Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            20, 10, 2, 10),
                                                    child: Text(('(11) '))),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                setState(() => phone =
                                                    int.parse('11$val'));
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                            //Metodo de pago
                                            Row(children: [
                                              const Text(
                                                'Método de pago',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                  (!paymentTypeSelected)
                                                      ? 'Selecciona un método de pago'
                                                      : '',
                                                  style: const TextStyle(
                                                      color: Colors.red))
                                            ]),
                                            delivery
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      '*El costo del delivery no está incluido en el precio',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(height: 15),
                                            SizedBox(
                                              height: 50,
                                              width: double.infinity,
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: (delivery)
                                                      ? deliveryPaymentMethods
                                                          .length
                                                      : takeawayPaymentMethods
                                                          .length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, i) {
                                                    List paymentMethods;
                                                    if (delivery) {
                                                      paymentMethods =
                                                          deliveryPaymentMethods;
                                                    } else {
                                                      paymentMethods =
                                                          takeawayPaymentMethods;
                                                    }
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            paymentTypeSelected =
                                                                true;
                                                            paymentType =
                                                                paymentMethods[
                                                                    i]['Type'];
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            8)),
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color: (paymentType ==
                                                                            paymentMethods[i][
                                                                                'Type'])
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .grey
                                                                            .shade300,
                                                                    width: 2),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  paymentMethods[
                                                                          i]
                                                                      ['Type'],
                                                                  style: TextStyle(
                                                                      color: (paymentType ==
                                                                              paymentMethods[i][
                                                                                  'Type'])
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .grey,
                                                                      fontWeight: (paymentType ==
                                                                              paymentMethods[i][
                                                                                  'Type'])
                                                                          ? FontWeight
                                                                              .bold
                                                                          : FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              )),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            const SizedBox(height: 5),
                                            //Button
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                SizedBox(
                                                  height: 45,
                                                  width: 150,
                                                  child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.black,
                                                        side: const BorderSide(
                                                            color: Colors.black,
                                                            width: 1),
                                                      ),
                                                      onPressed: () {
                                                        //%20 = Space //%0A Another Line
                                                        //%3A = : //%24 = $

                                                        if (_formKey
                                                                .currentState!
                                                                .validate() &&
                                                            paymentType != '') {
                                                          for (var i in data[
                                                              'Items']) {
                                                            orderItems =
                                                                orderItems +
                                                                    ('${i['Quantity']} ${i['Name']}%0A');
                                                          }

                                                          DatabaseService().createOrder(
                                                              '${widget.businessID}',
                                                              name,
                                                              '$address - $apt',
                                                              phone,
                                                              data['Items'],
                                                              paymentType,
                                                              widget.total,
                                                              orderType);

                                                          orderMessage =
                                                              'Nombre: $name %0ADelivery/Retiro: $orderType %0ADirección: $address Timbre: $apt %0ANro. Teléfono: $phone %0AMedio de Pago: $paymentType %0A%0AOrden:%0A$orderItems %0ATotal: %24${widget.total}';

                                                          openWhatsapp(widget
                                                              .businessPhone);

                                                          bloc.removeAllFromCart();

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      OrderSuccessful(
                                                                          widget
                                                                              .businessID)));
                                                        } else if (paymentType ==
                                                            '') {
                                                          setState(() {
                                                            paymentTypeSelected =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Center(
                                                            child: Text(
                                                          'Pedir',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                      )),
                                                ),
                                              ],
                                            )
                                          ]),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),
                                //Items
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 450,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //Title
                                            const Text(
                                              'Mi Pedido',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            //List of Products
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        data["Items"].length,
                                                    itemBuilder: (context, i) {
                                                      final cartList =
                                                          data["Items"];

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              //Column Name + Qty
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    //Name
                                                                    Container(
                                                                      constraints:
                                                                          const BoxConstraints(
                                                                              maxWidth: 150),
                                                                      child: Text(
                                                                          '${cartList[i]['Name']} (${cartList[i]['Quantity']})'),
                                                                    ),
                                                                    //Options
                                                                    (cartList[i]['Options']
                                                                            .isEmpty)
                                                                        ? const SizedBox()
                                                                        // : SizedBox(),
                                                                        : Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 5),
                                                                            child: Text(cartList[i]['Options'].join(', '),
                                                                                maxLines: 6,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                                          ),
                                                                  ],
                                                                ),
                                                              ),
                                                              //Amount
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(formatCurrency
                                                                  .format(cartList[
                                                                          i][
                                                                      'Total Price'])),
                                                            ]),
                                                      );
                                                    }),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Divider(
                                                color: Colors.grey,
                                                thickness: 0.5,
                                                indent: 15,
                                                endIndent: 15),
                                            const SizedBox(height: 10),
                                            //Total
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'Total',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Text(
                                                  'ARS',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  formatCurrency
                                                      .format(widget.total),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                          ])),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      iconSize: 24),
                  title: const Center(
                    child: Text(
                      'Checkout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Datos
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Delivery
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 100,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: delivery
                                              ? Colors.white
                                              : Colors.greenAccent[400],
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8)),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            delivery = false;
                                            address = '';
                                            apt = '';
                                            orderType = 'Takeaway';
                                          });
                                        },
                                        child: Center(
                                            child: Text('Retiro',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: delivery
                                                      ? Colors.grey
                                                      : Colors.white,
                                                ))),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      height: 45,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: delivery
                                              ? Colors.greenAccent[400]
                                              : Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight:
                                                    Radius.circular(8)),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            delivery = true;
                                            orderType = 'Delivery';
                                          });
                                        },
                                        child: Center(
                                            child: Text('Delivery',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: delivery
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ))),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                //Name
                                TextFormField(
                                  focusNode: nameNode,
                                  autofocus: true,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Agregá un nombre";
                                    } else {
                                      return null;
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(45)
                                  ],
                                  cursorColor: Colors.grey,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  decoration: InputDecoration(
                                    label: const Text('Nombre'),
                                    labelStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    setState(() => name = val);
                                  },
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () {
                                    nameNode.unfocus();
                                    addressNode.requestFocus();
                                  },
                                ),
                                const SizedBox(height: 20),
                                //Direccion
                                (delivery)
                                    ? TextFormField(
                                        focusNode: addressNode,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        autofocus: true,
                                        validator: (val) {
                                          if (delivery &&
                                              (val == null || val.isEmpty)) {
                                            return "No olvides agregar una dirección";
                                          } else {
                                            return null;
                                          }
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(45)
                                        ],
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          label: const Text('Dirección'),
                                          labelStyle: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.text,
                                        onChanged: (val) {
                                          setState(() => address = val);
                                        },
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          addressNode.unfocus();
                                          aptNode.requestFocus();
                                        },
                                      )
                                    : const SizedBox(),
                                SizedBox(height: delivery ? 20 : 0),
                                //Dpto (timbre)
                                (delivery)
                                    ? TextFormField(
                                        focusNode: aptNode,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        autofocus: true,
                                        validator: (val) {
                                          if (delivery &&
                                              (val == null || val.isEmpty)) {
                                            return "Agregá un nro de timbre";
                                          } else {
                                            return null;
                                          }
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(45)
                                        ],
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          label: const Text('Timbre/Dpto'),
                                          labelStyle: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.text,
                                        onChanged: (val) {
                                          setState(() => apt = val);
                                        },
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          aptNode.unfocus();
                                          phoneNode.requestFocus();
                                        },
                                      )
                                    : const SizedBox(),
                                SizedBox(height: delivery ? 20 : 0),
                                //Nro celular
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  focusNode: phoneNode,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  autofocus: true,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "El número debe tener 8 caracteres (sin el 11)";
                                    } else {
                                      return null;
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(8),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  cursorColor: Colors.grey,
                                  decoration: InputDecoration(
                                    prefixIcon: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 10, 2, 10),
                                        child: Text(('(11) '))),
                                    label: const Text('Nro. Whatsapp'),
                                    labelStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: () {
                                    phoneNode.unfocus();
                                  },
                                  onChanged: (val) {
                                    setState(() => phone = int.parse('11$val'));
                                  },
                                ),
                                const SizedBox(height: 20),
                                //Metodo de pago
                                const Text(
                                  'Método de pago',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                delivery
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          '*El costo del delivery no está incluido en el precio',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 15),
                                SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (delivery)
                                          ? deliveryPaymentMethods.length
                                          : takeawayPaymentMethods.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, i) {
                                        List paymentMethods;
                                        if (delivery) {
                                          paymentMethods =
                                              deliveryPaymentMethods;
                                        } else {
                                          paymentMethods =
                                              takeawayPaymentMethods;
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                paymentTypeSelected = true;
                                                paymentType =
                                                    paymentMethods[i]['Type'];
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(8)),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: (paymentType ==
                                                                paymentMethods[
                                                                    i]['Type'])
                                                            ? Colors.green
                                                            : Colors
                                                                .grey.shade300,
                                                        width: 2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      paymentMethods[i]['Type'],
                                                      style: TextStyle(
                                                          color: (paymentType ==
                                                                  paymentMethods[
                                                                          i]
                                                                      ['Type'])
                                                              ? Colors.black
                                                              : Colors.grey,
                                                          fontWeight: (paymentType ==
                                                                  paymentMethods[
                                                                          i]
                                                                      ['Type'])
                                                              ? FontWeight.bold
                                                              : FontWeight.w400,
                                                          fontSize: 14),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      //Button
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                            ),
                            onPressed: () {
                              //%20 = Space //%0A Another Line
                              //%3A = : //%24 = $

                              if (_formKey.currentState!.validate() &&
                                  paymentType != '') {
                                for (var i in data['Items']) {
                                  orderItems = orderItems +
                                      ('${i['Quantity']} ${i['Name']}%0A');
                                }

                                DatabaseService().createOrder(
                                    '${widget.businessID}',
                                    name,
                                    '$address - $apt',
                                    phone,
                                    data['Items'],
                                    paymentType,
                                    widget.total,
                                    orderType);

                                orderMessage =
                                    'Nombre: $name %0ADelivery/Retiro: $orderType %0ADirección: $address Timbre: $apt %0ANro. Teléfono: $phone %0AMedio de Pago: $paymentType %0A%0AOrden:%0A$orderItems %0ATotal: %24${widget.total}';

                                openWhatsapp(widget.businessPhone);
                                //Create order in Firestore "Saved"

                                bloc.removeAllFromCart();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderSuccessful(
                                            widget.businessID)));
                              } else if (paymentType == '') {
                                setState(() {
                                  paymentTypeSelected = false;
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text(
                                'Pedir',
                                style: TextStyle(color: Colors.white),
                              )),
                            )),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }
}
