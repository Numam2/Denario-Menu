// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:menu_denario/Screens/add_discount_dialog.dart';
import 'package:menu_denario/Screens/opening_hours_grid.dart';
import 'package:menu_denario/Screens/orders_successful.dart';
import 'package:menu_denario/Screens/reserve_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Database/database_service.dart';
import '../Database/ticket.dart';

class StoreCheckout extends StatefulWidget {
  final double total;
  final String? businessID;
  final String businessPhone;
  final String storeType;
  final List businessSchedule;
  const StoreCheckout(this.total, this.businessID, this.businessPhone,
      this.storeType, this.businessSchedule,
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
  String phone = '';
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

  //Schedule
  DateTime selectedDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 00);
  final FocusNode _emailNode = FocusNode();
  final FocusNode _noteNode = FocusNode();
  String email = '';
  String note = '';
  PageController pageController = PageController();
  void openSchedule() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        helpText: 'Día de retiro',
        confirmText: 'Guardar',
        cancelText: 'Cancelar',
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 150)),
        builder: ((context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black, // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.black, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // button text color
                  ),
                ),
              ),
              child: child!);
        }));
    if (pickedDate != null) {
      setState(() {
        selectedDate =
            DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 10);
      });
    }
  }

  void openTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Horario de retiro',
        confirmText: 'Guardar',
        cancelText: 'Cancelar',
        hourLabelText: 'Hora',
        minuteLabelText: 'Minuto',
        initialTime: const TimeOfDay(hour: 10, minute: 00),
        builder: ((context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black, // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.black, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // button text color
                  ),
                ),
              ),
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!));
        }));
    if (pickedTime != null) {
      setState(() {
        selectedDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  void setTime(TimeOfDay? selectedTime) {
    if (selectedTime != null) {
      setState(() {
        reservationTime = selectedTime;
        selectedDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  TimeOfDay? reservationTime;

  String clarificationMessage =
      '** Para confirmar la reserva por favor envíe el mensaje por whatsapp en el siguiente paso y nos pondremos en contacto lo antes posible para coordinar el pago';
  bool loading = false;
  String errorMessage =
      'Ups! Ocurrió un error, puede ser la conexión. Intentalo de nuevo';
  bool showError = false;

  void setLoading(bool load) {
    setState(() {
      loading = load;
    });
  }

  void setShowError(bool show) {
    setState(() {
      showError = show;
    });
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
    if (widget.storeType == 'Menu' || widget.storeType == 'Store') {
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
                                                            : Colors.greenAccent[
                                                                400],
                                                        padding:
                                                            const EdgeInsets
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
                                                          orderType =
                                                              'Takeaway';
                                                        });
                                                      },
                                                      child: Center(
                                                          child: Text('Retiro',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: delivery
                                                                    ? Colors
                                                                        .grey
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
                                                        padding:
                                                            const EdgeInsets
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
                                                                      Radius.circular(
                                                                          8)),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          delivery = true;
                                                          orderType =
                                                              'Delivery';
                                                        });
                                                      },
                                                      child: Center(
                                                          child: Text(
                                                              'Delivery',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: delivery
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .grey,
                                                              ))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              //Nombre
                                              const Text(
                                                'Nombre y apellido',
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
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
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
                                                          MainAxisAlignment
                                                              .start,
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
                                                        const SizedBox(
                                                            height: 8),
                                                        TextFormField(
                                                          focusNode:
                                                              addressNode,
                                                          enabled: delivery
                                                              ? true
                                                              : false,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
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
                                                                color:
                                                                    Colors.red,
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
                                                                color: Colors
                                                                    .green,
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
                                                          MainAxisAlignment
                                                              .start,
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
                                                        const SizedBox(
                                                            height: 8),
                                                        TextFormField(
                                                          focusNode: aptNode,
                                                          enabled: delivery
                                                              ? true
                                                              : false,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
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
                                                                color:
                                                                    Colors.red,
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
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          onChanged: (val) {
                                                            setState(() =>
                                                                apt = val);
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
                                              SizedBox(
                                                height: 45,
                                                width: double.infinity,
                                                child: IntlPhoneField(
                                                  focusNode: phoneNode,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      )),
                                                  languageCode: "es",
                                                  initialCountryCode: 'AR',
                                                  disableLengthCheck: true,
                                                  initialValue: '',
                                                  showCountryFlag: false,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  onChanged: (nO) {
                                                    setState(() => phone =
                                                        nO.completeNumber);
                                                  },
                                                ),
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
                                                      padding: EdgeInsets.only(
                                                          top: 8),
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
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    3.0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              paymentTypeSelected =
                                                                  true;
                                                              paymentType =
                                                                  paymentMethods[
                                                                          i]
                                                                      ['Type'];
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
                                                                            i][
                                                                        'Type'],
                                                                    style: TextStyle(
                                                                        color: (paymentType == paymentMethods[i]['Type'])
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .grey,
                                                                        fontWeight: (paymentType == paymentMethods[i]['Type'])
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
                                                    width: 200,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        foregroundColor: Colors
                                                            .grey.shade300,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AddDiscountDialog(
                                                                  widget
                                                                      .businessID!);
                                                            });
                                                      },
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.sell_outlined,
                                                            size: 21,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                              'Código promocional',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    height: 45,
                                                    width: 150,
                                                    child: OutlinedButton(
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.black,
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1),
                                                        ),
                                                        onPressed: () {
                                                          //%20 = Space //%0A Another Line
                                                          //%3A = : //%24 = $

                                                          if (_formKey
                                                                  .currentState!
                                                                  .validate() &&
                                                              paymentType !=
                                                                  '') {
                                                            for (var i in data[
                                                                'Items']) {
                                                              orderItems =
                                                                  orderItems +
                                                                      ('${i['Quantity']} ${i['Name']}%0A');
                                                            }

                                                            orderMessage =
                                                                'Nombre: $name %0ADelivery/Retiro: $orderType %0ADirección: $address Timbre: $apt %0ANro. Teléfono: $phone %0AMedio de Pago: $paymentType %0A%0AOrden:%0A$orderItems %0ATotal: ${formatCurrency.format(bloc.totalTicketAmount)}';

                                                            DatabaseService().saveOrder(
                                                                '${widget.businessID}',
                                                                name,
                                                                '$address - $apt',
                                                                phone,
                                                                data['Items'],
                                                                paymentType,
                                                                bloc.totalTicketAmount,
                                                                orderType,
                                                                data['Discount'],
                                                                data['Discount Code']);

                                                            openWhatsapp(widget
                                                                .businessPhone);

                                                            bloc.removeAllFromCart();

                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        OrderSuccessful(
                                                                            widget.businessID)));
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
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Center(
                                                              child: Text(
                                                            'Pedir',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                        )),
                                                  ),
                                                ],
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 40),
                                  //Items
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                      itemBuilder:
                                                          (context, i) {
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
                                                                            const BoxConstraints(maxWidth: 150),
                                                                        child: Text(
                                                                            '${cartList[i]['Name']} (${cartList[i]['Quantity']})'),
                                                                      ),
                                                                      //Options
                                                                      (cartList[i]['Options']
                                                                              .isEmpty)
                                                                          ? const SizedBox()
                                                                          // : SizedBox(),
                                                                          : Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                                                              child: Text(cartList[i]['Options'].join(', '), maxLines: 6, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                                              (data['Discount'] != null &&
                                                      data['Discount'] > 0)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                          const Icon(
                                                            Icons.sell_outlined,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          //Column Name + Qty
                                                          (snapshot.data[
                                                                      "Discount Code"] !=
                                                                  '')
                                                              ? Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          maxWidth:
                                                                              150),
                                                                  child: Text(
                                                                    snapshot.data[
                                                                        "Discount Code"],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          maxWidth:
                                                                              150),
                                                                  child: Text(
                                                                    'Descuento',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700),
                                                                  ),
                                                                ),
                                                          //Amount
                                                          const Spacer(),
                                                          Text(
                                                              formatCurrency
                                                                  .format(snapshot
                                                                          .data[
                                                                      "Discount"]),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700)),
                                                          const SizedBox(
                                                              width: 10),
                                                          //Delete
                                                          IconButton(
                                                              onPressed: () => bloc
                                                                  .setDiscountAmount(
                                                                      0),
                                                              icon: const Icon(
                                                                  Icons.close),
                                                              iconSize: 14)
                                                        ])
                                                  : const SizedBox(),
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Text(
                                                    'ARS',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    formatCurrency.format(
                                                        bloc.totalTicketAmount),
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
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
                      centerTitle: true,
                      actions: const []),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  bottomLeft:
                                                      Radius.circular(8)),
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
                                      label: const Text('Nombre y apellido'),
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
                                              color: Colors.black,
                                              fontSize: 14),
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
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            label: const Text('Dirección'),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
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
                                              color: Colors.black,
                                              fontSize: 14),
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
                                                color: Colors.grey,
                                                fontSize: 12),
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
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.text,
                                          onChanged: (val) {
                                            setState(() => apt = val);
                                          },
                                          onEditingComplete: () {
                                            aptNode.unfocus();
                                            phoneNode.requestFocus();
                                          },
                                        )
                                      : const SizedBox(),
                                  SizedBox(height: delivery ? 20 : 0),
                                  //Nro celular
                                  SizedBox(
                                    height: 45,
                                    width: double.infinity,
                                    child: IntlPhoneField(
                                      focusNode: phoneNode,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          )),
                                      languageCode: "es",
                                      initialCountryCode: 'AR',
                                      disableLengthCheck: true,
                                      initialValue: '',
                                      showCountryFlag: false,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (nO) {
                                        setState(
                                            () => phone = nO.completeNumber);
                                      },
                                    ),
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
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  8)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: (paymentType ==
                                                                  paymentMethods[
                                                                          i]
                                                                      ['Type'])
                                                              ? Colors.green
                                                              : Colors.grey
                                                                  .shade300,
                                                          width: 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        paymentMethods[i]
                                                            ['Type'],
                                                        style: TextStyle(
                                                            color: (paymentType ==
                                                                    paymentMethods[
                                                                            i][
                                                                        'Type'])
                                                                ? Colors.black
                                                                : Colors.grey,
                                                            fontWeight: (paymentType ==
                                                                    paymentMethods[
                                                                            i][
                                                                        'Type'])
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w400,
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
                        //Coupon
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade300,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddDiscountDialog(
                                        widget.businessID!);
                                  });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.sell_outlined,
                                  size: 21,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                    (data['Discount'] != null &&
                                            data['Discount'] > 0)
                                        ? '${snapshot.data["Discount Code"]} (${formatCurrency.format(snapshot.data["Discount"])})'
                                        : 'Código promocional',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              ],
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

                                  DatabaseService().saveOrder(
                                      '${widget.businessID}',
                                      name,
                                      '$address - $apt',
                                      phone,
                                      data['Items'],
                                      paymentType,
                                      bloc.totalTicketAmount,
                                      orderType,
                                                                data['Discount'],
                                                                data['Discount Code']);

                                  orderMessage =
                                      'Nombre: $name %0ADelivery/Retiro: $orderType %0ADirección: $address Timbre: $apt %0ANro. Teléfono: $phone %0AMedio de Pago: $paymentType %0A%0AOrden:%0A$orderItems %0ATotal: ${formatCurrency.format(bloc.totalTicketAmount)}';

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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  'Pedir (${formatCurrency.format(bloc.totalTicketAmount)})',
                                  style: const TextStyle(color: Colors.white),
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
    } else if (widget.storeType == 'Reservation') {
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          iconSize: 24),
                      title: const Text(
                        'Reservar',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      centerTitle: true,
                      actions: const [
                        SizedBox(width: 50),
                      ]),
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Padding(
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
                                              //Name
                                              TextFormField(
                                                focusNode: nameNode,
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
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                                decoration: InputDecoration(
                                                  label: const Text(
                                                      'Nombre y apellido'),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                onFieldSubmitted: (term) {
                                                  nameNode.unfocus();
                                                  openSchedule();
                                                },
                                                onChanged: (val) {
                                                  setState(() => name = val);
                                                },
                                                textInputAction:
                                                    TextInputAction.next,
                                                onEditingComplete: () {
                                                  nameNode.unfocus();
                                                  addressNode.requestFocus();
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              //Fecha
                                              const Text(
                                                'Agendar para:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Colors.black45),
                                              ),
                                              const SizedBox(height: 10),
                                              //Date
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                      child: OutlinedButton(
                                                        onPressed: openSchedule,
                                                        style: OutlinedButton.styleFrom(
                                                            side: const BorderSide(
                                                                color: Colors
                                                                    .transparent)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'dd/MM/yyyy')
                                                                  .format(
                                                                      selectedDate),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            SizedBox(
                                                              height: 20,
                                                              width: 20,
                                                              child: IconButton(
                                                                splashRadius: 1,
                                                                color: Colors
                                                                    .black,
                                                                onPressed:
                                                                    openSchedule,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                tooltip:
                                                                    'Seleccionar fecha',
                                                                iconSize: 18,
                                                                icon: const Icon(
                                                                    Icons
                                                                        .calendar_month),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  //Time
                                                  Expanded(
                                                    child: Container(
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                      child: OutlinedButton(
                                                        onPressed: openTime,
                                                        style: OutlinedButton.styleFrom(
                                                            side: const BorderSide(
                                                                color: Colors
                                                                    .transparent)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'HH:mm')
                                                                  .format(
                                                                      selectedDate),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            SizedBox(
                                                              height: 20,
                                                              width: 20,
                                                              child: IconButton(
                                                                color: Colors
                                                                    .black,
                                                                splashRadius: 1,
                                                                onPressed:
                                                                    openTime,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                tooltip:
                                                                    'Horario',
                                                                iconSize: 18,
                                                                icon: const Icon(
                                                                    Icons
                                                                        .av_timer),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              //Contacto
                                              // Tlf y mail
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Contacto',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        color: Colors.black45),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              //Tlf
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 45,
                                                      child: IntlPhoneField(
                                                        focusNode: phoneNode,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0),
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0),
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                )),
                                                        languageCode: "es",
                                                        initialCountryCode:
                                                            'AR',
                                                        disableLengthCheck:
                                                            true,
                                                        initialValue: '',
                                                        showCountryFlag: false,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        onChanged: (nO) {
                                                          setState(() => phone =
                                                              nO.completeNumber);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  //Mail
                                                  Expanded(
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                      cursorColor: Colors.grey,
                                                      focusNode: _emailNode,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'email (opcional)',
                                                        hintStyle:
                                                            const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12),
                                                        prefixIcon: const Icon(
                                                          Icons.mail_outline,
                                                          color: Colors.grey,
                                                        ),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.grey,
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
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onFieldSubmitted: (term) {
                                                        _emailNode.unfocus();
                                                        _noteNode
                                                            .requestFocus();
                                                      },
                                                      onChanged: (val) {
                                                        setState(
                                                            () => email = val);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              //Nota
                                              const Text(
                                                'Nota',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Colors.black45),
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                maxLines: 4,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16),
                                                cursorColor: Colors.grey,
                                                focusNode: _noteNode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                decoration: InputDecoration(
                                                  hintText: 'Agrega una nota',
                                                  hintStyle: const TextStyle(
                                                      fontSize: 14),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                onFieldSubmitted: (term) {
                                                  _noteNode.unfocus();
                                                },
                                                onChanged: (val) {
                                                  setState(() {
                                                    note = val;
                                                  });
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              (showError)
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                              errorMessage,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .redAccent,
                                                                fontSize: 12,
                                                              ))))
                                                  : const SizedBox(),

                                              //Button
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      child: Text(
                                                        clarificationMessage,
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 5,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  SizedBox(
                                                    height: 45,
                                                    width: 200,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        foregroundColor: Colors
                                                            .grey.shade300,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AddDiscountDialog(
                                                                  widget
                                                                      .businessID!);
                                                            });
                                                      },
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.sell_outlined,
                                                            size: 21,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                              'Código promocional',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ReserveButton(
                                                      widget.businessID!,
                                                      widget.businessPhone,
                                                      selectedDate,
                                                      _formKey,
                                                      data,
                                                      bloc.totalTicketAmount,
                                                      name,
                                                      note,
                                                      address,
                                                      email,
                                                      phone,
                                                      reservationTime,
                                                      pageController),
                                                ],
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 40),
                                  //Items
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                      itemBuilder:
                                                          (context, i) {
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
                                                                            const BoxConstraints(maxWidth: 150),
                                                                        child: Text(
                                                                            '${cartList[i]['Name']} (${cartList[i]['Quantity']})'),
                                                                      ),
                                                                      //Options
                                                                      (cartList[i]['Options']
                                                                              .isEmpty)
                                                                          ? const SizedBox()
                                                                          // : SizedBox(),
                                                                          : Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                                                              child: Text(cartList[i]['Options'].join(', '), maxLines: 6, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                                              (data['Discount'] != null &&
                                                      data['Discount'] > 0)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                          const Icon(
                                                            Icons.sell_outlined,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          //Column Name + Qty
                                                          (snapshot.data[
                                                                      "Discount Code"] !=
                                                                  '')
                                                              ? Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          maxWidth:
                                                                              150),
                                                                  child: Text(
                                                                    snapshot.data[
                                                                        "Discount Code"],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          maxWidth:
                                                                              150),
                                                                  child: Text(
                                                                    'Descuento',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700),
                                                                  ),
                                                                ),
                                                          //Amount
                                                          const Spacer(),
                                                          Text(
                                                              formatCurrency
                                                                  .format(snapshot
                                                                          .data[
                                                                      "Discount"]),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700)),
                                                          const SizedBox(
                                                              width: 10),
                                                          //Delete
                                                          IconButton(
                                                              onPressed: () => bloc
                                                                  .setDiscountAmount(
                                                                      0),
                                                              icon: const Icon(
                                                                  Icons.close),
                                                              iconSize: 14)
                                                        ])
                                                  : const SizedBox(),
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Text(
                                                    'ARS',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    formatCurrency.format(
                                                        bloc.totalTicketAmount),
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                            ])),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      //Loading?
                      loading
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.withOpacity(0.5),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.blueGrey.shade900,
                              )))
                          : const SizedBox()
                    ],
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        iconSize: 24),
                    actions: const [
                      SizedBox(width: 50),
                    ],
                    title: const Center(
                      child: Text(
                        'Reservar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  body: Stack(
                    children: [
                      PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          //Time/Date
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Datos
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Fecha
                                        const Row(
                                          children: [
                                            Text(
                                              'Agendar para:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        //Calendar
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: Colors
                                                  .black, // header background color
                                              onPrimary: Colors
                                                  .white, // header text color
                                              onSurface: Colors
                                                  .black, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // button text color
                                              ),
                                            ),
                                          ),
                                          child: CalendarDatePicker(
                                              initialDate: DateTime.now()
                                                  .add(const Duration(days: 1)),
                                              firstDate: DateTime.now()
                                                  .add(const Duration(days: 1)),
                                              lastDate: DateTime.now().add(
                                                  const Duration(days: 150)),
                                              onDateChanged:
                                                  (DateTime? pickedDate) {
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    reservationTime = null;
                                                    selectedDate = DateTime(
                                                        pickedDate.year,
                                                        pickedDate.month,
                                                        pickedDate.day,
                                                        10);
                                                  });
                                                }
                                              }),
                                        ),
                                        const SizedBox(height: 10),

                                        ///Times as grid
                                        ///If !Opens alert not available
                                        ///Create list of half hours from open hour to close hour
                                        const Text(
                                          'Horarios disponibles',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        (widget.businessSchedule[selectedDate.weekday - 1]['Opens'])
                                            ? OpeningHoursGrid(
                                                widget.businessSchedule[selectedDate.weekday - 1]
                                                    ['Open']['Hour'],
                                                widget.businessSchedule[selectedDate.weekday - 1]
                                                    ['Open']['Minute'],
                                                widget.businessSchedule[selectedDate.weekday - 1]
                                                    ['Close']['Hour'],
                                                widget.businessSchedule[selectedDate.weekday - 1]
                                                    ['Close']['Minute'],
                                                setTime,
                                                reservationTime)
                                            : const SizedBox(
                                                height: 50,
                                                width: double.infinity,
                                                child: Center(
                                                    child: Text('No hay horarios disponibles este día',
                                                        style: TextStyle(color: Colors.grey, fontSize: 14)))),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                //Button
                                ReserveButton(
                                    widget.businessID!,
                                    widget.businessPhone,
                                    selectedDate,
                                    _formKey,
                                    data,
                                    widget.total,
                                    name,
                                    note,
                                    address,
                                    email,
                                    phone,
                                    reservationTime,
                                    pageController),
                              ],
                            ),
                          ),
                          //Checkout
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Para el ${DateFormat.yMd().format(selectedDate)}, ${DateFormat.Hm().format(selectedDate)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(height: 15),
                                          //Name
                                          const SizedBox(height: 5),
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
                                              LengthLimitingTextInputFormatter(
                                                  45)
                                            ],
                                            cursorColor: Colors.grey,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            decoration: InputDecoration(
                                              label: const Text(
                                                  'Nombre y apellido'),
                                              labelStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
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
                                            onFieldSubmitted: (term) {
                                              nameNode.unfocus();
                                              openSchedule();
                                            },
                                            onChanged: (val) {
                                              setState(() => name = val);
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            onEditingComplete: () {
                                              nameNode.unfocus();
                                              addressNode.requestFocus();
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          //Contacto
                                          // Tlf y mail
                                          const Row(
                                            children: [
                                              Text(
                                                'Contacto',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Colors.black45),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          //Tlf
                                          SizedBox(
                                            height: 45,
                                            width: double.infinity,
                                            child: IntlPhoneField(
                                              focusNode: phoneNode,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  )),
                                              languageCode: "es",
                                              initialCountryCode: 'AR',
                                              disableLengthCheck: true,
                                              initialValue: '',
                                              showCountryFlag: false,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              onChanged: (nO) {
                                                setState(() =>
                                                    phone = nO.completeNumber);
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          //Nota
                                          const Row(
                                            children: [
                                              Text(
                                                'Nota',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Colors.black45),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            maxLines: 4,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                            cursorColor: Colors.grey,
                                            focusNode: _noteNode,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                              hintText: 'Agrega una nota',
                                              hintStyle:
                                                  const TextStyle(fontSize: 14),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.grey,
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
                                            onFieldSubmitted: (term) {
                                              _noteNode.unfocus();
                                            },
                                            onChanged: (val) {
                                              setState(() {
                                                note = val;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          //Message
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              clarificationMessage,
                                              textAlign: TextAlign.left,
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                (showError)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: SizedBox(
                                            width: double.infinity,
                                            child: Text(errorMessage,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 12,
                                                ))))
                                    : const SizedBox(),
                                //Coupon
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade300,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AddDiscountDialog(
                                                widget.businessID!);
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sell_outlined,
                                          size: 21,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                            (data['Discount'] != null &&
                                                    data['Discount'] > 0)
                                                ? '${snapshot.data["Discount Code"]} (${formatCurrency.format(snapshot.data["Discount"])})'
                                                : 'Código promocional',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400)),
                                      ],
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
                                        setLoading(true);
                                        if (reservationTime != null) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            for (var i in data['Items']) {
                                              if (i['Options'] != null &&
                                                  !i['Options'].isEmpty) {
                                                orderItems = orderItems +
                                                    ('${i['Quantity']} ${i['Name']} (${i['Options'].join(', ')}) %0A');
                                              } else {
                                                orderItems = orderItems +
                                                    ('${i['Quantity']} ${i['Name']}%0A');
                                              }
                                            }

                                            //%20 = Space //%0A Another Line
                                            //%3A = : //%24 = $
                                            try {
                                              String reservedTime =
                                                  '${DateFormat.yMMMd().format(selectedDate)} ${DateFormat.Hm().format(selectedDate)}';
                                              orderMessage =
                                                  'Nombre: $name %0ATipo de Orden: Reserva %0ANro. Teléfono: $phone %0Aemail: $email%0AFecha de reserva: $reservedTime  %0AOrden:%0A$orderItems %0ATotal: ${formatCurrency.format(bloc.totalTicketAmount)}';

                                              DatabaseService()
                                                  .scheduleSale(
                                                      widget.businessID,
                                                      // ignore: prefer_interpolation_to_compose_strings
                                                      '00' +
                                                          (DateTime.now().day)
                                                              .toString() +
                                                          (DateTime.now().month)
                                                              .toString() +
                                                          (DateTime.now().year)
                                                              .toString() +
                                                          (DateTime.now().hour)
                                                              .toString() +
                                                          (DateTime.now()
                                                                  .minute)
                                                              .toString() +
                                                          (DateTime.now()
                                                                  .millisecond)
                                                              .toString(),
                                                      bloc.subtotalTicketAmount,
                                                      data['Discount'],
                                                      data['Discount Code'],
                                                      0,
                                                      bloc.totalTicketAmount,
                                                      data['Items'],
                                                      name,
                                                      selectedDate,
                                                      {
                                                        'Name': name,
                                                        'Address': address,
                                                        'Phone': phone,
                                                        'email': email,
                                                      },
                                                      0,
                                                      bloc.totalTicketAmount,
                                                      note)
                                                  .then((value) async {
                                                openWhatsapp(
                                                    widget.businessPhone);
                                                bloc.removeAllFromCart();
                                                setState(() {
                                                  showError = false;
                                                });
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OrderSuccessful(widget
                                                                .businessID)));
                                              });
                                            } catch (e) {
                                              setShowError(true);
                                              setLoading(false);
                                            }
                                          } else {
                                            setLoading(false);
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Text(
                                          'Pedir (${formatCurrency.format(bloc.totalTicketAmount)})',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //Loading?
                      loading
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.withOpacity(0.5),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.blueGrey.shade900,
                              )))
                          : const SizedBox()
                    ],
                  ),
                );
              }
            } else {
              return Container();
            }
          });
    } else {
      return Container();
    }
  }
}
