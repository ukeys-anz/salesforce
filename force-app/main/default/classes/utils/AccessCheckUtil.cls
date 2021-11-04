/**
 *
 * @author Adnan
 * @since 09/2021
 * @description Utility class for checking access to object/fields
 */
public with sharing class AccessCheckUtil {
  /**
   * @description entry method for checking access
   * @param sObjtectName object name for which the access needs to be checked
   * @param access AccessType Enum for specifying which type of access we need to check
   * @param sObjectList list of records on which the access needs to be checked
   * @return AccessCheckWrapper details present in wrapper
   */
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

  /**
   * @description Wrapper class for containing data/information regarding access check
   */
  public with sharing class AccessCheckWrapper {
    /**
     * @description contains all the inaccessible fields for a particular operation
     */
    public string inAccessibleFields { get; set; }
    /**
     * @description contains sanitized list of records returned from stripInaccessible method
     */
    public List<SObject> records { get; set; }
  }
}
