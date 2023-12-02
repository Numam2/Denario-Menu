import 'package:flutter/material.dart';

class OpeningHoursGrid extends StatefulWidget {
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final Function setTime;
  final TimeOfDay? selectedTime;
  const OpeningHoursGrid(this.openHour, this.openMinute, this.closeHour,
      this.closeMinute, this.setTime, this.selectedTime,
      {super.key});

  @override
  State<OpeningHoursGrid> createState() => _OpeningHoursGridState();
}

class _OpeningHoursGridState extends State<OpeningHoursGrid> {
  // TimeOfDay? selectedTime;
  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map> buttons = [];
    int currentHour = widget.openHour;
    int currentMinute = widget.openMinute;
    while (currentHour < widget.closeHour ||
        (currentHour == widget.closeHour &&
            currentMinute <= widget.closeMinute)) {
      if (currentHour > widget.openHour ||
          (currentHour == widget.openHour &&
              currentMinute >= widget.openMinute)) {
        var buttonHour = currentHour;
        var buttonTime = currentMinute;
        buttons.add({'Button Hour': buttonHour, 'Button Minute': buttonTime});
      }

      currentMinute += 30;
      if (currentMinute >= 60) {
        currentHour++;
        currentMinute -= 60;
      }
    }

    return SizedBox(
        width: double.infinity,
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 10,
            children: List.generate(buttons.length, (i) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    side: BorderSide(
                        color: (widget.selectedTime ==
                                TimeOfDay(
                                    hour: buttons[i]['Button Hour'],
                                    minute: buttons[i]['Button Minute']))
                            ? Colors.greenAccent
                            : Colors.grey.shade300,
                        width: (widget.selectedTime ==
                                TimeOfDay(
                                    hour: buttons[i]['Button Hour'],
                                    minute: buttons[i]['Button Minute']))
                            ? 2
                            : 1)),
                onPressed: () {
                  // setState(() {
                  //   selectedTime = TimeOfDay(
                  //       hour: buttons[i]['Button Hour'],
                  //       minute: buttons[i]['Button Minute']);
                  // });
                  widget.setTime(TimeOfDay(
                      hour: buttons[i]['Button Hour'],
                      minute: buttons[i]['Button Minute']));
                },
                child: Text(
                  _formatTime(
                      buttons[i]['Button Hour'], buttons[i]['Button Minute']),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: (widget.selectedTime ==
                              TimeOfDay(
                                  hour: buttons[i]['Button Hour'],
                                  minute: buttons[i]['Button Minute']))
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              );
            })));
  }
}
