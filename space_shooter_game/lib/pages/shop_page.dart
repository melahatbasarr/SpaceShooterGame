import 'package:flutter/material.dart';

import '../models/ship_stats.dart';
import '../services/shop_service.dart';
import '../widgets/shop/shop_bottom_panel.dart';
import '../widgets/shop/shop_page_dots.dart';
import '../widgets/shop/shop_ship_card.dart';
import '../widgets/shop/shop_top_info_section.dart';

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
                ? 260
                : height < 820
                    ? 300
                    : 340;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Column(
                children: [
                  ShopTopInfoSection(
                    coins: _shopService.getCoins(),
                    ship: ship,
                    statusText: _getStatusText(ship),
                    statusColor: _getStatusColor(ship),
                  ),
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

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double scale = 1.0;

                            if (_pageController.hasClients) {
                              final page =
                                  _pageController.page ??
                                  _currentIndex.toDouble();
                              final diff = (page - index).abs();
                              scale = (1 - (diff * 0.12)).clamp(0.88, 1.0);
                            }

                            return ShopShipCard(
                              ship: ship,
                              isSelected:
                                  ship.id == _shopService.getSelectedShipId(),
                              scale: scale,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ShopPageDots(
                    itemCount: ships.length,
                    currentIndex: _currentIndex,
                  ),
                  const SizedBox(height: 16),
                  ShopBottomPanel(
                    ship: ship,
                    buttonText: _getMainButtonText(ship),
                    isButtonEnabled: _isMainButtonEnabled(ship),
                    onPressed: _handleMainAction,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}