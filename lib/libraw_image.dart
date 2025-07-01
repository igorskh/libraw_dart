import 'package:libraw_dart/libraw_image_meta_data.dart';

class LibRawImage {
  LibRawImage({
    required this.filepath,
    required this.metaData,
  });

  String filepath;
  LibRawImageMetaData metaData;
}
