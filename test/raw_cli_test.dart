import 'dart:io';

import 'package:libraw_dart/libraw.dart';
import 'package:libraw_dart/utils.dart';
import 'package:test/test.dart';

import 'package:image/image.dart' as img;

import 'dart:typed_data';

Future<double> comparePixels(String file1Path, String file2Path) async {
  /// Compares two images pixel by pixel and returns a similarity score between 0.0 and 1.0.
  /// A score of 1.0 indicates identical images, while 0.0 indicates completely different images.
  /// Throws an [ArgumentError] if the images have different dimensions.
  /// Uses the `image` package for image decoding and processing.
  
  final img1 = img.decodeImage(await File(file1Path).readAsBytes());
  final img2 = img.decodeImage(await File(file2Path).readAsBytes());

  if (img1 == null || img2 == null) return 0.0;

  if (img1.width != img2.width || img1.height != img2.height) {
    throw ArgumentError('Images must have the same dimensions for comparison');
  }

  int totalPixels = img1.width * img1.height;
  int differentPixels = 0;

  for (int y = 0; y < img1.height; y++) {
    for (int x = 0; x < img1.width; x++) {
      final pixel1 = img1.getPixel(x, y);
      final pixel2 = img2.getPixel(x, y);

      if (pixel1 != pixel2) {
        differentPixels++;
      }
    }
  }

  return 1.0 - (differentPixels / totalPixels);
}

Future<void> saveImageToJPG(
  img.Image image,
  String filePath, {
  int quality = 5,
}) async {
  /// Saves the given [image] as a JPEG file at the specified [filePath].
  /// The [quality] parameter controls the JPEG quality (1-100).

  await File(filePath).exists().then((exists) {
    if (exists) {
      File(filePath).deleteSync();
    }
  });

  final jpgBytes = img.encodeJpg(image, quality: quality);
  final file = File(filePath);
  await file.writeAsBytes(jpgBytes);
}

Future<void> saveRgbPixelsToJPG(
  Uint8List rgbPixels,
  int width,
  int height,
  String filePath, {
  int quality = 5,
}) async {
  /// Saves the given RGB pixel data as a JPEG file at the specified [filePath].
  /// The [rgbPixels] should be a flat list of RGB values (3 bytes per pixel).
  /// The [width] and [height] specify the dimensions of the image.

  if (rgbPixels.length != width * height * 3) {
    throw ArgumentError('RGB buffer size does not match width*height*3');
  }

  final image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgbPixels.buffer,
    numChannels: 3,
    order: img.ChannelOrder.rgb,
    format: img.Format.uint8,
  );

  await saveImageToJPG(image, filePath, quality: quality);
}

Future<void> saveThumbnailToJPG(
  Uint8List jpgBytes,
  String filePath, {
  int quality = 5,
}) async {
  /// Saves the given JPEG byte data as a JPEG file at the specified [filePath].
  /// The [jpgBytes] should contain valid JPEG data.

  final image = img.decodeJpg(jpgBytes);
  if (image == null) {
    throw Exception('Failed to decode thumbnail JPEG data');
  }

  await saveImageToJPG(image, filePath, quality: quality);
}

