// ignore_for_file: unnecessary_this

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceDocSnapshot {
  final DocumentSnapshot documentSnapshot;
  double distance;

  DistanceDocSnapshot(this.documentSnapshot, this.distance);
}

class GeoFireCollectionRef {
  Query _collectionReference;
  Stream<QuerySnapshot> _stream;

  GeoFireCollectionRef(this._collectionReference)
      : assert(_collectionReference != null) {
    _stream = _createStream(_collectionReference).shareReplay(maxSize: 1);
  }

  /// return QuerySnapshot stream
  Stream<QuerySnapshot> snapshot() {
    return _stream;
  }

  /// return the Document mapped to the [id]
  Stream<List<DocumentSnapshot>> data(String id) {
    return _stream.map((QuerySnapshot querySnapshot) {
      querySnapshot.docs.where((DocumentSnapshot documentSnapshot) {
        return documentSnapshot.id == id;
      });
      return querySnapshot.docs;
    });
  }

  /// add a document to collection with [data]
  Future<DocumentReference> add(Map<String, dynamic> data) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.add(data);
    } catch (e) {
      throw Exception(
          'cannot call add on Query, use collection reference instead');
    }
  }

  /// delete document with [id] from the collection
  Future<void> delete(id) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.doc(id).delete();
    } catch (e) {
      throw Exception(
          'cannot call delete on Query, use collection reference instead');
    }
  }

  /// create or update a document with [id], [merge] defines whether the document should overwrite
  Future<void> setDoc(String id, var data, {bool merge = false}) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.doc(id).set(data, SetOptions(merge: merge));
    } catch (e) {
      throw Exception(
          'cannot call set on Query, use collection reference instead');
    }
  }

  /// set a geo point with [latitude] and [longitude] using [field] as the object key to the document with [id]
  Future<void> setPoint(
      String id, String field, double latitude, double longitude) {
    try {
      CollectionReference colRef = _collectionReference;
      var point = GeoFirePoint(latitude, longitude).data;
      return colRef.doc(id).set({field: point}, SetOptions(merge: true));
    } catch (e) {
      throw Exception(
          'cannot call set on Query, use collection reference instead');
    }
  }

  /// query firestore documents based on geographic [radius] from geoFirePoint [center]
  /// [field] specifies the name of the key in the document
  Stream<List<DocumentSnapshot>> within({
    @required GeoFirePoint center,
    @required double radius,
    @required String field,
    bool strictMode = false,
  }) {
    final precision = Util.setPrecision(radius);
    final centerHash = center.hash.substring(0, precision);
    final area = GeoFirePoint.neighborsOf(hash: centerHash)..add(centerHash);

    Iterable<Stream<List<DistanceDocSnapshot>>> queries = area.map((hash) {
      final tempQuery = _queryPoint(hash, field);
      return _createStream(tempQuery).map((QuerySnapshot querySnapshot) {
        return querySnapshot.docs
            .map((element) => DistanceDocSnapshot(element, null))
            .toList();
      });
    });

    Stream<List<DistanceDocSnapshot>> mergedObservable =
        mergeObservable(queries);

    var filtered = mergedObservable.map((List<DistanceDocSnapshot> list) {
      var mappedList = list.map((DistanceDocSnapshot distanceDocSnapshot) {
        // split and fetch geoPoint from the nested Map
        final fieldList = field.split('.');
        Map pp = distanceDocSnapshot.documentSnapshot.data() as Map;
        var geoPointField = pp[fieldList[0]];
        if (fieldList.length > 1) {
          for (int i = 1; i < fieldList.length; i++) {
            geoPointField = geoPointField[fieldList[i]];
          }
        }
        final GeoPoint geoPoint = geoPointField['geopoint'];
        distanceDocSnapshot.distance =
            center.distance(lat: geoPoint.latitude, lng: geoPoint.longitude);
        return distanceDocSnapshot;
      });

      final filteredList = strictMode
          ? mappedList
              .where((DistanceDocSnapshot doc) =>
                      doc.distance <=
                      radius * 1.02 // buffer for edge distances;
                  )
              .toList()
          : mappedList.toList();
      filteredList.sort((a, b) {
        final distA = a.distance;
        final distB = b.distance;
        final val = (distA * 1000).toInt() - (distB * 1000).toInt();
        return val;
      });
      return filteredList.map((element) => element.documentSnapshot).toList();
    });
    return filtered.asBroadcastStream();
  }

  Stream<List<DistanceDocSnapshot>> mergeObservable(
      Iterable<Stream<List<DistanceDocSnapshot>>> queries) {
    Stream<List<DistanceDocSnapshot>> mergedObservable = Rx.combineLatest(
        queries, (List<List<DistanceDocSnapshot>> originalList) {
      final reducedList = <DistanceDocSnapshot>[];
      for (var t in originalList) {
        reducedList.addAll(t);
      }
      return reducedList;
    });
    return mergedObservable;
  }

  /// INTERNAL FUNCTIONS
  /// construct a query for the [geoHash] and [field]
  Query _queryPoint(String geoHash, String field) {
    final end = '$geoHash~';
    final temp = _collectionReference;
    return temp.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  /// create an observable for [ref], [ref] can be [Query] or [CollectionReference]
  Stream<QuerySnapshot> _createStream(var ref) {
    return ref.snapshots();
  }
}

