import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as digital;

class TwinnedSession {
  TwinnedSession._privateConstructor() {}

  Future load({bool debug = true, String host = 'twinned.digital'}) async {
    if (_inited) return;

    await dotenv.load(fileName: 'settings.txt');

    var session = SessionManager();

    _debug = debug;
    _host = host;

    _twinned =
        digital.Twinned.create(baseUrl: Uri.https(_host, '/rest/nocode'));
    _inited = true;

    await session.update();
  }

  Future cleanup() async {
    return SessionManager().destroy();
  }

  static final TwinnedSession _instance = TwinnedSession._privateConstructor();

  String authToken = '';
  bool _debug = true;
  String _host = '';
  digital.Twinned _twinned = digital.Twinned.create(
      baseUrl: Uri.https('twinned.boodskap.io', '/rest/nocode'));
  bool _inited = false;

  static TwinnedSession get instance => _instance;

  String get host => _host;
  bool get debug => _debug;
  digital.Twinned get twin => _twinned;
  bool get inited => _inited;
}
