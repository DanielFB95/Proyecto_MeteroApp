import 'package:flutter/material.dart';
import 'package:flutter_meteroapp/pages/google_map_app.dart';
import 'package:flutter_meteroapp/utils/constant.dart';
import 'package:flutter_meteroapp/utils/preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const CameraPosition _kInitialPosition =
    CameraPosition(target: LatLng(33, -5), zoom: 5.0);

class MapClickPage extends GoogleMapAppPage {
  const MapClickPage() : super(const Icon(Icons.mouse), 'Map click');

  @override
  Widget build(BuildContext context) {
    return const _MapClickBody();
  }
}

class _MapClickBody extends StatefulWidget {
  const _MapClickBody();

  @override
  State<StatefulWidget> createState() => _MapClickBodyState();
}

class _MapClickBodyState extends State<_MapClickBody> {
  _MapClickBodyState();

  GoogleMapController? mapController;
  LatLng? _lastTap;
  LatLng? _lastLongPress;

  List<String> latLong = [];
  String lat = '';
  String long = '';

  @override
  void initState() {
    PreferenceUtils.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onTap: (LatLng pos) {
        setState(() {
          _lastTap = pos;

          PreferenceUtils.setDouble(LAT, pos.latitude);
          PreferenceUtils.setDouble(LONG, pos.longitude);

          Navigator.pushNamed(context, '/');
        });
      },
      onLongPress: (LatLng pos) {
        setState(() {
          _lastLongPress = pos;
        });
      },
    );

    final List<Widget> columnChildren = <Widget>[
      SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.30,
            child: googleMap,
          ),
        ),
      ),
    ];

    if (mapController != null) {
      final String lastTap = 'Tap:\n${_lastTap ?? ""}\n';
      final String lastLongPress = 'Long press:\n${_lastLongPress ?? ""}';
      columnChildren.add(Center(
          child: Text(
        lastTap,
        textAlign: TextAlign.center,
      )));
      columnChildren.add(Center(
          child: Column(
        children: [
          Text(
            _lastTap != null ? 'Tapped' : '',
            textAlign: TextAlign.center,
          ),
        ],
      )));
      columnChildren.add(Center(
          child: Text(
        lastLongPress,
        textAlign: TextAlign.center,
      )));
      columnChildren.add(Center(
          child: Text(
        _lastLongPress != null ? 'Long pressed' : '',
        textAlign: TextAlign.center,
      )));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }
}
