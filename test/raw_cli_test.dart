import 'dart:io';

import 'package:libraw_dart/libraw.dart';
import 'package:libraw_dart/utils.dart';
import 'package:test/test.dart';

void main() {
  test('open file', () {
    final libname = determineLibraryName();
    final libPath = 'bin/$libname';

    expect(File(libPath).existsSync(), isTrue, reason: 'Library file not found: $libPath');

    LibRawLoader loader = LibRawLoader.fromPath(libPath);

    final image = loader.openImage("assets/DSC03748.ARW");

    final libRawImage = image;
    expect(libRawImage.filepath, isNotEmpty, reason: 'Filepath should not be empty');
    expect(libRawImage.metaData.make, isNotEmpty, reason: 'Make should not be empty');
    expect(libRawImage.metaData.model, isNotEmpty, reason: 'Model should not be empty');
    expect(libRawImage.metaData.lens, isNotEmpty, reason: 'Lens should not be empty');
    expect(libRawImage.metaData.aperture, isNotNull, reason: 'Aperture should not be null');
    expect(libRawImage.metaData.shutter, isNotNull, reason: 'Shutter should not be null');
    expect(libRawImage.metaData.iso, isNotNull, reason: 'ISO should not be null');
    expect(libRawImage.metaData.focalLength, isNotNull, reason: 'Focal Length should not be null');
    expect(libRawImage.metaData.width, greaterThan(0), reason: 'Width should be greater than 0');
    expect(libRawImage.metaData.height, greaterThan(0), reason: 'Height should be greater than 0');

    loader.unpackThumbnail(libRawImage);
    expect(libRawImage.thumbnailData!.length, greaterThan(0), reason: 'Thumbnail unpacked length should be greater than 0 bytes');

    // loader.closeImage(libRawImage);
    // expect(libRawImage.ptr, isNull, reason: 'Pointer should be null after closing the image');
  });
}
