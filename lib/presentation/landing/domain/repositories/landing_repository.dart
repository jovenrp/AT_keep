import 'package:hive/hive.dart';

abstract class LandingRepository {
  Future<Box> openStocksBox();
  Future<Box> openProfileBox();
  Future<Box> openOrderBox();
  Future<Box> openOrderLineBox();
  Future<Map<String, dynamic>> backupStocks(Box box);
  Future<Map<String, dynamic>> backupProfile(Box box);
  Future<Map<String, dynamic>> backupOrder(Box box);
  Future<Map<String, dynamic>> backupOrderLine(Box box);
  Future<String?> restoreStocks(Box box);
  Future<String?> importCSV(Box box, String action);
}