class Geoflutterfire {
  Geoflutterfire();

  GeoFireCollectionRef collection({Query collectionRef}) {
    return GeoFireCollectionRef(collectionRef);
  }

  GeoFirePoint point({double latitude, double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }
}

class GeoFirePoint {
  static Util _util = Util();
  double latitude, longitude;

  GeoFirePoint(this.latitude, this.longitude);

  /// return geographical distance between two Co-ordinates
  static double distanceBetween({Coordinates to, Coordinates from}) {
    return Util.distance(to, from);
  }

  /// return neighboring geo-hashes of [hash]
  static List<String> neighborsOf({String hash}) {
    return _util.neighbors(hash);
  }

  /// return hash of [GeoFirePoint]
  String get hash {
    return _util.encode(this.latitude, this.longitude, 9);
  }

  /// return all neighbors of [GeoFirePoint]
  List<String> get neighbors {
    return _util.neighbors(this.hash);
  }

  /// return [GeoPoint] of [GeoFirePoint]
  GeoPoint get geoPoint {
    return GeoPoint(this.latitude, this.longitude);
  }

  Coordinates get coords {
    return Coordinates(this.latitude, this.longitude);
  }

  /// return distance between [GeoFirePoint] and ([lat], [lng])
  double distance({double lat, double lng}) {
    return distanceBetween(from: coords, to: Coordinates(lat, lng));
  }

  get data {
    return {'geopoint': this.geoPoint, 'geohash': this.hash};
  }

  /// haversine distance between [GeoFirePoint] and ([lat], [lng])
  haversineDistance({double lat, double lng}) {
    return GeoFirePoint.distanceBetween(
        from: coords, to: Coordinates(lat, lng));
  }
}

class Coordinates {
  double latitude;
  double longitude;

  Coordinates(this.latitude, this.longitude);
}

class Util {
  static const BASE32_CODES = '0123456789bcdefghjkmnpqrstuvwxyz';
  Map<String, int> base32CodesDic = {};

  Util() {
    for (var i = 0; i < BASE32_CODES.length; i++) {
      base32CodesDic.putIfAbsent(BASE32_CODES[i], () => i);
    }
  }

  var encodeAuto = 'auto';

