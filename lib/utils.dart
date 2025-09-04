import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'libraw_bindings_gen.dart';

Uint8List pointerToUint8List(Pointer<Uint8> data, int length) {
  return data.asTypedList(length);
}

String arrayToString(Array<Uint8> arr) {
  final dartString = <int>[];
  for (var i = 0; i < 256; i++) {
    final char = arr[i];
    if (char == 0) break;
    dartString.add(char);
  }
  return String.fromCharCodes(dartString);
}

String determineLibraryName() {
  if (Platform.isWindows) {
    return 'libraw.dll';
  } else if (Platform.isMacOS) {
    return 'libraw.dylib';
  } else {
    return 'libraw.so';
  }
}

Pointer<Void> uint8ListToPointerVoid(Uint8List data) {
  final p = malloc<Uint8>(data.length);
  p.asTypedList(data.length).setAll(0, data);
  return p.cast<Void>();
}

String strError(LibRawDartBindings bindings, int code) {
  final ptr = bindings.libraw_strerror(code);
  return ptr.cast<Utf8>().toDartString();
}

Uint8List readProcessedImageBytes(Pointer<libraw_processed_image_t> p) {
  final len = p.ref.data_size;
  final headerSize = sizeOf<libraw_processed_image_t>() - 1;
  final base = p.cast<Uint8>();
  final dataPtr = base + headerSize;
  return dataPtr.asTypedList(len);
}
