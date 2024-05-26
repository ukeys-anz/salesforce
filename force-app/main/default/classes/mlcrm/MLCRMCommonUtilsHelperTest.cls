/**
 * @author Ashish Kumar
 * @since 04/2024
 * @description  To test MLCRMCommonUtilsHelperTest
 */
@isTest
public class MLCRMCommonUtilsHelperTest {
  /**
   * @description test method for FilterEligibleLeadSobjects
   */
  @isTest
  static void testValidateFilterEligibleSobjects() {
    List<sObject> lstOfSobject = new List<sObject>();
    sObject objSObject = new Lead();
    objSObject.put('RecordTypeId', MLCRMConstants.MLCRM_LEAD_RT_ID);
    objSObject.put(
      'Territory__c',
      Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    lstOfSobject.add(objSObject);
    List<sObject> lstOfValidSobject = MLCRMCommonUtilsHelper.filterEligibleSobjects(
      lstOfSobject
    );
    System.assertEquals(
      1,
      lstOfValidSobject.size(),
      'testValidateFilterEligibleSobjects method not working properly for lead sobject'
    );
  }

  /**
   * @description test method for FilterEligibleSobjectsForOpp
   */
  @isTest
  static void testValidateSobjectEligibilityForOpp() {
    List<sObject> lstOfSobject = new List<sObject>();
    sObject objSObject = new Opportunity();
    objSObject.put('RecordTypeId', MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID);
    objSObject.put(
      'Territory__c',
      Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    lstOfSobject.add(objSObject);
    List<sObject> lstOfValidSobject = MLCRMCommonUtilsHelper.filterEligibleSobjects(
      lstOfSobject
    );
    System.assertEquals(
      1,
      lstOfValidSobject.size(),
      'testValidateSobjectEligibilityForOpp method not working properly for opportunity sobject'
    );
  }

  /**
   * @description test method for filterOwnerIdChanged
   */
  @isTest
  static void testFilterOwnerIdChanged() {
    Map<Id, sObject> oldMapSobject = new Map<Id, sObject>();
    Id sobjectId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<sObject> lstOfSobject = new List<sObject>();
    sObject objSObject = new Lead();
    objSObject.put('Id', sobjectId);
    objSObject.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));
    lstOfSobject.add(objSObject);

    sObject oldSObject = new Lead();
    oldSObject.put('Id', sobjectId);
    oldSObject.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));
    oldMapSobject.put((Id) oldSObject.get('Id'), oldSObject);
    List<sObject> lstOfValidSobject = MLCRMCommonUtilsHelper.filterOwnerIdChanged(
      oldMapSobject,
      lstOfSobject
    );
    System.assertEquals(
      1,
      lstOfValidSobject.size(),
      'filterOwnerIdChanged method not working properly for lead sobject'
    );
  }

  /**
   * @description test method for ValidateUserRole
   */
  @isTest
  static void testValidateUserRole() {
    Id sobjectId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id strCurrentUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    sObject objSObject = new Lead();
    objSObject.put('Id', sobjectId);
    objSObject.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));
    Boolean isValidRecord = MLCRMCommonUtilsHelper.validateUserRole(
      'Admin',
      objSObject,
      strCurrentUserId
    );
    System.assertEquals(
      true,
      isValidRecord,
      'ValidateUserRole method not working properly for lead sobject'
    );
  }
}
