class ValidationError {
  final List<ErrorItem> errors;

  ValidationError({required this.errors});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ErrorItem.fromJson(e))
          .toList(),
    );
  }
}

extension ValidationErrorX on ValidationError? {

  String get allFieldMessages {
    final errs = this?.errors;
    if (errs == null || errs.isEmpty) return '';
    return errs.map((e) => e.detail).join('\n');
  }
}

class ErrorItem {
  final String code;
  final String detail;
  final String attr;

  ErrorItem({required this.code, required this.detail, required this.attr});

  factory ErrorItem.fromJson(Map<String, dynamic> json) {
    return ErrorItem(
      code: json['code'] ?? '',
      detail: json['detail'] ?? '',
      attr: json['attr'] ?? '',
    );
  }
}
