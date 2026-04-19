import 'package:flutter/material.dart';

import '../models/ship_stats.dart';
import '../services/shop_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ShopService _shopService = ShopService.instance;

  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    final ships = _shopService.getAllShips();
    final selectedShipId = _shopService.getSelectedShipId();

    final initialIndex = ships.indexWhere((ship) => ship.id == selectedShipId);

    _currentIndex = initialIndex >= 0 ? initialIndex : 0;

    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ShipStats get _currentShip => _shopService.getAllShips()[_currentIndex];

  Future<void> _handleMainAction() async {
    final ship = _currentShip;
    final selectedShipId = _shopService.getSelectedShipId();
    final isOwned = _shopService.isShipOwned(ship.id);
    final highestUnlockedLevel = _shopService.getHighestUnlockedLevel();

    if (selectedShipId == ship.id) {
      return;
    }

    if (isOwned) {
      final didSelect = await _shopService.selectShip(ship.id);

      if (!mounted) return;

      if (didSelect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ship.name} selected'),
          ),
        );
        setState(() {});
      }

      return;
    }

    if (highestUnlockedLevel < ship.requiredLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reach level ${ship.requiredLevel} to unlock this ship',
          ),
        ),
      );
      return;
    }

    final result = await _shopService.purchaseShip(ship.id);

    if (!mounted) return;

    switch (result) {
      case ShipPurchaseResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ship.name} purchased'),
          ),
        );
        setState(() {});
        break;

      case ShipPurchaseResult.alreadyOwned:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ship is already owned'),
          ),
        );
        break;

      case ShipPurchaseResult.levelLocked:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reach level ${ship.requiredLevel} to unlock this ship',
            ),
          ),
        );
        break;

      case ShipPurchaseResult.notEnoughCoins:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough coins'),
          ),
        );
        break;

      case ShipPurchaseResult.shipNotFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ship not found'),
          ),
        );
        break;
    }
  }

  String _getStatusText(ShipStats ship) {
    final selectedShipId = _shopService.getSelectedShipId();
    final isOwned = _shopService.isShipOwned(ship.id);
    final highestUnlockedLevel = _shopService.getHighestUnlockedLevel();

    if (selectedShipId == ship.id) {
      return 'Selected';
    }

    if (isOwned) {
      return 'Owned';
    }

    if (highestUnlockedLevel < ship.requiredLevel) {
      return 'Locked';
    }

    return 'Available';
  }

  Color _getStatusColor(ShipStats ship) {
    final selectedShipId = _shopService.getSelectedShipId();
    final isOwned = _shopService.isShipOwned(ship.id);
    final highestUnlockedLevel = _shopService.getHighestUnlockedLevel();

    if (selectedShipId == ship.id) {
      return Colors.greenAccent;
    }

    if (isOwned) {
      return Colors.lightBlueAccent;
    }

    if (highestUnlockedLevel < ship.requiredLevel) {
      return Colors.orangeAccent;
    }

    return Colors.white70;
  }

  String _getMainButtonText(ShipStats ship) {
    final selectedShipId = _shopService.getSelectedShipId();
    final isOwned = _shopService.isShipOwned(ship.id);
    final highestUnlockedLevel = _shopService.getHighestUnlockedLevel();

    if (selectedShipId == ship.id) {
      return 'Selected';
    }

    if (isOwned) {
      return 'Select';
    }

    if (highestUnlockedLevel < ship.requiredLevel) {
      return 'Locked at Level ${ship.requiredLevel}';
    }

    return 'Buy';
  }

  bool _isMainButtonEnabled(ShipStats ship) {
    final selectedShipId = _shopService.getSelectedShipId();
    final highestUnlockedLevel = _shopService.getHighestUnlockedLevel();

    if (selectedShipId == ship.id) {
      return false;
    }

    if (highestUnlockedLevel < ship.requiredLevel) {
      return false;
    }

    return true;
  }

  Widget _buildStatBox({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfo(ShipStats ship) {
    final statusText = _getStatusText(ship);
    final statusColor = _getStatusColor(ship);
    final coins = _shopService.getCoins();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13192A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Hangar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E263A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  ship.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ship.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: 'Health',
                  value: '${ship.maxHealth}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatBox(
                  label: 'Speed',
                  value: '${ship.moveSpeed.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: 'Fire Rate',
                  value: ship.fireCooldown.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatBox(
                  label: 'Damage',
                  value: '${ship.bulletDamage}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipCard(ShipStats ship, int index) {
    final selectedShipId = _shopService.getSelectedShipId();
    final isSelected = ship.id == selectedShipId;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;

        if (_pageController.hasClients) {
          final page = _pageController.page ?? _currentIndex.toDouble();
          final diff = (page - index).abs();
          scale = (1 - (diff * 0.12)).clamp(0.88, 1.0);
        }

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    const Color(0xFF3A7BFF),
                    const Color(0xFF1A49B8),
                  ]
                : [
                    const Color(0xFF1B2236),
                    const Color(0xFF121827),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? Colors.white38 : Colors.white10,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch,
                color: isSelected ? Colors.white : Colors.cyanAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                ship.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ship.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel(ShipStats ship) {
    final buttonText = _getMainButtonText(ship);
    final buttonEnabled = _isMainButtonEnabled(ship);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13192A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2236),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ship.price} Coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2236),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Required Level',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ship.requiredLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: buttonEnabled ? _handleMainAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C7CFA),
                disabledBackgroundColor: const Color(0xFF353D52),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageDots() {
    final ships = _shopService.getAllShips();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(ships.length, (index) {
        final isActive = index == _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ship = _currentShip;
    final ships = _shopService.getAllShips();

    return Scaffold(
      backgroundColor: const Color(0xFF090B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B1A),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Ship Shop'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double height = constraints.maxHeight;

            final double carouselHeight = height < 700
                ? 240
                : height < 820
                    ? 280
                    : 320;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Column(
                children: [
                  _buildTopInfo(ship),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: carouselHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: ships.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final ship = ships[index];
                        return _buildShipCard(ship, index);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPageDots(),
                  const SizedBox(height: 16),
                  _buildBottomPanel(ship),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}