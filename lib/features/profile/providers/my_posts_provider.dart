import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';
import 'package:fe_app/features/profile/viewmodels/my_posts_state.dart';
import 'package:fe_app/features/profile/viewmodels/my_posts_viewmodel.dart';

final myPostsProvider = StateNotifierProvider<MyPostsViewModel, MyPostsState>(
  (ref) => MyPostsViewModel(
    ref.watch(profileServiceProvider),
    ref.watch(feedServiceProvider),
  ),
);
