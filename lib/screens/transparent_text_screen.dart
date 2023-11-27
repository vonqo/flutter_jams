import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_jams/main.dart';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TransparentTextScreen extends StatefulWidget {
  const TransparentTextScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TransparentTextScreenState();
  }
}

class _TransparentTextScreenState extends State<TransparentTextScreen> {

  late CameraController _cameraController;
  final GlobalKey globalKey = GlobalKey();
  final ValueNotifier<Matrix4> _transformer = ValueNotifier<Matrix4>(Matrix4.identity());
  Uint8List? _image;

  /// =============================================================== ///
  @override
  void initState() {
    super.initState();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // await Future.delayed(const Duration(milliseconds: 1000));
      await _processImage();
    });
  }

  /// =============================================================== ///
  @override
  void dispose() {
    super.dispose();
  }

  /// ============================================================== ///
  Future<void> _initCamera() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  /// =============================================================== ///
  Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer = await
    ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id = ui.ImageDescriptor.raw(
        buffer,
        height: image.height,
        width: image.width,
        pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(
        targetHeight: image.height,
        targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  /// =============================================================== ///
  Future<void> _processImage() async {
    final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image widgetImage = await boundary.toImage(pixelRatio: 3);
    final ByteData? byteData = await widgetImage.toByteData();
    final image = img.Image.fromBytes(width: widgetImage.width, height: widgetImage.height, bytes: byteData!.buffer, numChannels: 4);

    for (img.Pixel pixel in image) {
      if(pixel.a == 0) {
        pixel.setRgba(0, 0, 0, 255);
      } else if(pixel.r == 0 && pixel.g == 0 && pixel.b == 0) {
        pixel.a = 0;
      } else {
        pixel.r = 255 - pixel.r;
        pixel.g = 255 - pixel.g;
        pixel.b = 255 - pixel.b;
        pixel.a = (pixel.r + pixel.g + pixel.b) / 3;
      }
    }

    setState(() { _image = img.encodePng(image); });
  }

  /// =============================================================== ///
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        (!_cameraController.value.isInitialized) ? const SizedBox() : ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: CameraPreview(_cameraController),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _image == null
                    ? RepaintBoundary(
                        key: globalKey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 30,),
                              Container(
                                height: 300,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/images/lenna.png'),
                                  )
                                ),
                              ),
                              const SizedBox(height: 10,),
                              const Text(
                                "Using programming to create art is a practice that started in the 1960s. In later decades groups such as Compos 68 successfully explored programming for artistic purposes, having their work exhibited in international exhibitions.",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 120,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage('assets/images/lenna.png'),
                                          )
                                      ),
                                    )
                                  ),
                                  const SizedBox(width: 20,),
                                  Expanded(
                                    child: Container(
                                      height: 120,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage('assets/images/lenna.png'),
                                          )
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  Expanded(
                                    child: Container(
                                      height: 120,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage('assets/images/lenna.png'),
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              const Text(
                                "From the 80s onward expert programmers joined the demoscene, and tested their skills against each other by creating \"demos\": highly technically competent visual creations. Recent exhibitions and books, including Dominic Lopes' A Philosophy of Computer Art (2009) have sought to examine the integral role of coding in contemporary art beyond that of Human Computer Interface (HCI).[2] Criticising Lopes however, Juliff and Cox argue that Lopes continues to privilege interface and user at the expense of the integral condition of code in much computer art. Arguing for a more nuanced appreciation of coding, Juliff and Cox set out contemporary creative coding as the examination of code and intentionality as integral to the users understanding of the work. Currently there is a renewed interest in the question why programming as a method of producing art hasn't flourished. Google has renewed interest with their Dev Art initiative,[4] but this in turn has elicited strong reactions from a number of creative coders who claim that coining a new term to describe their practice is counterproductive",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _transformWrapper(Image.memory(_image!)),
              ],
            ),
          ),
        )
      ],
    );
  }

  /// =============================================================== ///
  Widget _transformWrapper(Widget child) {
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) {

      },
      child: ValueListenableBuilder(
        valueListenable: _transformer,
        builder: (BuildContext context, Matrix4 value, Widget? child) {
          return Transform(
            transform: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

}