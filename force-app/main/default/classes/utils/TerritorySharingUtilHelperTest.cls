/**
 * @author Ashish Kumar
 * @since 05/2024
 * @description  To test TerritorySharingUtilHelper
 */
@isTest
public class TerritorySharingUtilHelperTest {
  /**
   * @description test method for testIsExcludedUsers
   */
  @isTest
  static void testIsExcludedUsers() {
    String strUserName = 'test@excludeduser.com;';
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.Excluded_Users__c = strUserName;
    Test.startTest();
    Boolean isExcludedUsers = TerritorySharingUtilHelper.isExcludedUsers(
      objMtd,
      strUserName
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      isExcludedUsers,
      'Method not able to filter exclude user correctly which are added to exclude user field of the metadata for a single user'
    );
  }

  /**
   * @description test method for testIsExcludedMultiUsers
   */
  @isTest
  static void testIsExcludedMultiUsers() {
    String strUserName = 'test@excludeduser.com;test1@excludeduser.com;';
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.Excluded_Users__c = strUserName;
    Test.startTest();
    Boolean isExcludedUsers = TerritorySharingUtilHelper.isExcludedUsers(
      objMtd,
      strUserName
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      isExcludedUsers,
      'Method not able to filter exclude user correctly which are added to exclude user field of the metadata for multiple user'
    );
  }

