import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
    if(searchAddress == '0'){
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                buses[0].lat,
                buses[0].lng,
              ),
              zoom: 18.0
          ),
        ),
      );
    }
    else {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                buses[1].lat,
                buses[1].lng,
              ),
              zoom: 18.0
          ),
        ),
      );
    }
    matureDistance();
  }

  void matureDistance ()async{
    gl.Position position = await gl.getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high );
    double distance =  gl.distanceBetween(position.latitude, position.longitude, buses[1].lat, buses[1].lng);
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
      body: Stack(
        children: [
          GoogleMap(
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
            left: 40,
            bottom: 40,
            child: FloatingActionButton(
              child: Icon(Icons.location_searching),
              onPressed: () {
                getCurrentLocation();
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 15,
            left: 15,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Where to go',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15, top: 15),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: search,
                    iconSize: 30,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    searchAddress = val;0
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
