import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'libraw_bindings_gen.dart';

Uint8List pointerToUint8List(Pointer<Uint8> data, int length) {
  /// Converts a [Pointer<Uint8>] to a [Uint8List] of the specified [length].
  /// Returns the resulting [Uint8List].

  return data.asTypedList(length);
}

String arrayToString(Array<Uint8> arr) {
  /// Converts a [Array<Uint8>] to a Dart [String].
  /// Stops at the first null byte (0).
  /// Returns the resulting [String].

  final dartString = <int>[];
  for (var i = 0; i < 256; i++) {
    final char = arr[i];
    if (char == 0) break;
    dartString.add(char);
  }
  return String.fromCharCodes(dartString);
}

String determineLibraryName() {
  /// Determines the appropriate library name based on the current platform.
  /// Returns the library name as a [String].

  if (Platform.isWindows) {
    return 'libraw.dll';
  } else if (Platform.isMacOS) {
    return 'libraw.dylib';
  } else {
    return 'libraw.so';
  }
}

Pointer<Void> uint8ListToPointerVoid(Uint8List data) {
  /// Converts a [Uint8List] to a [Pointer<Void>].
  /// Allocates memory for the data and copies the contents of the list into it.

  final p = malloc<Uint8>(data.length);
  p.asTypedList(data.length).setAll(0, data);
  return p.cast<Void>();
}

String strError(LibRawDartBindings bindings, int code) {
  /// Returns a human-readable error message corresponding to the given error code.
  ///
  /// Uses the `libraw_strerror` function from the provided [bindings] to retrieve the error message.
  /// The returned string is a Dart [String].

  final ptr = bindings.libraw_strerror(code);
  return ptr.cast<Utf8>().toDartString();
}

Uint8List readProcessedImageBytes(Pointer<libraw_processed_image_t> p) {
  /// Reads the processed image bytes from the given pointer.
  ///
  /// Returns a [Uint8List] containing the image bytes.

  final len = p.ref.data_size;
  final headerSize = sizeOf<libraw_processed_image_t>() - 1;
  final base = p.cast<Uint8>();
  final dataPtr = base + headerSize;
  return dataPtr.asTypedList(len);
}