  /**
   * @description test method for testPrepareSobjectShareRecord
   */
  @isTest
  static void testPrepareSobjectShareRecord() {
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);

    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'Customer_Relationship__Share';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.IsParentIdField__c = true;
    List<sObject> lstOfSobject = new List<sObject>();
    sObject objSObject = new Lead();
    objSObject.put('Id', idLead);
    objSObject.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));

    lstOfSobject.add(objSObject);
    Map<Id, sObject> oldMapSobject = new Map<Id, sObject>();
    sObject sObjectOld = new Lead();
    sObjectOld.put('Id', idLead);
    sObjectOld.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));

    oldMapSobject.put(idLead, sObjectOld);

    Test.startTest();
    sObject eachShareRecords = TerritorySharingUtilHelper.prepareSobjectShareRecord(
      'Customer_Relationship__c',
      objSObject,
      objMtd,
      Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Test.stopTest();

    Assert.areEqual(
      'Edit',
      eachShareRecords.get('AccessLevel'),
      'Method not able to prepare Customer_Relationship__Share record properly for the passed objSObject record with passed objMtd metadata record'
    );
  }

  /**
   * @description test method for testPopulateRecordIdsForPE
   */
  @isTest
  static void testPopulateRecordIdsForPE() {
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idAcc = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Territory_Base_Sharing_Event__e objEvt = new Territory_Base_Sharing_Event__e();

    List<sObject> lstOfSobject = new List<sObject>();
    sObject objSObject = new Lead();
    objSObject.put('Id', idLead);
    objSObject.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));

    lstOfSobject.add(objSObject);

    Test.startTest();
    Territory_Base_Sharing_Event__e objRes = TerritorySharingUtilHelper.populateRecordIdsForPE(
      lstOfSobject,
      objEvt
    );
    Test.stopTest();

    Assert.areEqual(
      idLead,
      objRes.Record_Ids__c,
      'Method not able to prepare territory event record with record ids for the given sobject record'
    );

    Territory_Base_Sharing_Event__e eventWithRecIds = new Territory_Base_Sharing_Event__e(
      Record_Ids__c = String.valueOf(idAcc)
    );
    Territory_Base_Sharing_Event__e objResWithRecords = TerritorySharingUtilHelper.populateRecordIdsForPE(
      lstOfSobject,
      eventWithRecIds
    );
    Assert.areEqual(
      idAcc + ';' + idLead,
      objResWithRecords.Record_Ids__c,
      'Method not able to prepare territory event record with record ids when Record_Ids__c is populated'
    );
  }

  /**
   * @description test method for testCreateSharingPE
   */
  @isTest
  static void testCreateSharingPE() {
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idMlRT = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead');
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Object_Name__c = 'Lead';
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    List<Lead> lstOfSobject = new List<lead>{
      new Lead(
        Id = idLead,
        RecordTypeId = idMlRT,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Map<Id, sObject> oldMapSobject = new Map<Id, sObject>();
    sObject sObjectOld = new Lead();
    sObjectOld.put('Id', idLead);
    sObjectOld.put('RecordTypeId', idMlRT);
    sObjectOld.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));

    oldMapSobject.put(idLead, sObjectOld);

    Test.startTest();
    Territory_Base_Sharing_Event__e objRes = TerritorySharingUtilHelper.createSharingPE(
      lstOfSobject,
      'Lead',
      oldMapSobject,
      objMtd
    );
    Test.stopTest();

    Assert.areEqual(
      idLead,
      objRes.Record_Ids__c,
      'Method not able to create territory base sharing event platform record correctly'
    );
  }

  /**
   * @description test method for testReShareToOriginalOwner
   */
  @isTest
  static void testReShareToOriginalOwner() {
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Object_Name__c = 'Lead';
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    List<Lead> lstOfSobject = new List<lead>{
      new Lead(
        Id = idLead,
        RecordTypeId = RTLead.mlcrmLead,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
      )
    };
    Map<Id, sObject> oldMapSobject = new Map<Id, sObject>();

    sObject sObjectOld = new Lead();
    sObjectOld.put('Id', idLead);
    sObjectOld.put('RecordTypeId', RTLead.mlcrmLead);
    sObjectOld.put('OwnerId', Lib_FakeIdGenerator.getMockId(User.SObjectType));
    sObjectOld.put(
      'Territory__c',
      Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
    );
    oldMapSobject.put(idLead, sObjectOld);

    Test.startTest();
    List<sObject> lstOfSobjects = TerritorySharingUtilHelper.reShareToOriginalOwner(
      lstOfSobject,
      'Lead',
      oldMapSobject,
      objMtd
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      lstOfSobjects.size(),
      'Method not able to reshare record with original owner correctly'
    );
  }

  /**
   * @description test method for testGetEligibleRT
   */
  @isTest
  static void testGetEligibleRT() {
    String strUserName = 'test@excludeduser.com;';
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Active__c = true;
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Eligible_Record_Types__c = 'MLCRM_Lead';
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.Excluded_Users__c = strUserName;
    Test.startTest();
    List<String> lstEligibleRTs = TerritorySharingUtilHelper.getEligibleRT(
      objMtd
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstEligibleRTs.size(),
      'Method not able to return correct recordtypeids for the passed recordtype name'
    );
  }
  /**
   * @description test method for testGetEligibleRT
   */
  @isTest
  static void testGetNewSobject() {
    String validSObjectName = 'Account'; // Change this to any valid SObject name
    SObject newSObject = TerritorySharingUtilHelper.getNewSobject(
      validSObjectName
    );
    Assert.areEqual(
      'Account',
      newSObject.getSObjectType().getDescribe().getName(),
      'The SObject type should be Account'
    );
  }

  @isTest
  static void testMergeMaps() {
    User_Territory__c ut1 = new User_Territory__c(ML_Role__c = 'UT1');
    User_Territory__c ut2 = new User_Territory__c(ML_Role__c = 'UT2');
    User_Territory__c ut3 = new User_Territory__c(ML_Role__c = 'UT3');
    User_Territory__c ut4 = new User_Territory__c(ML_Role__c = 'UT4');
    Map<String, List<User_Territory__c>> map1 = new Map<String, List<User_Territory__c>>();
    map1.put('Key1', new List<User_Territory__c>{ ut1, ut2 });
    map1.put('Key2', new List<User_Territory__c>{ ut3 });
    Map<String, List<User_Territory__c>> map2 = new Map<String, List<User_Territory__c>>();
    map2.put('Key1', new List<User_Territory__c>{ ut4 });
    map2.put('Key3', new List<User_Territory__c>{ ut2 });
    Map<String, List<User_Territory__c>> result = TerritorySharingUtilHelper.mergeMaps(
      map1,
      map2
    );
    Assert.areEqual(3, result.size(), 'Result map should have 3 keys');

    // Key1 should have ut1, ut2, ut4
    List<User_Territory__c> key1List = result.get('Key1');
    Assert.areEqual(
      3,
      key1List.size(),
      'Key1 should have 3 User_Territory__c objects'
    );
    System.assert(key1List.contains(ut1), 'Key1 list should contain ut1');
    System.assert(key1List.contains(ut2), 'Key1 list should contain ut2');
    System.assert(key1List.contains(ut4), 'Key1 list should contain ut4');

    // Key2 should have ut3 only
    List<User_Territory__c> key2List = result.get('Key2');
    Assert.areEqual(
      1,
      key2List.size(),
      'Key2 should have 1 User_Territory__c object'
    );
    Assert.areEqual(ut3, key2List[0], 'Key2 list should contain ut3');

    // Key3 should have ut2 only
    List<User_Territory__c> key3List = result.get('Key3');
    Assert.areEqual(
      1,
      key3List.size(),
      'Key3 should have 1 User_Territory__c object'
    );
    Assert.areEqual(ut2, key3List[0], 'Key3 list should contain ut2');
  }
}
