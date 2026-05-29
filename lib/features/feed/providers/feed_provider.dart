import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/feed/viewmodels/feed_state.dart';
import 'package:fe_app/features/feed/viewmodels/feed_viewmodel.dart';

final feedProvider = StateNotifierProvider<FeedViewModel, FeedState>(
  (ref) => FeedViewModel(ref.watch(feedServiceProvider)),
);
