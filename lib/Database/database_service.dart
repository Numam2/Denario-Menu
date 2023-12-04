// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Models/user.dart';

class DatabaseService {
  //Get User Business Profile
  BusinessProfile _userBusinessProfileFromSnapshot(DocumentSnapshot snapshot) {
    return BusinessProfile(
        snapshot.data().toString().contains('Business ID')
            ? snapshot['Business ID']
            : '',
        snapshot.data().toString().contains('Business Name')
            ? snapshot['Business Name']
            : '',
        snapshot.data().toString().contains('Business Field')
            ? snapshot['Business Field']
            : '',
        snapshot.data().toString().contains('Business Image')
            ? snapshot['Business Image']
            : '',
        snapshot.data().toString().contains('Catalog Background Image')
            ? snapshot['Catalog Background Image']
            : '',
        snapshot.data().toString().contains('Business Location')
            ? snapshot['Business Location']
            : '',
        snapshot.data().toString().contains('Business Size')
            ? snapshot['Business Size']
            : 0,
        snapshot.data().toString().contains('Business Users')
            ? snapshot['Business Users']
            : [],
        snapshot.data().toString().contains('Business Schedule')
            ? snapshot['Business Schedule']
            : [],
        snapshot.data().toString().contains('Social Media')
            ? snapshot['Social Media']
            : []);
  }

  //User Business Stream
  Stream<BusinessProfile> userBusinessProfile(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .snapshots()
        .map(_userBusinessProfileFromSnapshot);
  }

