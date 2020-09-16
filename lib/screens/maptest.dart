import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:masar/uti.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  String searchAddress;

  List<BussStation> buses = [
    BussStation(name: 'Amman', lat: 32.530092, lng: 35.870488),
    BussStation(name: 'Bushra', lat: 32.556068, lng: 35.857133),
  ];

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.551445, 35.851479),
    zoom: 14.4746,
  );
  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/magicbus.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              new CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(newLocalData.latitude, newLocalData.longitude),
                tilt: 0,
                zoom: 18.00,
              ),
            ),
          );
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void search() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    if (searchAddress == '0') {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                buses[0].lat,
                buses[0].lng,
              ),
              zoom: 18.0),
        ),
      );
    } else {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                buses[1].lat,
                buses[1].lng,
              ),
              zoom: 18.0),
        ),
      );
    }
    matureDistance();
  }

  void matureDistance() async {
    gl.Position position =
        await gl.getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high);
    double distance = gl.distanceBetween(
        position.latitude, position.longitude, buses[1].lat, buses[1].lng);
    print(distance);
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff8B0505),
        elevation: 50,
        centerTitle: true,
        title: Text(
          'Masar',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        leading: Row(
          children: [
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Image.asset(
                'images/logo.png',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 22.0, left: 22, right: 22, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0xff8B0505), spreadRadius: 0),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Where to go',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15, top: 15),
                    suffixIcon: IconButton(
                      color: Color(0xff8B0505),
                      icon: Icon(
                        Icons.search,
                      ),
                      onPressed: search,
                      iconSize: 30,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchAddress = val;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapType: MapType.hybrid,
                    initialCameraPosition: _kGooglePlex,
                    markers: Set.of((marker != null) ? [marker] : []),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _controller = controller;
                      });
                    },
                  ),
                  Positioned(
                    right: 10,
                    bottom: 50,
                    child: Container(
                      height: 40,
                      width: 40,
                      child: FloatingActionButton(
                        backgroundColor: Colors.grey[700],
                        child: Icon(Icons.location_searching),
                        onPressed: () {
                          getCurrentLocation();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 125,
        child: FittedBox(
          child: FloatingActionButton.extended(
            shape: CircleBorder(),
            onPressed: () {
              // Add your onPressed code here!
            },
            label: Text(
              'GO',
              style: TextStyle(fontSize: 22),
            ),
            backgroundColor: Color(0xff8B0505),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
