import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/features/wishlist/views/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistItemEntryScreen extends ConsumerStatefulWidget {
  const WishlistItemEntryScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<WishlistItemEntryScreen> createState() => _WishlistItemEntryScreenState();
}

class _WishlistItemEntryScreenState extends ConsumerState<WishlistItemEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.itemId.isEmpty) return;
      ref.read(wishlistViewModelProvider.notifier).openEditPanel(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const WishlistScreen();
  }
}