  //Get Categories
  List _categoriesFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return snapshot.data().toString().contains('Visible Store Categories')
          ? snapshot['Visible Store Categories']
          : [];
    } catch (e) {
      return [];
    }
  }

  //Categories Stream (Costo de Ventas)
  Stream<List> categoriesList(uid) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(uid)
        .snapshots()
        .map(_categoriesFromSnapshot);
  }

  // Product List from snapshot
  List<Products> _productListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Products(
          doc.data().toString().contains('Product') ? doc['Product'] : '',
          doc.data().toString().contains('Price') ? doc['Price'] : 0,
          doc.data().toString().contains("Image") ? doc['Image'] : '',
          doc.data().toString().contains('Description')
              ? doc['Description']
              : '',
          doc.data().toString().contains('Category') ? doc['Category'] : '',
          doc.data().toString().contains('Product Options')
              ? doc['Product Options'].map<ProductOptions>((item) {
                  return ProductOptions(
                    item.toString().contains('Title') ? item['Title'] : '',
                    item.toString().contains('Mandatory')
                        ? item['Mandatory']
                        : false,
                    item.toString().contains('Multiple Options')
                        ? item['Multiple Options']
                        : false,
                    item.toString().contains('Price Structure')
                        ? item['Price Structure']
                        : 'Non',
                    item.toString().contains('Price Options')
                        ? item['Price Options']
                        : [],
                  );
                }).toList()
              : [],
          doc.data().toString().contains('Available') ? doc['Available'] : true,
          doc.id,
          doc.data().toString().contains('Code') ? doc['Code'] : '',
          doc.data().toString().contains('Search Name')
              ? doc['Search Name']
              : [],
          doc.data().toString().contains('Vegan')
              ? (doc['Vegan'] == null)
                  ? false
                  : doc['Vegan']
              : false,
          doc.data().toString().contains('Show') ? doc['Show'] : true,
          doc.data().toString().contains('Featured') ? doc['Featured'] : false,
          doc.data().toString().contains('List of Ingredients')
              ? doc['List of Ingredients']
              : [],
          doc.data().toString().contains('Ingredients')
              ? doc['Ingredients']
              : [],
          doc.data().toString().contains('IVA')
              ? (doc['IVA'] != null)
                  ? doc['IVA']
                  : 0
              : 0,
          doc.data().toString().contains('Price Type')
              ? doc['Price Type']
              : 'Precio por unidad',
          doc.data().toString().contains('Control Stock')
              ? doc['Control Stock']
              : false,
          doc.data().toString().contains('Current Stock')
              ? doc['Current Stock']
              : 0,
          doc.data().toString().contains('Low Stock Alert')
              ? doc['Low Stock Alert']
              : 0,
          doc.data().toString().contains('Allow Delivery')
              ? doc['Allow Delivery']
              : true,
          doc.data().toString().contains('Allow Reservation')
              ? doc['Allow Reservation']
              : false,
        );
      }).toList();
    } catch (e) {
      return snapshot.docs.map((doc) {
        return Products('', 0, '', '', '', [], false, doc.id, '', [], false,
            false, false, [], [], 0, '', false, 0, 0, true, false);
      }).toList();
    }
  }

  // Product Stream
  Stream<List<Products>> productList(String category, uid, display) async* {
    if (display == 'Categorized') {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Category', isEqualTo: category)
          .where('Show', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    } else {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Show', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    }
  }

  Stream<List<Products>> allProductsList(uid) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(uid)
        .collection('Menu')
        .where('Show', isEqualTo: true)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  Stream<List<Products>> featuredProductList(uid) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(uid)
        .collection('Menu')
        .where('Show', isEqualTo: true)
        .where('Featured', isEqualTo: true)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  //Menu Product Stream
  Stream<List<Products>> menuProductList(String category, uid, display) async* {
    if (display == 'Categorized') {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Category', isEqualTo: category)
          .where('Show', isEqualTo: true)
          .where('Allow Delivery', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    } else {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Show', isEqualTo: true)
          .where('Allow Delivery', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    }
  }

  //Reservation Product Stream
  Stream<List<Products>> reservationProductList(
      String category, uid, display) async* {
    if (display == 'Categorized') {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Category', isEqualTo: category)
          .where('Show', isEqualTo: true)
          .where('Allow Reservation', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    } else {
      yield* FirebaseFirestore.instance
          .collection('Products')
          .doc(uid)
          .collection('Menu')
          .where('Show', isEqualTo: true)
          .where('Allow Reservation', isEqualTo: true)
          .snapshots()
          .map(_productListFromSnapshot);
    }
  }

  //Create Order
  Future createOrder(String businessID, orderName, address, phone, orderDetail,
      paymentType, total, String orderType) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Pending')
        .doc(DateTime.now().toString())
        .set({
      'Order Name': orderName,
      'Address': address,
      'Phone': phone,
      'Saved Date': DateTime.now(),
      'Discount': 0,
      'IVA': 0,
      'Items': orderDetail,
      'Payment Type': paymentType,
      'Total': total,
      'Order Type': orderType
    });
  }

  void saveOrder(String businessID, orderName, address, phone, orderDetail,
      paymentType, total, String orderType) async {
    /////////////////////////// Update Product Stock ///////////////////////////

    for (var i = 0; i < orderDetail.length; i++) {
      if (orderDetail[i]['Control Stock'] == true) {
        //Firestore reference
        var firestore = FirebaseFirestore.instance;
        var prdRef = firestore
            .collection('Products')
            .doc(businessID)
            .collection('Menu')
            .doc(orderDetail[i]['Product ID']);

        final prdDoc = await prdRef.get();

        try {
          if (prdDoc.exists) {
            prdRef.update({
              'Current Stock': FieldValue.increment(-orderDetail[i]["Quantity"])
            });
          }
        } catch (error) {
          print('Error updating Total Sales Value: $error');
        }
      }
    }
    createOrder(businessID, orderName, address, phone, orderDetail, paymentType,
        total, orderType);
  }

  /// Schedule
  Future scheduleFirebaseSale(
      businessID,
      String transactionID,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      DateTime dueDate,
      client,
      initialPayment,
      remainingBalance,
      String note) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .doc(transactionID)
        .set({
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Subtotal': subTotal,
      'Total': total,
      'Initial Payment': initialPayment,
      'Remaining Blanace': remainingBalance,
      'Document ID': transactionID,
      'Order Type': 'Encargo',
      'Saved Date': DateTime.now(),
      'Due Date': dueDate,
      'Client': client,
      'Pending': true,
      'Note': note,
      'New Reservation': true,
      'Hide Notification': false,
    });
  }

  void scheduleSale(
      businessID,
      String transactionID,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      DateTime dueDate,
      client,
      initialPayment,
      remainingBalance,
      String note) async {
    /////////////////////////// Update Product Stock ///////////////////////////

    for (var i = 0; i < orderDetail.length; i++) {
      if (orderDetail[i]['Control Stock'] == true) {
        //Firestore reference
        var firestore = FirebaseFirestore.instance;
        var prdRef = firestore
            .collection('Products')
            .doc(businessID)
            .collection('Menu')
            .doc(orderDetail[i]['Product ID']);

        final prdDoc = await prdRef.get();

        try {
          if (prdDoc.exists) {
            prdRef.update({
              'Current Stock': FieldValue.increment(-orderDetail[i]["Quantity"])
            });
          }
        } catch (error) {
          print('Error updating Total Sales Value: $error');
        }
      }
    }
    scheduleFirebaseSale(
        businessID,
        transactionID,
        subTotal,
        discount,
        tax,
        total,
        orderDetail,
        orderName,
        dueDate,
        client,
        initialPayment,
        remainingBalance,
        note);
  }
}
