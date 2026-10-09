import 'dart:isolate';

import 'package:flutter/foundation.dart';

Future<T> runHeavy<T>(T Function() work) =>
    kIsWeb ? Future(work) : Isolate.run(work);
