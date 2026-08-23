import 'package:call_log/call_log.dart';
import 'package:cod_delivery_app/core/utils/phone_matcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  Future<bool> dialCustomer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> verifyOutboundCall(
    String clientPhone, {
    DateTime? since,
  }) async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    if (!status.isGranted) {
      throw CallLogPermissionException(
          'Call log permission is required to verify the call.');
    }
    final from =
        (since ?? DateTime.now().subtract(const Duration(hours: 1)))
            .millisecondsSinceEpoch;
    final Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: from,
      durationFrom: 1,
      type: CallType.outgoing,
    );
    for (final entry in entries) {
      if (phoneNumbersMatch(entry.number, clientPhone)) return true;
    }
    return false;
  }
}

class CallLogPermissionException implements Exception {
  CallLogPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
