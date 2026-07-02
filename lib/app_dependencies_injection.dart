import 'package:get_it/get_it.dart';
import 'storage/database.dart';
import 'repositories/conversation_repository.dart';
import 'repositories/message_repository.dart';
import 'repositories/import_repository.dart';
import 'services/import_whatsapp_service.dart';

final GetIt locator = GetIt.instance;

void setupDependencyInjection() {
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  locator.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(locator<AppDatabase>()),
  );

  locator.registerLazySingleton<MessageRepository>(
    () => MessageRepository(locator<AppDatabase>()),
  );

  locator.registerLazySingleton<ImportRepository>(
    () => ImportRepository(locator<AppDatabase>()),
  );

  locator.registerLazySingleton<ImportWhatsappService>(
    () => ImportWhatsappService(locator<ImportRepository>()),
  );
}
