// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:menu_denario/Database/ticket.dart';

class CartButton extends StatelessWidget {
  const CartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.getStream,
        initialData: bloc.ticketItems,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            final data = snapshot.data as Map;

            return Container(
              padding: const EdgeInsets.all(8.0),
              width: 75,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: Stack(
                children: [
                  //Icon
                  const Align(
                      alignment: Alignment(0, 0),
                      child: Icon(Icons.shopping_cart_outlined,
                          color: Colors.black, size: 24)),
                  //Item Count
                  (data['Items'].length > 0)
                      ? Align(
                          alignment: const Alignment(0.85, -0.85),
                          child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Center(
                                  child: Text(
                                '${data['Items'].length}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ))),
                        )
                      : Container()
                ],
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(8.0),
              width: 120,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: Stack(
                children: const [
                  //Icon
                  Align(
                      alignment: Alignment(0, 0),
                      child: Icon(Icons.shopping_cart_outlined,
                          color: Colors.black, size: 24)),
                ],
              ),
            );
          }
        });
  }
}