  ///
  /// Significant Figure Hash Length
  ///
  /// This is a quick and dirty lookup to figure out how long our hash
  /// should be in order to guarantee a certain amount of trailing
  /// significant figures. This was calculated by determining the error:
  /// 45/2^(n-1) where n is the number of bits for a latitude or
  /// longitude. Key is # of desired sig figs, value is minimum length of
  /// the geohash.
  /// @type Array
  // Desired sig figs:    0  1  2  3   4   5   6   7   8   9  10
  var sigfigHashLength = [0, 5, 7, 8, 11, 12, 13, 15, 16, 17, 18];

  ///
  /// Encode
  /// Create a geohash from latitude and longitude
  /// that is 'number of chars' long
  String encode(var latitude, var longitude, var numberOfChars) {
    if (numberOfChars == encodeAuto) {
      if (latitude.runtimeType == double || longitude.runtimeType == double) {
        throw Exception('string notation required for auto precision.');
      }
      int decSigFigsLat = latitude.split('.')[1].length;
      int decSigFigsLon = longitude.split('.')[1].length;
      int numberOfSigFigs = max(decSigFigsLat, decSigFigsLon);
      numberOfChars = sigfigHashLength[numberOfSigFigs];
    } else {
      numberOfChars ??= 9;
    }

    var chars = [], bits = 0, bitsTotal = 0, hashValue = 0;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    while (chars.length < numberOfChars) {
      if (bitsTotal % 2 == 0) {
        mid = (maxLon + minLon) / 2;
        if (longitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLon = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLon = mid;
        }
      } else {
        mid = (maxLat + minLat) / 2;
        if (latitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLat = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLat = mid;
        }
      }

      bits++;
      bitsTotal++;
      if (bits == 5) {
        var code = BASE32_CODES[hashValue];
        chars.add(code);
        bits = 0;
        hashValue = 0;
      }
    }

    return chars.join('');
  }

