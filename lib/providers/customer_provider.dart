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

  CustomerListNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadCustomers(String organizationId, String workspaceId,
      Map<String, String> queryParams) async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getCustomers(
          organizationId, workspaceId,
          queryParameters: queryParams);
      final items = response['content'] as List;
      state = AsyncValue.data(items.cast<Map<String, dynamic>>());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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
