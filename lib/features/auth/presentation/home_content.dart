import 'package:flutter/material.dart';
import 'package:turfr_app/features/auth/presentation/kickbits_card.dart';

import 'friendlist_preview.dart';
import 'kickoff_matchlist.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        KickBitsCard(balance: 12),
        SizedBox(height: 24),
        FriendListPreview(),
        KickOffMatchList(),
      ],
    );
  }
}