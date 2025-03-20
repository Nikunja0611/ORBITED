// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_mlkit_commons;

// Exports
export 'input_image.dart';
export 'vision_input.dart';

// Utilities for ML Kit Vision plugins
class ImageFormatGroup {
  /// Do not use this directly!
  static const bgra8888 = 'bgra8888';

  /// Do not use this directly!
  static const yuv420 = 'yuv420';

  /// Do not use this directly!
  static const jpeg = 'jpeg';

  /// Do not use this directly!
  static const nv21 = 'nv21';
}

/// Common enum for ML kit plugins
enum DetectionMode { stream, single }

// Base ML Kit exception class
class MLKitException implements Exception {
  String code;
  String message;

  MLKitException(this.code, this.message);

  @override
  String toString() => 'MLKitException($code, $message)';
}

// Input image source types
enum InputImageSource {
  gallery,
  camera,
  file,
  bytes,
}