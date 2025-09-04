import 'utils.dart';

import 'libraw_bindings_gen.dart';

class LibRawIData {
  final String make;
  final String model;
  final String normalizedMake;
  final String normalizedModel;
  final int makerIndex;
  final String software;
  final int rawCount;
  final int isFoveon;
  final int dngVersion;
  final int colors;
  final int filters;

  LibRawIData(libraw_iparams_t idata)
    : make = arrayToString(idata.make),
      model = arrayToString(idata.model),
      normalizedMake = arrayToString(idata.normalized_make),
      normalizedModel = arrayToString(idata.normalized_model),
      makerIndex = idata.maker_index,
      software = arrayToString(idata.software),
      rawCount = idata.raw_count,
      isFoveon = idata.is_foveon,
      dngVersion = idata.dng_version,
      colors = idata.colors,
      filters = idata.filters;
}

class LibRawImageSizes {
  final int width;
  final int height;
  final int topMargin;
  final int leftMargin;
  final int iwidth;
  final int iheight;
  final int rawHeight;
  final int rawWidth;
  final int flip;
  final int rawPitch;
  final double pixelAspect;

  LibRawImageSizes(libraw_image_sizes_t sizes)
    : width = sizes.width,
      height = sizes.height,
      topMargin = sizes.top_margin,
      leftMargin = sizes.left_margin,
      iwidth = sizes.iwidth,
      iheight = sizes.iheight,
      rawHeight = sizes.raw_height,
      rawWidth = sizes.raw_width,
      flip = sizes.flip,
      rawPitch = sizes.raw_pitch,
      pixelAspect = sizes.pixel_aspect;
}

class LibRawImageOther {
  final double isoSpeed;
  final int timestamp;
  final double aperture;
  final double shutter;
  final double focalLength;
  final int shotOrder;
  final String description;
  final String artist;

  LibRawImageOther(libraw_imgother_t other)
    : isoSpeed = other.iso_speed,
      shutter = other.shutter,
      aperture = other.aperture,
      focalLength = other.focal_len,
      timestamp = other.timestamp,
      shotOrder = other.shot_order,
      description = arrayToString(other.desc),
      artist = arrayToString(other.artist);
}

class LibRawLensInfo {
  final String lens;
  final String lensMake;
  final double minFocal;
  final double maxFocal;
  final double maxAp4MinFocal;
  final double maxAp4MaxFocal;
  final double exifMaxAperture;
  final int focalLengthIn35mmFormat;

  LibRawLensInfo(libraw_lensinfo_t lens)
    : lens = arrayToString(lens.Lens),
      lensMake = arrayToString(lens.LensMake),
      minFocal = lens.MinFocal,
      maxFocal = lens.MaxFocal,
      maxAp4MinFocal = lens.MaxAp4MinFocal,
      maxAp4MaxFocal = lens.MaxAp4MaxFocal,
      exifMaxAperture = lens.EXIF_MaxAp,
      focalLengthIn35mmFormat = lens.FocalLengthIn35mmFormat;
}

class LibRawData {
  final LibRawIData idata;
  final LibRawImageSizes sizes;
  final LibRawImageOther other;
  final LibRawLensInfo lens;

  LibRawData(libraw_data_t data)
    : idata = LibRawIData(data.idata),
      sizes = LibRawImageSizes(data.sizes),
      other = LibRawImageOther(data.other),
      lens = LibRawLensInfo(data.lens);
}