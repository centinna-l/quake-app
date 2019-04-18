import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

Map _data;
List _features;

void main() async {
  _data = await getQuake();
  _features = _data["features"];
  print(_data["features"][0]["properties"]["title"]);
  runApp(new MaterialApp(
    title: 'Quake',
    home: new Quake(),
    debugShowCheckedModeBanner: false,
  ));
}

class Quake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Quake'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: new Center(
        child: new ListView.builder(
          itemCount: _features.length,
          itemBuilder: (BuildContext context, int position) {
            if (position.isOdd) return new Divider();
            final index = position ~/ 2;
            var format = new DateFormat.yMMMMd("en_US").add_jm();

            var date = format.format(DateTime.fromMicrosecondsSinceEpoch(
                _features[index]["properties"]["time"] * 1000,
                isUtc: true));
            return new ListTile(
              title: new Text(
                'At $date, ${_features[index]["properties"]["place"]}',
                style: new TextStyle(
                  fontSize: 14.5,
                ),
              ),
              subtitle: new Text(
                _features[index]["properties"]["title"],
                style: new TextStyle(
                  fontSize: 10.5,
                ),
              ),
              leading: new CircleAvatar(
                backgroundColor: Colors.redAccent.shade100,
                child: new Text(
                  '${_features[index]["properties"]["mag"]}',
                  style: new TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
              onTap: () => showTapMessage(context, position,
                  _features[position]["properties"]["place"]),
            );
          },
        ),
      ),
    );
  }
}

void showTapMessage(BuildContext context, int position, String message) {
  var alertDiag = new AlertDialog(
    title: new Text("Quakes"),
    content: new Text(message),
    actions: <Widget>[
      new Column(
        children: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: new Text('OK'),
          ),
        ],
      )
    ],
  );
  showDialog(
      context: context,
      builder: (context) {
        return alertDiag;
      });
}

Future<Map> getQuake() async {
  String apiUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}
