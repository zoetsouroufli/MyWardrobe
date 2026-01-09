import 'background_remover_stub.dart'
    if (dart.library.io) 'background_remover_mobile.dart';

class BackgroundRemover {
  static final BackgroundRemover _instance = BackgroundRemover._internal();
  factory BackgroundRemover() => _instance;
  BackgroundRemover._internal();

  final _impl = getBackgroundRemoverImplementation();

  Future<String?> removeBackground(String imagePath) {
    return _impl.removeBackground(imagePath);
  }
}
