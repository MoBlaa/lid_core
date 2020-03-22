import 'package:core/infrastructure/owner.dart';
import 'package:flutter/services.dart';

abstract class CorePlugin {
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'generateId':
        return await this.generateId(call.arguments['length']);
      case 'generateOwner':
        return await this
            .generateOwner(call.arguments['id'], call.arguments['name']);
      default:
        throw UnimplementedError(
            "Method '${call.method}' not supported for CorePlugin");
    }
  }

  Future<String> generateId(int length) async {
    throw UnimplementedError(
        "Method 'generateId' not implemented for this platform");
  }

  Future<String> generateOwner(String id, String name) async {
    throw UnimplementedError(
        "'Method 'generateOwner' not implemented for this platform");
  }
}

const MethodChannel _channel = MethodChannel('plugins.flutter.io/core');

Future<String> generateId(int length) async {
  assert(length > 0);
  final result =
      await _channel.invokeMethod<String>('generateId', {'length': length});
  return result;
}

Future<Owner> generateOwner(String id, String name) async {
  assert(name != null && id != null);
  final result = await _channel
      .invokeMethod<String>('generateOwner', {'id': id, 'name': name});
  return Owner.fromString(result);
}
