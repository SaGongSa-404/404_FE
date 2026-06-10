import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/firebase/firebase_bootstrap.dart';
import 'package:fe_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  EnvConfig.validate();
  await FirebaseBootstrap.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
