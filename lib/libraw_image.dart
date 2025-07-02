import 'dart:ffi';

import 'package:libraw_dart/libraw_image_meta_data.dart';

import 'package:libraw_dart/libraw_bindings_gen.dart';

class LibRawImage {
  LibRawImage({
    required this.filepath,
    required this.metaData,
    this.ptr,
  });

  String filepath;
  LibRawImageMetaData metaData;
  Pointer<libraw_data_t>? ptr;

  
}
