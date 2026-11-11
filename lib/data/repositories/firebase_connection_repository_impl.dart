import '../../domain/repositories/firebase_connection_repository.dart';
import '../datasources/firebase/firebase_connection_datasource.dart';

class FirebaseConnectionRepositoryImpl implements FirebaseConnectionRepository {
  FirebaseConnectionRepositoryImpl(this._dataSource);

  final FirebaseConnectionDataSource _dataSource;

  @override
  Future<void> testConnection() => _dataSource.writeConnectionTest();
}
