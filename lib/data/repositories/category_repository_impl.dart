import 'package:flutter/foundation.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/firebase/firebase_category_datasource.dart';
import '../datasources/local/category_local_datasource.dart';
import '../models/category_model.dart';
import '../models/firestore/category_firestore_model.dart';
import '../../core/utils/app_logger.dart';

/// Reads from Firestore first so seeded/remote data is visible. Writes to both local and Firestore.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(
    this._local, {
    FirebaseCategoryDataSource? firestore,
  }) : _firestore = firestore;

  final CategoryLocalDatasource _local;
  final FirebaseCategoryDataSource? _firestore;

  @override
  Future<List<CategoryEntity>> getAll() async {
    if (_firestore != null) {
      try {
        final list = await _firestore.getAll();
        AppLogger.repository('Category', 'getAll() from Firestore: ${list.length} items');
        return list.map(_firestoreModelToEntity).toList();
      } catch (e, st) {
        if (kDebugMode) {
          AppLogger.repository('Category', 'getAll() Firestore failed, fallback to local', e);
          debugPrint(st.toString());
        }
      }
    }
    final local = await _local.getAll();
    AppLogger.repository('Category', 'getAll() from local: ${local.length} items');
    return local;
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    if (_firestore != null) {
      try {
        final model = await _firestore.getById(id);
        if (model != null) return _firestoreModelToEntity(model);
      } catch (_) {}
    }
    return _local.getById(id);
  }

  @override
  Future<void> create(CategoryEntity entity) async {
    final model = CategoryModel.fromEntity(entity);
    await _local.create(model);
    if (_firestore != null) {
      try {
        final now = DateTime.now();
        await _firestore.create(CategoryFirestoreModel(
          id: entity.id,
          name: entity.name,
          createdAt: now,
          updatedAt: now,
          isActive: true,
        ));
      } catch (_) {}
    }
  }

  @override
  Future<void> update(CategoryEntity entity) async {
    await _local.update(CategoryModel.fromEntity(entity));
    if (_firestore != null) {
      try {
        final existing = await _firestore.getById(entity.id);
        if (existing != null) {
          await _firestore.create(CategoryFirestoreModel(
            id: entity.id,
            name: entity.name,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
            isActive: true,
          ));
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    // Firestore: optional soft-delete or document delete could be added
  }

  CategoryEntity _firestoreModelToEntity(CategoryFirestoreModel m) {
    return CategoryEntity(
      id: m.id,
      name: m.name,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      isActive: m.isActive,
    );
  }
}
