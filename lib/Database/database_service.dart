// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_denario/Models/categories.dart';
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
            : [],
        snapshot.data().toString().contains('Visible Store Categories')
            ? snapshot['Visible Store Categories']
            : ['All']);
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
  CategoryList _categoriesFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return CategoryList(snapshot.data().toString().contains('Category List')
          ? snapshot['Category List']
          : []);
    } catch (e) {
      return CategoryList([]);
    }
  }

  //Categories Stream (Costo de Ventas)
  Stream<CategoryList> categoriesList(uid) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(uid)
        .collection('Master Data')
        .doc('Categories')
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
        );
      }).toList();
    } catch (e) {
      return snapshot.docs.map((doc) {
        return Products(
            '', 0, '', '', '', [], false, doc.id, '', [], false, false, false);
      }).toList();
    }
  }

  // Product Stream
  Stream<List<Products>> productList(String category, uid) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(uid)
        .collection('Menu')
        .where('Category', isEqualTo: category)
        .where('Show', isEqualTo: true)
        .snapshots()
        .map(_productListFromSnapshot);
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
}
