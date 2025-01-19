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
