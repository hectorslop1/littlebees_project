import 'package:flutter/material.dart';
import '../../../../design_system/widgets/lb_loading_state.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const LBLoadingState(layout: LBLoadingLayout.home);
  }
}
