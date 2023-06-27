import 'dart:typed_data';
import 'package:flutter/material.dart';

class FutureImage extends StatelessWidget {
  final Future<Uint8List?>? futureImage;
  final Widget placeholder;
  final BoxFit boxFit;

  const FutureImage({
    required this.futureImage,
    required this.placeholder,
    this.boxFit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: futureImage,
        builder: (context, snapshot) => snapshot.hasError
            ? const Icon(Icons.error_outline_outlined)
            : snapshot.hasData
                ? Image.memory(
                    snapshot.data!,
                    key: ObjectKey(key),
                    fit: boxFit,
                  )
                : placeholder,
      );
}
