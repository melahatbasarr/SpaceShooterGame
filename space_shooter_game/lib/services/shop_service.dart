import '../models/ship_stats.dart';
import 'progress_service.dart';

enum ShipPurchaseResult {
  success,
  alreadyOwned,
  levelLocked,
  notEnoughCoins,
  shipNotFound,
}

class ShopService {
  ShopService._();

  static final ShopService instance = ShopService._();

  final ProgressService _progressService = ProgressService.instance;

  List<ShipStats> getAllShips() {
    return ShipCatalog.all;
  }

  ShipStats getShipById(String shipId) {
    return ShipCatalog.getById(shipId);
  }

  int getCoins() {
    return _progressService.getCoins();
  }

  int getHighestUnlockedLevel() {
    return _progressService.getHighestUnlockedLevel();
  }

  List<String> getOwnedShipIds() {
    return _progressService.getOwnedShipIds();
  }

  String getSelectedShipId() {
    return _progressService.getSelectedShipId();
  }

  ShipStats getSelectedShip() {
    return _progressService.getSelectedShipStats();
  }

  bool isShipOwned(String shipId) {
    return _progressService.isShipOwned(shipId);
  }

  bool canPurchaseShip(String shipId) {
    final ship = ShipCatalog.getById(shipId);
    final highestUnlockedLevel = _progressService.getHighestUnlockedLevel();
    final coins = _progressService.getCoins();

    if (isShipOwned(shipId)) {
      return false;
    }

    if (!ship.canBePurchased(
      highestUnlockedLevel: highestUnlockedLevel,
    )) {
      return false;
    }

    if (coins < ship.price) {
      return false;
    }

    return true;
  }

  Future<ShipPurchaseResult> purchaseShip(String shipId) async {
    final exists = ShipCatalog.all.any((ship) => ship.id == shipId);

    if (!exists) {
      return ShipPurchaseResult.shipNotFound;
    }

    if (isShipOwned(shipId)) {
      return ShipPurchaseResult.alreadyOwned;
    }

    final ship = ShipCatalog.getById(shipId);
    final highestUnlockedLevel = _progressService.getHighestUnlockedLevel();

    if (!ship.canBePurchased(
      highestUnlockedLevel: highestUnlockedLevel,
    )) {
      return ShipPurchaseResult.levelLocked;
    }

    final didSpendCoins = await _progressService.spendCoins(ship.price);

    if (!didSpendCoins) {
      return ShipPurchaseResult.notEnoughCoins;
    }

    await _progressService.unlockShip(ship.id);

    return ShipPurchaseResult.success;
  }

  Future<bool> selectShip(String shipId) async {
    if (!isShipOwned(shipId)) {
      return false;
    }

    return _progressService.selectShip(shipId);
  }
}