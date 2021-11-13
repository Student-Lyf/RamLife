///
abstract class DataRefreshInterface{
  ///
  Future<void> getRefreshData();
  ///
  Future<void> setRefreshData(String data);
}