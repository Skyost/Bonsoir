import 'package:bonsoir/bonsoir.dart';

/// Sorts the given list of services.
void sortServiceList(List<BonsoirService> services) => services.sort((a, b) => a.name.compareTo(b.name));
