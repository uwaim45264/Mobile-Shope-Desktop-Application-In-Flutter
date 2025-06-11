class Mobile {
  final String model;
  final double price;
  final String barcode;
  final String imei1;
  final String imei2;
  final String ram;
  final String storage;
  final String cpu;
  final String color;
  final String chipset;
  final String gpu;
  final String camera;
  final String screenSize;
  final String battery;
  int stockQuantity;

  Mobile({
    required this.model,
    required this.price,
    required this.barcode,
    required this.imei1,
    required this.imei2,
    required this.ram,
    required this.storage,
    required this.cpu,
    required this.color,
    required this.chipset,
    required this.gpu,
    required this.camera,
    required this.screenSize,
    required this.battery,
    required this.stockQuantity,
  });

  Map<String, dynamic> toJson() => {
    'model': model,
    'price': price,
    'barcode': barcode,
    'imei1': imei1,
    'imei2': imei2,
    'ram': ram,
    'storage': storage,
    'cpu': cpu,
    'color': color,
    'chipset': chipset,
    'gpu': gpu,
    'camera': camera,
    'screenSize': screenSize,
    'battery': battery,
    'stockQuantity': stockQuantity,
  };

  factory Mobile.fromJson(Map<String, dynamic> json) => Mobile(
    model: json['model'],
    price: json['price'],
    barcode: json['barcode'],
    imei1: json['imei1'],
    imei2: json['imei2'],
    ram: json['ram'],
    storage: json['storage'],
    cpu: json['cpu'],
    color: json['color'],
    chipset: json['chipset'],
    gpu: json['gpu'],
    camera: json['camera'],
    screenSize: json['screenSize'],
    battery: json['battery'],
    stockQuantity: json['stockQuantity'] ?? 0,
  );
}