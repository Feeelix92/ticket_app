class Location {
  final int id;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double ticketid;
  final String address;

  const Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.ticketid,
    required this.address,
  });
}