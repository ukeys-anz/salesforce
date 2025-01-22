/**
 * @author Ashish Kumar
 * @since  04/2023
 * @description This class is to provide generic test data setups CCRM test classes.
 * @group Utils
 */
@IsTest
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public with sharing class MLCRMTestDataFactory {
  public static Id adminProfileId = CommonUtil.getProfileByName(
      'System Administrator'
    )
    .Id;
  public static Id anzStandardProfileId = CommonUtil.getProfileByName(
      'ANZ ML Standard User'
    )
    .Id;
  public static Id integrationProfileId = CommonUtil.getProfileByName(
      'Integration User'
    )
    .Id;
  public static Id batchUserProfileId = CommonUtil.getProfileByName(
      'Minimum Access - Salesforce'
    )
    .Id;
  public static Id mlRoleId = CommonUtil.getUserRoleByDevName(
      MLCRMConstants.ML_ROLE_DEV_NAME
    )
    ?.Id;
  private static Id mlBusinessAdminRoleId = CommonUtil.getUserRoleByDevName(
      MLCRMConstants.ML_BUSINESS_ADMIN_ROLE_NAME
    )
    ?.Id;
  public static Id anzIIQUser = CommonUtil.getProfileByName(
      'Minimum Access - External Apps'
    )
    .Id;
  private static Id arcRoleId = CommonUtil.getUserRoleByDevName(
      MLCRMConstants.ARC_USER_ROLE
    )
    ?.Id;
  private static Id anzRoleId = CommonUtil.getUserRoleByDevName('ANZ')?.Id;

  private static User adminUser;
  private static User mlcrmBaseUser;
  private static User mlcrmIntegrationUser;
  private static User minimumAccessBaseUser;
  private static User mlBusinessAdminUser;
  private static User ccrmBatchUser;

  /**
   * @description Create a MLCRM Base User
   * @name createCCRMBaseUser
   * @return ANZ Standard User with MLCRM Base User Permission Set.
   */
  public static User createMLCRMBaseUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    mlcrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    mlcrmBaseUser.FirstName = 'BaseUser' + staticNumber;
    mlcrmBaseUser.LastName = 'MLCRM';
    mlcrmBaseUser.UserRoleId = mlRoleId;
    mlcrmBaseUser.email = 'CRMtestMLUser@anz.com';
    mlcrmBaseUser.IsActive = true;
    mlcrmBaseUser.ProfileId = anzStandardProfileId;
    mlcrmBaseUser.IsActive = true;
    mlcrmBaseUser.Lan_Id__c = 'testMLBaseUL' + (Math.random() * 10);
    insert mlcrmBaseUser;
    TestUtil.assignPermissionSetGroups(
      new List<String>{ MLCRMConstants.LOAN_WRITER_PSG_NAME },
      new List<User>{ mlcrmBaseUser }
    );
    return mlcrmBaseUser;
  }

  /**
   * @description Create a Minimum Access User
   * @name createIIQBaseUser
   * @return Minimum Access User with API and User Provisioning User Permission Set.
   */
  public static User createIIQBaseUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    minimumAccessBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    minimumAccessBaseUser.FirstName = 'BaseUser' + staticNumber;
    minimumAccessBaseUser.LastName = 'IIQ';
    minimumAccessBaseUser.ProfileId = anzIIQUser;
    minimumAccessBaseUser.IsActive = true;
    minimumAccessBaseUser.Lan_Id__c = 'testMLBaseUL' + (Math.random() * 10);
    insert minimumAccessBaseUser;
    addMLCRMUserPS(minimumAccessBaseUser.id, 'API_Only');
    addMLCRMUserPS(minimumAccessBaseUser.id, 'User_Provisioning');
    return minimumAccessBaseUser;
  }

  /**
   * @description Create a MLCRM Base User
   * @param numberOfUser Count of users needed to be created
   * @name createListOfMLCRMBaseUser
   */
  public static void createListOfMLCRMBaseUser(Integer numberOfUser) {
    List<User> lstOfMlUser = new List<User>();
    for (Integer data = 0; data < numberOfUser; data++) {
      String staticNumber =
        Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
      mlcrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
      mlcrmBaseUser.FirstName = 'BaseUser' + staticNumber;
      mlcrmBaseUser.LastName = 'MLCRM';
      mlcrmBaseUser.UserRoleId = mlRoleId;
      mlcrmBaseUser.ProfileId = anzStandardProfileId;
      mlcrmBaseUser.ML_Role__c = 'Franchise Owner';
      mlcrmBaseUser.ML_Territories__c = 'Canberra Inner South (ACT);Central Coast North (NSW)';
      mlcrmBaseUser.IsActive = true;
      mlcrmBaseUser.Lan_Id__c = 'testMLBaseUL' + (Math.random() * 10);
      lstOfMlUser.add(mlcrmBaseUser);
    }

    insert lstOfMlUser;
    for (user objUser : lstOfMlUser) {
      addMLCRMUserPS(objUser.id, 'MLCRM_Base');
    }
  }
  /**
   * @description Create a MLCRM System Admin User
   * @name createAdminUser
   * @return System Administrator User
   */
  public static User createAdminUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    adminUser = (User) FakerFactory.make(new FakerUserFactory());
    adminUser.FirstName = 'TestUser' + staticNumber;
    adminUser.LastName = 'Admin';
    adminUser.UserRoleId = anzRoleId;
    adminUser.ProfileId = adminProfileId;
    adminUser.IsActive = true;
    adminUser.Lan_Id__c = 'testMLAdminUL' + (Math.random() * 10);
    insert adminUser;
    addMLCRMUserPS(adminUser.id, 'MLCRM_Base');
    return adminUser;
  }

  /**
   * @description Get a MLCRM Base User, if such user not exists yet then create one
   * @name getMLCRMBaseUser
   * @return ANZ ML Standard User with MLCRM Base User Permission Set.
   */
  public static User getMLCRMBaseUser() {
    if (mlcrmBaseUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :anzStandardProfileId AND LastName = 'MLCRM'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        mlcrmBaseUser = createMLCRMBaseUser();
      } else {
        mlcrmBaseUser = users[0];
      }
    }
    return mlcrmBaseUser;
  }

  /**
   * @description Get a MLCRM System Admin User, if such user not exists yet then create one
   * @name getAdminUser
   * @return System Administrator User
   */
  public static User getAdminUser() {
    if (adminUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :adminProfileId AND LastName = 'Admin'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        adminUser = createAdminUser();
      } else {
        adminUser = users[0];
      }
    }
    return adminUser;
  }
  /**
   * @description Create a MLCRM Integration User
   * @name createMLCRMIntegrationUser
   * @param username username of the user
   * @return ANZ ML Standard User with MLCRM Integration User Permission Set.
   */
  public static User createMLCRMIntegrationUser(string username) {
    String staticNumber = Datetime.now().format('MMddHHmmss');
    mlcrmIntegrationUser = (User) FakerFactory.make(new FakerUserFactory());
    mlcrmIntegrationUser.FirstName = 'IntegrationUser' + staticNumber;
    mlcrmIntegrationUser.LastName = 'MLCRM Integration';
    mlcrmIntegrationUser.Username = username;
    mlcrmIntegrationUser.UserRoleId = anzRoleId;
    mlcrmIntegrationUser.ProfileId = integrationProfileId;
    insert mlcrmIntegrationUser;
    addMLCRMUserPS(mlcrmIntegrationUser.id, 'MLCRM_Marketing_Integration_User');
    addMLCRMUserPS(mlcrmIntegrationUser.id, 'Read_Write_Customer_Details');
    addMLCRMUserPS(mlcrmIntegrationUser.id, 'Financial_Accounts_Read_and_Edit');
    return mlcrmIntegrationUser;
  }

  /**
   * @description Get a CCRM Integration User, if such user not exists yet then create one
   * @name getMLCRMIntegrationUser
   * @param username username of the user
   * @return ANZ ML Standard User with MLCRM Integration User Permission Set.
   */
  public static User getMLCRMIntegrationUser(String username) {
    if (mlcrmIntegrationUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :integrationProfileId AND username LIKE :username
        LIMIT 1
      ];
      if (users.isEmpty()) {
        mlcrmIntegrationUser = createMLCRMIntegrationUser(username);
      } else {
        mlcrmIntegrationUser = users[0];
      }
    }
    return mlcrmIntegrationUser;
  }

  /**
   * @description Create Lead Records for CCRM Testing
   * @name createLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @return `List<Lead>` New lead records
   */
  public static List<Lead> createLeadRecords(Integer count, User ownerUser) {
    return createLeadRecords(count, ownerUser, true);
  }

  /**
   * @description Create Lead Records for CCRM Testing
   * @name createManualLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @return `List<Lead>` New lead records
   */
  public static List<Lead> createManualLeadRecords(
    Integer count,
    User ownerUser
  ) {
    return createManualLeadRecords(count, ownerUser, true);
  }

  /**
   * @description Create Lead Records for MLCRM Testing
   * @name createLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param doInsert Whether or not to insert the records.
   * @return `List<Lead>` New lead records
   */
  public static List<Lead> createLeadRecords(
    Integer count,
    User ownerUser,
    Boolean doInsert
  ) {
    count = count == null || count == 0 ? 1 : count;

    List<Lead> newLeads = new List<Lead>();
    for (Integer i = 1; i <= count; i++) {
      String staticNumber = Datetime.now().format('MMddHHmmss') + i;
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam' + staticNumber + '@test.com';
      leadRecord.RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Personal Loan';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Sam' + staticNumber;
      leadRecord.LastName = 'Jacob';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Campaign_Code__c = staticNumber;
      leadRecord.Lead_Originator__c = 'Adobe';
      leadRecord.Business_ID__c = '012345';
      leadRecord.Status = CCRMConstants.STATUS_NEW;
      leadRecord.OwnerId = ownerUser.Id == null
        ? UserInfo.getUserId()
        : ownerUser.Id;

      newLeads.add(leadRecord);
    }
    if (doInsert) {
      Database.insert(newLeads);
    }

    return newLeads;
  }

  /**
   * @description Create Lead Records for MLCRM Testing
   * @name createManualLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param doInsert Whether or not to insert the records.
   * @return `List<Lead>` New lead records
   */
  public static List<Lead> createManualLeadRecords(
    Integer count,
    User ownerUser,
    Boolean doInsert
  ) {
    count = count == null || count == 0 ? 1 : count;

    List<Lead> newLeads = new List<Lead>();
    for (Integer i = 1; i <= count; i++) {
      String staticNumber = Datetime.now().format('MMddHHmmss') + i;
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam' + staticNumber + '@test.com';
      leadRecord.RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Personal Loan';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Sam' + staticNumber;
      leadRecord.LastName = 'Jacob';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Campaign_Code__c = staticNumber;
      leadRecord.Lead_Originator__c = 'MLCRM';
      leadRecord.Business_ID__c = '012345';
      leadRecord.Status = CCRMConstants.STATUS_NEW;
      leadRecord.OwnerId = ownerUser.Id == null
        ? UserInfo.getUserId()
        : ownerUser.Id;

      newLeads.add(leadRecord);
    }
    if (doInsert) {
      Database.insert(newLeads);
    }

    return newLeads;
  }

  /**
   * @description Add required PermissionSet - MLCRM Base
   * @name addMLCRMUserPS
   * @param userId of User to which MLCRM_Base Permission Set needed to be assigned.
   * @param permissionSet Permission Set needed to be assigned.
   */
  public static void addMLCRMUserPS(Id userId, String permissionSet) {
    PermissionSet ps = CommonUtil.getPermissionSetByName(permissionSet);
    PermissionSetAssignment psa = TestUtil.createPSAssignment(userId, ps.Id);
    insert psa;
  }

  /**
   * @description Create Territory Records for MLCRM Testing
   * @name createTerritoryRecords
   * @param count Count of Territory records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param doInsert Whether or not to insert the records.
   * @return `List<Territory__c>` New territory records
   */
  public static List<Territory__c> createTerritoryRecords(
    Integer count,
    User ownerUser,
    Boolean doInsert
  ) {
    count = count == null || count == 0 ? 1 : count;
    List<Territory__c> lstOfNewTerritory = new List<Territory__c>();
    for (Integer i = 1; i <= count; i++) {
      Territory__c objTerritory = new Territory__c();
      objTerritory.Access_Scope__c = 'Restricted';
      objTerritory.Name = 'Melbourne CBD (VIC)';
      objTerritory.Primary_Franchise_Owner__c = userInfo.getUserId();
      objTerritory.OwnerId = ownerUser.Id == null
        ? UserInfo.getUserId()
        : ownerUser.Id;

      lstOfNewTerritory.add(objTerritory);
    }
    if (doInsert) {
      Database.insert(lstOfNewTerritory);
    }
    return lstOfNewTerritory;
  }

  /**
   * @description Create User Territory Records for MLCRM Testing
   * @name createUserTerritoryRecords
   * @param count Count of User Territory records needed to be created
   * @param userId territory user.
   * @param idTerritory territory Id.
   * @return `List<User_Territory__c>` New user territory records
   */
  public static List<User_Territory__c> createUserTerritoryRecords(
    Integer count,
    Id userId,
    Id idTerritory
  ) {
    count = count == null || count == 0 ? 1 : count;
    List<User_Territory__c> lstOfNewUserTerritory = new List<User_Territory__c>();
    for (Integer i = 1; i <= count; i++) {
      User_Territory__c objUserTerritory = new User_Territory__c();
      objUserTerritory.ML_Role__c = 'Franchise Owner';
      objUserTerritory.Status__c = 'Active';
      objUserTerritory.Territory__c = idTerritory;
      objUserTerritory.User__c = userId;
      lstOfNewUserTerritory.add(objUserTerritory);
    }
    Database.insert(lstOfNewUserTerritory);
    return lstOfNewUserTerritory;
  }

  /**
   * @description Create Opportunity Records for MLCRM Testing
   * @name createOpportunityRecords
   * @param count Count of Opportunity records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param accId Account id for which Opportunity needs to be created
   * @param doInsert Whether or not to insert the records
   * @return `List<Opportunity>`
   */
  public static List<Opportunity> createOpportunityRecords(
    Integer count,
    User ownerUser,
    Id accId,
    Boolean doInsert
  ) {
    //Default Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;
    List<Opportunity> newOpps = new List<Opportunity>();
    for (Integer i = 1; i <= count; i++) {
      Opportunity objOpportunity = new Opportunity();
      objOpportunity.Name = 'Test Opp ' + i;
      objOpportunity.Accountid = accId;
      objOpportunity.StageName = 'Need Analysis';
      objOpportunity.Customer_Needs__c = 'Asset Finance';
      objOpportunity.Amount = 200;
      objOpportunity.CloseDate = system.Today() + 10;
      objOpportunity.Description = 'Test Opportunity';
      objOpportunity.RecordTypeId = MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID;
      objOpportunity.OwnerId = ownerUser.Id == null
        ? UserInfo.getUserId()
        : ownerUser.Id;
      newOpps.add(objOpportunity);
    }
    if (doInsert) {
      Database.insert(newOpps);
    }

    return newOpps;
  }

  /**
   * @description Create Task Records for MLCRM Testing
   * @name createTaskRecords
   * @param count Count of Task records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param whatId What id for which Opportunity needs to be created
   * @param whoId What id for which Opportunity needs to be created
   * @return `List<Task>`
   */
  public static List<Task> createTaskRecords(
    Integer count,
    User ownerUser,
    Id whatId,
    Id whoId
  ) {
    //Default Count to 1 if null
    count = count == null || count == 0 ? 1 : count;
    List<Task> newTaskList = new List<Task>();
    for (Integer i = 1; i <= count; i++) {
      Task task = new Task(
        recordtypeId = MLCRMConstants.MLCRM_TASK_RT_ID,
        Status = MLCRMConstants.STATUS_OPEN,
        Priority = MLCRMConstants.PRIORITY_NORMAL,
        Subject = 'Test Subject',
        WhatId = whatId,
        WhoId = whoId,
        OwnerId = ownerUser.Id,
        ActivityDate = System.today() + 2,
        Description = 'Test Description'
      );
      newTaskList.add(task);
    }
    return newTaskList;
  }

  /**
   * @description Create Account Records for MLCRM Testing
   * @name createAccountRecords
   * @param count Count of Account records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param doInsert Whether or not to insert the records
   * @return `List<Account>`
   */
  public static List<Account> createAccountRecords(
    Integer count,
    User ownerUser,
    Boolean doInsert
  ) {
    //Default Count to 1 if null
    count = count == null || count == 0 ? 1 : count;
    List<Account> accountList = new List<Account>();
    for (Integer i = 1; i <= count; i++) {
      Account accnt = new Account();
      accnt.FirstName = 'TestAccount' + i;
      accnt.LastName = 'surname';
      accnt.OCV_ID__c = 'OCV' + i;
      //accnt.Industry = createIndustries[0].Code__c;
      accnt.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
      accnt.ABN__c = '50 110 219 460';
      accnt.PersonMobilePhone = '+6143000000' + i;
      accnt.PersonEmail = 'test' + i + '@test.com';
      accnt.FinServ__Gender__pc = 'Male';
      accnt.BillingStreet = '833 Collins Street';
      accnt.BillingCity = 'Docklands';
      accnt.BillingPostalCode = '3008';
      accnt.BillingState = 'Victoria';
      accnt.BillingCountry = 'AUS';
      accnt.FinServ__Status__c = 'Prospect';
      accnt.Source_System_Name__c = CCRMConstants.SOURCE_SYSTEM_NAME;
      accnt.ANZx_Customer__c = false;
      accountList.add(accnt);
    }
    if (doInsert) {
      Database.insert(accountList);
    }
    return accountList;
  }

  /**
   * @description Create a customer relationship record
   * @name createCustomerRelationNotes
   */
  public static void createCustomerRelationNotes() {
    Customer_Relationship__c objRelation = new Customer_Relationship__c();
    objRelation.Relationship_To_Franchise__c = 'Primary';
    insert objRelation;
  }

  /**
   * @description Create a ML Business Admin User
   * @name createMLBusinessAdminUser
   * @return ML Business Admin User with MLCRM Business Admin User Permission Set Group.
   */
  public static User createMLBusinessAdminUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    mlBusinessAdminUser = (User) FakerFactory.make(new FakerUserFactory());
    mlBusinessAdminUser.FirstName = 'AdminUser' + staticNumber;
    mlBusinessAdminUser.LastName = 'BusinessAdmin';
    mlBusinessAdminUser.UserRoleId = mlBusinessAdminRoleId;
    mlBusinessAdminUser.ProfileId = anzStandardProfileId;
    mlBusinessAdminUser.IsActive = true;
    mlBusinessAdminUser.Lan_Id__c =
      'testMLBusinessAdminUL' + (Math.random() * 10);
    insert mlBusinessAdminUser;
    TestUtil.assignPermissionSetGroups(
      new List<String>{
        MLCRMConstants.ML_SUPER_USER_PSG_NAME,
        MLCRMConstants.BUSINESS_ADMIN_USER_PSG_NAME,
        MLCRMConstants.ENGINEER_PSG_NAME
      },
      new List<User>{ mlBusinessAdminUser }
    );
    return mlBusinessAdminUser;
  }

  /**
   * @description Create a CCRM Batch User
   * @name createCRMBatchUser
   * @return CCRM Batch User
   */
  public static User createCRMBatchUser() {
    String staticNumber = Datetime.now().format('MMddHHmmss');
    ccrmBatchUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmBatchUser.FirstName = 'CRM' + staticNumber;
    ccrmBatchUser.LastName = 'Batch User';
    ccrmBatchUser.email = 'CRMtestBatchUser@anz.com';
    ccrmBatchUser.UserRoleId = arcRoleId;
    ccrmBatchUser.IsActive = true;
    ccrmBatchUser.ProfileId = batchUserProfileId;
    insert ccrmBatchUser;
    addMLCRMUserPS(ccrmBatchUser.id, 'API_Only');
    addMLCRMUserPS(ccrmBatchUser.id, 'Validation_Bypass');
    addMLCRMUserPS(ccrmBatchUser.id, 'CCRM_User_Base');
    addMLCRMUserPS(ccrmBatchUser.id, 'MLCRM_Base_Read_Only');
    return ccrmBatchUser;
  }

  /**
   * @description Create ContactPointPhone Records for MLCRM Testing
   * @name createContactPointPhoneRecords
   * @param count Count of ContactPointPhone records needed to be created
   * @param telephoneNumber  Telephone Number of the contact Point phone
   * @param  parentId parent id
   * @param usageType  Usage Type (Home/Mobile/Work)
   * @return `List<ContactPointPhone>`
   */
  public static List<ContactPointPhone> getContactPointPhoneRecords(
    Integer count,
    String telephoneNumber,
    String parentId,
    String usageType
  ) {
    //Default Count to 1 if null
    count = count == null || count == 0 ? 1 : count;
    List<ContactPointPhone> contactPointPhonesList = new List<ContactPointPhone>();
    for (Integer i = 1; i <= count; i++) {
      ContactPointPhone testContactPointPhone = new ContactPointPhone();
      testContactPointPhone.TelephoneNumber = telephoneNumber;
      testContactPointPhone.ParentId = parentId;
      testContactPointPhone.UsageType = usageType;
      testContactPointPhone.Recordtypeid = Schema.SObjectType.ContactPointPhone.getRecordTypeInfosByDeveloperName()
        .get(MLCRMConstants.INDIVIDUAL_RT)
        .getRecordTypeId();
      contactPointPhonesList.add(testContactPointPhone);
    }
    return contactPointPhonesList;
  }

  /**
   * @description Create  Territory share Records for MLCRM Testing
   * @name createTerritoryShare
   * @param userId territory user to share with.
   * @param territoryList list of territory records
   * @param doInsert Whether or not to insert the records
   * @return `List<Territory__Share>`  territory share records
   */
  public static List<Territory__Share> createTerritoryShare(
    Id userId,
    List<Territory__c> territoryList,
    Boolean doInsert
  ) {
    List<Territory__Share> lstOfTerritoryShare = new List<Territory__Share>();
    for (Integer i = 0; i < territoryList.size(); i++) {
      Territory__Share objShare = new Territory__Share();
      objShare.parentId = territoryList[i].id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = userId;
      //objShare.RowCause = 'Manual';
      lstOfTerritoryShare.add(objShare);
    }
    if (doInsert) {
      Database.insert(lstOfTerritoryShare);
    }
    return lstOfTerritoryShare;
  }

  /**
   * @description Create  Territory share Records for MLCRM Testing
   * @name createTerritoryShareWithMultipleUsers
   * @param territoryRecord territory record to share with users
   * @param userIds territory users to share with.
   * @param doInsert Whether or not to insert the records
   * @return `List<Territory__Share>`  territory share records
   */
  public static List<Territory__Share> createTerritoryShareWithMultipleUsers(
    Territory__c territoryRecord,
    Set<ID> userIds,
    Boolean doInsert
  ) {
    List<Territory__Share> lstOfTerritoryShare = new List<Territory__Share>();
    for (Id userId : userIds) {
      Territory__Share objShare = new Territory__Share();
      objShare.parentId = territoryRecord.id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = userId;
      lstOfTerritoryShare.add(objShare);
    }
    if (doInsert) {
      Database.insert(lstOfTerritoryShare);
    }
    return lstOfTerritoryShare;
  }

  /**
   * @description Create Lead share Records for MLCRM Testing
   * @name createLeadShare
   * @param userId Lead user to share with.
   * @param leadList list of Lead records
   * @param doInsert Whether or not to insert the records
   * @return `List<LeadShare>`  Lead share records
   */
  public static List<LeadShare> createLeadShare(
    Id userId,
    List<Lead> leadList,
    Boolean doInsert
  ) {
    List<LeadShare> leadShareList = new List<LeadShare>();
    for (Integer i = 0; i < leadList.size(); i++) {
      LeadShare objShare = new LeadShare();
      objShare.LeadId = leadList[i].id;
      objShare.LeadAccesslevel = 'Edit';
      objShare.userOrgroupid = userId;
      objShare.RowCause = 'Manual';
      leadShareList.add(objShare);
    }
    if (doInsert) {
      Database.insert(leadShareList);
    }
    return leadShareList;
  }
}
