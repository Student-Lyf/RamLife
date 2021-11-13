import "package:ramaz/models.dart";
import "package:ramaz/services.dart";
import "../../firestore.dart";
import "interface.dart";
///
class CloudDataRefresh implements DataRefreshInterface{
  ///
  static final CollectionReference<Map> data = Firestore
      .instance.collection("dataRefresh");

  @override
  Future<void> getRefreshData() async{
    final Map<String, String> map = Map<String,String>.from(await data
        .doc("dataRefresh").throwIfNull("Cannot get refreshed data"));
    if(DateTime.parse(map["user"]!).isAfter(Services.instance.prefs
        .getRefreshData("user")!)||
        Services.instance.prefs.getRefreshData("user")==null){
        await Models.instance.user.init();
        print(map["user"]);
        print("User model initialized");
    }else if(DateTime.parse(map["schedule"]!).isAfter(Services.instance.prefs
        .getRefreshData("schedule")!)){
          await Models.instance.schedule.init();
          print(map["schedule"]);
          print("Schedule model initialized");
    }
  }
  @override
  Future<DateTime> setRefreshData(String data){
    //TODO: implement setRefreshData
    throw UnimplementedError();
  }
}
///
class LocalDataRefresh implements DataRefreshInterface{
  @override
  Future<void> getRefreshData() {
    //TODO: implement setRefreshData
    throw UnimplementedError();
  }
  @override
  Future<void> setRefreshData(String data) async{
    await Services.instance.prefs.setRefreshData(data, DateTime.now());
  }
}

