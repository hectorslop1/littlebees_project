class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({required this.data, required this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }
}

class ApiErrorResponse {
  final int statusCode;
  final String message;
  final String? error;
  final Map<String, List<String>>? details;

  const ApiErrorResponse({
    required this.statusCode,
    required this.message,
    this.error,
    this.details,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      error: json['error'] as String?,
      details: json['details'] != null
          ? (json['details'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            )
          : null,
    );
  }
}

class SuccessResponse {
  final bool success;
  final String message;

  const SuccessResponse({required this.success, required this.message});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}
