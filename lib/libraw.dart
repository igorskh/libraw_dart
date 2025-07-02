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

  static LibRawLoader fromAutoDetect() {
    return LibRawLoader.fromDynamicLibrary(DynamicLibrary.open(determineLibraryName()));
  }

  LibRawLoader(this.bindings);

  LibRawImage openImage(String filepath) {
    final rawFile = File(filepath);

    if (!rawFile.existsSync()) { 
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

    return LibRawImage(
      filepath: rawFile.absolute.path,
      metaData: metaData,
      ptr: ptr,
    );
  }

  void unpackThumbnail(LibRawImage libRawImage) {
    if (libRawImage.ptr == null) {
      throw Exception('LibRawImage pointer is null. Ensure the image is opened correctly.');
    }

    final result = bindings.libraw_unpack_thumb(libRawImage.ptr!);
    if (result != 0) {
      bindings.libraw_close(libRawImage.ptr!);
      throw Exception('Failed to unpack thumbnail');
    }

    final thumbnailData = pointerToUint8List(
      libRawImage.ptr!.ref.thumbnail.thumb, libRawImage.ptr!.ref.thumbnail.tlength,
    );

    if (thumbnailData.isEmpty) {
      throw Exception('No thumbnail data found');
    }

    libRawImage.thumbnailData = Uint8List.fromList(thumbnailData);
  }

  void closeImage(LibRawImage libRawImage) {
    if (libRawImage.ptr != null) {
      bindings.libraw_close(libRawImage.ptr!);
    }
  }
}