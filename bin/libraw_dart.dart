import 'dart:io';

import 'package:libraw_dart/libraw.dart';
import 'package:libraw_dart/utils.dart';

void main(List<String> arguments) async {

  final libname = determineLibraryName();
  final libPath = 'bin/$libname';

  if (!File(libPath).existsSync()) {
    print('Library file not found: $libPath');
    return;
  }

  LibRawLoader loader = LibRawLoader.fromPath(libPath);

  final image = loader.openImage("assets/DSC03748.ARW");

  try {
    final libRawImage = image;
    print('Image loaded: ${libRawImage.filepath}');
    print('Make: ${libRawImage.metaData.make}');
    print('Model: ${libRawImage.metaData.model}');
    print('Lens: ${libRawImage.metaData.lens}');
    print('Aperture: ${libRawImage.metaData.aperture}');
    print('Shutter: ${libRawImage.metaData.shutter}');
    print('ISO: ${libRawImage.metaData.iso}');
    print('Focal Length: ${libRawImage.metaData.focalLength}');
    print('Width: ${libRawImage.metaData.width}');
    print('Height: ${libRawImage.metaData.height}');

    final thumbnail = loader.unpackThumbnailFromLibRawImage(libRawImage);
    print('Thumbnail unpacked, length: ${thumbnail.length} bytes');
  } catch (e) {
    print('Error: $e');
  }
}