  ///
  /// Decode Bounding box
  ///
  /// Decode a hashString into a bound box that matches it.
  /// Data returned in a List [minLat, minLon, maxLat, maxLon]
  List<double> decodeBbox(String hashString) {
    var isLon = true;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    var hashValue = 0;
    for (var i = 0, l = hashString.length; i < l; i++) {
      var code = hashString[i].toLowerCase();
      hashValue = base32CodesDic[code];

      for (var bits = 4; bits >= 0; bits--) {
        var bit = (hashValue >> bits) & 1;
        if (isLon) {
          mid = (maxLon + minLon) / 2;
          if (bit == 1) {
            minLon = mid;
          } else {
            maxLon = mid;
          }
        } else {
          mid = (maxLat + minLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isLon = !isLon;
      }
    }
    return [minLat, minLon, maxLat, maxLon];
  }

  ///
  /// Decode a [hashString] into a pair of latitude and longitude.
  /// A map is returned with keys 'latitude', 'longitude','latitudeError','longitudeError'
  Map<String, double> decode(String hashString) {
    List<double> bbox = decodeBbox(hashString);
    double lat = (bbox[0] + bbox[2]) / 2;
    double lon = (bbox[1] + bbox[3]) / 2;
    double latErr = bbox[2] - lat;
    double lonErr = bbox[3] - lon;
    return {
      'latitude': lat,
      'longitude': lon,
      'latitudeError': latErr,
      'longitudeError': lonErr,
    };
  }

  ///
  /// Neighbor
  ///
  /// Find neighbor of a geohash string in certain direction.
  /// Direction is a two-element array, i.e. [1,0] means north, [-1,-1] means southwest.
  ///
  /// direction [lat, lon], i.e.
  /// [1,0] - north
  /// [1,1] - northeast
  String neighbor(String hashString, var direction) {
    var lonLat = decode(hashString);
    var neighborLat =
        lonLat['latitude'] + direction[0] * lonLat['latitudeError'] * 2;
    var neighborLon =
        lonLat['longitude'] + direction[1] * lonLat['longitudeError'] * 2;
    return encode(neighborLat, neighborLon, hashString.length);
  }

  ///
  /// Neighbors
  /// Returns all neighbors' hashstrings clockwise from north around to northwest
  /// 7 0 1
  /// 6 X 2
  /// 5 4 3
  List<String> neighbors(String hashString) {
    int hashStringLength = hashString.length;
    var lonlat = decode(hashString);
    double lat = lonlat['latitude'];
    double lon = lonlat['longitude'];
    double latErr = lonlat['latitudeError'] * 2;
    double lonErr = lonlat['longitudeError'] * 2;

    // ignore: prefer_typing_uninitialized_variables
    var neighborLat, neighborLon;

    String encodeNeighbor(neighborLatDir, neighborLonDir) {
      neighborLat = lat + neighborLatDir * latErr;
      neighborLon = lon + neighborLonDir * lonErr;
      return encode(neighborLat, neighborLon, hashStringLength);
    }

    var neighborHashList = [
      encodeNeighbor(1, 0),
      encodeNeighbor(1, 1),
      encodeNeighbor(0, 1),
      encodeNeighbor(-1, 1),
      encodeNeighbor(-1, 0),
      encodeNeighbor(-1, -1),
      encodeNeighbor(0, -1),
      encodeNeighbor(1, -1)
    ];

    return neighborHashList;
  }

  static int setPrecision(double km) {
    /*
      * 1	≤ 5,000km	×	5,000km
      * 2	≤ 1,250km	×	625km
      * 3	≤ 156km	×	156km
      * 4	≤ 39.1km	×	19.5km
      * 5	≤ 4.89km	×	4.89km
      * 6	≤ 1.22km	×	0.61km
      * 7	≤ 153m	×	153m
      * 8	≤ 38.2m	×	19.1m
      * 9	≤ 4.77m	×	4.77m
      *
     */

    if (km <= 0.00477) {
      return 9;
    } else if (km <= 0.0382) {
      return 8;
    } else if (km <= 0.153) {
      return 7;
    } else if (km <= 1.22) {
      return 6;
    } else if (km <= 4.89) {
      return 5;
    } else if (km <= 39.1) {
      return 4;
    } else if (km <= 156) {
      return 3;
    } else if (km <= 1250) {
      return 2;
    } else {
      return 1;
    }
  }

  static const double MAX_SUPPORTED_RADIUS = 8587;

  // Length of a degree latitude at the equator
  static const double METERS_PER_DEGREE_LATITUDE = 110574;

  // The equatorial circumference of the earth in meters
  static const double EARTH_MERIDIONAL_CIRCUMFERENCE = 40007860;

  // The equatorial radius of the earth in meters
  static const double EARTH_EQ_RADIUS = 6378137;

  // The meridional radius of the earth in meters
  static const double EARTH_POLAR_RADIUS = 6357852.3;

  /* The following value assumes a polar radius of
     * r_p = 6356752.3
     * and an equatorial radius of
     * r_e = 6378137
     * The value is calculated as e2 == (r_e^2 - r_p^2)/(r_e^2)
     * Use exact value to avoid rounding errors
     */
  static const double EARTH_E2 = 0.00669447819799;

  // Cutoff for floating point calculations
  static const double EPSILON = 1e-12;

  static double distance(Coordinates location1, Coordinates location2) {
    return calcDistance(location1.latitude, location1.longitude,
        location2.latitude, location2.longitude);
  }

  static double calcDistance(
      double lat1, double long1, double lat2, double long2) {
    // Earth's mean radius in meters
    const double radius = (EARTH_EQ_RADIUS + EARTH_POLAR_RADIUS) / 2;
    double latDelta = _toRadians(lat1 - lat2);
    double lonDelta = _toRadians(long1 - long2);

    double a = (sin(latDelta / 2) * sin(latDelta / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(lonDelta / 2) *
            sin(lonDelta / 2));
    double distance = radius * 2 * atan2(sqrt(a), sqrt(1 - a)) / 1000;
    return double.parse(distance.toStringAsFixed(3));
  }

  static double _toRadians(double num) {
    return num * (pi / 180.0);
  }
}
