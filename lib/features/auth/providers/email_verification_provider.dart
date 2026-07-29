import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/email_verification_controller.dart';

final emailVerificationProvider =
    NotifierProvider.autoDispose<
      EmailVerificationController,
      EmailVerificationState
    >(EmailVerificationController.new);
