import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/repositories/customer_repository.dart';
import '../api/api_client.dart';

final customerListProvider = StateNotifierProvider<CustomerListNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CustomerListNotifier(CustomerRepository(ApiClient()));
});

class CustomerListNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final CustomerRepository _repository;
  String? _lastOrganizationId;
  String? _lastWorkspaceId;
  Map<String, String>? _lastQueryParams;

  CustomerListNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadCustomers(String organizationId, String workspaceId,
      Map<String, String> queryParams) async {
    if (_lastOrganizationId == organizationId &&
        _lastWorkspaceId == workspaceId &&
        _mapEquals(_lastQueryParams, queryParams)) {
      return;
    }

    try {
      if (state.value == null) {
        state = const AsyncValue.loading();
      }

      final response = await _repository.getCustomers(
          organizationId, workspaceId,
          queryParameters: queryParams);
      final items = response['content'] as List;

      _lastOrganizationId = organizationId;
      _lastWorkspaceId = workspaceId;
      _lastQueryParams = Map<String, String>.from(queryParams);

      state = AsyncValue.data(items.cast<Map<String, dynamic>>());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool _mapEquals(Map<String, String>? map1, Map<String, String>? map2) {
    if (map1 == null || map2 == null) return map1 == map2;
    if (map1.length != map2.length) return false;
    return map1.entries.every((e) => map2[e.key] == e.value);
  }

  void addCustomer(Map<String, dynamic> customer) {
    state.whenData((customers) {
      state = AsyncValue.data([customer, ...customers]);
    });
  }

  void removeCustomer(String customerId) {
    state.whenData((customers) {
      state = AsyncValue.data(
        customers.where((c) => c['id'] != customerId).toList(),
      );
    });
  }

  void updateCustomer(Map<String, dynamic> updatedCustomer) {
    state.whenData((customers) {
      final index =
          customers.indexWhere((c) => c['id'] == updatedCustomer['id']);
      if (index != -1) {
        final newList = [...customers];
        newList[index] = updatedCustomer;
        state = AsyncValue.data(newList);
      }
    });
  }
}

final customerDetailProvider = StateNotifierProvider.family<
    CustomerDetailNotifier,
    AsyncValue<Map<String, dynamic>?>,
    String>((ref, customerId) {
  return CustomerDetailNotifier(
    customerRepository: CustomerRepository(ApiClient()),
    customerId: customerId,
    ref: ref,
  );
});

final customerJourneyProvider = StateNotifierProvider.family<
    CustomerJourneyNotifier,
    AsyncValue<List<dynamic>>,
    String>((ref, customerId) {
  return CustomerJourneyNotifier(
    customerRepository: CustomerRepository(ApiClient()),
    customerId: customerId,
  );
});

class CustomerDetailNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final CustomerRepository _customerRepository;
  final String _customerId;
  final Ref _ref;

  CustomerDetailNotifier({
    required CustomerRepository customerRepository,
    required String customerId,
    required Ref ref,
  })  : _customerRepository = customerRepository,
        _customerId = customerId,
        _ref = ref,
        super(const AsyncValue.loading());

  Future<void> loadCustomerDetail(
    String organizationId,
    String workspaceId, {
    bool skipLoading = false,
  }) async {
    try {
      if (!skipLoading) {
        state = const AsyncValue.loading();
      }
      final response = await _customerRepository.getCustomerDetail(
        organizationId,
        workspaceId,
        _customerId,
      );
      state = AsyncValue.data(response['content'] as Map<String, dynamic>);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> assignToCustomer(
    String organizationId,
    String workspaceId,
    Map<String, dynamic> assignToData,
  ) async {
    try {
      await _customerRepository.assignToCustomer(
        organizationId,
        workspaceId,
        _customerId,
        assignToData,
      );

      // Load lại customer detail
      await loadCustomerDetail(organizationId, workspaceId, skipLoading: true);

      // Load lại journey list
      _ref.invalidate(customerJourneyProvider(_customerId));
      await _ref
          .read(customerJourneyProvider(_customerId).notifier)
          .loadJourneyList(organizationId, workspaceId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCustomer(
    String organizationId,
    String workspaceId,
    dynamic formData,
  ) async {
    try {
      final response = await _customerRepository.updateCustomer(
        organizationId,
        workspaceId,
        _customerId,
        formData,
      );

      // Reload customer detail after update
      await loadCustomerDetail(organizationId, workspaceId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(
    String organizationId,
    String workspaceId,
  ) async {
    try {
      await _customerRepository.deleteCustomer(
        organizationId,
        workspaceId,
        _customerId,
      );
      state = const AsyncValue.data(null);
    } catch (error) {
      rethrow;
    }
  }

  void clearCustomerDetail() {
    state = const AsyncValue.data(null);
  }
}

class CustomerJourneyNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final CustomerRepository _customerRepository;
  final String _customerId;

  CustomerJourneyNotifier({
    required CustomerRepository customerRepository,
    required String customerId,
  })  : _customerRepository = customerRepository,
        _customerId = customerId,
        super(const AsyncValue.loading());

  Future<void> loadJourneyList(
    String organizationId,
    String workspaceId,
  ) async {
    state = await AsyncValue.guard(() async {
      final response = await _customerRepository.getJourneyList(
        organizationId,
        workspaceId,
        _customerId,
      );
      return response['content'] as List;
    });
  }

  Future<void> updateJourney(
    String organizationId,
    String workspaceId,
    String stageId,
    String note,
  ) async {
    try {
      await _customerRepository.updateJourney(
        organizationId,
        workspaceId,
        _customerId,
        stageId,
        note,
      );
      state = await AsyncValue.guard(() async {
        final response = await _customerRepository.getJourneyList(
          organizationId,
          workspaceId,
          _customerId,
        );
        return response['content'] as List;
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
