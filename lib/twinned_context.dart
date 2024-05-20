import 'package:twinned_api/api/twinned.swagger.dart';

class TwinnedContext {
  TwinnedContext._privateConstructor();

  static final TwinnedContext _instance = TwinnedContext._privateConstructor();

  String apiToken = '';

  static TwinnedContext get instance => _instance;
}
