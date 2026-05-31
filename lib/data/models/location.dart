// location.dart
class Division {
  final int id;
  final String name;
  final String bnName;

  Division({required this.id, required this.name, required this.bnName});

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(id: json['id'], name: json['name'], bnName: json['bnName']);
  }
}

class District {
  final int id;
  final String name;
  final String bnName;

  District({required this.id, required this.name, required this.bnName});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'], name: json['name'], bnName: json['bnName']);
  }
}

class Upazilla {
  final int id;
  final String name;
  final String bnName;

  Upazilla({required this.id, required this.name, required this.bnName});

  factory Upazilla.fromJson(Map<String, dynamic> json) {
    return Upazilla(id: json['id'], name: json['name'], bnName: json['bnName']);
  }
}

class Union {
  final int id;
  final String name;
  final String bnName;

  Union({required this.id, required this.name, required this.bnName});

  factory Union.fromJson(Map<String, dynamic> json) {
    return Union(id: json['id'], name: json['name'], bnName: json['bnName']);
  }
}

class PumpStation {
  final int id;
  final String name;
  final String bnName;

  PumpStation({required this.id, required this.name, required this.bnName});

  factory PumpStation.fromJson(Map<String, dynamic> json) {
    return PumpStation(
      id: json['id'],
      name: json['name'],
      bnName:
          json['bnName'] ??
          json['name'], // fallback to name if bnName not available
    );
  }
}

// office.dart
class Office {
  final int id;
  final String name;

  const Office({required this.id, required this.name});

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class LocationSelection {
  final Division? division;
  final District? district;
  final Upazilla? upazilla;
  final Union? union;
  final PumpStation? pumpStation;

  LocationSelection({
    this.division,
    this.district,
    this.upazilla,
    this.union,
    this.pumpStation,
  });

  bool get isComplete => union != null;

  bool get hasDivision => division != null;

  bool get hasDistrict => district != null;

  bool get hasUpazilla => upazilla != null;

  bool get hasUnion => union != null;

  bool get hasPumpStation => pumpStation != null;

  // Check if all visible fields are filled
  bool isCompleteFor({
    bool needsDivision = true,
    bool needsDistrict = true,
    bool needsUpazilla = true,
    bool needsUnion = true,
    bool needsPumpStation = false,
  }) {
    if (needsDivision && division == null) return false;
    if (needsDistrict && district == null) return false;
    if (needsUpazilla && upazilla == null) return false;
    if (needsUnion && union == null) return false;
    if (needsPumpStation && pumpStation == null) return false;
    return true;
  }
}
