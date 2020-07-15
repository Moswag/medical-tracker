import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicaltracker/model/Emergency.dart';

class ViewOnMap extends StatefulWidget {
  ViewOnMap({this.emergency});

  final Emergency emergency;

  @override
  State createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewOnMap> {

//  _ViewMapState() : super() {
//    emergency ??= widget.emergency;
//  }

  static Emergency emergency=new Emergency(
    latitude: -17.8283227,
    longitude: 30.9645786
  );

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(emergency.latitude!=null?emergency.latitude:-17.8283227, emergency.longitude!=null?emergency.longitude:30.9645786),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target:  LatLng(emergency.latitude!=null?emergency.latitude:-17.8283227, emergency.longitude!=null?emergency.longitude:30.9645786),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('View Detailed!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}