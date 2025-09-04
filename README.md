# LibRaw Bindings For Dart

## Versions

Version of [LibRaw](https://github.com/LibRaw/LibRaw/tree/0.21.4) used: 0.21.4

## Generate bindings
```bash
dart run ffigen --config .\ffigen_config.yaml
```

## CLI Example

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