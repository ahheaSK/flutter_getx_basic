import 'package:flutter_test/flutter_test.dart';
import 'package:project_flutter_getx_basic/data/model/response/page_response.dart';
import 'package:project_flutter_getx_basic/data/model/response/sse_event.dart';
import 'package:project_flutter_getx_basic/data/model/user_model.dart';
import 'package:project_flutter_getx_basic/util/validator.dart';

/// These cover the pieces that break silently when the backend's JSON changes:
/// envelope parsing, and the validation rules that must stay in step with the
/// server's own `UserValidator`.
void main() {
  group('UserModel', () {
    test('parses a UserResponse and derives display fields', () {
      final UserModel user = UserModel.fromJson(<String, dynamic>{
        'id': 3,
        'username': 'student@example.com',
        'nickName': 'Study Buddy',
        'enabled': true,
        'imageName': '3-a1b2.png',
        'imageUrl': '/api/files/3-a1b2.png',
        'createdAt': '2026-08-14T11:20:03.029574Z',
        'updatedAt': '2026-08-14T11:20:03.029574Z',
      });

      expect(user.id, 3);
      expect(user.displayName, 'Study Buddy');
      expect(user.initials, 'SB');
      // The server sends a path; the client has to prepend the host.
      expect(user.fullImageUrl, endsWith('/api/files/3-a1b2.png'));
      expect(user.createdAt, isNotNull);
    });

    test('falls back to the username when there is no nickname', () {
      final UserModel user = UserModel.fromJson(<String, dynamic>{
        'id': 1,
        'username': 'admin@example.com',
      });

      expect(user.displayName, 'admin@example.com');
      expect(user.initials, 'AD');
      expect(user.fullImageUrl, isNull);
    });

    test('survives missing and malformed fields', () {
      final UserModel user = UserModel.fromJson(<String, dynamic>{
        'id': 9,
        'username': 'x@y.com',
        'createdAt': 'not-a-date',
      });

      // A bad timestamp must not take the whole list down.
      expect(user.createdAt, isNull);
      expect(user.enabled, isTrue);
    });
  });

  group('PageResponse', () {
    test('reads the pagination block that sits beside data', () {
      final PageResponse<UserModel> page = PageResponse<UserModel>.fromJson(
        <String, dynamic>{
          'status': 200,
          'pagination': <String, dynamic>{
            'page': 0,
            'size': 10,
            'total': 25,
            'totalPages': 3,
          },
          'data': <dynamic>[
            <String, dynamic>{'id': 1, 'username': 'a@b.com'},
            <String, dynamic>{'id': 2, 'username': 'c@d.com'},
          ],
        },
        UserModel.fromJson,
      );

      expect(page.items.length, 2);
      expect(page.total, 25);
      expect(page.hasNext, isTrue);
      expect(page.nextPage, 1);
    });

    test('knows when it is on the last page', () {
      final PageResponse<UserModel> page = PageResponse<UserModel>.fromJson(
        <String, dynamic>{
          'pagination': <String, dynamic>{
            'page': 2,
            'size': 10,
            'total': 25,
            'totalPages': 3,
          },
          'data': <dynamic>[],
        },
        UserModel.fromJson,
      );

      expect(page.hasNext, isFalse);
    });
  });

  group('SseEvent', () {
    test('parses a CREATED frame into a full user', () {
      final SseEvent event = SseEvent.fromJson('user-event', <String, dynamic>{
        'action': 'CREATED',
        'user': <String, dynamic>{'id': 9, 'username': 'new@example.com'},
        'timestamp': '2026-08-14T11:22:04.473941Z',
      });

      expect(event.action, SseAction.created);
      expect(event.isUserChange, isTrue);
      expect(event.user?.username, 'new@example.com');
    });

    test('a DELETED frame carries only the id, not a full user', () {
      final SseEvent event = SseEvent.fromJson('user-event', <String, dynamic>{
        'action': 'DELETED',
        'user': <String, dynamic>{'id': 6, 'username': 'gone@example.com'},
      });

      expect(event.action, SseAction.deleted);
      expect(event.userId, 6);
      // Building a full model here would invent defaults the server never sent.
      expect(event.user, isNull);
    });

    test('an unknown action is ignored rather than crashing', () {
      final SseEvent event = SseEvent.fromJson('user-event', <String, dynamic>{
        'action': 'ROTATED',
      });

      expect(event.action, SseAction.unknown);
      expect(event.isUserChange, isFalse);
    });
  });

  group('Validator', () {
    test('username must look like an email', () {
      expect(Validator.username('admin@example.com'), isNull);
      expect(Validator.username(''), isNotNull);
      expect(Validator.username('not-an-email'), isNotNull);
    });

    test('password matches the backend complexity rule', () {
      expect(Validator.password('Admin@123'), isNull);
      expect(Validator.password('short1!'), isNotNull); // too short
      expect(Validator.password('alllowercase1!'), isNotNull); // no uppercase
      expect(Validator.password('NoSymbol123'), isNotNull); // no special char
    });
  });
}
