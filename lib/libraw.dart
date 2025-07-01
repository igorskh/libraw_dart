import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:libraw_dart/libraw_bindings_gen.dart';
import 'package:libraw_dart/libraw_image.dart';
import 'package:libraw_dart/libraw_image_meta_data.dart';
import 'package:libraw_dart/utils.dart';

class LibRawLoader {
  final LibRawDartBindings bindings;

  static LibRawLoader fromBindings(LibRawDartBindings bindings) => 
      LibRawLoader(bindings); 

  static LibRawLoader fromPath(String path) =>
      LibRawLoader.fromDynamicLibrary(DynamicLibrary.open(path));

  static LibRawLoader fromDynamicLibrary(DynamicLibrary dylib) =>
      LibRawLoader(LibRawDartBindings(dylib));

  LibRawLoader(this.bindings);

  Future<LibRawImage> openImage(String filepath) async {
    final rawFile = File(filepath);

    if (!await rawFile.exists()) { 
      throw Exception('File not found: $filepath');
    }

    Pointer<libraw_data_t> ptr = bindings.libraw_init(0);
    int result = bindings.libraw_open_file(ptr, rawFile.absolute.path.toNativeUtf8().cast());
      if (result != 0) {
      bindings.libraw_close(ptr);
      throw Exception('Failed to open raw file: $filepath');
    }

    LibRawImageMetaData metaData = LibRawImageMetaData(
      dateTime: DateTime.fromMillisecondsSinceEpoch(ptr.ref.other.timestamp * 1000),
      make: arrayToString(ptr.ref.idata.make),
      model: arrayToString(ptr.ref.idata.model),
      lens: arrayToString(ptr.ref.lens.Lens),
      aperture: ptr.ref.other.aperture,
      shutter: 1 / ptr.ref.other.shutter,
      iso: ptr.ref.other.iso_speed.ceil(),
      focalLength: ptr.ref.other.focal_len.ceil().toDouble(),
      width: ptr.ref.sizes.width,
      height: ptr.ref.sizes.height
    );

    bindings.libraw_close(ptr);

    return LibRawImage(
      filepath: rawFile.absolute.path,
      metaData: metaData,
    );
  }
  
  Future<Uint8List> unpackThumbnailFromLibRawImage(LibRawImage libRawImage) async {
    return unpackThumbnail(libRawImage.filepath);
  }

  Uint8List unpackThumbnail(String filepath) {
    final rawFile = File(filepath);
    
    Pointer<libraw_data_t> ptr = bindings.libraw_init(0);

    int result = bindings.libraw_open_file(ptr, rawFile.absolute.path.toNativeUtf8().cast());
    if (result != 0) {
      bindings.libraw_close(ptr);
      throw Exception('Failed to open raw file: $filepath');
    } 

    result = bindings.libraw_unpack_thumb(ptr);
    if (result != 0) {
      bindings.libraw_close(ptr);
      throw Exception('Failed to unpack thumbnail for: $filepath');
    }

    final thumbnailData = pointerToUint8List(ptr.ref.thumbnail.thumb, ptr.ref.thumbnail.tlength);
    bindings.libraw_close(ptr);

    if (thumbnailData.isEmpty) {
      throw Exception('No thumbnail data found for: $filepath');
    }

    return thumbnailData;
  }
}