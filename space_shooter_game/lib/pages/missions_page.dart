import 'package:flutter/material.dart';

import '../services/mission_service.dart';
import '../services/progress_service.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  late List<MissionWithProgress> missions;
  late int coins;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    missions = MissionService.instance.getAllMissionsWithProgress();
    coins = ProgressService.instance.getCoins();
  }

  Future<void> _claimReward(String missionId) async {
    final result = await MissionService.instance.claimReward(missionId);

    if (!mounted) return;

    switch (result) {
      case MissionClaimResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward claimed'),
          ),
        );
        break;

      case MissionClaimResult.alreadyClaimed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward already claimed'),
          ),
        );
        break;

      case MissionClaimResult.notCompleted:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mission is not completed yet'),
          ),
        );
        break;

      case MissionClaimResult.missionNotFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mission not found'),
          ),
        );
        break;
    }

    setState(() {
      _reloadData();
    });
  }

  String _buildStatusText(MissionWithProgress item) {
    if (item.progress.isClaimed) {
      return 'Claimed';
    }

    if (item.progress.isCompleted) {
      return 'Completed';
    }

    return 'In Progress';
  }

  Color _buildStatusColor(MissionWithProgress item) {
    if (item.progress.isClaimed) {
      return Colors.blueAccent;
    }

    if (item.progress.isCompleted) {
      return Colors.greenAccent;
    }

    return Colors.orangeAccent;
  }

  Widget _buildMissionCard(MissionWithProgress item) {
    final mission = item.mission;
    final progress = item.progress;

    final bool canClaim = progress.isCompleted && !progress.isClaimed;
    final bool alreadyClaimed = progress.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151A2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mission.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _buildStatusColor(item).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _buildStatusColor(item).withOpacity(0.35),
                  ),
                ),
                child: Text(
                  _buildStatusText(item),
                  style: TextStyle(
                    color: _buildStatusColor(item),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mission.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: item.progressRatio,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${progress.currentValue} / ${mission.targetValue}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mission.rewardCoins}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim ? () => _claimReward(mission.id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim
                    ? const Color(0xFF5C7CFA)
                    : const Color(0xFF353D52),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                alreadyClaimed ? 'Claimed' : (canClaim ? 'Claim Reward' : 'Locked'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B1A),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Missions'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF151A2D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Your Coins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: missions.isEmpty
                    ? const Center(
                        child: Text(
                          'No missions found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: missions.length,
                        itemBuilder: (context, index) {
                          final item = missions[index];
                          return _buildMissionCard(item);
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