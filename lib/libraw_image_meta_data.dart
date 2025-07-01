class LibRawImageMetaData {
  DateTime dateTime;
  String make = '';
  String model = '';
  String lens = '';
  double aperture = 0.0;
  double shutter = 0.0;
  int iso = 0;
  double focalLength = 0.0;
  int width = 0;
  int height = 0;

  LibRawImageMetaData({
    required this.dateTime,
    required this.make,
    required this.model,
    required this.lens,
    required this.aperture,
    required this.shutter,
    required this.iso,
    required this.focalLength,
    required this.width,
    required this.height
  });
}