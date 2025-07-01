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

    expect(image, completes, reason: 'Image loading should complete successfully');

    image.then((libRawImage) {
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

      return loader.unpackThumbnailFromLibRawImage(libRawImage);
    }).then((thumbnail) {
      expect(thumbnail.lengthInBytes, greaterThan(0), reason: 'Thumbnail unpacked length should be greater than 0 bytes');
    }).catchError((e) {
      fail('Error during image processing: $e');
    });
  });
}
