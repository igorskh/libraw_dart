import 'dart:ffi';
import 'dart:typed_data';

import 'libraw_bindings_gen.dart';
import 'libraw_data_type.dart';

class LibRawImage {
  LibRawImage({required this.filepath, required this.libRawData, this.ptr});

  String filepath;
  LibRawData libRawData;
  Pointer<libraw_data_t>? ptr;
  Uint8List? thumbnailData;
  Uint8List? imageData;
}
