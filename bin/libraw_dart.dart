import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:libraw_dart/libraw.dart';
import 'package:libraw_dart/libraw_image.dart';
import 'package:libraw_dart/utils.dart';

Future<Uint8List> unpackRAWThumbnail(String imagePath) async {
  final libname = determineLibraryName();
  final libPath = 'bin/$libname';

  LibRawLoader? loader = LibRawLoader.fromPath(libPath); // FFI object must be created here
  LibRawImage? rawImage = loader.openImage(imagePath);
  final thumbnail = loader.unpackThumbnail(rawImage);

  loader.closeImage(rawImage);

  return thumbnail;
}


void printMemoryUsage() {
  final info = ProcessInfo.currentRss;
  // final maxInfo = ProcessInfo.maxRss;
  
  print('Current RSS: ${(info / 1024 / 1024).toStringAsFixed(2)} MB');
  // print('Max RSS: ${(maxInfo / 1024 / 1024).toStringAsFixed(2)} MB');
}


void main(List<String> arguments) async {
  printMemoryUsage();

  Uint8List? data = await Isolate.run(() async {
    final imagePath = 'assets/DSC03748.ARW'; 
    final thumbnailData = await unpackRAWThumbnail(imagePath);

    return thumbnailData;
  });
  print('Thumbnail length: ${data?.length} bytes');

  printMemoryUsage();


  data = await Isolate.run(() async {
    final imagePath = 'assets/DSC03748.ARW'; 
    final thumbnailData = await unpackRAWThumbnail(imagePath);

    return thumbnailData;
  });
  printMemoryUsage();

  // try {
  //   final libRawImage = image;
  //   print('Image loaded: ${libRawImage.filepath}');
  //   print('Make: ${libRawImage.metaData.make}');
  //   print('Model: ${libRawImage.metaData.model}');
  //   print('Lens: ${libRawImage.metaData.lens}');
  //   print('Aperture: ${libRawImage.metaData.aperture}');
  //   print('Shutter: ${libRawImage.metaData.shutter}');
  //   print('ISO: ${libRawImage.metaData.iso}');
  //   print('Focal Length: ${libRawImage.metaData.focalLength}');
  //   print('Width: ${libRawImage.metaData.width}');
  //   print('Height: ${libRawImage.metaData.height}');

  //   final thumbnail = loader.unpackThumbnail(libRawImage);
  //   print('Thumbnail unpacked, length: ${thumbnail.length} bytes');
  //   printMemoryUsage();
  //   print(libRawImage.ptr!.ref.thumbnail.tformatAsInt);

  //   // Close the image to free resources
  //   loader.closeImage(libRawImage);
  //   printMemoryUsage();

  //   print('Image closed successfully.');
  // } catch (e) {
  //   print('Error: $e');
  // }
}
