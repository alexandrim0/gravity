import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:gravity/ui/utils.dart';

class QRScanDialog extends StatefulWidget {
  static Future<String?> show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const QRScanDialog(),
      );

  const QRScanDialog({super.key});

  @override
  State<QRScanDialog> createState() => _QRScanDialogState();
}

class _QRScanDialogState extends State<QRScanDialog> {
  bool _hasResult = false;
  late Rect _scanWindow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    final scanAreaSize = switch (ScreenSize.get(size)) {
      ScreenSmall _ => size.width * 0.7,
      ScreenMedium _ => size.width * 0.7,
      ScreenLarge _ => size.width * 0.6,
      ScreenBig _ => size.width * 0.5,
    };
    _scanWindow = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scanAreaSize,
      height: scanAreaSize,
    );
  }

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.lightbulb_outline_rounded),
                onPressed: () {},
              ),
            ],
            backgroundColor: Colors.transparent,
            title: const Text('Scan the QR Code'),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              MobileScanner(
                scanWindow: _scanWindow,
                onDetect: (BarcodeCapture captured) {
                  if (_hasResult || captured.barcodes.isEmpty) return;
                  if (context.mounted) {
                    _hasResult = true;
                    Navigator.of(context)
                        .pop<String?>(captured.barcodes.first.rawValue);
                  }
                },
              ),
              CustomPaint(painter: _ScannerOverlay(scanWindow: _scanWindow)),
              Positioned.fromRect(
                rect: _scanWindow,
                child: SizedBox(
                  height: _scanWindow.height,
                  width: _scanWindow.width,
                  child: const SvgPicture(
                    AssetBytesLoader('assets/images/frame.svg.vec'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ScannerOverlay extends CustomPainter {
  final Rect scanWindow;

  const _ScannerOverlay({required this.scanWindow});

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.largest),
          Path()..addRect(scanWindow),
        ),
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.dstOut,
      );
}
