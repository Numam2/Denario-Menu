import 'package:flutter/material.dart';
import 'package:menu_denario/Database/database_service.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Models/user.dart';
import 'package:menu_denario/Screens/store_home.dart';
import 'package:provider/provider.dart';

class InitialConfig extends StatelessWidget {
  final String? businessID;
  final String? storeType;
  final String? display;
  const InitialConfig(this.businessID,
      {this.storeType, this.display, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<List>.value(
              initialData: const [],
              value: DatabaseService().categoriesList(businessID)),
          StreamProvider<BusinessProfile>.value(
              initialData:
                  BusinessProfile('', '', '', '', '', '', 0, [], [], []),
              value:
                  DatabaseService().userBusinessProfile(businessID.toString())),
          StreamProvider<List<Products>>.value(
            initialData: const [],
            value: DatabaseService().allProductsList(businessID),
          )
        ],
        child: StoreHome(
            businessID, storeType ?? 'Menu', display ?? 'Categorized'));
  }
}
