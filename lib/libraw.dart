import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'package:libraw_dart/libraw_bindings_gen.dart';
import 'package:libraw_dart/libraw_image.dart';
import 'package:libraw_dart/utils.dart';

import 'libraw_data_type.dart';

class LibRawLoader {
  /// A loader class for handling RAW image files using the LibRaw library.
  /// Provides methods to open, unpack, and close RAW images.
  /// Requires an instance of [LibRawDartBindings] for FFI calls.

  /// The FFI bindings for LibRaw functions.
  final LibRawDartBindings bindings;

  /// Creates a [LibRawLoader] instance from the given [bindings].
  static LibRawLoader fromBindings(LibRawDartBindings bindings) =>
      LibRawLoader(bindings);

  /// Creates a [LibRawLoader] instance by loading the library from the specified [path].
  static LibRawLoader fromPath(String path) =>
      LibRawLoader.fromDynamicLibrary(DynamicLibrary.open(path));

  /// Creates a [LibRawLoader] instance by auto-detecting the library based on the current platform.
  static LibRawLoader fromDynamicLibrary(DynamicLibrary dylib) =>
      LibRawLoader(LibRawDartBindings(dylib));

  /// Creates a [LibRawLoader] instance by auto-detecting the library based on the current platform.
  static LibRawLoader fromAutoDetect() {
    return LibRawLoader.fromDynamicLibrary(
      DynamicLibrary.open(determineLibraryName()),
    );
  }

  LibRawLoader(this.bindings);

  Pointer<libraw_data_t> _openFromBytes(Uint8List bytes) {
    /// Opens a RAW image from the given [bytes].
    /// Returns a pointer to the [libraw_data_t] structure.
    /// Throws an [Exception] if the operation fails.

    Pointer<libraw_data_t> ptr = bindings.libraw_init(0);
    int result = bindings.libraw_open_buffer(
      ptr,
      uint8ListToPointerVoid(bytes),
      bytes.length,
    );
    if (result != 0) {
      bindings.libraw_close(ptr);
      throw Exception('Failed to open raw data from bytes');
    }
    return ptr;
  }

  Pointer<libraw_data_t> _openFromFile(File rawFile) {
    /// Opens a RAW image from the specified [rawFile].
    /// Returns a pointer to the [libraw_data_t] structure.
    /// Throws an [Exception] if the file does not exist or fails to open.

    Pointer<libraw_data_t> ptr = bindings.libraw_init(0);
    int result = bindings.libraw_open_file(
      ptr,
      rawFile.absolute.path.toNativeUtf8().cast(),
    );
    if (result != 0) {
      bindings.libraw_close(ptr);
      throw Exception('Failed to open raw file');
    }
    return ptr;
  }

  LibRawImage openImageFromPath(String filepath) {
    /// Opens a RAW image from the specified [filepath].
    /// Returns a [LibRawImage] containing image metadata and a pointer to the LibRaw data structure.
    /// Throws an [Exception] if the file does not exist or fails to open.

    final rawFile = File(filepath);

    if (!rawFile.existsSync()) {
      throw Exception('File not found: $filepath');
    }

    final ptr = _openFromFile(rawFile);
    return LibRawImage(
      filepath: rawFile.absolute.path,
      libRawData: LibRawData(ptr.ref),
      ptr: ptr,
    );
  }

  LibRawImage openImageFromBytes(Uint8List bytes) {
    /// Opens a RAW image from the given [bytes].
    /// Returns a [LibRawImage] containing image metadata and a pointer to the LibRaw data structure.
    /// Throws an [Exception] if the operation fails.

    final ptr = _openFromBytes(bytes);

    return LibRawImage(
      filepath: 'In-Memory Data',
      libRawData: LibRawData(ptr.ref),
      ptr: ptr,
    );
  }

  void unpackImage(LibRawImage libRawImage) {
    /// Unpacks the RAW image data for the given [libRawImage].
    /// Populates the [imageData] field of the [LibRawImage] with the processed image bytes.
    /// Throws an [Exception] if unpacking or processing fails.

    if (libRawImage.ptr == null) {
      throw Exception(
        'LibRawImage pointer is null. Ensure the image is opened correctly.',
      );
    }

    final result = bindings.libraw_unpack(libRawImage.ptr!);
    if (result != 0) {
      bindings.libraw_close(libRawImage.ptr!);
      throw Exception('Failed to unpack image');
    }

    final processResult = bindings.libraw_dcraw_process(libRawImage.ptr!);

    final errPtr = calloc<Int>();
    if (processResult != 0) throw Exception('Processing failed');
    final imgPtr = bindings.libraw_dcraw_make_mem_image(
      libRawImage.ptr!,
      errPtr,
    );

    if (errPtr.value != 0 || imgPtr == nullptr) {
      final code = errPtr.value;
      final msg = code != 0 ? strError(bindings, code) : 'null image pointer';
      throw Exception('libraw_dcraw_make_mem_image failed: ($code) $msg');
    }

    libRawImage.imageData = Uint8List.fromList(readProcessedImageBytes(imgPtr));

    bindings.libraw_dcraw_clear_mem(imgPtr);
  }

  void unpackThumbnail(LibRawImage libRawImage) {
    /// Unpacks the thumbnail image data for the given [libRawImage].
    /// Populates the [thumbnailData] field of the [LibRawImage] with the thumbnail bytes.
    /// Throws an [Exception] if unpacking fails or no thumbnail data is found.

    if (libRawImage.ptr == null) {
      throw Exception(
        'LibRawImage pointer is null. Ensure the image is opened correctly.',
      );
    }

    final result = bindings.libraw_unpack_thumb(libRawImage.ptr!);
    if (result != 0) {
      bindings.libraw_close(libRawImage.ptr!);
      throw Exception('Failed to unpack thumbnail');
    }

    final thumbnailData = pointerToUint8List(
      libRawImage.ptr!.ref.thumbnail.thumb,
      libRawImage.ptr!.ref.thumbnail.tlength,
    );

    if (thumbnailData.isEmpty) {
      throw Exception('No thumbnail data found');
    }

    libRawImage.thumbnailData = Uint8List.fromList(thumbnailData);
  }

  void closeImage(LibRawImage libRawImage) {
    /// Closes the given [libRawImage] and frees associated resources.

    if (libRawImage.ptr != null) {
      bindings.libraw_close(libRawImage.ptr!);
    }
  }
}
