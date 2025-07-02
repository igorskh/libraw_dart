import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

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