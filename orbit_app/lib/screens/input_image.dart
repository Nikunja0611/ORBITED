// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

/// Represents an image object used for both input and output of ML vision detectors.
class InputImage {
  /// The file path from which the image should be read.
  final String? filePath;

  /// The binary data of the image.
  final Uint8List? bytes;

  /// The metadata of the image.
  final InputImageMetadata? metadata;

  // Private constructor to enforce type safety
  InputImage._({this.filePath, this.bytes, this.metadata})
      : assert(filePath != null || bytes != null);

  /// Creates an instance from a file.
  factory InputImage.fromFilePath(String filePath) {
    return InputImage._(filePath: filePath);
  }

  /// Creates an instance from binary data.
  factory InputImage.fromBytes({
    required Uint8List bytes,
    required InputImageMetadata metadata,
  }) {
    return InputImage._(bytes: bytes, metadata: metadata);
  }

  /// Creates an instance from a [File] object.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path);
  }

  /// Converts the image properties to a map.
  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'bytes': bytes,
        'metadata': metadata?.toJson(),
      };
}

/// Metadata for an input image.
class InputImageMetadata {
  /// Size of the input image.
  final Size size;

  /// Image rotation degree.
  final InputImageRotation rotation;

  /// Format of the input image.
  final InputImageFormat format;

  /// The plane attributes if the image is in multi-plane format.
  final List<InputImagePlaneMetadata>? planeData;

  /// Constructor to create an immutable metadata object.
  InputImageMetadata({
    required this.size,
    required this.rotation,
    required this.format,
    this.planeData,
  });

  /// Converts metadata to a map.
  Map<String, dynamic> toJson() => {
        'width': size.width,
        'height': size.height,
        'rotation': rotation.rawValue,
        'format': format.rawValue,
        'planeData': planeData?.map((plane) => plane.toJson()).toList(),
      };
}

/// Plane metadata for multi-plane images.
class InputImagePlaneMetadata {
  /// The width of the plane.
  final int width;

  /// The height of the plane.
  final int height;

  /// Number of bytes per row in this plane.
  final int bytesPerRow;

  /// Constructor for immutable plane metadata.
  InputImagePlaneMetadata({
    required this.width,
    required this.height,
    required this.bytesPerRow,
  });

  /// Converts plane metadata to a map.
  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'bytesPerRow': bytesPerRow,
      };
}

/// The format of the input image.
enum InputImageFormat {
  nv21,
  yv12,
  yuv_420_888,
  yuv420,
  bgra8888,
  rgba8888,
}

/// Extension to get raw value for InputImageFormat.
extension InputImageFormatValue on InputImageFormat {
  int get rawValue {
    switch (this) {
      case InputImageFormat.nv21:
        return 17;
      case InputImageFormat.yv12:
        return 842094169;
      case InputImageFormat.yuv_420_888:
        return 35;
      case InputImageFormat.yuv420:
        return 875704438;
      case InputImageFormat.bgra8888:
        return 1111970369;
      case InputImageFormat.rgba8888:
        return 1;
      default:
        return 0;
    }
  }
}

/// The rotation of the input image.
enum InputImageRotation {
  rotation0deg,
  rotation90deg,
  rotation180deg,
  rotation270deg,
}

/// Extension to get raw value for InputImageRotation.
extension InputImageRotationValue on InputImageRotation {
  int get rawValue {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return 0;
      case InputImageRotation.rotation90deg:
        return 90;
      case InputImageRotation.rotation180deg:
        return 180;
      case InputImageRotation.rotation270deg:
        return 270;
      default:
        return 0;
    }
  }
}