void main() {
  test('open filepath', () async {
    final libname = determineLibraryName();
    final libPath = 'bin/$libname';

    expect(
      File(libPath).existsSync(),
      isTrue,
      reason: 'Library file not found: $libPath',
    );

    LibRawLoader loader = LibRawLoader.fromPath(libPath);

    final image = loader.openImageFromPath("test_assets/DSC03748.ARW");

    final libRawImage = image;
    expect(
      libRawImage.filepath,
      isNotEmpty,
      reason: 'Filepath should not be empty',
    );
    expect(
      libRawImage.libRawData.idata.make,
      equals('Sony'),
      reason: 'Make should not be empty',
    );
    expect(
      libRawImage.libRawData.idata.model,
      equals('ILCE-7M4'),
      reason: 'Model should not be empty',
    );
    expect(
      libRawImage.libRawData.lens.lens,
      equals("150-600mm F5-6.3 DG DN OS | Sports 021"),
      reason: 'Lens should not be empty',
    );
    expect(
      libRawImage.libRawData.other.aperture,
      closeTo(6.3, 0.1),
      reason: 'Aperture should not be null',
    );
    expect(
      libRawImage.libRawData.other.shutter,
      closeTo(0.002, 0.001),
      reason: 'Shutter should not be null',
    );
    expect(
      libRawImage.libRawData.other.isoSpeed,
      closeTo(32000.0, 0.1),
      reason: 'ISO should not be null',
    );
    expect(
      libRawImage.libRawData.other.focalLength,
      closeTo(600.0, 0.1),
      reason: 'Focal Length should not be null',
    );
    expect(
      libRawImage.libRawData.sizes.width,
      equals(7028),
      reason: 'Width should be greater than 0',
    );
    expect(
      libRawImage.libRawData.sizes.height,
      equals(4688),
      reason: 'Height should be greater than 0',
    );

    loader.unpackThumbnail(libRawImage);
    expect(
      libRawImage.thumbnailData!.length,
      equals(7072714),
      reason: 'Thumbnail unpacked length should be greater than 0 bytes',
    );

    final outputPath = 'test_output/DSC03748_t_q5.jpg';

    await Directory('test_output').create(recursive: true);

    await saveThumbnailToJPG(libRawImage.thumbnailData!, outputPath);

    final similarity = await comparePixels(
      'test_assets/snapshots/DSC03748_t_q5.jpg',
      outputPath,
    );
    expect(
      similarity,
      greaterThan(0.99),
      reason: 'Images should be at least 99% similar',
    );
  });

  test('open bytes', () async {
    final libname = determineLibraryName();
    final libPath = 'bin/$libname';

    expect(
      File(libPath).existsSync(),
      isTrue,
      reason: 'Library file not found: $libPath',
    );

    LibRawLoader loader = LibRawLoader.fromPath(libPath);

    final bytes = File("test_assets/P6270279.ORF").readAsBytesSync();
    final image = loader.openImageFromBytes(bytes);

    final libRawImage = image;
    expect(
      libRawImage.filepath,
      isNotEmpty,
      reason: 'Filepath should not be empty',
    );
    expect(
      libRawImage.libRawData.idata.make,
      equals("OM Digital"),
      reason: 'Make should not be empty',
    );
    expect(
      libRawImage.libRawData.idata.model,
      equals("OM-1"),
      reason: 'Model should not be empty',
    );
    expect(
      libRawImage.libRawData.lens.lens,
      equals("OLYMPUS M.300mm F4.0"),
      reason: 'Lens should not be empty',
    );
    expect(
      libRawImage.libRawData.other.aperture,
      closeTo(4.0, 0.1),
      reason: 'Aperture should not be null',
    );
    expect(
      libRawImage.libRawData.other.shutter,
      closeTo(0.0049, 0.0001),
      reason: 'Shutter should not be null',
    );
    expect(
      libRawImage.libRawData.other.isoSpeed,
      closeTo(5000.0, 0.1),
      reason: 'ISO should not be null',
    );
    expect(
      libRawImage.libRawData.other.focalLength,
      closeTo(300.0, 0.1),
      reason: 'Focal Length should not be null',
    );
    expect(
      libRawImage.libRawData.sizes.width,
      equals(5220),
      reason: 'Width should be greater than 0',
    );
    expect(
      libRawImage.libRawData.sizes.height,
      equals(3912),
      reason: 'Height should be greater than 0',
    );

    loader.unpackThumbnail(libRawImage);

    expect(
      libRawImage.thumbnailData!.length,
      equals(1136575),
      reason: 'Thumbnail unpacked length should be greater than 0 bytes',
    );

    final outputPath = 'test_output/P6270279_t_q5.jpg';

    await Directory('test_output').create(recursive: true);

    await saveThumbnailToJPG(libRawImage.thumbnailData!, outputPath);

    final similarity = await comparePixels(
      'test_assets/snapshots/P6270279_t_q5.jpg',
      outputPath,
    );
    expect(
      similarity,
      greaterThan(0.99),
      reason: 'Images should be at least 99% similar',
    );
  });

  test('decode image', () async {
    final libname = determineLibraryName();
    final libPath = 'bin/$libname';

    expect(
      File(libPath).existsSync(),
      isTrue,
      reason: 'Library file not found: $libPath',
    );

    LibRawLoader loader = LibRawLoader.fromPath(libPath);

    final bytes = File("test_assets/DSC03748.ARW").readAsBytesSync();
    final image = loader.openImageFromBytes(bytes);
    loader.unpackImage(image);

    expect(
      image.imageData,
      isNotNull,
      reason: 'Image data should not be null after unpacking',
    );
    expect(
      image.imageData!.length,
      equals(98841792),
      reason: 'Image unpacked length should be equal to 98841792 bytes',
    );

    final outputPath = 'test_output/DSC03748_q5.jpg';

    await Directory('test_output').create(recursive: true);

    await saveRgbPixelsToJPG(
      image.imageData!,
      image.libRawData.sizes.width,
      image.libRawData.sizes.height,
      outputPath,
      quality: 5,
    );

    final similarity = await comparePixels(
      'test_assets/snapshots/DSC03748_q5.jpg',
      outputPath,
    );
    expect(
      similarity,
      greaterThan(0.99),
      reason: 'Images should be at least 99% similar',
    );
  });
}
