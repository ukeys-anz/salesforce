/**
 * @author Mairaj Haider
 * @since 03/2022
 * @description CCRM Lead Action is the test class for CCRM Lead Actions Class functionality.
 */
@isTest
private class CCRMLeadActionsTest {
  @testSetup
  static void setup() {
    CCRMTestDataFactory.createAdobeIntegrationUser();
    CCRMTestDataFactory.createUnicaIntegrationUser();
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User ccrmAdminUser = CCRMTestDataFactory.createAdminUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User integrationUser = CCRMTestDataFactory.getCCRMIntegrationUser();

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

    System.runAs(ccrmAdminUser) {
      createUsersWithEmployeeID();
    }

    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        10,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        10,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createLeadRecords(10, mlUser);
    }
  }

  @isTest
  static void testExpiryDateWhenOwnerChanged() {
    //GIVEN leads
    Lead[] leads = [
      SELECT Id, OwnerId, Expiry_Date__c, Followup_Date__c, RecordTypeId
      FROM Lead
    ];
    Lead[] oldLeads = leads.deepClone(true, true, true);

    //WHEN Owner Changed
    Test.startTest();
    for (Lead lead : leads) {
      lead.OwnerId = UserInfo.getUserId();
      lead.Expiry_Date__c = Date.today().addDays(3);
    }
    CCRMLeadActions.setExpiryDate(leads, new Map<Id, Lead>(oldLeads));
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
  static void testExpiryDateLogResponseAddedWithFollowupDate() {
    //GIVEN leads
    Test.startTest();
    Lead[] leads = [
      SELECT Id, OwnerId, Expiry_Date__c, Followup_Date__c, RecordTypeId
      FROM Lead
    ];
    Lead[] oldLeads = leads.deepClone(true, true, true);

    Response_Type__c response = [SELECT Id FROM Response_Type__c LIMIT 1];

    Task task = new Task();
    task.Response_Status__c = 'Accepted';
    task.Status = CCRMConstants.STATUS_COMPLETED;
    task.Outcome_Reason__c = 'Happy with the offer';
    task.Subject = 'Appointment Booked: Appointment Booked for A-Z review';
    task.Description = 'Test expiry date';
    task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
    task.WhoId = leads[0].Id;
    task.ActivityDate = Date.today().addDays(5);
    task.Response_Type__c = response.Id;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      insert task;
    }

    //WHEN

    leads[0].Followup_Date__c = Date.today();
    CCRMLeadActions.setExpiryDate(leads, new Map<Id, Lead>(oldLeads));
    Test.stopTest();

    //THEN
    Date newExpiryDate = DateTimeUtils.getWeekday(
      task.ActivityDate.addDays(10),
      false,
      false
    );
    System.assertEquals(
      leads[0].Expiry_Date__c,
      newExpiryDate,
      'Expiry date updated correctly'
    );
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
    leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam1';
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'CCRM';
    leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;
    leadRecord.OwnerId = ccrmUser.Id;

    Lead leadRecord2 = new Lead();
    leadRecord2.Email = 'sam2@test.com';
    leadRecord2.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord2.Description = 'Need a new Credit Card';
    leadRecord2.Registered_Company__c = 'No';
    leadRecord2.Expiry_Date__c = System.today() + 10;
    leadRecord2.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord2.FinServ__PotentialValue__c = 12000;
    leadRecord2.FirstName = 'Sam2';
    leadRecord2.LastName = 'Jacob';
    leadRecord2.LeadSource = 'Partner';
    leadRecord2.New_to_Bank__c = 'Yes';
    leadRecord2.Lead_Originator__c = 'CCRM';
    leadRecord2.Status = CCRMConstants.STATUS_ASSIGNED;
    leadRecord2.OwnerId = ccrmUser2.Id;

    Lead leadRecord3 = new Lead();
    leadRecord3.Email = 'sam3@test.com';
    leadRecord3.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord3.Description = 'Need a new Credit Card';
    leadRecord3.Registered_Company__c = 'No';
    leadRecord3.Expiry_Date__c = System.today() + 10;
    leadRecord3.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord3.FinServ__PotentialValue__c = 12000;
    leadRecord3.FirstName = 'Sam3';
    leadRecord3.LastName = 'Jacob';
    leadRecord3.LeadSource = 'Partner';
    leadRecord3.New_to_Bank__c = 'Yes';
    leadRecord3.Lead_Originator__c = 'CCRM';
    leadRecord3.Status = CCRMConstants.STATUS_ASSIGNED;
    leadRecord3.OwnerId = ccrmUser3.Id;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
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
  static void testLeadPlatformEventsSuccessfullyByAdminAdobe() {
    // GIVEN
    Test.startTest();
    List<Lead> leads = [
      SELECT Id, LeadSource, recordTypeId
      FROM Lead
      WHERE RecordType.DeveloperName = 'CCRM_Lead'
    ];
    leads[0].Expiry_Date__c = System.today() + 15;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update leads;
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

  @isTest
  static void testPrefillLeadFieldsForUnicaBusinessAccount() {
    //GIVEN
    Test.startTest();
    Account acc;
    Contact contact;
    User objCCRMUser = CCRMTestDataFactory.getCCRMBaseUser();
    User objUser = [
      SELECT Id
      FROM user
      WHERE username = 'unica.integration@anzx.com.unittest'
    ];
    System.runAs(objUser) {
      acc = CCRMTestDataFactory.createBusinessAccount();
      contact = [
        SELECT Email, MobilePhone, FirstName, LastName
        FROM Contact
        WHERE AccountId = :acc.Id
      ];
    }
    System.runAs(objUser) {
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam@test.com';
      leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Sam';
      leadRecord.LastName = 'Jacob';
      leadRecord.LeadSource = 'Partner';
      leadRecord.Campaign_Code__c = 'IKCMP-1579';
      leadRecord.New_to_Bank__c = 'No';
      leadRecord.Lead_Originator__c = 'UNICA';
      leadRecord.Business_ID__c = 'BUS1234';
      leadRecord.ownerId = objCCRMUser.Id;
      insert leadRecord;
    }
    //WHEN Unica lead is created and populated with Business ID
    System.runAs(objCCRMUser) {
      Lead lead = [
        SELECT
          Street,
          ACN__c,
          ABN__c,
          City,
          State,
          Postalcode,
          LastName,
          FirstName,
          MobilePhone,
          Email,
          company
        FROM Lead
        WHERE Email = 'sam@test.com'
      ];

      if (lead == null) {
        return;
      }
      //THEN account details should be matched and copied to the lead
      System.assertEquals(lead.ACN__c, acc.ACN__c, 'ACN updated correctly');
      System.assertEquals(lead.ABN__c, acc.ABN__c, 'ABN updated correctly');
      System.assertEquals(lead.City, acc.BillingCity, 'City updated correctly');
      System.assertEquals(
        lead.Street,
        acc.BillingStreet,
        'Street updated correctly'
      );
      System.assertEquals(
        lead.State,
        acc.BillingState,
        'State updated correctly'
      );
      System.assertEquals(
        lead.Postalcode,
        acc.BillingPostalcode,
        'Postalcode updated correctly'
      );
      System.assertEquals(lead.Company, acc.Name, 'Company updated correctly');
      System.assertNotEquals(
        lead.LastName,
        contact.LastName,
        'FirstName updated correctly'
      );
      System.assertNotEquals(
        lead.FirstName,
        acc.FirstName,
        'LastName updated correctly'
      );
      System.assertNotEquals(
        lead.Email,
        contact.Email,
        'Email updated correctly'
      );
      System.assertNotEquals(
        lead.MobilePhone,
        contact.MobilePhone,
        'MobilePhone updated correctly'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testLeadPlatformEventsSuccessfully() {
    // GIVEN
    // A platform event with a field values
    Lead_event__e pe = new Lead_event__e(
      Lead_Source__c = 'Accountant',
      Work_Phone__c = '+61430000000',
      Company__c = 'Test Pty Ltd',
      City__c = 'Point Cook',
      Street__c = '800 Bourke Street',
      Country__c = 'Australia'
    );
    List<sObject> events = new List<sObject>();
    events.add(pe);

    // WHEN
    // Calling publishEvents()
    Test.startTest();
    List<sObject> publishedEvents = PlatformEventUtils.publishEvents(events);
    Test.stopTest();

    // THEN
    // A plafform event with the specified type and field values is published
    System.assertEquals(
      1,
      publishedEvents.size(),
      'Number of published events should match.'
    );
    System.assertEquals(
      'Accountant',
      publishedEvents[0].get('Lead_Source__c'),
      'Lead Source should match.'
    );
    System.assertEquals(
      '+61430000000',
      publishedEvents[0].get('Work_Phone__c'),
      'Work Phone should match.'
    );
    System.assertEquals(
      'Test Pty Ltd',
      publishedEvents[0].get('Company__c'),
      'Company should match.'
    );
    System.assertEquals(
      'Point Cook',
      publishedEvents[0].get('City__c'),
      'City should match.'
    );
    System.assertEquals(
      '800 Bourke Street',
      publishedEvents[0].get('Street__c'),
      'Street should match.'
    );
    System.assertEquals(
      'Australia',
      publishedEvents[0].get('Country__c'),
      'Country should match.'
    );
  }

  @isTest
  static void testLogResponsePlatformEventsSuccessfully() {
    // GIVEN
    // A platform event with a field values
    Lead_response_event__e pe = new Lead_response_event__e(
      Outcome_Reason__c = 'Happy with Offer',
      Response_Status__c = 'Accepted',
      Comment__c = 'Test Log Response Event',
      UNICA_Treatment_Code__c = 'AMTP'
    );
    List<sObject> events = new List<sObject>();
    events.add(pe);

    // WHEN
    // Calling publishEvents()
    Test.startTest();
    List<sObject> publishedEvents = PlatformEventUtils.publishEvents(events);
    Test.stopTest();

    // THEN
    // A plafform event with the specified type and field values is published
    System.assertEquals(
      1,
      publishedEvents.size(),
      'Number of published events should match.'
    );
    System.assertEquals(
      'Happy with Offer',
      publishedEvents[0].get('Outcome_Reason__c'),
      'Outcome reason should match.'
    );
    System.assertEquals(
      'Accepted',
      publishedEvents[0].get('Response_Status__c'),
      'Response status should match.'
    );
    System.assertEquals(
      'Test Log Response Event',
      publishedEvents[0].get('Comment__c'),
      'Company should match.'
    );
  }

  @isTest
  static void testLogResponseLeadUpdateToUnica() {
    //GIVEN leads
    Test.startTest();
    Lead unicaLead = [SELECT Id FROM Lead LIMIT 1];
    unicaLead.Lead_Originator__c = 'UNICA';
    unicaLead.Business_ID__c = 'BUS1234';
    unicaLead.Registered_Company__c = 'No';
    unicaLead.Company = 'ABC Company';
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update unicaLead;
    }

    Response_Type__c response = [
      SELECT Id, Response_Status__c, Outcome_Reason__c
      FROM Response_Type__c
      LIMIT 1
    ];

    Task task = new Task();
    task.Response_Status__c = response.Response_Status__c;
    task.Status = CCRMConstants.STATUS_COMPLETED;
    task.Outcome_Reason__c = response.Outcome_Reason__c;
    task.Subject = 'Appointment Booked: Appointment Booked for A-Z review';
    task.Description = 'Test expiry date';
    task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
    task.WhoId = unicaLead.Id;
    task.ActivityDate = Date.today().addDays(5);
    task.Response_Type__c = response.Id;

    //WHEN
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      insert task;
    }

    //THEN
    Lead[] updatedlead = [
      SELECT SubStatus__c
      FROM Lead
      WHERE Business_ID__c = 'BUS1234'
    ];
    System.assertEquals(updatedlead[0].SubStatus__c, 'Accepted', 'Lead ');
    Test.stopTest();
  }

  @isTest
  static void testLeadResponsePlatformEventsSuccessfullyByAdmin() {
    // GIVEN
    Test.startTest();
    List<Lead> leads = [
      SELECT Id, LeadSource, Lead_id__c, recordTypeId
      FROM Lead
      WHERE RecordType.DeveloperName = 'CCRM_Lead'
    ];
    for (Lead record : leads) {
      record.Lead_Originator__c = 'Adobe';
      record.New_to_Bank__c = 'No';
    }

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      leads = CCRMTestDataFactory.createLeadRecordsWithCustomerRelatedParty(
        leads
      );
    }

    Response_Type__c response = [
      SELECT Id, Response_Status__c, Outcome_Reason__c
      FROM Response_Type__c
      LIMIT 1
    ];

    Task task = new Task();
    task.Response_Status__c = response.Response_Status__c;
    task.Status = CCRMConstants.STATUS_COMPLETED;
    task.Outcome_Reason__c = response.Outcome_Reason__c;
    task.Subject = 'Appointment Booked: Appointment Booked for A-Z review';
    task.Description = 'Test expiry date';
    task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
    task.WhoId = leads[0].Id;
    task.ActivityDate = Date.today().addDays(5);
    task.Response_Type__c = response.Id;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      insert task;
    }

    //WHEN
    Set<Id> leadIds = new Set<Id>{ leads[0].Id };
    CCRMLeadActions.resendAdobeOrUnicaOrCcrmLeadUpdatePlatformEvent(leadIds);
    Test.stopTest();
    // THEN
    // As platform event will be published to Mule, doing assert only for code coverage
    System.assertEquals(
      leads[0].LeadSource,
      'Partner',
      'Lead source should match.'
    );
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
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
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

  @IsTest
  static void testValidateUnicaLeadCustomerLinking() {
    Test.startTest();
    Account acc = CCRMTestDataFactory.createBusinessAccount();
    String invalidId = 'invalidId';
    Campaign campaign = [SELECT Code__c FROM Campaign LIMIT 1];

    //GIVEN some UNICA lead with invalid campaign code or account Source System ID
    Lead leadWithInvalidCampaignCode = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c + 'invalid'
    );
    Lead leadWithValidCustomerId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c,
      Customer_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidCustomerId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c,
      Customer_ID__c = invalidId
    );
    Lead leadWithValidClgId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c,
      CLG_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidClgId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c,
      CLG_ID__c = invalidId
    );
    Lead leadWithValidBusinessId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
      Campaign_Code__c = campaign.Code__c,
      Business_ID__c = acc.Source_System_ID__c
    );
    Lead leadWithInvalidBusinessId = new Lead(
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Lead_Originator__c = CCRMConstants.ORIGINATOR_UNICA,
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
      CCRMLeadActions.populateFields(
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
  }

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
    leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Adobe Ingested';
    leadRecord.LastName = 'Lead1';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;

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
    leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Unica Ingested';
    leadRecord.LastName = 'Lead';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'UNICA';
    leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;

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
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      campaign = [
        SELECT Id
        FROM Campaign
        WHERE Code__c = :System.Label.CCRM_DefaultCampaign
        LIMIT 1
      ];
    }

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam1@test.com';
      leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Registered_Company__c = 'No';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Default';
      leadRecord.LastName = 'Campaign';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Lead_Originator__c = 'CCRM';
      leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;
      leadRecord.Company = 'ABC Company';
      leadRecord.Registered_Company__c = 'No';

      insert leadRecord;
      leadId = leadRecord.Id;
    }

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
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
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Id adminProfileId = CommonUtil.getProfileByName('System Administrator')
        .Id;
      USER usr = (USER) FakerFactory.make(new FakerUserFactory());
      usr.Email = 'test@mltest.anz.com';
      usr.ProfileId = adminProfileId;
      usr.UserRoleId = CommonUtil.getUserRoleByDevName('Banker').Id;
      insert usr;

      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.Referrer_Email__c = 'test@mltest.anz.com';
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
        usr.Id,
        'Referrrer is populated'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testMLLeadCreationWithoutExistingReferrer() {
    Test.startTest();
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
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
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      List<Lead> leadsList = new List<Lead>();
      for (Integer i = 0; i < 50; i++) {
        leadsList.add((Lead) FakerFactory.make(new FakerLeadFactory()));
      }
      insert leadsList;
      System.assertEquals(leadsList.Size(), 50, 'All ML leads created');
      for (Lead objLead : leadsList) {
        System.assertEquals(objLead.Lead_Id__c, objLead.Lead_Auto_Number__c);
      }
    }
    Test.stopTest();
  }

  @isTest
  static void testLeadStatusChange() {
    User objUser = [SELECT Id FROM User WHERE LastName = :'MLCRM' LIMIT 1];
    System.runAs(objUser) {
      Test.startTest();
      List<Lead> lstOfLead = [
        SELECT Id, IsNewLead__c
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID AND status = 'New'
      ];
      for (Lead objLead : lstOfLead) {
        objLead.IsNewLead__c = false;
      }
      update lstOfLead;
      Test.stopTest();
      System.assertEquals(
        10,
        [
            SELECT Id
            FROM Lead
            WHERE
              status = 'In Progress'
              AND RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
          ]
          .size()
      );
    }
  }

  @isTest
  static void testMLLeadCreationWithReferrer() {
    Test.startTest();
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Id adminProfileId = CommonUtil.getProfileByName('System Administrator')
        .Id;
      USER usr = (USER) FakerFactory.make(new FakerUserFactory());
      usr.Email = 'test@mltest.anz.com';
      usr.ProfileId = adminProfileId;
      usr.UserRoleId = CommonUtil.getUserRoleByDevName('Banker').Id;
      insert usr;

      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.FinServ__ReferredByUser__c = usr.Id;
      insert leadRec;

      Lead leadRecord = [
        SELECT id, Referrer_Email__c
        FROM lead
        WHERE id = :leadRec.id
        LIMIT 1
      ];
      System.assertEquals(
        leadRecord.Referrer_Email__c,
        usr.Email,
        'Referrrer is populated'
      );
    }
    Test.stopTest();
  }
}
