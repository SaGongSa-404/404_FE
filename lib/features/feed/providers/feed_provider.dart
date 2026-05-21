import 'package:fe_app/features/feed/viewmodels/feed_state.dart';
import 'package:fe_app/features/feed/viewmodels/feed_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedProvider = StateNotifierProvider<FeedViewModel, FeedState>(
  (_) => FeedViewModel(),
);
