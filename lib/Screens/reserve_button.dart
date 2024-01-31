import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_denario/Database/database_service.dart';
import 'package:menu_denario/Database/ticket.dart';
import 'package:menu_denario/Screens/orders_successful.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ReserveButton extends StatefulWidget {
  final String businessID;
  final String businessPhone;
  final DateTime selectedDate;
  final GlobalKey<FormState> formKey;
  final Map data;
  final double total;
  final String name;
  final String note;
  final String address;
  final String email;
  final String phone;
  final TimeOfDay? reservationTime;
  final PageController pageController;
  const ReserveButton(
      this.businessID,
      this.businessPhone,
      this.selectedDate,
      this.formKey,
      this.data,
      this.total,
      this.name,
      this.note,
      this.address,
      this.email,
      this.phone,
      this.reservationTime,
      this.pageController,
      {super.key});

  @override
  State<ReserveButton> createState() => _ReserveButtonState();
}

class _ReserveButtonState extends State<ReserveButton> {
  openWhatsapp(orderMessage) {
    var whatsapp =
        Uri.parse("https://wa.me/${widget.businessPhone}?text=$orderMessage");
    launchUrl(whatsapp);
  }

  late Future checkAvailability;
  //Check if day is unavailable in firestore
  Future dayIsAvailable() async {
    try {
      var firestore = FirebaseFirestore.instance;

      var docRef = firestore
          .collection('ERP')
          .doc(widget.businessID)
          .collection('Schedule Limits')
          .doc(widget.selectedDate.year.toString())
          .get();
      return docRef;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    checkAvailability = dayIsAvailable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkAvailability,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool isAvailable = true;
            if (snapshot.hasData &&
                snapshot.data.exists &&
                snapshot.data['${widget.selectedDate.month}']
                    .contains('${widget.selectedDate.day}')) {
              isAvailable = false;
            }
            if (isAvailable) {
              if (MediaQuery.of(context).size.width > 750) {
                return SizedBox(
                  height: 45,
                  width: 150,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      onPressed: () {
                        //%20 = Space //%0A Another Line
                        //%3A = : //%24 = $

                        if (widget.formKey.currentState!.validate()) {
                          String orderItems = '';
                          for (var i in widget.data['Items']) {
                            if (i['Options'] != null && !i['Options'].isEmpty) {
                              orderItems = orderItems +
                                  ('${i['Quantity']} ${i['Name']} (${i['Options'].join(', ')}) %0A');
                            } else {
                              orderItems = orderItems +
                                  ('${i['Quantity']} ${i['Name']}%0A');
                            }
                          }

                          try {
                            String reservedTime =
                                '${DateFormat.yMMMd().format(widget.selectedDate)} ${DateFormat.Hm().format(widget.selectedDate)}';
                            var orderMessage =
                                'Nombre: ${widget.name} %0ATipo de Orden: Reserva %0ANro. Teléfono: ${widget.phone} %0Aemail: ${widget.email}%0AFecha de reserva: $reservedTime  %0AOrden:%0A$orderItems %0ATotal: %24${widget.total}';

                            DatabaseService()
                                .scheduleSale(
                                    widget.businessID,
                                    // ignore: prefer_interpolation_to_compose_strings
                                    '00' +
                                        (DateTime.now().day).toString() +
                                        (DateTime.now().month).toString() +
                                        (DateTime.now().year).toString() +
                                        (DateTime.now().hour).toString() +
                                        (DateTime.now().minute).toString() +
                                        (DateTime.now().millisecond).toString(),
                                    widget.total,
                                    widget.data['Discount'],
                                    widget.data['Discount Code'],
                                    0,
                                    widget.total,
                                    widget.data['Items'],
                                    widget.name,
                                    widget.selectedDate,
                                    {
                                      'Name': widget.name,
                                      'Address': widget.address,
                                      'Phone': widget.phone,
                                      'email': widget.email,
                                    },
                                    0,
                                    widget.total,
                                    widget.note)
                                .then((value) async {
                              openWhatsapp(orderMessage);
                              bloc.removeAllFromCart();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderSuccessful(widget.businessID)));
                            });
                          } catch (e) {
                            print('Error');
                          }
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          'Reservar',
                          style: TextStyle(color: Colors.white),
                        )),
                      )),
                );
              } else {
                return SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (widget.reservationTime != null)
                            ? Colors.black
                            : Colors.grey,
                      ),
                      onPressed: () {
                        widget.pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          'Avanzar',
                          style: TextStyle(
                              color: (widget.reservationTime != null)
                                  ? Colors.white
                                  : Colors.black),
                        )),
                      )),
                );
              }
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: (MediaQuery.of(context).size.width > 750)
                          ? 150
                          : double.infinity,
                      child: const Text(
                        'No hay disponibilidad para el día seleccionado',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 45,
                    width: (MediaQuery.of(context).size.width > 750)
                        ? 150
                        : double.infinity,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'No disponible',
                            style: TextStyle(color: Colors.grey.shade800),
                          )),
                        )),
                  ),
                ],
              );
            }
          } else {
            return const CircularProgressIndicator(color: Colors.black);
          }
        });
  }
}
