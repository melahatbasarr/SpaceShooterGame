import 'package:flutter/material.dart';

import '../models/player_progress.dart';
import '../models/ship_stats.dart';
import '../services/mission_service.dart';
import '../services/progress_service.dart';
import 'game_page.dart';
import 'missions_page.dart';
import 'shop_page.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  static const int totalLevels = 20;

  PlayerProgress progress = const PlayerProgress();
  bool isLoading = true;
  int claimableMissionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final loadedProgress = ProgressService.instance.loadProgress();
    final missionClaimCount = MissionService.instance.getClaimableMissionCount();

    if (!mounted) return;

    setState(() {
      progress = loadedProgress;
      claimableMissionCount = missionClaimCount;
      isLoading = false;
    });
  }

  Future<void> _openLevel(int level) async {
    if (!progress.isLevelUnlocked(level)) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePage(level: level),
      ),
    );

    await _loadProgress();
  }

  Future<void> _openShop() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ShopPage(),
      ),
    );

    await _loadProgress();
  }

  Future<void> _openMissions() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MissionsPage(),
      ),
    );

    await _loadProgress();
  }

  Widget _buildStars(int starCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool filled = index < starCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amber : Colors.white38,
            size: 18,
          ),
        );
      }),
    );
  }

  Widget _buildLevelCard(int level) {
    final bool isUnlocked = progress.isLevelUnlocked(level);
    final levelProgress = progress.getLevelProgress(level);
    final int stars = levelProgress.stars;

    return GestureDetector(
      onTap: isUnlocked ? () => _openLevel(level) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isUnlocked
              ? const Color(0xFF1B2238)
              : const Color(0xFF111522),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked ? Colors.white24 : Colors.white10,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUnlocked ? Icons.rocket_launch : Icons.lock,
                color: isUnlocked ? Colors.cyanAccent : Colors.white30,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                'Level $level',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white38,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _buildStars(stars),
              const SizedBox(height: 8),
              Text(
                isUnlocked ? 'Tap to play' : 'Locked',
                style: TextStyle(
                  color: isUnlocked ? Colors.white60 : Colors.white24,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final selectedShip = ShipCatalog.getById(progress.selectedShipId);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Space Shooter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked Level: ${progress.highestUnlockedLevel}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF222943),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${progress.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF222943),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.rocket,
                  color: Colors.cyanAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Ship',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedShip.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.assignment_rounded,
                label: 'Missions',
                onTap: _openMissions,
                backgroundColor: const Color(0xFF00A8A8),
                badgeCount: claimableMissionCount,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.storefront,
                label: 'Shop',
                onTap: _openShop,
                backgroundColor: const Color(0xFF5C7CFA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B1A),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Clear levels, earn stars, unlock the next challenge.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.builder(
                        itemCount: totalLevels,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.12,
                        ),
                        itemBuilder: (context, index) {
                          final level = index + 1;
                          return _buildLevelCard(level);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}