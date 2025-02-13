import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/repositories/report_repository.dart';
import '../api/api_client.dart';

final reportSummaryProvider = StateNotifierProvider.family<
    ReportSummaryNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportSummaryNotifier(ReportRepository(ApiClient()), params);
});

final reportStatisticsByUtmSourceProvider = StateNotifierProvider.family<
    ReportStatisticsByUtmSourceNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportStatisticsByUtmSourceNotifier(
      ReportRepository(ApiClient()), params);
});

final reportStatisticsByDataSourceProvider = StateNotifierProvider.family<
    ReportStatisticsByDataSourceNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportStatisticsByDataSourceNotifier(
      ReportRepository(ApiClient()), params);
});

final reportStatisticsByTagProvider = StateNotifierProvider.family<
    ReportStatisticsByTagNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportStatisticsByTagNotifier(ReportRepository(ApiClient()), params);
});

final reportChartByOverTimeProvider = StateNotifierProvider.family<
    ReportChartByOverTimeNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportOverTimeParams>((ref, params) {
  return ReportChartByOverTimeNotifier(ReportRepository(ApiClient()), params);
});

final reportChartByRatingProvider = StateNotifierProvider.family<
    ReportChartByRatingNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportChartByRatingNotifier(ReportRepository(ApiClient()), params);
});

final reportStatisticsByUserProvider = StateNotifierProvider.family<
    ReportStatisticsByUserNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportParams>((ref, params) {
  return ReportStatisticsByUserNotifier(ReportRepository(ApiClient()), params);
});

final reportStatisticsByStageGroupProvider = StateNotifierProvider.family<
    ReportStatisticsByStageGroupNotifier,
    AsyncValue<Map<String, dynamic>>,
    ReportStageGroupParams>((ref, params) {
  return ReportStatisticsByStageGroupNotifier(
      ReportRepository(ApiClient()), params);
});

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
}

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

class ReportSummaryNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportSummaryNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchSummaryData();
  }

  Future<void> fetchSummaryData() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getSummaryData(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportStatisticsByUtmSourceNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportStatisticsByUtmSourceNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchStatisticsByUtmSource();
  }

  Future<void> fetchStatisticsByUtmSource() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getStatisticsByUtmSource(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportStatisticsByDataSourceNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportStatisticsByDataSourceNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchStatisticsByDataSource();
  }

  Future<void> fetchStatisticsByDataSource() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getStatisticsByDataSource(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportStatisticsByTagNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportStatisticsByTagNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchStatisticsByTag();
  }

  Future<void> fetchStatisticsByTag() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getStatisticsByTag(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportChartByOverTimeNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportOverTimeParams _params;

  ReportChartByOverTimeNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchChartByOverTime();
  }

  Future<void> fetchChartByOverTime() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getChartByOverTime(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
        _params.type,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportChartByRatingNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportChartByRatingNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchChartByRating();
  }

  Future<void> fetchChartByRating() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getChartByRating(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportStatisticsByUserNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportParams _params;

  ReportStatisticsByUserNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchStatisticsByUser();
  }

  Future<void> fetchStatisticsByUser() async {
    try {
      state = const AsyncValue.loading();
      final response = await _reportRepository.getStatisticsByUser(
        _params.organizationId,
        _params.workspaceId,
        _params.startDate,
        _params.endDate,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ReportStatisticsByStageGroupNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportRepository _reportRepository;
  final ReportStageGroupParams _params;

  ReportStatisticsByStageGroupNotifier(this._reportRepository, this._params)
      : super(const AsyncValue.loading()) {
    fetchStatisticsByStageGroup();
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
