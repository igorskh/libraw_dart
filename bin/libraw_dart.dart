import 'dart:io';
import 'dart:isolate';

import 'package:libraw_dart/libraw.dart';
import 'package:libraw_dart/libraw_image.dart';
import 'package:libraw_dart/utils.dart';

Future<LibRawImage> loadRAWImage(String imagePath) async {
  final libname = determineLibraryName();
  final libPath = 'bin/$libname';

  LibRawLoader? loader = LibRawLoader.fromPath(libPath);
  LibRawImage? rawImage = loader.openImageFromPath(imagePath);
  loader.unpackThumbnail(rawImage);

  loader.closeImage(rawImage);

  return rawImage;
}

void printMemoryUsage() {
  final info = ProcessInfo.currentRss;

  print('Current RSS: ${(info / 1024 / 1024).toStringAsFixed(2)} MB');
}

void main(List<String> arguments) async {
  printMemoryUsage();

  LibRawImage? data = await Isolate.run(() async {
    final imagePath = 'test_assets/DSC03748.ARW';
    return await loadRAWImage(imagePath);
  });
  print('Thumbnail length: ${data?.thumbnailData?.length} bytes');

  printMemoryUsage();

  data = await Isolate.run(() async {
    final imagePath = 'test_assets/DSC03748.ARW';
    return await loadRAWImage(imagePath);
  });
  printMemoryUsage();

  if (data == null) {
    print('Failed to load image.');
    return;
  }

  try {
    print('Image loaded: ${data.filepath}');
    print('Make: ${data.libRawData.idata.make}');
    print('Model: ${data.libRawData.idata.model}');
    print('Lens: ${data.libRawData.lens.lens}');
    print('Aperture: ${data.libRawData.other.aperture}');
    print('Shutter: ${data.libRawData.other.shutter}');
    print('ISO: ${data.libRawData.other.isoSpeed}');
    print('Focal Length: ${data.libRawData.other.focalLength}');
    print('Width: ${data.libRawData.sizes.width}');
    print('Height: ${data.libRawData.sizes.height}');

    print('Image closed successfully.');
  } catch (e) {
    print('Error: $e');
  }
}
