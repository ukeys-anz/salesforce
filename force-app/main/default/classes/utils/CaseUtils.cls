/**
 *
 * @author Jasmine Nguyen
 * @since Oct 2021
 * @description Utils class for utitlies related to Case object
 */

public with sharing class CaseUtils {
    /**
     * @description Returns the RecordTypeId Developer name passed through
     * @param developerName String - The developer name of the Record Type you wish to query.
     * @return Id Returns the RecordTypeId
     */
    public static Id getCaseRecordTypeIdByDeveloperName(String developerName) {
      if (String.isNotBlank(developerName)) {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get(developerName)
          .getRecordTypeId();
      }
  
      return null;
    }
  }
  