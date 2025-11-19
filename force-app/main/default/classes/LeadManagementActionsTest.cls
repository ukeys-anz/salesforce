/**
 * @author Naman Garg
 * @since Jun 2025
 * @description LeadManagementActionsTest is the test class for LeadManagementActions Class functionality.
 */
@isTest
private class LeadManagementActionsTest {
  static Lib_MockProvider leadActionRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userActionsRepositoryMock;
  static String statusAssigned = 'Assigned';
  static String statusCompleted = 'Completed';
  static String originatorUnica = 'UNICA';
  static Id ccrmLeadRtId = RTLead.commercialLead;
  static Id mlcrmLeadRtId = RTLead.mlcrmLead;
  static Id leadResponseRtId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Lead_Response')
    .getRecordTypeId();
  static Id azReviewRtId = Schema.SObjectType.A_Z_Review__c.getRecordTypeInfosByDeveloperName()
    .get('Commercial_A_Z_Review')
    .getRecordTypeId();

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadActionRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
    userActionsRepositoryMock = Lib_MockProvider.forType(
      UserActionsRepository.class
    );
  }

  @testSetup
  static void setup() {
    CCRMTestDataFactory.createAdobeIntegrationUser();
    CCRMTestDataFactory.createUnicaIntegrationUser();
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();

    //CREATE Test Lead Records
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmUser
      );
      List<Campaign> campaignRecord = CCRMTestDataFactory.createCCRMCampaignRecord(
        1
      );
      CCRMTestDataFactory.createResponseTypeRecords(campaignRecord[0]);
    }
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      );
      MLCRMTestDataFactory.createTerritoryShare(
        mlUser.id,
        lstOfTerritory,
        true
      );
    }
    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(iiQUser) {
      createUsersWithEmployeeID();
      Test.startTest();
      mlUser.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser.ML_Role__c = 'Loan Writer';
      update mlUser;
      Test.stopTest();
    }
    //CREATE Test Lead Records
    System.runAs(mlUser) {
      MLCRMTestDataFactory.createManualLeadRecords(10, mlUser, true);
    }
  }

  @isTest
  static void testExpiryDateWhenOwnerChanged() {
    //GIVEN leads
    Lead[] leads = [
      SELECT Id, OwnerId, Expiry_Date__c, Followup_Date__c, RecordTypeId, Status
      FROM Lead
    ];
    Lead[] oldLeads = leads.deepClone(true, true, true);

    //WHEN Owner Changed
    Test.startTest();
    for (Lead lead : leads) {
      lead.OwnerId = UserInfo.getUserId();
      lead.Expiry_Date__c = DateTimeUtils.getWeekday(
        Date.today().addDays(3),
        true,
        false
      );
    }
    MobileLendingLeadActions.setExpiryDate(leads, new Map<Id, Lead>(oldLeads));
    Test.stopTest();

    //THEN
    Date newExpiryDate = DateTimeUtils.getWeekday(
      Date.today().addDays(3),
      true,
      false
    );
    for (Lead lead : leads) {
      System.assertEquals(
        lead.Expiry_Date__c,
        newExpiryDate,
        'Expiry date updated correctly'
      );
    }
  }

  @isTest
  static void testCreateLeadsWithUsersWithCPID() {
    Test.startTest();
    //Controlling Posts
    Controlling_Post__c cp1 = new Controlling_Post__c();
    cp1.Is_Active__c = true;
    cp1.CPID__c = 'L4567';
    cp1.Name = 'L4567';
    cp1.Responsible_Employee_Id__c = '00456789';

    Controlling_Post__c cp2 = new Controlling_Post__c();
    cp2.Is_Active__c = true;
    cp2.CPID__c = 'L5678';
    cp2.Name = 'L5678';
    cp2.Responsible_Employee_Id__c = '00567890';

    Controlling_Post__c cp3 = new Controlling_Post__c();
    cp3.Is_Active__c = true;
    cp3.CPID__c = null;
    cp3.Name = 'No CPID';
    cp3.Responsible_Employee_Id__c = '00678901';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      insert new List<SObject>{ cp1, cp2, cp3 };
    }

    User ccrmUser = [
      SELECT id
      FROM User
      WHERE Employee_Id__c = '00456789'
      LIMIT 1
    ];

    User ccrmUser2 = [
      SELECT id
      FROM User
      WHERE Employee_Id__c = '00567890'
      LIMIT 1
    ];

    User ccrmUser3 = [
      SELECT id
      FROM User
      WHERE Employee_Id__c = '00678901'
      LIMIT 1
    ];

    //Leads
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam1@test.com';
    leadRecord.RecordTypeId = ccrmLeadRtId;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Commercial Lending';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam1';
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'CCRM';
    leadRecord.Status = statusAssigned;
    leadRecord.OwnerId = ccrmUser.Id;

    Lead leadRecord2 = new Lead();
    leadRecord2.Email = 'sam2@test.com';
    leadRecord2.RecordTypeId = ccrmLeadRtId;
    leadRecord2.Description = 'Need a new Credit Card';
    leadRecord2.Registered_Company__c = 'No';
    leadRecord2.Expiry_Date__c = System.today() + 10;
    leadRecord2.FinServ__ExpressedInterest__c = 'Commercial Lending';
    leadRecord2.FinServ__PotentialValue__c = 12000;
    leadRecord2.FirstName = 'Sam2';
    leadRecord2.LastName = 'Jacob';
    leadRecord2.LeadSource = 'Partner';
    leadRecord2.New_to_Bank__c = 'Yes';
    leadRecord2.Lead_Originator__c = 'CCRM';
    leadRecord2.Status = statusAssigned;
    leadRecord2.OwnerId = ccrmUser2.Id;

    Lead leadRecord3 = new Lead();
    leadRecord3.Email = 'sam3@test.com';
    leadRecord3.RecordTypeId = ccrmLeadRtId;
    leadRecord3.Description = 'Need a new Credit Card';
    leadRecord3.Registered_Company__c = 'No';
    leadRecord3.Expiry_Date__c = System.today() + 10;
    leadRecord3.FinServ__ExpressedInterest__c = 'Commercial Lending';
    leadRecord3.FinServ__PotentialValue__c = 12000;
    leadRecord3.FirstName = 'Sam3';
    leadRecord3.LastName = 'Jacob';
    leadRecord3.LeadSource = 'Partner';
    leadRecord3.New_to_Bank__c = 'Yes';
    leadRecord3.Lead_Originator__c = 'CCRM';
    leadRecord3.Status = statusAssigned;
    leadRecord3.OwnerId = ccrmUser3.Id;

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMControllingPostActions.retrieveControllingPost(
        new List<Lead>{ leadRecord, leadRecord2, leadRecord3 },
        null
      );
    }

    //asserting leadRecord
    System.assertEquals(cp1.CPID__c, leadRecord.CPID__c, 'CPID is equal');
    System.assertEquals(
      cp1.id,
      leadRecord.Controlling_Post__c,
      'Controlling Post is Set'
    );
    System.assertEquals(ccrmUser.Id, leadRecord.CPID_Owner__c, 'Owner is Set');

    //asserting leadRecord2
    System.assertEquals(cp2.CPID__c, leadRecord2.CPID__c, 'CPID is Equal');
    System.assertEquals(
      cp2.id,
      leadRecord2.Controlling_Post__c,
      'Controlling Post is Set'
    );
    System.assertEquals(
      ccrmUser2.Id,
      leadRecord2.CPID_Owner__c,
      'Owner is Set'
    );

    //asserting leadRecord3
    System.assertEquals(
      cp2.CPID__c,
      leadRecord3.CPID__c,
      'CPID is Manager CPID'
    );
    System.assertEquals(
      ccrmUser2.Id,
      leadRecord3.CPID_Owner__c,
      'Owner is Set'
    );
    System.assertEquals(
      cp2.id,
      leadRecord3.Controlling_Post__c,
      'Controlling Post is Set'
    );
    Test.stopTest();
  }

  private static void createUsersWithEmployeeID() {
    //Roles and Permission Sets
    UserRole bankerRole = CommonUtil.getUserRoleByDevName('Banker');
    UserRole bankerManagerRole = CommonUtil.getUserRoleByDevName(
      'Banker_Line_Manager'
    );
    PermissionSet ps = CommonUtil.getPermissionSetByName('CCRM_User_Base');

    //User 1
    User ccrmUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmUser.UserRoleId = bankerRole.Id;
    ccrmUser.ProfileId = UserInfo.getProfileId();
    ccrmUser.Employee_Id__c = '00456789';
    insert ccrmUser;

    PermissionSetAssignment psa1 = TestUtil.createPSAssignment(
      ccrmUser.id,
      ps.Id
    );
    insert psa1;

    //User 2
    User ccrmUser2 = (User) FakerFactory.make(new FakerUserFactory());
    ccrmUser2.UserRoleId = bankerManagerRole.Id;
    ccrmUser2.ProfileId = UserInfo.getProfileId();
    ccrmUser2.Employee_Id__c = '00567890';
    insert ccrmUser2;

    PermissionSetAssignment psa2 = TestUtil.createPSAssignment(
      ccrmUser2.id,
      ps.Id
    );
    insert psa2;

    //User 3
    User ccrmUser3 = (User) FakerFactory.make(new FakerUserFactory());
    ccrmUser3.ManagerId = ccrmUser2.id;
    ccrmUser3.UserRoleId = bankerRole.Id;
    ccrmUser3.ProfileId = UserInfo.getProfileId();
    ccrmUser3.Employee_Id__c = '00678901';
    insert ccrmUser3;

    PermissionSetAssignment psa3 = TestUtil.createPSAssignment(
      ccrmUser3.id,
      ps.Id
    );
    insert psa3;
  }

  static void testPrefillLeadFieldsFromCustomerAccount() {
    //GIVEN leads
    List<Lead> leads = [SELECT Id FROM Lead];

    //WHEN
    leads = CCRMTestDataFactory.createLeadRecordsWithCustomerRelatedParty(
      leads
    );

    //THEN
    List<Lead> updatedLeads = [SELECT Id, ABN__c FROM Lead];
    System.assertEquals(
      updatedLeads[0].ABN__c,
      '50 110 219 460',
      'ABN updated correctly'
    );
  }

  @isTest
  static void prefillManualLeadsFromAccountTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead adobeLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      FinServ__RelatedAccount__c = accId,
      Lead_Originator__c = 'Adobe'
    );
    Lead adobeLeadOld = new Lead(
      Id = adobeLead.Id,
      RecordTypeId = ccrmLeadRtId,
      FinServ__RelatedAccount__c = accId,
      Lead_Originator__c = 'Adobe'
    );
    Lead mlcrmLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = 'CCRM'
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ adobeLeadOld.Id => adobeLeadOld };
    Test.startTest();
    LeadManagementActions.prefillManualLeadsFromAccountOnUpdate(
      new List<Lead>{ adobeLead },
      oldMap
    );
    LeadManagementActions.prefillManualLeadsFromAccountOnInsert(
      new List<Lead>{ mlcrmLead }
    );
    Test.stopTest();
    //As platform event will be published to Mule, doing assert only for code coverage
    Assert.areEqual(
      adobeLead.Lead_Originator__c,
      'Adobe',
      'Lead Originator is not adobe'
    );
  }

  @isTest
  static void testLeadPlatformEventsSuccessfullyByAdminUnica() {
    // GIVEN
    Test.startTest();
    List<Lead> leads = [
      SELECT Id, LeadSource, recordTypeId
      FROM Lead
      WHERE RecordType.DeveloperName = 'CCRM_Lead'
    ];
    for (Lead record : leads) {
      record.Lead_Originator__c = 'CCRM';
      record.New_to_Bank__c = 'No';
      record.Company = 'ABC Company';
      record.Registered_Company__c = 'No';
    }
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update leads;
      leads = CCRMTestDataFactory.createLeadRecordsWithCustomerRelatedParty(
        leads
      );
    }

    //WHEN
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leads[0].Id);
    CCRMLeadPlatformEventActions.resendManualLeadPlatformEvent(leadIds);

    // THEN
    // As platform event will be published to Mule, doing assert only for code coverage
    System.assertEquals(
      leads[0].LeadSource,
      'Partner',
      'Lead source should match.'
    );
    Test.stopTest();
  }

  @IsTest
  static void testValidateUnicaLeadExpiryDate() {
    //GIVEN new UNICA lead without expiry date info
    User adobeUser = [
      SELECT Id
      FROM User
      WHERE username = 'adobe.integration@anzx.com.unittest'
    ];
    Lead leadWithNoExpiryDate = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      OwnerId = adobeUser.Id
    );

    Test.startTest();
    //WHEN validated
    CCRMLeadUtil.validateUnicaLeads(new List<Lead>{ leadWithNoExpiryDate });
    Test.stopTest();

    //THEN expiry date validation error will be added
    System.assert(
      leadWithNoExpiryDate.hasErrors(),
      'Record should have validation error'
    );
    System.assertEquals(
      CCRMLeadUtil.EXPIRY_DATE_MISSING_ERROR_MESSAGE,
      leadWithNoExpiryDate.getErrors()[0].getMessage(),
      'Expiry date validation error should be added to record'
    );
  }

  /*@IsTest
  static void testValidateUnicaLeadCustomerLinking() {
    Test.startTest();
    Account acc = CCRMTestDataFactory.createBusinessAccount();
    String invalidId = 'invalidId';
    Campaign campaign = [SELECT Code__c FROM Campaign LIMIT 1];

    //GIVEN some UNICA lead with invalid campaign code or account Source System ID
    Lead leadWithInvalidCampaignCode = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c + 'invalid'
    );
    Lead leadWithValidCustomerId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      Customer_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidCustomerId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      Customer_ID__c = invalidId
    );
    Lead leadWithValidClgId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      CLG_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidClgId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      CLG_ID__c = invalidId
    );
    Lead leadWithValidBusinessId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      Business_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidBusinessId = new Lead(
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = originatorUnica,
      Campaign_Code__c = campaign.Code__c,
      Business_ID__c = invalidId
    );

    User unicaIntegrationUser = [
      SELECT Id
      FROM User
      WHERE username = 'unica.integration@anzx.com.unittest'
      LIMIT 1
    ];

    //WHEN validated
    System.runAs(unicaIntegrationUser) {
      LeadManagementActions.populateFields(
        new List<Lead>{
          leadWithInvalidCampaignCode,
          leadWithValidCustomerId,
          leadWithInvalidCustomerId,
          leadWithValidClgId,
          leadWithInvalidClgId,
          leadWithValidBusinessId,
          leadWithInvalidBusinessId
        }
      );
    }

    //THEN leads with no matching campaign or related account will fail validation
    System.assert(
      leadWithInvalidCampaignCode.hasErrors(),
      'Lead with invalid campaign code should fail validation'
    );
    System.assert(
      leadWithInvalidCustomerId.hasErrors(),
      'Lead with invalid Customer ID should fail validation'
    );
    System.assert(
      leadWithInvalidClgId.hasErrors(),
      'Lead with invalid CLG ID should fail validation'
    );
    System.assert(
      leadWithInvalidBusinessId.hasErrors(),
      'Lead with invalid Business ID should fail validation'
    );
    Test.stopTest();
  }*/

  @isTest
  static void testLeadCreatedByAdobeUserWithNoOwnerShouldFail() {
    //GIVEN
    User adobeUser = [
      SELECT Id
      FROM User
      WHERE username = 'adobe.integration@anzx.com.unittest'
    ];
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam21@test.com';
    leadRecord.RecordTypeId = ccrmLeadRtId;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Commercial Lending';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Adobe Ingested';
    leadRecord.LastName = 'Lead1';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Status = statusAssigned;

    System.runAs(adobeUser) {
      try {
        //WHEN
        Test.startTest();
        insert leadRecord;
        Test.stopTest();
      } catch (Exception ex) {
        //THEN
        if (
          ex.getMessage()
            .contains(CCRMLeadUtil.ADOBE_LEAD_OWNER_MISSING_ERROR_MESSAGE)
        ) {
          System.assert(true, 'Error message displayed');
        } else {
          System.assert(false, 'Incorrect error message');
        }
      }
    }

  }

  @isTest
  static void testLeadCreatedByUnicaUserWithNoOwnerShouldFail() {
    //GIVEN
    User unicaUser = [
      SELECT Id
      FROM User
      WHERE username = 'unica.integration@anzx.com.unittest'
    ];
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam1@test.com';
    leadRecord.RecordTypeId = ccrmLeadRtId;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Commercial Lending';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Unica Ingested';
    leadRecord.LastName = 'Lead';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'UNICA';
    leadRecord.Status = statusAssigned;

    System.runAs(unicaUser) {
      try {
        //WHEN
        Test.startTest();
        insert leadRecord;
        Test.stopTest();
      } catch (Exception ex) {
        //THEN
        if (
          ex.getMessage()
            .contains(CCRMLeadUtil.UNICA_LEAD_OWNER_MISSING_ERROR_MESSAGE)
        ) {
          System.assert(true, 'Error message displayed');
        } else {
          System.assert(false, 'Incorrect error message');
        }
      }
    }
  }

  @isTest
  static void testLeadCreatedWithDefaultCampaign() {
    //GIVEN when I create a Lead
    //When the lead is manually created
    //Then campaign value is set to default
    Test.startTest();
    Id leadId;
    Campaign campaign;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      campaign = [
        SELECT Id
        FROM Campaign
        WHERE Code__c = :System.Label.Commercial_DefaultCampaign
        LIMIT 1
      ];
    }

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam1@test.com';
      leadRecord.RecordTypeId = ccrmLeadRtId;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Registered_Company__c = 'No';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Commercial Lending';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Default';
      leadRecord.LastName = 'Campaign';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Lead_Originator__c = 'CCRM';
      leadRecord.Status = statusAssigned;
      leadRecord.Company = 'ABC Company';
      leadRecord.Registered_Company__c = 'No';

      insert leadRecord;
      leadId = leadRecord.Id;
    }

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      List<CampaignMember> members = [
        SELECT Id
        FROM CampaignMember
        WHERE CampaignId = :campaign.Id AND LeadId = :leadId
      ];
      System.assert(!members.isEmpty(), 'Campaign Member was created');
    }
    Test.stopTest();
  }

  @isTest
  static void testMLLeadCreationWithReferrerEmail() {
    Test.startTest();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    System.runAs(iiQUser) {
      Id adminProfileId = CommonUtil.getProfileByName('System Administrator')
        .Id;
      USER usr = (USER) FakerFactory.make(new FakerUserFactory());
      usr.Email = 'test@mltest.anz.com';
      usr.ProfileId = adminProfileId;
      usr.UserRoleId = CommonUtil.getUserRoleByDevName('Banker').Id;
      insert usr;
    }
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.Referrer_Email__c = 'test@mltest.anz.com';
      leadRec.Referrer_Name__c = 'Test Referrer Name';
      leadRec.LeadSource = MLCRMConstants.INTERNAL_REFERRAL;
      insert leadRec;

      User testUser1 = [
        SELECT id, Email
        FROM User
        WHERE Email = 'test@mltest.anz.com'
        LIMIT 1
      ];
      Lead leadRecord = [
        SELECT id, FinServ__ReferredByUser__c
        FROM lead
        WHERE id = :leadRec.id
        LIMIT 1
      ];
      System.assertEquals(
        leadRecord.FinServ__ReferredByUser__c,
        testUser1.Id,
        'Referrrer is populated'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testMLLeadCreationWithoutExistingReferrer() {
    Test.startTest();
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.Referrer_Email__c = 'test@mltest2.anz.com';
      leadRec.Referrer_Name__c = 'Test Referrer Name';
      leadRec.LeadSource = MLCRMConstants.INTERNAL_REFERRAL;
      insert leadRec;

      Lead leadRecord = [
        SELECT id, FinServ__ReferredByUser__c
        FROM lead
        WHERE id = :leadRec.id
        LIMIT 1
      ];
      System.assertEquals(
        leadRecord.FinServ__ReferredByUser__c,
        null,
        'Referrrer is not found'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testBulkMLLeadCreation() {
    Test.startTest();
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      List<Lead> leadsList = new List<Lead>();
      for (Integer i = 0; i < 50; i++) {
        leadsList.add((Lead) FakerFactory.make(new FakerLeadFactory()));
      }
      insert leadsList;
      System.assertEquals(leadsList.Size(), 50, 'All ML leads created');
      for (Lead objLead : leadsList) {
        System.assertEquals(
          objLead.Lead_Auto_Number__c,
          objLead.Lead_Id__c,
          'Lead ID should be equals to Lead AutoNumber'
        );
      }
    }
    Test.stopTest();
  }

  @isTest
  static void updateLeadStatusTest() {
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      isNewLead__c = false
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      isNewLead__c = false
    );
    List<Lead> leadRecords = new List<Lead>{ lead1, lead2 };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      lead1.Id => new Lead(
        Id = lead1.Id,
        RecordTypeId = ccrmLeadRtId,
        Status = 'New'
      ),
      lead2.Id => new Lead(
        Id = lead2.Id,
        RecordTypeId = mlcrmLeadRtId,
        Status = 'Complete'
      )
    };
    Test.startTest();
    LeadManagementActions.updateLeadStatus(leadRecords, oldMap);
    Test.stopTest();
    Assert.areEqual(
      'New',
      lead2.Status,
      'testblankFollowUpDateOnLeadConvert is updating status of wrong record'
    );
    Assert.areEqual(
      'In progress',
      lead1.Status,
      'testblankFollowUpDateOnLeadConvert is not updating status'
    );
  }

  @isTest
  static void testMLLeadCreationWithReferrer() {
    Test.startTest();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    System.runAs(iiQUser) {
      Id adminProfileId = CommonUtil.getProfileByName('System Administrator')
        .Id;
      USER usr = (USER) FakerFactory.make(new FakerUserFactory());
      usr.Email = 'test@mltest.anz.com';
      usr.ProfileId = adminProfileId;
      usr.UserRoleId = CommonUtil.getUserRoleByDevName('Banker').Id;
      insert usr;
    }
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      User testUser1 = [
        SELECT id, Email
        FROM User
        WHERE Email = 'test@mltest.anz.com'
        LIMIT 1
      ];
      leadRec.FinServ__ReferredByUser__c = testUser1.Id;
      insert leadRec;

      Lead leadRecord = [
        SELECT id, Referrer_Email__c
        FROM lead
        WHERE id = :leadRec.id
        LIMIT 1
      ];
      System.assertEquals(
        leadRecord.Referrer_Email__c,
        testUser1.Email,
        'Referrrer is populated'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testsetCustomerOnA2ZReview() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Account testAccount = CCRMTestDataFactory.createProspectBusinessAccount(
        ccrmBaseUser.Id
      );
      Lead testLead = CCRMTestDataFactory.createLeadRecords(
        1,
        ccrmBaseUser,
        true
      )[0];
      A_Z_Review__c testA2ZReview = new A_Z_Review__c(
        Name = 'A-Z Review Record',
        Status__c = 'In Progress',
        RecordTypeId = azReviewRtId,
        OwnerId = ccrmBaseUser.Id,
        Lead__c = testLead.Id
      );
      insert testA2ZReview;

      Lead testLeadNew = testLead;
      testLeadNew.FinServ__RelatedAccount__c = testAccount.Id;

      Test.startTest();
      update testLeadNew;
      Test.stopTest();

      A_Z_Review__c updatedReview = [
        SELECT Id, Name, Lead__c, Opportunity__c, Customer__c
        FROM A_Z_Review__c
        WHERE Id = :testA2ZReview.Id
      ];

      System.assertEquals(
        testAccount.Id,
        updatedReview.Customer__c,
        'Customer__c should be set to the Account'
      );
    }
  }

  @isTest
  static void testblankFollowUpDateOnLeadConvert() {
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Status = 'Converted',
      Followup_Date__c = System.Today()
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Status = 'Converted',
      Followup_Date__c = System.Today()
    );
    Lead lead3 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Followup_Date__c = System.Today()
    );
    List<Lead> leadRecords = new List<Lead>{ lead1, lead2, lead3 };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      lead1.Id => new Lead(
        Id = lead1.Id,
        RecordTypeId = ccrmLeadRtId,
        Status = 'New'
      ),
      lead2.Id => new Lead(
        Id = lead2.Id,
        RecordTypeId = mlcrmLeadRtId,
        Status = 'New'
      ),
      lead3.Id => lead3
    };
    Test.startTest();
    LeadManagementActions.blankFollowUpDateOnLeadConvert(oldMap, leadRecords);
    Test.stopTest();
    Assert.isNull(
      leadRecords[0].Followup_Date__c,
      'blankFollowUpDateOnLeadConvert is not setting follow up date to null for CCRM lead'
    );
    Assert.isNull(
      leadRecords[1].Followup_Date__c,
      'blankFollowUpDateOnLeadConvert is not setting follow up date to null for MLCRM lead'
    );
    Assert.isNotNull(
      leadRecords[2].Followup_Date__c,
      'blankFollowUpDateOnLeadConvert is setting follow up date to null for unwanted lead'
    );
  }

  @isTest
  static void testCopyLeadId() {
    registerMocks();
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Lead_Id__c = 'null'
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Lead_Id__c = '123456'
    );
    List<Lead> leadRecords = new List<Lead>{ lead1, lead2 };
    Test.startTest();
    LeadManagementActions.copyLeadId(leadRecords);
    Test.stopTest();
    List<Lead> updatedLeadRecords = (List<Lead>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      updatedLeadRecords.size(),
      'copyLeadId is not updating records correctly'
    );
    Assert.areEqual(
      updatedLeadRecords[0].Lead_Id__c,
      updatedLeadRecords[0].Lead_Auto_Number__c,
      'copyLeadId is not updating LeadId correctly'
    );
  }

  @isTest
  static void testPopulateFromPreviousLead() {
    registerMocks();
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Country = 'Australia'
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Email = 'Test@anz.com'
    );
    Lead lead3 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Previous_Lead__c = lead1.Id
    );
    Lead lead4 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Previous_Lead__c = lead2.Id
    );
    List<Lead> leadRecords = new List<Lead>{ lead3, lead4 };
    leadActionRepoMock.mock('getLeadData', new List<Lead>{ lead1, lead2 });
    Test.startTest();
    LeadManagementActions.populateFromPreviousLead(leadRecords);
    Test.stopTest();
    Assert.areEqual(
      leadRecords[0].Country,
      lead1.Country,
      'populateFromPreviousLead is not populating country correctly'
    );
    Assert.areEqual(
      leadRecords[1].Email,
      lead2.Email,
      'populateFromPreviousLead is not populating email correctly'
    );
  }

  @isTest
  static void testGetPreviousLeadRecords() {
    registerMocks();
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = mlcrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Country = 'Australia'
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = ccrmLeadRtId,
      Lead_Originator__c = 'Adobe',
      Email = 'Test@anz.com'
    );
    leadActionRepoMock.mock('getLeadData', new List<Lead>{ lead1, lead2 });
    Test.startTest();
    Map<Id, Lead> previousLeadMap = LeadManagementActions.getPreviousrecords(
      new Set<Id>{ lead1.Id, lead2.Id },
      Schema.SObjectType.Lead.fieldSets.CCRM_Previous_Lead_Fields.getFields()
    );
    Test.stopTest();
    Assert.areEqual(
      previousLeadMap.keySet().size(),
      2,
      'getPreviousLeadRecordsTest is not returning correct lead records'
    );
  }

  @isTest
  static void setDuplicateBlockTest() {
    Id leadId1 = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id leadId2 = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Lead newRec1 = new Lead(
      Id = leadId1,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'In progress'
    );
    Lead oldRec1 = new Lead(
      Id = leadId1,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New'
    );
    Lead newRec2 = new Lead(
      Id = leadId2,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New'
    );
    Lead oldRec2 = new Lead(
      Id = leadId2,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New'
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      oldRec1.Id => oldRec1,
      oldRec2.Id => oldRec2
    };
    Test.startTest();
    LeadManagementActions.setDuplicateBlock(
      new List<Lead>{ newRec1, newRec2 },
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      'Yes',
      newRec1.CCRM_Duplicate_Block_Check__c,
      'setDuplicateBlock is not updating duplicate block'
    );
    Assert.isNull(
      newRec2.CCRM_Duplicate_Block_Check__c,
      'setDuplicateBlock is updating duplicate block for wrong record'
    );
  }

  @isTest
  static void removeValidationStatusTest() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Lead newRec = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      ABN__c = '',
      ACN__c = '',
      ABN_Validation_Status__c = 'test',
      ACN_Validation_Status__c = 'test'
    );
    Lead oldRec = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'Complete',
      ABN__c = '123',
      ACN__c = '456'
    );

    Test.startTest();
    AbnAcnServiceActions.removeValidationStatus(
      new List<Lead>{ newRec },
      new Map<Id, Lead>{ leadId => oldRec }
    );
    Test.stopTest();
    Assert.areEqual(
      '',
      newRec.ABN_Validation_Status__c,
      'removeValidationStatus is not updating ABN_Validation_Status__c'
    );
    Assert.areEqual(
      '',
      newRec.ACN_Validation_Status__c,
      'removeValidationStatus is not updating ACN_Validation_Status__c'
    );
  }

  @isTest
  static void setValidationStatusTest() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Lead newRecWithCompany = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      ABN__c = '321',
      ACN__c = '654',
      Registered_Company__c = 'Yes'
    );
    Lead oldRecWithCompany = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'Complete',
      ABN__c = '123',
      ACN__c = '456',
      Registered_Company__c = 'Yes'
    );
    Lead newRecWithouCompany = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      ABN__c = '321',
      ACN__c = '654',
      Registered_Company__c = 'No'
    );
    Lead oldRecWithoutCompany = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'Complete',
      ABN__c = '123',
      ACN__c = '456',
      Registered_Company__c = 'No'
    );
    Test.startTest();
    AbnAcnServiceActions.setValidationStatus(
      new List<Lead>{ newRecWithCompany },
      new Map<Id, Lead>{ leadId => oldRecWithCompany }
    );
    AbnAcnServiceActions.setValidationStatus(
      new List<Lead>{ newRecWithouCompany },
      new Map<Id, Lead>{ leadId => oldRecWithoutCompany }
    );
    Test.stopTest();
    Assert.areEqual(
      '',
      newRecWithCompany.ABN_Validation_Status__c,
      'setValidationStatus is not updating abn validation status'
    );
    Assert.areEqual(
      '',
      newRecWithCompany.ACN_Validation_Status__c,
      'setValidationStatus is not updating acn validation status'
    );
    Assert.isNull(
      newRecWithouCompany.ABN_Validation_Status__c,
      'setValidationStatus is updating abn validation for wrong lead'
    );
    Assert.isNull(
      newRecWithouCompany.ACN_Validation_Status__c,
      'setValidationStatus is updating acn validation for wrong lead'
    );
  }

  @isTest
  static void makeAcnCalloutTest() {
    registerMocks();
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Test.startTest();
    AbnAcnServiceActions.makeAcnCallout('005357522', leadId);
    Test.stopTest();
    Lead updatedLeadRecord = (Lead) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(
      updatedLeadRecord,
      'makeAcnCallout is not updating leads correctly'
    );
    Assert.areEqual(
      'Active',
      updatedLeadRecord.ACN_Validation_Status__c,
      'makeAcnCallout is not updating leads correctl'
    );
  }

  @isTest
  static void makeAbnCalloutTest() {
    registerMocks();
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Test.startTest();
    AbnAcnServiceActions.makeAbnCallout('005357522', leadId);
    Test.stopTest();
    Lead updatedLeadRecord = (Lead) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(
      updatedLeadRecord,
      'makeAcnCallout is not updating leads correctly'
    );
    Assert.areEqual(
      'Active',
      updatedLeadRecord.ABN_Validation_Status__c,
      'makeAcnCallout is not updating leads correctl'
    );
  }

  @isTest
  static void validateAbnAcnForCalloutTest() {
    registerMocks();
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      ABN__c = '005357522',
      ACN__c = '005357522',
      Registered_Company__c = 'Yes'
    );
    Test.startTest();
    AbnAcnServiceActions.validateAbnAcnForCallout(
      new List<Lead>{ leadRec },
      null
    );
    Test.stopTest();
    Lead updatedLeadRecord = (Lead) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(
      updatedLeadRecord,
      'makeAcnCallout is not updating leads correctly'
    );
    Assert.areEqual(
      'Active',
      updatedLeadRecord.ABN_Validation_Status__c,
      'makeAcnCallout is not updating leads correctly'
    );
  }

  @isTest
  static void sendLeadUpdateToUnicaOrAdobeTest() {
    registerMocks();
    userActionsRepositoryMock.mock('isIntegrationUser', false);
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = userId, Lan_Id__c = 'test123')
      }
    );
    Lead newLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'Complete',
      Lead_Originator__c = 'Adobe',
      ownerId = userId
    );
    Lead oldLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Lead_Originator__c = 'Adobe',
      ownerId = userId
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };
    Test.startTest();
    LeadManagementActions.sendLeadUpdateToUnicaOrAdobe(
      new List<Lead>{ newLead },
      oldMap
    );
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'sendLeadUpdateToUnicaOrAdobe did not published Event successfully'
    );
  }

  @isTest
  static void publishLeadResponseUpdateToAdobeOrUnicaTest() {
    registerMocks();
    userActionsRepositoryMock.mock('isIntegrationUser', false);

    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Task taskRecord = new Task(
      whoId = leadId,
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType)
    );
    leadActionRepoMock.mock(
      new Map<String, Object>{
        'getTaskRecords' => new List<Task>{ taskRecord },
        'getLeadResponseToPlatformEventMappingMetadata' => new List<CCRM_Lead_Response_Event_Mapping__mdt>{
          new CCRM_Lead_Response_Event_Mapping__mdt(
            Object__c = 'Task',
            Platform_Event_Field_API_Name__c = 'Activity_Date__c',
            Task_or_Lead_Field_API_Name__c = 'ActivityDate'
          )
        }
      }
    );
    Lead newLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Lead_Originator__c = 'Adobe',
      SubStatus__c = 'Accepted',
      ownerId = userId
    );
    Lead oldLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Lead_Originator__c = 'Adobe',
      SubStatus__c = 'Referral Made',
      ownerId = userId
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };

    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = userId, Lan_Id__c = 'test123')
      }
    );
    Test.startTest();
    LeadManagementActions.publishLeadResponseUpdateToAdobeOrUnica(
      new List<Lead>{ newLead },
      oldMap
    );
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'publishLeadResponseUpdateToAdobeOrUnica did not published Event successfully'
    );
  }

  @isTest
  static void sendManualLeadsToUnicaTest() {
    registerMocks();
    userActionsRepositoryMock.mock('isIntegrationUser', false);

    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Task taskRecord = new Task(
      whoId = leadId,
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType)
    );
    leadActionRepoMock.mock('getTaskRecords', new List<Task>{ taskRecord });
    Lead newLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Lead_Originator__c = 'UNICA',
      SubStatus__c = 'Accepted',
      ownerId = userId
    );
    Lead oldLead = new Lead(
      Id = leadId,
      RecordTypeId = mlcrmLeadRtId,
      Status = 'New',
      Lead_Originator__c = 'UNICA',
      SubStatus__c = 'Referral Made',
      ownerId = userId
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };

    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = userId, Lan_Id__c = 'test123')
      }
    );
    Test.startTest();
    LeadManagementActions.sendManualLeadsToUnica(
      new List<Lead>{ newLead },
      oldMap
    );
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'sendManualLeadsToUnica did not published Event successfully'
    );
  }
}
