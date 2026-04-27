import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/wishlist/views/components/consider_product_header.dart';
import 'package:fe_app/features/wishlist/views/components/consider_budget_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider_checklist.dart';
import 'package:fe_app/features/wishlist/views/components/consider_result_card.dart';
import 'package:fe_app/features/wishlist/views/components/consider_scroll_indicator.dart';

class WishlistConsiderScreen extends StatefulWidget {
  const WishlistConsiderScreen({super.key});

  @override
  State<WishlistConsiderScreen> createState() => _WishlistConsiderScreenState();
}

class _WishlistConsiderScreenState extends State<WishlistConsiderScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        title: const Text('살까 말까', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        children: [
          // P1
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const ConsiderProductHeader(),
                      const Divider(thickness: 2, color: Color(0xFFE0E0E0)),
                      const Padding(padding: EdgeInsets.all(16.0), child: ConsiderBudgetCard()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  child: const ConsiderScrollIndicator(),
                ),
              ),
            ],
          ),
          // P2
          ConsiderChecklist(pageController: _pageController),
          // P3
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                const ConsiderResultCard(),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF616161), width: 2.5), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('참을게요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(color: const Color(0xFFCBE9FF), border: Border.all(color: const Color(0xFF3BA2EA), width: 2.5), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('살게요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3BA2EA)))),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}