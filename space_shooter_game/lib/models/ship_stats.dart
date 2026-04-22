import 'player_weapon_type.dart';

class ShipStats {
  final String id;
  final String name;
  final String description;
  final int price;
  final int requiredLevel;
  final int maxHealth;
  final double moveSpeed;
  final double fireCooldown;
  final int bulletDamage;
  final bool isStarterShip;
  final String assetName;
  final PlayerWeaponType weaponType;

  const ShipStats({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.requiredLevel,
    required this.maxHealth,
    required this.moveSpeed,
    required this.fireCooldown,
    required this.bulletDamage,
    required this.assetName,
    required this.weaponType,
    this.isStarterShip = false,
  });

  String get assetPath => 'assets/images/$assetName';

  bool canBePurchased({
    required int highestUnlockedLevel,
  }) {
    return highestUnlockedLevel >= requiredLevel;
  }
}

class ShipCatalog {
  static const ShipStats starter = ShipStats(
    id: 'starter',
    name: 'Falcon',
    description: 'Balanced starter ship. Reliable in every situation.',
    price: 0,
    requiredLevel: 1,
    maxHealth: 5,
    moveSpeed: 300,
    fireCooldown: 0.25,
    bulletDamage: 1,
    assetName: 'ship_one.png',
    weaponType: PlayerWeaponType.single,
    isStarterShip: true,
  );

  static const ShipStats rapid = ShipStats(
    id: 'rapid',
    name: 'Wisp',
    description: 'Very fast and agile ship with rapid fire but lower durability.',
    price: 300,
    requiredLevel: 4,
    maxHealth: 4,
    moveSpeed: 350,
    fireCooldown: 0.17,
    bulletDamage: 1,
    assetName: 'ship_two.png',
    weaponType: PlayerWeaponType.doubleShot,
  );

  static const ShipStats tank = ShipStats(
    id: 'tank',
    name: 'Bulwark',
    description: 'Heavy armored ship with stronger shots but slower movement.',
    price: 700,
    requiredLevel: 8,
    maxHealth: 8,
    moveSpeed: 245,
    fireCooldown: 0.33,
    bulletDamage: 2,
    assetName: 'ship_three.png',
    weaponType: PlayerWeaponType.heavy,
  );

  static const ShipStats reaper = ShipStats(
    id: 'reaper',
    name: 'Reaper',
    description: 'Slow-firing assault ship that deals massive damage per shot.',
    price: 1500,
    requiredLevel: 13,
    maxHealth: 4,
    moveSpeed: 285,
    fireCooldown: 0.42,
    bulletDamage: 3,
    assetName: 'ship_four.png',
    weaponType: PlayerWeaponType.power,
  );

  static const ShipStats tempest = ShipStats(
    id: 'tempest',
    name: 'Tempest',
    description: 'Advanced combat ship with strong sustained fire and high speed.',
    price: 3000,
    requiredLevel: 18,
    maxHealth: 5,
    moveSpeed: 330,
    fireCooldown: 0.21,
    bulletDamage: 2,
    assetName: 'ship_five.png',
    weaponType: PlayerWeaponType.spread,
  );

  static const List<ShipStats> all = [
    starter,
    rapid,
    tank,
    reaper,
    tempest,
  ];

  static const String defaultShipId = 'starter';

  static List<String> get defaultOwnedShipIds => [
        defaultShipId,
      ];

  static ShipStats getById(String id) {
    return all.firstWhere(
      (ship) => ship.id == id,
      orElse: () => starter,
    );
  }
}