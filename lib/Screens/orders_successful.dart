// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:menu_denario/initial_config.dart';

class OrderSuccessful extends StatelessWidget {
  final String? businessID;
  const OrderSuccessful(this.businessID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Icon
            Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.greenAccent)),
                child: const Icon(Icons.check,
                    color: Colors.greenAccent, size: 50)),
            const SizedBox(height: 30),
            //RECIBIMOS
            const Text(
              'Gracias por tu pedido!',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(height: 15),
            //Detalle
            const SizedBox(
              width: 400,
              child: Text(
                'Recibimos tu orden en nuestro local y pronto estaremos confirmando por whatsapp al número que agregaste para coordinar los detalles',
                maxLines: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            //Boton de volver
            SizedBox(
              width: 250,
              height: 40,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InitialConfig(
                                  '$businessID',
                                  storeType: Uri.base.queryParameters['type'] ??
                                      'Menu',
                                  display:
                                      Uri.base.queryParameters['display'] ??
                                          'Categorized',
                                )));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      'Volver al inicio',
                      style: TextStyle(color: Colors.white),
                    )),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
