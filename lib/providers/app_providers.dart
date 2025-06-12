import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coka/api/providers.dart';
import 'package:coka/providers/multi_source_connection_provider.dart';

final multiSourceConnectionProvider = Provider<MultiSourceConnectionProvider>((ref) {
  final leadRepository = ref.read(leadRepositoryProvider);
  return MultiSourceConnectionProvider(leadRepository: leadRepository);
}); 