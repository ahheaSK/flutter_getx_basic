import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../constant/api_constant.dart';
import '../../constant/app_constant.dart';
import '../../core/util/api_client.dart';
import '../../core/util/logger.dart';
import '../../core/util/token_storage.dart';
import '../model/response/sse_event.dart';

/// Keeps a live `text/event-stream` open to the backend.
///
/// Flutter has no `EventSource`, so the stream is read by hand:
/// Dio is asked for a raw byte stream, the bytes are decoded into lines, and
/// lines are folded back into frames. One frame looks like this on the wire —
///
/// ```
/// event:user-event
/// data:{"action":"CREATED","user":{…}}
/// <blank line ends the frame>
/// ```
///
/// The server also sends `: ping` comment lines every 25 seconds. They exist
/// only to stop proxies closing an idle connection and carry no data, so they
/// are skipped here.
class SseService {
  SseService(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  /// Broadcast so several controllers can listen to the same connection.
  final StreamController<SseEvent> _controller =
      StreamController<SseEvent>.broadcast();

  CancelToken? _cancelToken;
  StreamSubscription<String>? _subscription;
  Timer? _retryTimer;
  bool _wantConnected = false;

  /// Listen to this for every frame the server pushes.
  Stream<SseEvent> get events => _controller.stream;

  bool get isConnected => _subscription != null;

  /// Opens the stream. Safe to call twice — the second call is ignored.
  Future<void> connect() async {
    if (_subscription != null) return;
    if (!_storage.hasToken) return;

    _wantConnected = true;
    final String token = _storage.token!;

    try {
      // A normal GET, except the body is never expected to finish.
      final Response<ResponseBody> response = await _api.dio.get<ResponseBody>(
        ApiConstant.sseSubscribe(token),
        cancelToken: _cancelToken = CancelToken(),
        options: Options(
          responseType: ResponseType.stream,
          headers: <String, String>{'Accept': 'text/event-stream'},
          // No receive timeout: an idle stream is normal, not a failure.
          receiveTimeout: Duration.zero,
        ),
      );

      final int status = response.statusCode ?? 0;
      if (status != 200) {
        Logger.e('SSE', 'subscribe failed with $status');
        _scheduleRetry();
        return;
      }

      String eventName = 'message';
      final StringBuffer data = StringBuffer();

      _subscription = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (String line) {
              // Blank line = end of frame; emit whatever was collected.
              if (line.isEmpty) {
                _emit(eventName, data.toString());
                eventName = 'message';
                data.clear();
                return;
              }

              // Comment frame (the heartbeat) — ignore.
              if (line.startsWith(':')) return;

              if (line.startsWith('event:')) {
                eventName = _valueOf(line, 'event:');
              } else if (line.startsWith('data:')) {
                data.write(_valueOf(line, 'data:'));
              }
            },
            onDone: () {
              Logger.d('SSE', 'stream closed by server');
              _teardown();
              _scheduleRetry();
            },
            onError: (Object error) {
              Logger.e('SSE', error);
              _teardown();
              _scheduleRetry();
            },
            cancelOnError: true,
          );

      Logger.d('SSE', 'connected');
    } catch (e) {
      Logger.e('SSE', 'connect failed: $e');
      _scheduleRetry();
    }
  }

  /// Closes the stream and stops reconnecting. Called on logout.
  Future<void> disconnect() async {
    _wantConnected = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _teardown();
    Logger.d('SSE', 'disconnected');
  }

  /// Releases everything; call from the binding when the app shuts down.
  void dispose() {
    disconnect();
    _controller.close();
  }

  void _teardown() {
    _subscription?.cancel();
    _subscription = null;
    _cancelToken?.cancel('sse closed');
    _cancelToken = null;
  }

  /// The server restarting, or the phone changing network, drops the stream.
  /// Reconnecting is the client's job — a browser's EventSource does the same.
  void _scheduleRetry() {
    if (!_wantConnected || _retryTimer != null) return;
    _retryTimer = Timer(AppConstant.sseRetryDelay, () {
      _retryTimer = null;
      if (_wantConnected) connect();
    });
  }

  /// Turns one finished frame into a typed event.
  void _emit(String name, String payload) {
    if (payload.isEmpty) return;
    try {
      final Object? decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _controller.add(SseEvent.fromJson(name, decoded));
      }
    } catch (e) {
      // A malformed frame must not kill the subscription.
      Logger.e('SSE', 'bad frame: $payload');
    }
  }

  /// `data:{…}` and `data: {…}` are both legal; strip the optional space.
  String _valueOf(String line, String prefix) {
    final String value = line.substring(prefix.length);
    return value.startsWith(' ') ? value.substring(1) : value;
  }
}
