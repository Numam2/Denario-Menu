// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:menu_denario/Database/database_service.dart';
import 'package:menu_denario/Models/products.dart';
import 'package:menu_denario/Models/user.dart';
import 'package:menu_denario/Screens/cart_button.dart';
import 'package:menu_denario/Screens/featured_products.dart';
import 'package:menu_denario/Screens/product_selection.dart';
import 'package:menu_denario/Screens/ticket_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreHome extends StatefulWidget {
  final String? businessID;
  final String storeType;
  final String display;
  const StoreHome(this.businessID, this.storeType, this.display, {super.key});

  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedCategory = '';
  List categories = [];
  bool firstLoad = true;

  double _appBarTitleOpacity = 0.0;

  List socialMedia = [];
  List businessSchedule = [];

  int businessPhone = 0;
  void openLink(rrss) {
    if (rrss['Social Media'] == 'Whatsapp') {
      var whatsapp = Uri.parse("https://wa.me/${rrss['Link']}?text=Hola!");
      launchUrl(whatsapp);
    } else {
      var link = Uri.parse(rrss['Link']);
      launchUrl(link);
    }
  }

  late String storeType;
  late String display;
  //Menu, Reservations and Store, have the same store layout for now
  //Catalog has no cart, only display and contact through whatsapp

  //Menu has delivery/takeaway
  //Store has arrange with seller
  //Reservation has only reserve form

  @override
  void initState() {
    storeType = widget.storeType;
    display = widget.display;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<List?>(context);
    final businessProvider = Provider.of<BusinessProfile?>(context);

    if (categoriesProvider == null ||
        categoriesProvider.isEmpty ||
        businessProvider == null) {
      return Center(
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
              image:
                  DecorationImage(image: AssetImage('images/Logo negro.png'))),
        ),
      );
    }

    List categories = categoriesProvider;

    if (firstLoad == true) {
      selectedCategory = categories.first;
    }

    if (businessProvider.businessSchedule.isNotEmpty) {
      businessSchedule = businessProvider.businessSchedule;
    } else {
      businessSchedule = [
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
        {
          'Opens': false,
          'Open': {'Hour': 9, 'Minute': 00},
          'Close': {'Hour': 19, 'Minute': 00},
        },
      ];
    }

    if (businessProvider.socialMedia.isNotEmpty) {
      socialMedia = businessProvider.socialMedia;
    } else {
      socialMedia = [
        {'Social Media': 'Whatsapp', 'Link': '', 'Active': false},
        {'Social Media': 'Instagram', 'Link': '', 'Active': false},
        {'Social Media': 'Google', 'Link': '', 'Active': false},
        {'Social Media': 'Facebook', 'Link': '', 'Active': false},
        {'Social Media': 'Twitter', 'Link': '', 'Active': false}
      ];
    }

    TimeOfDay closeTime = TimeOfDay(
        hour: businessSchedule[DateTime.now().weekday - 1]['Close']['Hour'],
        minute: businessSchedule[DateTime.now().weekday - 1]['Close']
            ['Minute']);

    if (storeType != 'Catálogo') {
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          width: (MediaQuery.of(context).size.width > 900)
              ? 500
              : MediaQuery.of(context).size.width,
          child: TicketView(widget.businessID, socialMedia[0]['Link'],
              storeType, businessSchedule),
        ),
        body: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            // Detect when the SliverAppBar is expanded
            if (notification.metrics.pixels > 200) {
              setState(() {
                _appBarTitleOpacity = 1.0;
              });
            } else {
              setState(() {
                _appBarTitleOpacity = 0.0;
              });
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              //App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: _appBarTitleOpacity,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      businessProvider.businessName,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  background: Stack(
                    children: [
                      //Image
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                            businessProvider.businessBackgroundImage,
                            fit: BoxFit.cover),
                      ),
                      //Info
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: (MediaQuery.of(context).size.width > 700)
                                ? MediaQuery.of(context).size.width * 0.5
                                : MediaQuery.of(context).size.width * 0.8,
                            height: (MediaQuery.of(context).size.width > 700)
                                ? 200
                                : 300,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            padding: EdgeInsets.all(20),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Business Header
                                    (MediaQuery.of(context).size.width > 500)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              //Image
                                              (businessProvider.businessImage !=
                                                      '')
                                                  ? Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  businessProvider
                                                                      .businessImage),
                                                              fit: BoxFit
                                                                  .cover)))
                                                  : Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.white),
                                                      child: Center(
                                                          child: Text(
                                                        businessProvider
                                                            .businessName
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      ))),
                                              SizedBox(width: 20),
                                              //Data
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //Name
                                                  Text(
                                                    businessProvider
                                                        .businessName,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24),
                                                  ),
                                                  SizedBox(height: 5),
                                                  //Address
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.location_pin,
                                                        color: Colors.grey,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5),
                                                      SizedBox(
                                                        width: 175,
                                                        child: Text(
                                                          businessProvider
                                                              .businessLocation,
                                                          maxLines: 3,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  //Open/Close
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        color: Colors.grey,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5),
                                                      ((businessSchedule[DateTime.now().weekday -
                                                                              1]
                                                                          ['Open']
                                                                      ['Hour'] >
                                                                  TimeOfDay
                                                                          .now()
                                                                      .hour) ||
                                                              businessSchedule[DateTime.now().weekday -
                                                                              1]
                                                                          [
                                                                          'Close']
                                                                      ['Hour'] <
                                                                  TimeOfDay
                                                                          .now()
                                                                      .hour)
                                                          ? Text(
                                                              'Local cerrado',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )
                                                          : Text(
                                                              'Abierto hasta las ${closeTime.format(context)}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              //Image
                                              (businessProvider.businessImage !=
                                                      '')
                                                  ? Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  businessProvider
                                                                      .businessImage),
                                                              fit: BoxFit
                                                                  .cover)))
                                                  : Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.white),
                                                      child: Center(
                                                          child: Text(
                                                        businessProvider
                                                            .businessName
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      ))),
                                              SizedBox(height: 15),
                                              //Data
                                              Text(
                                                businessProvider.businessName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              SizedBox(height: 10),
                                              //Address
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.location_pin,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 5),
                                                  SizedBox(
                                                    width: 175,
                                                    child: Text(
                                                      businessProvider
                                                          .businessLocation,
                                                      maxLines: 3,
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 11),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              //Open/Close
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 5),
                                                  ((businessSchedule[DateTime.now()
                                                                          .weekday -
                                                                      1]['Open']
                                                                  ['Hour'] >
                                                              TimeOfDay.now()
                                                                  .hour) ||
                                                          businessSchedule[DateTime
                                                                              .now()
                                                                          .weekday -
                                                                      1]['Close']
                                                                  ['Hour'] <
                                                              TimeOfDay.now()
                                                                  .hour)
                                                      ? Text(
                                                          'Local cerrado',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      : Text(
                                                         'Abierto hasta las ${closeTime.format(context)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                    SizedBox(height: 20),
                                    //Social Media
                                    SizedBox(
                                      // width: double.infinity,
                                      height:
                                          (MediaQuery.of(context).size.width >
                                                  700)
                                              ? 25
                                              : 50,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: socialMedia.length,
                                          itemBuilder: ((context, i) {
                                            if (socialMedia[i]['Active'] ==
                                                false) {
                                              return SizedBox();
                                            }
                                            return TextButton(
                                              onPressed: () {
                                                openLink(socialMedia[i]);
                                              },
                                              child: Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width >
                                                          700)
                                                      ? 25
                                                      : 40,
                                                  height:
                                                      (MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              700)
                                                          ? 25
                                                          : 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              'images/${socialMedia[i]['Social Media']}.png'),
                                                          fit: BoxFit
                                                              .fitHeight))),
                                            );
                                          })),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: Colors.white,
                      child: TextButton(
                          onPressed: () {
                            _scaffoldKey.currentState!.openEndDrawer();
                          },
                          child: CartButton()),
                    ),
                  ),
                ],
                expandedHeight:
                    (MediaQuery.of(context).size.width > 700) ? 300 : 450,
              ),
              //Featured
              (storeType == 'Menu' || storeType == 'Store')
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Text('Destacados',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(),
              (storeType == 'Menu' || storeType == 'Store')
                  ? SliverToBoxAdapter(
                      child: StreamProvider<List<Products>>.value(
                          initialData: const [],
                          value: DatabaseService()
                              .featuredProductList(widget.businessID),
                          child: SizedBox(
                              height: 240,
                              width: double.infinity,
                              child: FeaturedProducts(
                                  ((businessSchedule[DateTime.now().weekday - 1]
                                                  ['Open']['Hour'] >
                                              TimeOfDay.now().hour) ||
                                          (businessSchedule[
                                                  DateTime.now().weekday -
                                                      1]['Close']['Hour'] <
                                              TimeOfDay.now().hour))
                                      ? false
                                      : true))),
                    )
                  : SliverToBoxAdapter(),
              //Categories
              (display == 'Categorized')
                  ? SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      elevation: 5,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      actions: <Widget>[Container()],
                      flexibleSpace: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: (i == 0)
                                    ? EdgeInsets.fromLTRB(15, 5, 5, 5)
                                    : EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        (selectedCategory == categories[i])
                                            ? MaterialStateProperty.all<Color>(
                                                Colors.black)
                                            : MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
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
                                    setState(() {
                                      selectedCategory = categories[i];
                                      firstLoad = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10),
                                    child: Center(
                                      child: Text(
                                        categories[i],
                                        style: TextStyle(
                                            color: (selectedCategory ==
                                                    categories[i])
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Text('Productos',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
              //Products
              StreamProvider<List<Products>>.value(
                  initialData: const [],
                  value: (storeType == 'Menu')
                      ? DatabaseService().menuProductList(
                          selectedCategory, widget.businessID, display)
                      : (storeType == 'Reservation')
                          ? DatabaseService().reservationProductList(
                              selectedCategory, widget.businessID, display)
                          : DatabaseService().productList(
                              selectedCategory, widget.businessID, display),
                  child: ProductSelection(
                      ((businessSchedule[DateTime.now().weekday - 1]['Open']
                                      ['Hour'] >
                                  TimeOfDay.now().hour) ||
                              (businessSchedule[DateTime.now().weekday - 1]
                                      ['Close']['Hour'] <
                                  TimeOfDay.now().hour))
                          ? false
                          : true,
                      storeType)),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            // Detect when the SliverAppBar is expanded
            if (notification.metrics.pixels > 200) {
              setState(() {
                _appBarTitleOpacity = 1.0;
              });
            } else {
              setState(() {
                _appBarTitleOpacity = 0.0;
              });
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              //App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: _appBarTitleOpacity,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      businessProvider.businessName,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  background: Stack(
                    children: [
                      //Image
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                            businessProvider.businessBackgroundImage,
                            fit: BoxFit.cover),
                      ),
                      //Info
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: (MediaQuery.of(context).size.width > 700)
                                ? MediaQuery.of(context).size.width * 0.5
                                : MediaQuery.of(context).size.width * 0.8,
                            height: (MediaQuery.of(context).size.width > 700)
                                ? 200
                                : 300,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            padding: EdgeInsets.all(20),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Business Header
                                    (MediaQuery.of(context).size.width > 500)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              //Image
                                              (businessProvider.businessImage !=
                                                      '')
                                                  ? Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  businessProvider
                                                                      .businessImage),
                                                              fit: BoxFit
                                                                  .cover)))
                                                  : Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.white),
                                                      child: Center(
                                                          child: Text(
                                                        businessProvider
                                                            .businessName
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      ))),
                                              SizedBox(width: 20),
                                              //Data
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //Name
                                                  Text(
                                                    businessProvider
                                                        .businessName,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24),
                                                  ),
                                                  SizedBox(height: 5),
                                                  //Address
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.location_pin,
                                                        color: Colors.grey,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5),
                                                      SizedBox(
                                                        width: 175,
                                                        child: Text(
                                                          businessProvider
                                                              .businessLocation,
                                                          maxLines: 3,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  //Open/Close
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        color: Colors.grey,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5),
                                                      ((businessSchedule[DateTime.now().weekday -
                                                                              1]
                                                                          ['Open']
                                                                      ['Hour'] >
                                                                  TimeOfDay
                                                                          .now()
                                                                      .hour) ||
                                                              businessSchedule[DateTime.now().weekday -
                                                                              1]
                                                                          [
                                                                          'Close']
                                                                      ['Hour'] <
                                                                  TimeOfDay
                                                                          .now()
                                                                      .hour)
                                                          ? Text(
                                                              'Local cerrado',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )
                                                          : Text(
                                                              'Abierto hasta las ${closeTime.format(context)}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              //Image
                                              (businessProvider.businessImage !=
                                                      '')
                                                  ? Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  businessProvider
                                                                      .businessImage),
                                                              fit: BoxFit
                                                                  .cover)))
                                                  : Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.white),
                                                      child: Center(
                                                          child: Text(
                                                        businessProvider
                                                            .businessName
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      ))),
                                              SizedBox(height: 15),
                                              //Data
                                              Text(
                                                businessProvider.businessName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              SizedBox(height: 10),
                                              //Address
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.location_pin,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 5),
                                                  SizedBox(
                                                    width: 175,
                                                    child: Text(
                                                      businessProvider
                                                          .businessLocation,
                                                      maxLines: 3,
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 11),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              //Open/Close
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 5),
                                                  ((businessSchedule[DateTime.now()
                                                                          .weekday -
                                                                      1]['Open']
                                                                  ['Hour'] >
                                                              TimeOfDay.now()
                                                                  .hour) ||
                                                          businessSchedule[DateTime
                                                                              .now()
                                                                          .weekday -
                                                                      1]['Close']
                                                                  ['Hour'] <
                                                              TimeOfDay.now()
                                                                  .hour)
                                                      ? Text(
                                                          'Local cerrado',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      : Text(
                                                          'Abierto hasta las ${closeTime.format(context)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                    SizedBox(height: 20),
                                    //Social Media
                                    SizedBox(
                                      // width: double.infinity,
                                      height:
                                          (MediaQuery.of(context).size.width >
                                                  700)
                                              ? 25
                                              : 50,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: socialMedia.length,
                                          itemBuilder: ((context, i) {
                                            if (socialMedia[i]['Active'] ==
                                                false) {
                                              return SizedBox();
                                            }
                                            return TextButton(
                                              onPressed: () {
                                                openLink(socialMedia[i]);
                                              },
                                              child: Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width >
                                                          700)
                                                      ? 25
                                                      : 40,
                                                  height:
                                                      (MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              700)
                                                          ? 25
                                                          : 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              'images/${socialMedia[i]['Social Media']}.png'),
                                                          fit: BoxFit
                                                              .fitHeight))),
                                            );
                                          })),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: Colors.white,
                      child: TextButton(
                          onPressed: () {
                            //Open whatsapp
                          },
                          child: Icon(Icons.phone)),
                    ),
                  ),
                ],
                expandedHeight:
                    (MediaQuery.of(context).size.width > 700) ? 300 : 450,
              ),
              //Categories
              (display == 'Categorized')
                  ? SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      elevation: 5,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      actions: <Widget>[Container()],
                      flexibleSpace: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: (i == 0)
                                    ? EdgeInsets.fromLTRB(15, 5, 5, 5)
                                    : EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        (selectedCategory == categories[i])
                                            ? MaterialStateProperty.all<Color>(
                                                Colors.black)
                                            : MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
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
                                    setState(() {
                                      selectedCategory = categories[i];
                                      firstLoad = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10),
                                    child: Center(
                                      child: Text(
                                        categories[i],
                                        style: TextStyle(
                                            color: (selectedCategory ==
                                                    categories[i])
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Text('Productos',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
              //Products
              StreamProvider<List<Products>>.value(
                  initialData: const [],
                  value: DatabaseService().productList(
                      selectedCategory, widget.businessID, display),
                  child: ProductSelection(
                      ((businessSchedule[DateTime.now().weekday - 1]['Open']
                                      ['Hour'] >
                                  TimeOfDay.now().hour) ||
                              (businessSchedule[DateTime.now().weekday - 1]
                                      ['Close']['Hour'] <
                                  TimeOfDay.now().hour))
                          ? false
                          : true,
                      storeType)),
            ],
          ),
        ),
      );
    }
  }
}
