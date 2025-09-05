# LibRaw Bindings For Dart

## Versions

Version of [LibRaw](https://github.com/LibRaw/LibRaw/tree/0.21.4) used: 0.21.4

## Generate bindings

The submodule is linked to the tested version of LibRaw:
```bash
git submodule update --init --recursive
```

Generate bindings:
```bash
dart run ffigen --config ./ffigen_config.yaml
```

## Usage

This library is not bundled with libraw binaries. Corresponding binaries are required to run an application, `libraw.dylib` for macOS/iOS/iPadOS, `libraw.dll` for Windows, `libraw.so` for desktop Linux or Android.

Create loader. determineLibraryName returns library name for the runtime:
```dart
final libname = determineLibraryName();
final libPath = 'bin/$libname';

LibRawLoader loader = LibRawLoader.fromPath(libPath);
```

Load image, it does not unpack thumbnail or image yet:
```dart
final image = loader.openImageFromPath("test_assets/DSC03748.ARW");
```

Alternatively use `openImageFromBytes`:
```dart
final bytes = File("test_assets/DSC03748.ARW").readAsBytesSync();
final image = loader.openImageFromBytes(bytes);
```

Loads thumbnail in place. The `thumbnailData` property contains bytes for thumbnail image that can be directly written to a file:
```dart
loader.unpackThumbnail(libRawImage);

print(libRawImage.thumbnailData!);
```


Load image RGB data in place. The `imageData` property contains bytes of RGB data and need to be processed to be saved to a file:
```dart
loader.unpackImage(image);

print(image.imageData!.length);
```

Close image to free resources, unpacked data persists in the `image` instance:
```dart
loader.closeImage(image);
```

## CLI Example

Following script downloads a DLL: 
```bash
.\download-libraw.ps1
```

Run CLI exmample:
```bash
dart pub get
dart run
```

This should output the following:
```bash
Building package executable... 
Built libraw_dart:libraw_dart.
Image loaded: [REDACTED]/assets/DSC03748.ARW
Make: Sony
Model: ILCE-7M4
Lens: 150-600mm F5-6.3 DG DN OS | Sports 021
Aperture: 6.300000190734863
Shutter: 499.9999762512755
ISO: 32000
Focal Length: 600.0
Width: 7028
Height: 4688
Thumbnail unpacked, length: 7072714 bytes
```