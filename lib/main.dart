import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polygon.dart';
import 'package:map_view/polyline.dart';

const API_KEY = "AIzaSyA0YLX3TxebUDP7YTt1mqalcl822HOg6zo";

void main() {
  MapView.setApiKey(API_KEY);
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

addMarker(id, tag, latitude, longitude) {
  return new Marker(
    id,
    tag,
    latitude,
    longitude,
    color: Colors.blue,
    draggable: true, //Allows the user to move the marker.
    markerIcon: new MarkerIcon(
      "assests/images/flower_vase.png",
      width: 112.0,
      height: 75.0,
    ),
  );
}

class _MyAppState extends State<MyApp> {
  MapView mapView = new MapView();
  CameraPosition cameraPosition;
  var compositeSubscription = new CompositeSubscription();
  var staticMapProvider = new StaticMapProvider(API_KEY);
  Uri staticMapUri;

  //Marker bubble
  List<Marker> _markers = <Marker>[
    addMarker("1", "Your Current Location", 13.1146544, 80.206045)
  ];

  //Line
  

  //Drawing

  @override
  initState() {
    super.initState();
    cameraPosition = new CameraPosition(Locations.portland, 2.0);
    staticMapUri = staticMapProvider.getStaticUri(Locations.portland, 12,
        width: 900, height: 400, mapType: StaticMapViewType.roadmap);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Map View Example'),
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                child: showMap(),
              )
            ],
            // children: <Widget>[
            //   new Container(
            //     height: 250.0,
            //     child: new Stack(
            //       children: <Widget>[
            //         new Center(
            //             child: new Container(
            //           child: new Text(
            //             "You are supposed to see a map here.\n\nAPI Key is not valid.\n\n"
            //                 "To view maps in the example application set the "
            //                 "API_KEY variable in example/lib/main.dart. "
            //                 "\n\nIf you have set an API Key but you still see this text "
            //                 "make sure you have enabled all of the correct APIs "
            //                 "in the Google API Console. See README for more detail.",
            //             textAlign: TextAlign.center,
            //           ),
            //           padding: const EdgeInsets.all(20.0),
            //         )),
            //         new InkWell(
            //           child: new Center(
            //             child: new Image.network(staticMapUri.toString()),
            //           ),
            //           onTap: showMap,
            //         )
            //       ],
            //     ),
            //   ),
            //   new Container(
            //     padding: new EdgeInsets.only(top: 10.0),
            //     child: new Text(
            //       "Tap the map to interact",
            //       style: new TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            //   new Container(
            //     padding: new EdgeInsets.only(top: 25.0),
            //     child:
            //         new Text("Camera Position: \n\nLat: ${cameraPosition.center
            //         .latitude}\n\nLng:${cameraPosition.center
            //         .longitude}\n\nZoom: ${cameraPosition.zoom}"),
            //   ),
            // ],
          )),
    );
  }

  showMap() {
    bool isDragged = false;
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location(45.526607443935724, -122.66731660813093), 15.0),
            hideToolbar: false,
            title: "Recently Visited"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
    StreamSubscription sub = mapView.onMapReady.listen((_) {
      mapView.setMarkers(_markers);
    });
    compositeSubscription.add(sub);
    sub = mapView.onLocationUpdated.listen((location) {
      
        if(!isDragged){
        //    mapView.removeMarker(_m);
        // mapView.addMarker(addMarker("1", "Your Current Location",
        //     location.latitude, location.longitude));
        mapView.setCameraPosition(new CameraPosition(
            new Location(location.latitude, location.longitude), 15.0));
        }
        else{
          sub.cancel();
        }
       
      print("Location updated $location");
    });
    compositeSubscription.add(sub);
    sub = mapView.onTouchAnnotation
        .listen((annotation) => print("annotation ${annotation.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onTouchPolyline
        .listen((polyline) => print("polyline ${polyline.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onTouchPolygon
        .listen((polygon) => print("polygon ${polygon.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onMapTapped
        .listen((location) => print("Touched location $location"));
    compositeSubscription.add(sub);
    sub = mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));
    compositeSubscription.add(sub);
    sub = mapView.onAnnotationDragStart.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging started");
    });
    sub = mapView.onAnnotationDragEnd.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging ended");
      isDragged = true;
    });
    sub = mapView.onAnnotationDrag.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker];
      print(
          "Annotation ${marker.id} moved to ${location.latitude} , ${location.longitude}");
    });
    compositeSubscription.add(sub);
    sub = mapView.onToolbarAction.listen((id) {
      print("Toolbar button id = $id");
      if (id == 1) {
        _handleDismiss();
      }
    });
    compositeSubscription.add(sub);
    sub = mapView.onInfoWindowTapped.listen((marker) {
      print("Info Window Tapped for ${marker.title}");
    });
    compositeSubscription.add(sub);
  }

  _handleDismiss() async {
    double zoomLevel = await mapView.zoomLevel;
    Location centerLocation = await mapView.centerLocation;
    List<Marker> visibleAnnotations = await mapView.visibleAnnotations;
    List<Polyline> visibleLines = await mapView.visiblePolyLines;
    List<Polygon> visiblePolygons = await mapView.visiblePolygons;
    print("Zoom Level: $zoomLevel");
    print("Center: $centerLocation");
    print("Visible Annotation Count: ${visibleAnnotations.length}");

    print("Visible Polygons Count: ${visiblePolygons.length}");
    var uri = await staticMapProvider.getImageUriFromMap(mapView,
        width: 900, height: 400);
    setState(() => staticMapUri = uri);
    mapView.dismiss();
    compositeSubscription.cancel();
  }
}

class CompositeSubscription {
  Set<StreamSubscription> _subscriptions = new Set();

  void cancel() {
    for (var n in this._subscriptions) {
      n.cancel();
    }
    this._subscriptions = new Set();
  }

  void add(StreamSubscription subscription) {
    this._subscriptions.add(subscription);
  }

  void addAll(Iterable<StreamSubscription> subs) {
    _subscriptions.addAll(subs);
  }

  bool remove(StreamSubscription subscription) {
    return this._subscriptions.remove(subscription);
  }

  bool contains(StreamSubscription subscription) {
    return this._subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return this._subscriptions.toList();
  }
}
