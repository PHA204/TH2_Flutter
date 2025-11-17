// lib/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:noidung3/data/datasources/remote/cloudinary_service.dart';
import 'package:noidung3/data/repositories/review_repository_impl.dart';
import 'package:noidung3/domain/repositories/review_repository.dart';
import 'package:noidung3/domain/usecases/add_review_usecase.dart';
import 'package:noidung3/presentation/providers/review_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
    () => ReviewProvider(
      addReviewUseCase: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => AddReviewUseCase(sl()));
  
  // Repositories
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      firestore: sl(),
      cloudinaryService: sl(),
    ),
  );
  
  // Data Sources
  sl.registerLazySingleton(() => CloudinaryService());
  
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}