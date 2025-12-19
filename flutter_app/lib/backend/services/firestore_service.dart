// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Helper function type for converting Firestore map data to a Dart object
typedef FromFirestore<T> = T Function(Map<String, dynamic> data, String documentId);
// Helper function type for converting a Dart object to a Firestore map
typedef ToFirestore<T> = Map<String, dynamic> Function(T model);

class FirestoreService {
  // 1. Singleton Instance
  // This makes the service easily accessible throughout the app without creating
  // multiple instances.
  static final FirestoreService instance = FirestoreService._internal();
  factory FirestoreService() => instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 2. Generic READ Operations ---

  /// Reads a single document from a path and converts it to a generic model T.
  Future<T?> getDocument<T>({
    required String path,
    required FromFirestore<T> fromFirestore,
  }) async {
    try {
      final docSnapshot = await _db.doc(path).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return fromFirestore(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting document at $path: $e');
      rethrow;
    }
  }

  /// Streams a collection, returning a list of generic model T objects.
  Stream<List<T>> collectionStream<T>({
    required String path,
    required FromFirestore<T> fromFirestore,
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = _db.collection(path);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      return fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList());
  }

  // --- 3. WRITE Operations ---

  /// Sets (creates or overwrites) a document with a specific ID.
  Future<void> setData<T>({
    required String path,
    required T model,
    required ToFirestore<T> toFirestore,
    bool merge = false,
  }) async {
    try {
      await _db.doc(path).set(toFirestore(model), SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Error setting data at $path: $e');
      rethrow;
    }
  }

  /// Adds a new document to a collection (Firestore generates the ID).
  Future<String> addData<T>({
    required String collectionPath,
    required T model,
    required ToFirestore<T> toFirestore,
  }) async {
    try {
      final docRef = await _db.collection(collectionPath).add(toFirestore(model));
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding data to $collectionPath: $e');
      rethrow;
    }
  }

  /// Updates specific fields in a document.
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.doc(path).update(data);
    } catch (e) {
      debugPrint('Error updating data at $path: $e');
      rethrow;
    }
  }

  // --- 4. DELETE Operation ---

  /// Deletes a document at the specified path.
  Future<void> deleteData({required String path}) async {
    try {
      await _db.doc(path).delete();
    } catch (e) {
      debugPrint('Error deleting data at $path: $e');
      rethrow;
    }
  }
}

