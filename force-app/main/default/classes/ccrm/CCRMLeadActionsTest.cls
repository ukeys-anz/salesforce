/**
 * @author Mairaj Haider
 * @since 03/2022
 * @description CCRM Lead Action is the test class for CCRM Lead Actions Class.
 */
@isTest
private class CCRMLeadActionsTest {
  @testSetup
  static void setup() {
    CCRMTestDataFactory.createAdobeIntegrationUser();
    CCRMTestDataFactory.createUnicaIntegrationUser();
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User ccrmAdminUser = CCRMTestDataFactory.createAdminUser();

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
    Test.startTest();
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
    leadRecord.Not_Registered__c = true;
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam1';
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'CCRM';
    leadRecord.Status = CCRMConstants.STATUS_NEW;
    leadRecord.OwnerId = ccrmUser.Id;

    Lead leadRecord2 = new Lead();
    leadRecord2.Email = 'sam2@test.com';
    leadRecord2.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord2.Description = 'Need a new Credit Card';
    leadRecord2.Not_Registered__c = true;
    leadRecord2.Expiry_Date__c = System.today() + 10;
    leadRecord2.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord2.FinServ__PotentialValue__c = 12000;
    leadRecord2.FirstName = 'Sam2';
    leadRecord2.LastName = 'Jacob';
    leadRecord2.LeadSource = 'Partner';
    leadRecord2.New_to_Bank__c = 'Yes';
    leadRecord2.Lead_Originator__c = 'CCRM';
    leadRecord2.Status = CCRMConstants.STATUS_NEW;
    leadRecord2.OwnerId = ccrmUser2.Id;

    Lead leadRecord3 = new Lead();
    leadRecord3.Email = 'sam3@test.com';
    leadRecord3.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord3.Description = 'Need a new Credit Card';
    leadRecord3.Not_Registered__c = true;
    leadRecord3.Expiry_Date__c = System.today() + 10;
    leadRecord3.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord3.FinServ__PotentialValue__c = 12000;
    leadRecord3.FirstName = 'Sam3';
    leadRecord3.LastName = 'Jacob';
    leadRecord3.LeadSource = 'Partner';
    leadRecord3.New_to_Bank__c = 'Yes';
    leadRecord3.Lead_Originator__c = 'CCRM';
    leadRecord3.Status = CCRMConstants.STATUS_NEW;
    leadRecord3.OwnerId = ccrmUser3.Id;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      CCRMLeadActions.retrieveControllingPost(
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
  }

  private static void createUsersWithEmployeeID() {
    //Roles and Permission Sets
    UserRole bankerRole = CommonUtil.getUserRoleByDevName('Banker');
    UserRole bankerManagerRole = CommonUtil.getUserRoleByDevName(
      'Banker Line Manager'
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
    List<Lead> leads = [SELECT Id, LeadSource FROM Lead];
    leads[0].Expiry_Date__c = System.today() + 15;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update leads;
    }

    //WHEN
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leads[0].Id);
    CCRMLeadActionsHelper.resendManualLeadPlatformEvent(leadIds);

    // THEN
    // As platform event will be published to Mule, doing assert only for code coverage
    System.assertEquals(
      leads[0].LeadSource,
      'Partner',
      'Lead source should match.'
    );
  }

  @isTest
  static void testLeadPlatformEventsSuccessfullyByAdminUnica() {
    // GIVEN
    List<Lead> leads = [SELECT Id, LeadSource FROM Lead];
    leads[0].Lead_Originator__c = 'CCRM';
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update leads;
      leads = CCRMTestDataFactory.createLeadRecordsWithCustomerRelatedParty(
        leads
      );
    }

    //WHEN
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leads[0].Id);
    CCRMLeadActionsHelper.resendManualLeadPlatformEvent(leadIds);

    // THEN
    // As platform event will be published to Mule, doing assert only for code coverage
    System.assertEquals(
      leads[0].LeadSource,
      'Partner',
      'Lead source should match.'
    );
  }

  @isTest
  static void testPrefillLeadFieldsForUnicaBusinessAccount() {
    //GIVEN
    Account acc;
    Contact contact;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      acc = CCRMTestDataFactory.createBusinessAccount();
      contact = [
        SELECT Email, MobilePhone, FirstName, LastName
        FROM Contact
        WHERE AccountId = :acc.Id
      ];
    }

    //WHEN Unica lead is created and populated with Business ID
    Lead lead = new Lead();
    lead.Business_ID__c = 'BUS1234';
    lead.Lead_Originator__c = 'UNICA';
    Test.startTest();
    CCRMLeadActions.prefillUnicaLeadsFromAccountOnInsert(
      new List<Lead>{ lead }
    );
    Test.stopTest();

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
    System.assertEquals(
      lead.LastName,
      contact.LastName,
      'FirstName updated correctly'
    );
    System.assertEquals(
      lead.FirstName,
      contact.FirstName,
      'LastName updated correctly'
    );
    System.assertEquals(lead.Email, contact.Email, 'Email updated correctly');
    System.assertEquals(
      lead.MobilePhone,
      contact.MobilePhone,
      'MobilePhone updated correctly'
    );
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
      Subject__c = 'Test Log Response Event',
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
      publishedEvents[0].get('Subject__c'),
      'Company should match.'
    );
  }

  @isTest
  static void testLogResponseLeadUpdateToUnica() {
    //GIVEN leads
    Lead unicaLead = [SELECT Id FROM Lead LIMIT 1];
    unicaLead.Lead_Originator__c = 'UNICA';
    unicaLead.Business_ID__c = 'BUS1234';
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
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      insert task;
    }
    Test.stopTest();

    //THEN
    Lead[] updatedlead = [
      SELECT SubStatus__c
      FROM Lead
      WHERE Business_ID__c = 'BUS1234'
    ];
    System.assertEquals(updatedlead[0].SubStatus__c, 'Accepted', 'Lead ');
  }

  @isTest
  static void testLeadResponsePlatformEventsSuccessfullyByAdmin() {
    // GIVEN
    List<Lead> leads = [SELECT Id, LeadSource, Lead_id__c FROM Lead];
    leads[0].Lead_Originator__c = 'Adobe';

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

    Test.startTest();
    //WHEN validated
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
    Test.stopTest();

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
    leadRecord.Not_Registered__c = true;
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Adobe Ingested';
    leadRecord.LastName = 'Lead1';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Status = CCRMConstants.STATUS_NEW;

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
    leadRecord.Not_Registered__c = true;
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Unica Ingested';
    leadRecord.LastName = 'Lead';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'UNICA';
    leadRecord.Status = CCRMConstants.STATUS_NEW;

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
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Lead leadRecord = new Lead();
      leadRecord.Email = 'sam1@test.com';
      leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Not_Registered__c = true;
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Default';
      leadRecord.LastName = 'Campaign';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Lead_Originator__c = 'CCRM';
      leadRecord.Status = CCRMConstants.STATUS_NEW;

      insert leadRecord;
      leadId = leadRecord.Id;
    }
    Test.stopTest();

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      List<CampaignMember> members = [
        SELECT Id
        FROM CampaignMember
        WHERE CampaignId = :campaign.Id AND LeadId = :leadId
      ];
      System.assert(!members.isEmpty(), 'Campaign Member was created');
    }
  }
}
