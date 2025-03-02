import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/repositories/report_repository.dart';
import '../api/api_client.dart';

// Provider để kiểm soát việc load dữ liệu
final shouldLoadReportsProvider = StateProvider<bool>((ref) => false);

// Cache key để quản lý việc invalidate cache
final _cacheKeyProvider = StateProvider<int>((ref) => 0);

// Provider để lưu trữ params hiện tại
final reportParamsProvider = StateProvider<ReportParams?>((ref) => null);

class ReportParams {
  final String organizationId;
  final String workspaceId;
  final String startDate;
  final String endDate;

  ReportParams({
    required this.organizationId,
    required this.workspaceId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, String> toQueryParameters() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class ReportOverTimeParams extends ReportParams {
  final String type;

  ReportOverTimeParams({
    required super.organizationId,
    required super.workspaceId,
    required super.startDate,
    required super.endDate,
    required this.type,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'Type': type,
    };
  }
}

final reportSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    print('reportSummaryProvider - shouldLoad: $shouldLoad');
    if (!shouldLoad) {
      print(
          'reportSummaryProvider - Skipping API call because shouldLoad is false');
      return {'content': [], 'metadata': {}};
    }

    try {
      print('reportSummaryProvider - Starting API call');
      print(
          'reportSummaryProvider - Params: organizationId: ${params.organizationId}, workspaceId: ${params.workspaceId}');
      final repository = ReportRepository(ApiClient());
      final response = await repository.getSummaryData(
        params.organizationId,
        params.workspaceId,
        params.startDate,
        params.endDate,
      );
      print('reportSummaryProvider - API call successful');
      return response;
    } catch (e, stack) {
      print('reportSummaryProvider - API error: $e');
      print('reportSummaryProvider - Stack trace: $stack');
      rethrow;
    }
  },
);

final reportStatisticsByUtmSourceProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    print('reportStatisticsByUtmSourceProvider - shouldLoad: $shouldLoad');
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    try {
      print('reportStatisticsByUtmSourceProvider - Starting API call');
      final repository = ReportRepository(ApiClient());
      final response = await repository.getStatisticsByUtmSource(
        params.organizationId,
        params.workspaceId,
        params.startDate,
        params.endDate,
      );
      print('reportStatisticsByUtmSourceProvider - API call successful');
      return response;
    } catch (e, stack) {
      print('reportStatisticsByUtmSourceProvider - API error: $e');
      print('reportStatisticsByUtmSourceProvider - Stack trace: $stack');
      rethrow;
    }
  },
);

final reportStatisticsByDataSourceProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    final repository = ReportRepository(ApiClient());
    final response = await repository.getStatisticsByDataSource(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );
    return response;
  },
);

final reportStatisticsByTagProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    final repository = ReportRepository(ApiClient());
    final response = await repository.getStatisticsByTag(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );
    return response;
  },
);

final reportChartByOverTimeProvider =
    FutureProvider.family<Map<String, dynamic>, ReportOverTimeParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    final repository = ReportRepository(ApiClient());
    final response = await repository.getChartByOverTime(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
      params.type,
    );
    return response;
  },
);

final reportChartByRatingProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    final repository = ReportRepository(ApiClient());
    final response = await repository.getChartByRating(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );
    return response;
  },
);

final reportStatisticsByUserProvider =
    FutureProvider.family<Map<String, dynamic>, ReportParams>(
  (ref, params) async {
    final shouldLoad = ref.read(shouldLoadReportsProvider);
    if (!shouldLoad) {
      return {'content': [], 'metadata': {}};
    }

    final repository = ReportRepository(ApiClient());
    final response = await repository.getStatisticsByUser(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );
    return response;
  },
);

final reportStatisticsByStageGroupProvider = StateNotifierProvider.family<
    ReportStatisticsByStageGroupNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportStageGroupParams>((ref, params) {
  return ReportStatisticsByStageGroupNotifier(
      ReportRepository(ApiClient()), params, ref);
});

class ReportStageGroupParams {
  final String organizationId;
  final String workspaceId;
  final Map<String, String>? queryParameters;

  ReportStageGroupParams({
    required this.organizationId,
    required this.workspaceId,
    this.queryParameters,
  });
}

class ReportStatisticsByStageGroupNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportStageGroupParams _params;
  final Ref _ref;

  ReportStatisticsByStageGroupNotifier(
    this._reportRepository,
    this._params,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _ref.listen(shouldLoadReportsProvider, (previous, next) {
      if (next) {
        fetchStatisticsByStageGroup();
      }
    });
  }

  Future<void> fetchStatisticsByStageGroup() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getStatisticsByStageGroup(
        _params.organizationId,
        _params.workspaceId,
        queryParameters: _params.queryParameters,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider chính để lấy dữ liệu báo cáo
final reportDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final params = ref.watch(reportParamsProvider);

  if (params == null) {
    return {
      'summary': {'content': [], 'metadata': {}},
      'utmSource': {'content': [], 'metadata': {}},
      'dataSource': {'content': [], 'metadata': {}},
      'tag': {'content': [], 'metadata': {}},
      'rating': {'content': [], 'metadata': {}},
      'user': {'content': [], 'metadata': {}},
    };
  }

  try {
    print('reportDataProvider - Starting API calls with params:');
    print('organizationId: ${params.organizationId}');
    print('workspaceId: ${params.workspaceId}');
    print('startDate: ${params.startDate}');
    print('endDate: ${params.endDate}');

    final repository = ReportRepository(ApiClient());

    // Cache các future để tránh gọi API nhiều lần
    final summaryFuture = repository.getSummaryData(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    final utmSourceFuture = repository.getStatisticsByUtmSource(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    final dataSourceFuture = repository.getStatisticsByDataSource(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    final tagFuture = repository.getStatisticsByTag(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    final ratingFuture = repository.getChartByRating(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    final userFuture = repository.getStatisticsByUser(
      params.organizationId,
      params.workspaceId,
      params.startDate,
      params.endDate,
    );

    // Thực hiện tất cả các API calls song song
    final results = await Future.wait([
      summaryFuture,
      utmSourceFuture,
      dataSourceFuture,
      tagFuture,
      ratingFuture,
      userFuture,
    ]);

    print('reportDataProvider - All API calls completed successfully');

    return {
      'summary': results[0],
      'utmSource': results[1],
      'dataSource': results[2],
      'tag': results[3],
      'rating': results[4],
      'user': results[5],
    };
  } catch (e, stack) {
    print('reportDataProvider - Error occurred: $e');
    print('reportDataProvider - Stack trace: $stack');
    rethrow;
  }
});
