import "package:yaml/yaml.dart";

import "package:firestore/helpers.dart";
import "package:node_io/node_io.dart";

final File file = File(DataFiles.constants);

final YamlMap yamlContents = loadYaml(file.readAsStringSync());

final Set<String> dayNames = Set.from(yamlContents ["dayNames"]);

final Set<String> corruptStudents = Set.from(yamlContents ["corruptStudents"]);

final bool isSemester1 = DateTime.now().month > 7;