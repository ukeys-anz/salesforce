public with sharing class AccessCheckUtil {
  public static AccessCheckWrapper checkAccess(
    String sObjtectName,
    AccessType access,
    List<SObject> sObjectList
  ) {
    AccessCheckWrapper acw = new AccessCheckWrapper();
    SObjectAccessDecision securityDecision = Security.stripInaccessible(
      access,
      sObjectList
    );
    if (securityDecision.getRemovedFields().get(sObjtectName) != null) {
      acw.inAccessibleFields = String.join(
        (Iterable<String>) securityDecision.getRemovedFields()
          .get(sObjtectName),
        ', '
      );
    }
    acw.records = securityDecision.getRecords();
    return acw;
  }

  public with sharing class AccessCheckWrapper {
    public string inAccessibleFields { get; set; }
    public List<SObject> records { get; set; }
  }
}
