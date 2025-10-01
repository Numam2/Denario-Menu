// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
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
      String formattedForWaMe = rrss['Link']
          .replaceAll(' ', '')
          .replaceAll('-', '');
      var whatsapp = Uri.parse("https://wa.me/$formattedForWaMe?text=Hola!");
      launchUrl(whatsapp);
    } else {
      var link = Uri.parse(rrss['Link']);
      launchUrl(link);
    }
  }

  late String storeType;
  late String display;
  bool searchByName = false;
  String searchName = '';
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
    final products = Provider.of<List<Products>?>(context);

    if (widget.businessID == null || widget.businessID == '') {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Logo
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/Logo negro.png'),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                //Title
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '¿Estás buscando una tienda en particular?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //Text
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Intenta desde el link del negocio para llevarte a su tienda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                //Button to go to website
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Si quieres ver lo que Denario puede hacer por tu negocio o emprendimiento, mira nuestra página web',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width > 850) ? 250 : double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.black,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.grey.shade300;
                        }
                        if (states.contains(WidgetState.focused) ||
                            states.contains(WidgetState.pressed)) {
                          return Colors.grey.shade200;
                        }
                        return Colors.black; // Defer to the widget's default.
                      }),
                    ),
                    onPressed: () async {
                      const denarioURL = 'https://denario.info';
                      if (await canLaunchUrl(Uri.parse(denarioURL))) {
                        await launchUrl(Uri.parse(denarioURL));
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: const Text(
                                'Ocurrió un error al intentar abrir la página. Visita https://denario.info',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Ir a la web',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (categoriesProvider == null ||
        categoriesProvider.isEmpty ||
        businessProvider == null ||
        products == null) {
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
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
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
                      child: FeaturedProducts(
                          ((businessSchedule[DateTime.now().weekday - 1]['Open']
                                          ['Hour'] >
                                      TimeOfDay.now().hour) ||
                                  (businessSchedule[DateTime.now().weekday - 1]
                                          ['Close']['Hour'] <
                                      TimeOfDay.now().hour))
                              ? false
                              : true,
                          products
                              .where((product) => product.featured == true)
                              .toList()),
                    )
                  : SliverToBoxAdapter(),
              //Categories
              (display == 'Categorized')
                  ? SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 5,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      actions: <Widget>[Container()],
                      flexibleSpace: (searchByName)
                          ? Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 600
                                      ? 500
                                      : double.infinity,
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: TextFormField(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      validator: (val) => val!.isEmpty
                                          ? "Agrega un nombre"
                                          : null,
                                      expands: false,
                                      autofocus: true,
                                      cursorColor: Colors.grey,
                                      cursorHeight: 18,
                                      initialValue: '',
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        suffixIcon: IconButton(
                                            tooltip: 'Cerrar',
                                            splashRadius: 25,
                                            onPressed: () {
                                              setState(() {
                                                searchByName = false;
                                                searchName = '';
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.grey,
                                            )),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontSize: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          borderSide: BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() => searchName = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                //Search
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: IconButton(
                                      tooltip: 'Buscar',
                                      splashRadius: 25,
                                      onPressed: () {
                                        setState(() {
                                          searchByName = true;
                                        });
                                      },
                                      icon: Icon(Icons.search, size: 16)),
                                ),
                                //List
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    (selectedCategory ==
                                                            categories[i])
                                                        ? WidgetStateProperty
                                                            .all<Color>(
                                                                Colors.black)
                                                        : WidgetStateProperty
                                                            .all<Color>(Colors
                                                                .transparent),
                                                overlayColor:
                                                    WidgetStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<WidgetState> states) {
                                                    if (states.contains(
                                                        WidgetState.hovered)) {
                                                      return Colors
                                                          .grey.shade300;
                                                    }
                                                    if (states.contains(
                                                            WidgetState
                                                                .focused) ||
                                                        states.contains(
                                                            WidgetState
                                                                .pressed)) {
                                                      return Colors
                                                          .grey.shade200;
                                                    }
                                                    return Colors
                                                        .black; // Defer to the widget's default.
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedCategory =
                                                      categories[i];
                                                  firstLoad = false;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                child: Center(
                                                  child: Text(
                                                    categories[i],
                                                    style: TextStyle(
                                                        color:
                                                            (selectedCategory ==
                                                                    categories[
                                                                        i])
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : SliverToBoxAdapter(
                      child: (searchByName)
                          ? Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width > 600
                                            ? 500
                                            : double.infinity,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        validator: (val) => val!.isEmpty
                                            ? "Agrega un nombre"
                                            : null,
                                        expands: false,
                                        autofocus: true,
                                        cursorColor: Colors.grey,
                                        cursorHeight: 18,
                                        initialValue: '',
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          suffixIcon: IconButton(
                                              tooltip: 'Cerrar',
                                              splashRadius: 25,
                                              onPressed: () {
                                                setState(() {
                                                  searchByName = false;
                                                  searchName = '';
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.grey,
                                              )),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() => searchName = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
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
                                SizedBox(width: 30),
                                //Search
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: IconButton(
                                      tooltip: 'Buscar',
                                      splashRadius: 25,
                                      onPressed: () {
                                        setState(() {
                                          searchByName = true;
                                        });
                                      },
                                      icon: Icon(Icons.search, size: 16)),
                                ),
                              ],
                            ),
                    ),
              //Products
              ProductSelection(
                  ((businessSchedule[DateTime.now().weekday - 1]['Open']
                                  ['Hour'] >
                              TimeOfDay.now().hour) ||
                          (businessSchedule[DateTime.now().weekday - 1]['Close']
                                  ['Hour'] <
                              TimeOfDay.now().hour))
                      ? false
                      : true,
                  storeType,
                  (searchByName)
                      ? products
                          .where((prd) =>
                              prd.product.toLowerCase() == searchName.toLowerCase() ||
                              prd.product
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()) ||
                              prd.category
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()) ||
                              prd.description
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()))
                          .toList()
                      : (storeType == 'Menu')
                          ? (display == 'Consolidated')
                              ? products
                                  .where(
                                      (product) => product.deliveryMenu == true)
                                  .toList()
                              : products
                                  .where((product) =>
                                      product.category == selectedCategory &&
                                      product.deliveryMenu == true)
                                  .toList()
                          : (storeType == 'Reservation' && display == 'Categorized')
                              ? products.where((product) => product.category == selectedCategory && product.allowReservation == true).toList()
                              : (storeType == 'Reservation' && display != 'Categorized')
                                  ? products.where((product) => product.allowReservation == true).toList()
                                  : (display == 'Categorized')
                                      ? products.where((product) => product.category == selectedCategory).toList()
                                      : products),
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
                            var whatsapp = Uri.parse(
                                "https://wa.me/$businessPhone?text=¡Hola!");
                            launchUrl(whatsapp);
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 5,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      actions: <Widget>[Container()],
                      flexibleSpace: (searchByName)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width >
                                            600)
                                        ? 500
                                        : double.infinity,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        validator: (val) => val!.isEmpty
                                            ? "Agrega un nombre"
                                            : null,
                                        autofocus: true,
                                        cursorColor: Colors.grey,
                                        cursorHeight: 18,
                                        initialValue: '',
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          suffixIcon: IconButton(
                                              tooltip: 'Cerrar',
                                              splashRadius: 25,
                                              onPressed: () {
                                                setState(() {
                                                  searchByName = false;
                                                  searchName = '';
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.grey,
                                              )),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() => searchName = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              children: [
                                //Search
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: IconButton(
                                      tooltip: 'Buscar',
                                      splashRadius: 25,
                                      onPressed: () {
                                        setState(() {
                                          searchByName = true;
                                        });
                                      },
                                      icon: Icon(Icons.search, size: 16)),
                                ),
                                //List
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    (selectedCategory ==
                                                            categories[i])
                                                        ? WidgetStateProperty
                                                            .all<Color>(
                                                                Colors.black)
                                                        : WidgetStateProperty
                                                            .all<Color>(Colors
                                                                .transparent),
                                                overlayColor:
                                                    WidgetStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<WidgetState> states) {
                                                    if (states.contains(
                                                        WidgetState.hovered)) {
                                                      return Colors
                                                          .grey.shade300;
                                                    }
                                                    if (states.contains(
                                                            WidgetState
                                                                .focused) ||
                                                        states.contains(
                                                            WidgetState
                                                                .pressed)) {
                                                      return Colors
                                                          .grey.shade200;
                                                    }
                                                    return Colors
                                                        .black; // Defer to the widget's default.
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedCategory =
                                                      categories[i];
                                                  firstLoad = false;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                child: Center(
                                                  child: Text(
                                                    categories[i],
                                                    style: TextStyle(
                                                        color:
                                                            (selectedCategory ==
                                                                    categories[
                                                                        i])
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : SliverToBoxAdapter(
                      child: (searchByName)
                          ? Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SizedBox(
                                    width: (MediaQuery.of(context).size.width >
                                            600)
                                        ? 500
                                        : double.infinity,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        validator: (val) => val!.isEmpty
                                            ? "Agrega un nombre"
                                            : null,
                                        autofocus: true,
                                        cursorColor: Colors.grey,
                                        cursorHeight: 18,
                                        initialValue: '',
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          suffixIcon: IconButton(
                                              tooltip: 'Cerrar',
                                              splashRadius: 25,
                                              onPressed: () {
                                                setState(() {
                                                  searchByName = false;
                                                  searchName = '';
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.grey,
                                              )),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() => searchName = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
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
                                SizedBox(width: 30),
                                //Search
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: IconButton(
                                      tooltip: 'Buscar',
                                      splashRadius: 25,
                                      onPressed: () {
                                        setState(() {
                                          searchByName = true;
                                        });
                                      },
                                      icon: Icon(Icons.search, size: 16)),
                                ),
                              ],
                            ),
                    ),
              //Products
              ProductSelection(
                  ((businessSchedule[DateTime.now().weekday - 1]['Open']
                                  ['Hour'] >
                              TimeOfDay.now().hour) ||
                          (businessSchedule[DateTime.now().weekday - 1]['Close']
                                  ['Hour'] <
                              TimeOfDay.now().hour))
                      ? false
                      : true,
                  storeType,
                  (searchByName)
                      ? products
                          .where((prd) =>
                              prd.product.toLowerCase() ==
                                  searchName.toLowerCase() ||
                              prd.product
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()) ||
                              prd.category
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()) ||
                              prd.description
                                  .toLowerCase()
                                  .contains(searchName.toLowerCase()))
                          .toList()
                      : (display == 'Categorized')
                          ? products
                              .where((product) =>
                                  product.category == selectedCategory)
                              .toList()
                          : products),
            ],
          ),
        ),
      );
    }
  }
}
