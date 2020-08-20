import "package:idb_shim/idb_shim.dart";
import "package:idb_shim/idb_browser.dart";

Future<IdbFactory> get idbFactory async => idbFactoryBrowser;
