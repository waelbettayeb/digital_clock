// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

enum _Element {
  background,
  text,
  secondaryColor,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
  _Element.secondaryColor: Colors.black45,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.secondaryColor: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  String _date = "";
  num _temperature = 0.0;
  String _unitString = "°C";
  String _location = "";
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateTemperature();
    _updateLocation();
    _updateDate();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _updateTemperature();
      _updateLocation();
      _updateDate();
    });
  }
  void _updateTemperature(){
    setState(() {
      _temperature = widget.model.temperature;
      _unitString = widget.model.unitString;
    });
  }
  void _updateLocation(){
    setState(() {
      _location = widget.model.location;
    });
  }
  void _updateDate(){
    setState(() {
      _dateTime = DateTime.now();
      _date = Jiffy(_dateTime).format("EEEE, MMMM do, yyyy");
    });
  }
  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
       _timer = Timer(
         Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
         _updateTime,
       );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
    DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final amPm = widget.model.is24HourFormat ?
    DateFormat('a').format(_dateTime).toLowerCase(): '';
    final fontSize = MediaQuery.of(context).size.width / 14;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Kollektif',
      fontSize: fontSize,
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(hour+':'+minute),
                    Text(amPm),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(_date),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(this._temperature.toString()),
                    Text(_unitString),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(_location),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
