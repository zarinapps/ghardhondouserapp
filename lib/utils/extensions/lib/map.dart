extension MapExt on Map<dynamic, dynamic> {
  void removeEmptyKeys() {
    removeWhere(
      (key, value) =>
          value.isEmpty as bool? ?? false || value == '' || value == null,
    );
  }

  dynamic get(key) {
    return this[key];
  }
}

extension ListExt on List<Map<dynamic, dynamic>> {
  Map<dynamic, dynamic> findByKey(key, {equals}) {
    return where((element) {
      return element[key] == equals;
    }).first;
  }
}
