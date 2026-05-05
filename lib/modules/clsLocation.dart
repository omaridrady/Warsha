class clsLocation {
  double lat;
  double lng;

  clsLocation({required this.lat, required this.lng});

  factory clsLocation.fromJson(Map<String, dynamic> json) =>
      clsLocation(lat: json["lat"]?.toDouble(), lng: json["lng"]?.toDouble());

  Map<String, dynamic> toJson() => {"lat": lat, "lng": lng};
}
