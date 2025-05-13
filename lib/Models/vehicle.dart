class Vehicle {
  String? name;
  String? maker;
  String? model;

  Vehicle({this.name, this.maker, this.model});

  // Factory method to create a Vehicle from a JSON map
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'],
      maker: json['maker'],
      model: json['model'],
    );
  }

  // Method to convert a Vehicle instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maker': maker,
      'model': model,
    };
  }
}
