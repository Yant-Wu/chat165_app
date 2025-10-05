import 'package:equatable/equatable.dart';

class ScamType extends Equatable {
  final String type;
  final int count;

  const ScamType({required this.type, required this.count});

  factory ScamType.fromJson(Map<String, dynamic> json) {
    final typeValue = json['type'];
    final countValue = json['count'];

    if (typeValue is! String) {
      throw const FormatException('Invalid scam type value');
    }
    if (countValue is! num) {
      throw const FormatException('Invalid scam type count');
    }

    return ScamType(
      type: typeValue,
      count: countValue.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'count': count,
      };

  @override
  List<Object?> get props => [type, count];
}

class ScamTypesResponse extends Equatable {
  final List<ScamType> scamTypes;
  final DateTime updatedAt;

  const ScamTypesResponse({required this.scamTypes, required this.updatedAt});

  factory ScamTypesResponse.fromJson(Map<String, dynamic> json) {
    final typesRaw = json['scam_types'];
    final updatedAtRaw = json['updated_at'];

    if (typesRaw is! List) {
      throw const FormatException('Invalid scam types payload');
    }
    if (updatedAtRaw is! String) {
      throw const FormatException('Invalid updated_at payload');
    }

    final types = typesRaw.map((item) {
      if (item is Map<String, dynamic>) {
        return ScamType.fromJson(item);
      }
      if (item is Map) {
        return ScamType.fromJson(item.cast<String, dynamic>());
      }
      throw const FormatException('Invalid scam type entry');
    }).toList(growable: false);

    final updatedAt = DateTime.parse(updatedAtRaw).toLocal();

    return ScamTypesResponse(scamTypes: types, updatedAt: updatedAt);
  }

  @override
  List<Object?> get props => [scamTypes, updatedAt];
}
