import 'package:flutter/material.dart';
import 'package:menu_denario/Database/database_service.dart';
import 'package:menu_denario/Models/categories.dart';
import 'package:menu_denario/Models/user.dart';
import 'package:menu_denario/Screens/store_home.dart';
import 'package:provider/provider.dart';

class InitialConfig extends StatelessWidget {
  final String? businessID;
  const InitialConfig(this.businessID, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      StreamProvider<CategoryList>.value(
          initialData: CategoryList([]),
          value: DatabaseService().categoriesList(businessID)),
      StreamProvider<BusinessProfile>.value(
          initialData:
              BusinessProfile('', '', '', '', '', '', 0, [], [], [], []),
          value: DatabaseService().userBusinessProfile(businessID.toString())),
    ], child: StoreHome(businessID));
  }
}
