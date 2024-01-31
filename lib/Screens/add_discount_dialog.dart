import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_denario/Database/ticket.dart';

class AddDiscountDialog extends StatefulWidget {
  final String businessID;
  const AddDiscountDialog(this.businessID, {super.key});

  @override
  State<AddDiscountDialog> createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  String couponCode = '';
  late double discount;
  String errorMsg = '';

  Future<DocumentSnapshot?> fetchDocument(String businessID, documentId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection('Discounts')
          .doc(documentId)
          .get();
      return snapshot;
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }

  double totalAmount(snapshot) {
    double total = 0;
    snapshot.data['Items'].forEach((x) {
      total = total + (x['Price'] * x['Quantity']);
    });

    return total;
  }

  @override
  void initState() {
    discount = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, AsyncSnapshot snapshot) {
          return SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: SizedBox(
                height: 300,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: const Alignment(1.0, 0.0),
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            iconSize: 20.0),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //Title
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 5),
                        child: Text(
                          "Aplica un descuento",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //Code
                      SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: TextFormField(
                            key: const ValueKey(1),
                            autofocus: true,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                            onFieldSubmitted: ((value) async {
                              DocumentSnapshot? document = await fetchDocument(
                                  widget.businessID, couponCode);
                              if (document!.data() != null) {
                                // You can access document data using document.data()
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;

                                if (data['Active']) {
                                  setState(() {
                                    discount = totalAmount(snapshot) *
                                        (data['Discount'] / 100);
                                    bloc.setDiscountAmount(discount);
                                    bloc.setDiscountCode(data['Code']);
                                  });
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    errorMsg = 'Cupón inactivo';
                                  });
                                }
                              } else {
                                // Handle the case where the document retrieval failed
                                setState(() {
                                  errorMsg =
                                      'Ups, ocurrió un error, intenta de nuevo';
                                });
                              }
                            }),
                            decoration: InputDecoration(
                              hintText: 'Cupón',
                              label: const Text(''),
                              labelStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              errorStyle: TextStyle(
                                  color: Colors.redAccent[700], fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            cursorColor: Colors.grey,
                            initialValue: '',
                            onChanged: (val) {
                              if (val == '') {
                                setState(() {
                                  discount = 0;
                                  couponCode = '';
                                });
                              } else {
                                setState(() {
                                  couponCode = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //Button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () async {
                            DocumentSnapshot? document = await fetchDocument(
                                widget.businessID, couponCode);

                            if (document!.data() != null) {
                              // You can access document data using document.data()
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              if (data['Active']) {
                                setState(() {
                                  discount = totalAmount(snapshot) *
                                      (data['Discount'] / 100);
                                  bloc.setDiscountAmount(discount);
                                  bloc.setDiscountCode(data['Code']);
                                });
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  errorMsg = 'Cupón inactivo';
                                });
                              }
                            } else {
                              // Handle the case where the document retrieval failed

                              setState(() {
                                errorMsg =
                                    'Ups, no parece ser un código válido';
                              });
                            }
                          },
                          child: const Center(
                              child: Text('Aplicar',
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      //Error
                      (errorMsg.isNotEmpty)
                          ? const SizedBox(height: 10)
                          : const SizedBox(),
                      (errorMsg.isNotEmpty)
                          ? Text(
                              errorMsg,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
