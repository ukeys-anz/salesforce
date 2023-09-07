// Script to associate the related address to location record
Map<Id, Schema.Address> mapLocationIdAddress = new Map<Id, Schema.Address>();
List<Schema.Location> locationToUpdate = new List<Schema.Location>();
List<Schema.Location> allLocations = [
  SELECT Id, Name, VisitorAddressId
  FROM Location
  WHERE VisitorAddressId = NULL
];
for (Schema.Address add : [SELECT Id, ParentId FROM Address]) {
  mapLocationIdAddress.put(add.ParentId, add);
}
for (Schema.Location lo : allLocations) {
  if (mapLocationIdAddress.keyset().contains(lo.Id)) {
    lo.VisitorAddressId = mapLocationIdAddress.get(lo.Id).Id;
    locationToUpdate.add(lo);
  }
}
update locationToUpdate;
