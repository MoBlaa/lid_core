import 'dart:convert';

const GenIdType = "GenId";
const GenOwnerType = "GenOwner";

abstract class WorkerEvent {
  final String type;

  WorkerEvent({this.type});

  static WorkerEvent resolve(String input) {
    final parsed = jsonDecode(input);
    switch (parsed['type']) {
      case GenIdType:
        return GenIdEvent.fromJson(parsed);
      case GenOwnerType:
        return GenOwnerEvent.fromJson(parsed);
      default:
        throw 'Failed to parse WorkerEvent: $input';
    }
  }

  Map<String, dynamic> toJson() => {'type': type};
}

class GenIdEvent extends WorkerEvent {
  final int strlen;

  GenIdEvent({this.strlen}) : super(type: GenIdType);

  GenIdEvent.fromJson(Map<String, dynamic> json): this(strlen: json['strlen']);

  @override
  Map<String, dynamic> toJson() => {
        'strlen': strlen,
        'type': type,
  };
}

class GenOwnerEvent extends WorkerEvent {
  final String id;
  final String name;

  GenOwnerEvent({this.id, this.name}) : super(type: GenOwnerType);

  GenOwnerEvent.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        super(type: GenOwnerType);

  @override
  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'type': type};
}
