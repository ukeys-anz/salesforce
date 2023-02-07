/**
 * @author Sahil S
 * @since  09/2021
 * @description This class is to provide generic test data setups CCRM test classes.
 * @group Utils
 */
@isTest
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public with sharing class CCRMTestDataFactory {
  public static Id anzStandardProfileId = CommonUtil.getProfileByName(
      'ANZ Standard User'
    )
    .Id;
  public static Id adminProfileId = CommonUtil.getProfileByName(
      'System Administrator'
    )
    .Id;
  public static Id integrationProfileId = CommonUtil.getProfileByName(
      'Minimum Access - Salesforce'
    )
    .Id;
  public static UserRole bankerRole = CommonUtil.getUserRoleByDevName('Banker');

  private static User adminUser;
  private static User ccrmBaseUser;
  private static User ccrmIntegrationUser;
  private static User twilioIntegrationUser;

  /**
   * @description Create a CCRM System Admin User
   * @name createAdminUser
   * @return System Administrator User
   */
  public static User createAdminUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    adminUser = (User) FakerFactory.make(new FakerUserFactory());
    adminUser.FirstName = 'TestUser' + staticNumber;
    adminUser.LastName = 'Admin';
    adminUser.UserRoleId = bankerRole.Id;
    adminUser.ProfileId = adminProfileId;
    insert adminUser;
    return adminUser;
  }

  /**
   * @description Get a CCRM System Admin User, if such user not exists yet then create one
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
   * @description Create a CCRM Base User
   * @name createCCRMBaseUser
   * @return ANZ Standard User with CCRM Base User Permission Set.
   */
  public static User createCCRMBaseUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    ccrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmBaseUser.FirstName = 'BaseUser' + staticNumber;
    ccrmBaseUser.LastName = 'CCRM';
    ccrmBaseUser.UserRoleId = bankerRole.Id;
    ccrmBaseUser.ProfileId = anzStandardProfileId;
    insert ccrmBaseUser;
    addCCRMUserPS(ccrmBaseUser.id, 'CCRM_User_Base');
    return ccrmBaseUser;
  }

  /**
   * @description Get a CCRM Base User, if such user not exists yet then create one
   * @name getCCRMBaseUser
   * @return ANZ Standard User with CCRM Base User Permission Set.
   */
  public static User getCCRMBaseUser() {
    if (ccrmBaseUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :anzStandardProfileId AND LastName = 'CCRM'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        ccrmBaseUser = createCCRMBaseUser();
      } else {
        ccrmBaseUser = users[0];
      }
    }
    return ccrmBaseUser;
  }

  /**
   * @description Create a CCRM Integration User
   * @name createCCRMBaseUser
   * @return ANZ Standard User with CCRM Integration User Permission Set.
   */
  public static User createCCRMIntegrationUser() {
    String staticNumber = Datetime.now().format('MMddHHmmss');
    ccrmIntegrationUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmIntegrationUser.FirstName = 'IntegrationUser' + staticNumber;
    ccrmIntegrationUser.LastName = 'CCRM';
    ccrmIntegrationUser.UserRoleId = bankerRole.Id;
    ccrmIntegrationUser.ProfileId = integrationProfileId;
    insert ccrmIntegrationUser;
    addCCRMUserPS(ccrmIntegrationUser.id, 'CCRM_Marketing_Integration_User');
    return ccrmIntegrationUser;
  }

  /**
   * @description Get a CCRM Integration User, if such user not exists yet then create one
   * @name getCCRMIntegrationUser
   * @return ANZ Standard User with CCRM Integration User Permission Set.
   */
  public static User getCCRMIntegrationUser() {
    if (ccrmIntegrationUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :integrationProfileId AND LastName = 'CCRM'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        ccrmIntegrationUser = createCCRMIntegrationUser();
      } else {
        ccrmIntegrationUser = users[0];
      }
    }
    return ccrmIntegrationUser;
  }

  /**
   * @description Create OCV Integration User
   * @name createOCVIntegrationUser
   * @return ANZ Standard User with CCRM Integration User Permission Set.
   */
  public static User createTwilioIntegrationUser() {
    twilioIntegrationUser = (User) FakerFactory.make(new FakerUserFactory());
    twilioIntegrationUser.FirstName = 'IntegrationUserTwilio';
    twilioIntegrationUser.UserRoleId = CommonUtil.getUserRoleByDevName('ANZ')
      .Id;
    twilioIntegrationUser.ProfileId = CommonUtil.getProfileByName(
        'Integration User'
      )
      .Id;
    insert twilioIntegrationUser;
    TestUtil.assignPermissionSets(
      new List<String>{ 'Chat_Read_Write', 'Interaction_Integration' },
      new List<User>{ twilioIntegrationUser }
    );
    return twilioIntegrationUser;
  }

  /**
   * @description Create ADOBE Integration User
   * @name createAdobeIntegrationUser
   * @return ADOBE Integration User with API Only & CCRM Base User Permission Set.
   */
  public static User createAdobeIntegrationUser() {
    String staticNumber = Datetime.now().format('MMddHHmmss');

    Id integrationProfileId = CommonUtil.getProfileByName(
        'Minimum Access - Salesforce'
      )
      .Id;
    User adobeUser = (User) FakerFactory.make(new FakerUserFactory());
    adobeUser.FirstName = 'IntegrationUser' + staticNumber;
    adobeUser.LastName = 'Adobe ';
    adobeUser.Username = 'adobe.integration@anzx.com.unittest';
    adobeUser.UserRoleId = bankerRole.Id;
    adobeUser.ProfileId = integrationProfileId;
    insert adobeUser;
    addCCRMUserPS(adobeUser.id, 'CCRM_User_Base');
    addCCRMUserPS(adobeUser.id, 'API_Only');
    return adobeUser;
  }

  /**
   * @description Create ADOBE Integration User
   * @name createUnicaIntegrationUser
   * @return UNICA Integration User with API Only & CCRM Base User Permission Set.
   */
  public static User createUnicaIntegrationUser() {
    String staticNumber = Datetime.now().format('MMddHHmmss');

    Id integrationProfileId = CommonUtil.getProfileByName(
        'Minimum Access - Salesforce'
      )
      .Id;
    User unicaUser = (User) FakerFactory.make(new FakerUserFactory());
    unicaUser.FirstName = 'IntegrationUser' + staticNumber;
    unicaUser.LastName = 'Unica ';
    unicaUser.Username = 'unica.integration@anzx.com.unittest';
    unicaUser.UserRoleId = bankerRole.Id;
    unicaUser.ProfileId = integrationProfileId;
    insert unicaUser;
    addCCRMUserPS(unicaUser.id, 'CCRM_User_Base');
    addCCRMUserPS(unicaUser.id, 'API_Only');
    return unicaUser;
  }

  /**
   * @description Add required PermissionSet - CCRM Base User
   * @name addCCRMUserPS
   * @param userId of User to which CCRM_User_Base Permission Set needed to be assigned.
   * @param permissionSet Permission Set needed to be assigned.
   */
  public static void addCCRMUserPS(Id userId, String permissionSet) {
    PermissionSet ps = CommonUtil.getPermissionSetByName(permissionSet);
    PermissionSetAssignment psa = TestUtil.createPSAssignment(userId, ps.Id);
    insert psa;
  }

  /**
   * @description Create Industries
   * @name createIndustries
   * @param count Count of industries to be created
   * @return List<Industry__c> Industries created
   */
  public static List<Industry__c> createIndustries(Integer count) {
    List<Industry__c> industryList = new List<Industry__c>();
    for (Integer i = 1; i <= count; i++) {
      Industry__c industry = new Industry__c();
      industry.Name = 'ANZ - AUSTRALIA' + i;
      industry.Code__c = '1000' + i;
      industry.IsActive__c = true;
      industryList.add(industry);
    }
    insert industryList;
    return industryList;
  }

  /**
   * @description Create Product
   * @name createProduct
   * @return Product2
   */
  public static Product2 createProduct() {
    //Create your product
    Product2 prod = new Product2(
      Name = 'Product X',
      ProductCode = 'Pro-X',
      isActive = true
    );
    insert prod;
    return prod;
  }

  /**
   * @description Create Pricebook
   * @name createPriceBook
   * @return PricebookEntry
   */
  public static PricebookEntry createPriceBook() {
    //Create your pricebook entry
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = createProduct();
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 100.00,
      IsActive = true
    );
    insert pbEntry;
    return pbEntry;
  }

  /**
   * @description Create Opportunity Line Item
   * @name createOpportunityLineItem
   * @return OpportunityLineItem
   */
  public static OpportunityLineItem createOpportunityLineItem() {
    //create your opportunity line item.
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    PricebookEntry pbEntry = createPriceBook();
    OpportunityLineItem oli = new OpportunityLineItem(
      OpportunityId = opp.Id,
      PricebookEntryId = pbEntry.Id,
      Quantity = 1,
      TotalPrice = 1000.00
    );
    return oli;
  }

  /**
   * @description Create Legal Entities
   * @name createLegalEntities
   * @param count Count of legal entity to be created
   * @return List<Legal_Entity__c> Entities created
   */
  public static List<Legal_Entity__c> createLegalEntities(Integer count) {
    List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
      1,
      null
    );
    OpportunityLineItem oli = createOpportunityLineItem();
    insert oli;

    List<Legal_Entity__c> entityList = new List<Legal_Entity__c>();
    for (Integer i = 1; i <= count; i++) {
      Legal_Entity__c entity = new Legal_Entity__c();
      entity.Account__c = opps[0].AccountId;
      entity.Opportunity_Product__c = oli.Id;
      entityList.add(entity);
    }
    return entityList;
  }

  /**
   * @description Create leads with related parties
   * @name createLeadRecordsWithCustomerRelatedParty
   * @param leads List of leads.
   * @return List<Lead> Leads with related party
   */
  public static List<Lead> createLeadRecordsWithCustomerRelatedParty(
    List<Lead> leads
  ) {
    List<Industry__c> createIndustries = createIndustries(1);
    List<Account> accountList = new List<Account>();
    for (Integer i = 1; i <= leads.size(); i++) {
      Account accnt = new Account();
      accnt.FirstName = 'TestAccount' + i;
      accnt.LastName = 'surname';
      accnt.OCV_ID__c = 'OCV' + i;
      accnt.Industry = createIndustries[0].Code__c;
      accnt.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
      accnt.ABN__c = '50 110 219 460';
      accnt.PersonMobilePhone = '+6143000000' + i;
      accnt.PersonEmail = 'test' + i + '@test.com';
      accnt.FinServ__Gender__pc = 'Male';
      accnt.BillingStreet = '833 Collins Street';
      accnt.BillingCity = 'Docklands';
      accnt.BillingPostalCode = '3008';
      accnt.BillingState = 'Victoria';
      accnt.BillingCountry = 'Australia';
      accountList.add(accnt);
    }
    insert accountList;

    for (Integer a = 0; a < accountList.size(); a++) {
      leads[a].FinServ__RelatedAccount__c = accountList[a].Id;
    }
    update leads;
    return leads;
  }
  /**
   * @description Create Lead Records with Business Account
   * @name createLeadWithBusinessAccount
   * @param ownerUser User to which created records should be assigned.
   */
  public static void createLeadWithBusinessAccount(User ownerUser) {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.AR_C_Customer__c = true;
    accnt.FinServ__TotalFinAcctsPrimaryOwner__c = 200;
    accnt.External_Id__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    //Rollup summary hardcoded to 200, as it doesn't work in test scenarios and is not the focus of these test cases
    insert accnt;

    String staticNumber = Datetime.now().format('MMddHHmmss') + 1;
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam' + staticNumber + '@test.com';
    leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Not_Registered__c = true;
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam' + staticNumber;
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'No';
    leadRecord.Campaign_Code__c = staticNumber;
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Business_ID__c = '012345';
    leadRecord.Status = CCRMConstants.STATUS_NEW;
    leadRecord.FinServ__RelatedAccount__c = accnt.id;
    leadRecord.OwnerId = ownerUser.Id == null
      ? UserInfo.getUserId()
      : ownerUser.Id;

    insert leadRecord;
  }

  /**
   * @description Create Business Account with contact
   * @name createBusinessAccount
   * @return Account Business account
   */
  public static Account createBusinessAccount() {
    Faker faker = new Faker('AU');
    List<Industry__c> createIndustries = createIndustries(1);
    Account accnt = new Account();
    accnt.Name = 'Test Pty Ltd';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.Industry = createIndustries[0].Code__c;
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.ABN__c = '50 110 219 460';
    accnt.Phone = '+61333333333';
    accnt.BillingStreet = '833 Collins Street';
    accnt.BillingCity = 'Docklands';
    accnt.BillingPostalCode = '3008';
    accnt.BillingState = 'Victoria';
    accnt.BillingCountry = 'Australia';
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = System.Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Active';
    insert accnt;

    Contact contact = new Contact();
    contact.FirstName = 'conFname';
    contact.LastName = 'conLname';
    contact.Email = 'con@test.com';
    contact.MobilePhone = '+61430499999';
    contact.Phone = '+61255556666';
    contact.AccountId = accnt.Id;
    insert contact;

    return accnt;
  }

  /**
   * @description Create a Prospect Business Account with contact
   * @name createProspectBusinessAccount
   * @param ownerId Id of the owner user
   * @return Prospect Business Account Business account
   */
  public static Account createProspectBusinessAccount(Id ownerId) {
    Faker faker = new Faker('AU');

    List<Industry__c> createIndustries = createIndustries(1);
    Account accnt = new Account();
    accnt.Name = faker.randomString(10);
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.Industry = createIndustries[0].Code__c;
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.ABN__c = '50 110 219 460';
    accnt.Phone = faker.person.phone(true, false);
    accnt.BillingStreet = faker.address.street();
    accnt.BillingCity = faker.address.city();
    accnt.BillingPostalCode = faker.address.stateCode();
    accnt.BillingState = faker.address.state();
    accnt.BillingCountry = faker.address.country();
    accnt.Source_System_ID__c = faker.randomString(10);
    accnt.Source_System_Name__c = Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Prospect';
    if (ownerId != null) {
      accnt.OwnerId = ownerId;
    }
    insert accnt;

    Contact contact = new Contact();
    contact.FirstName = faker.person.firstName();
    contact.LastName = faker.randomString(10);
    contact.Email = faker.internet.companyEmail();
    contact.MobilePhone = faker.person.phone(true, true);
    contact.Phone = faker.person.phone(true, false);
    contact.AccountId = accnt.Id;
    insert contact;

    return accnt;
  }

  /**
   * @description Create Person Account
   * @name createPersonAccount
   * @return Account PersonAccount
   */
  public static Account createPersonAccount() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.FirstName = 'Test';
    accnt.LastName = 'Account';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    accnt.Phone = '+61333333333';
    accnt.BillingStreet = '833 Collins Street';
    accnt.BillingCity = 'Docklands';
    accnt.BillingPostalCode = '3008';
    accnt.BillingState = 'VIC';
    accnt.BillingCountry = 'Australia';
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = 'CAP';
    accnt.Finserv__KYCStatus__c = 'CO';
    accnt.FinServ__Status__c = 'Active';
    insert accnt;

    return accnt;
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
      leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      leadRecord.Description = 'Need a new Credit Card';
      leadRecord.Not_Registered__c = true;
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Credit Card';
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
   * @description Create Campaign Records for CCRM Testing
   * @name createCCRMCampaignRecord
   * @param count Count of Records needed to be created
   * @return List of Campaign records.
   */
  public static List<Campaign> createCCRMCampaignRecord(Integer count) {
    //Deafault Count to 200 when in excess.
    List<Campaign> newCampaignList = new List<Campaign>();
    count = count == null || count == 0 ? 1 : count;

    for (Integer i = 1; i <= count; i++) {
      Campaign campaignRecord = new Campaign();
      campaignRecord.Name = 'CRM Manual Leads';
      campaignRecord.Code__c = System.Label.CCRM_DefaultCampaign;
      campaignRecord.Type = 'Targeted Offer';
      campaignRecord.StartDate = System.today();
      campaignRecord.EndDate = campaignRecord.StartDate.addMonths(1);
      campaignRecord.Source__c = 'CCM';
      campaignRecord.Organization__c = 'ANZ Commercial Bank';
      campaignRecord.Description = 'Manual Leads created by bankers in CRM';

      newCampaignList.add(campaignRecord);
    }
    Database.insert(newCampaignList);
    return newCampaignList;
  }

  /**
   * @description Create Campaign_Document__C Records for CCRM Testing
   * @name createCampaignDocumentRecords
   * @param count Count of Records needed to be created
   */
  public static void createCampaignDocumentRecords(Integer count) {
    //Deafault Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;

    //Campaign Record
    List<Campaign> campaignList = CCRMTestDataFactory.createCCRMCampaignRecord(
      1
    );

    List<Campaign_Document__C> newCampaignDocuments = new List<Campaign_Document__C>();
    for (Integer i = 1; i <= count; i++) {
      Campaign_Document__C campaignDocumentRecord = new Campaign_Document__C();
      campaignDocumentRecord.Campaign__c = campaignList[0].Id;
      campaignDocumentRecord.Comments__c = 'Comment Test Data';
      campaignDocumentRecord.Is_Private__c = false;
      campaignDocumentRecord.URL__c = 'https://www.anz.com';

      newCampaignDocuments.add(campaignDocumentRecord);
    }
    Database.insert(newCampaignDocuments);
  }

  /**
   * @description Create Campaign_Flex_Field__c Records for CCRM Testing
   * @name createCampaignFlexFieldRecords
   * @param count Count of Records needed to be created
   */
  public static void createCampaignFlexFieldRecords(Integer count) {
    //Deafault Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;

    //Campaign Record
    List<Campaign> campaignList = CCRMTestDataFactory.createCCRMCampaignRecord(
      1
    );

    List<Campaign_Flex_Field__c> newCampaignFlexFields = new List<Campaign_Flex_Field__c>();
    for (Integer i = 1; i <= count; i++) {
      Campaign_Flex_Field__c campaignFlexFieldRecord = new Campaign_Flex_Field__c();
      campaignFlexFieldRecord.Campaign__c = campaignList[0].Id;
      campaignFlexFieldRecord.Name = 'Flex Field Test Data';
      campaignFlexFieldRecord.Sequence__c = 5;
      campaignFlexFieldRecord.FlexFieldName__c = 'Flex Field Name';

      newCampaignFlexFields.add(campaignFlexFieldRecord);
    }
    Database.insert(newCampaignFlexFields);
  }

  /**
   * @description Create Campaign Member Records for CCRM Testing
   * @name createCampaignMemberRecord
   * @param leadList List of Lead Records.
   * @param campaignId Campaign Id value.
   */
  public static void createCampaignMemberRecord(
    List<Lead> leadList,
    Id campaignId
  ) {
    List<CampaignMember> newCampaignMember = new List<CampaignMember>();
    for (Lead leadRecord : leadList) {
      CampaignMember campaignMemberRecord = new CampaignMember();
      campaignMemberRecord.LeadId = leadRecord.Id;
      campaignMemberRecord.CampaignId = campaignId;

      newCampaignMember.add(campaignMemberRecord);
    }
    Database.insert(newCampaignMember);
  }

  /**
   * @description Create Response_Type__C Records for CCRM Testing
   * @name createResponseTypeRecords
   * @param campaignRecord Campaign Record
   * @return Response_Type__c Record.
   */
  public static List<Response_Type__c> createResponseTypeRecords(
    Campaign campaignRecord
  ) {
    List<Response_Type__C> responseTypes = new List<Response_Type__C>();
    //Response Type
    Response_Type__c responseTypeRecord1 = new Response_Type__c();
    responseTypeRecord1.Campaign__c = campaignRecord.Id;
    responseTypeRecord1.Name = 'Flex Field Test Data';
    responseTypeRecord1.Display_Order__c = 1;
    responseTypeRecord1.Response_Status__c = 'Accepted';
    responseTypeRecord1.Outcome_Reason__c = 'Happy with the Offer.';
    responseTypeRecord1.Create_Opportunity__c = true;
    responseTypeRecord1.Create_To_Do_Activities__c = true;
    responseTypeRecord1.Follow_Up_State__c = 'R';
    responseTypeRecord1.Is_Active__c = true;
    responseTypeRecord1.UNICA_Lead_SubStatus__c = 'RPC';
    responseTypes.add(responseTypeRecord1);

    Response_Type__c responseTypeRecord2 = new Response_Type__c();
    responseTypeRecord2.Campaign__c = campaignRecord.Id;
    responseTypeRecord2.Name = 'Flex Field Test Data';
    responseTypeRecord2.Display_Order__c = 2;
    responseTypeRecord2.Response_Status__c = 'Customer Declined';
    responseTypeRecord2.Outcome_Reason__c = 'Competitor offer superior.';
    responseTypeRecord2.Follow_Up_State__c = 'R';
    responseTypeRecord2.Is_Active__c = true;
    responseTypeRecord2.UNICA_Lead_SubStatus__c = 'RPC';
    responseTypes.add(responseTypeRecord2);

    Response_Type__c responseTypeRecord3 = new Response_Type__c();
    responseTypeRecord3.Campaign__c = campaignRecord.Id;
    responseTypeRecord3.Name = 'Flex Field Test Data';
    responseTypeRecord3.Display_Order__c = 3;
    responseTypeRecord3.Response_Status__c = 'Call Back';
    responseTypeRecord3.Outcome_Reason__c = 'Customer was busy';
    responseTypeRecord3.Follow_Up_State__c = 'M';
    responseTypeRecord3.UNICA_Lead_SubStatus__c = 'RPC';
    responseTypes.add(responseTypeRecord3);

    insert responseTypes;
    return responseTypes;
  }

  /**
   * @description Create Lead Records for CCRM Testing
   * @name createLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @return `List<Opportunity>`
   */
  public static List<Opportunity> createOpportunityRecords(
    Integer count,
    User ownerUser
  ) {
    return createOpportunityRecords(count, ownerUser, true);
  }

  /**
   * @description Create Lead Records for CCRM Testing
   * @name createLeadRecords
   * @param count Count of Lead records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param doInsert Whether or not to insert the records
   * @return `List<Opportunity>`
   */
  public static List<Opportunity> createOpportunityRecords(
    Integer count,
    User ownerUser,
    Boolean doInsert
  ) {
    Faker faker = new Faker('AU');
    //Deafault Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;
    Account parentAccount = createBusinessAccount();

    Account objAccount = new Account();
    objAccount.Name = 'Test Account';
    objAccount.OCV_ID__c = faker.randomString(10);
    objAccount.FinServ__KYCStatus__c = 'Completed - Valid';
    objAccount.ParentId = parentAccount.Id;
    objAccount.FinServ__Status__c = 'Active';
    objAccount.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    insert objAccount;

    List<Opportunity> newOpps = new List<Opportunity>();
    for (Integer i = 1; i <= count; i++) {
      Opportunity objOpportunity = new Opportunity();
      objOpportunity.Name = 'Test Opp ' + i;
      objOpportunity.Accountid = objAccount.id;
      objOpportunity.StageName = 'Prospecting';
      objOpportunity.CloseDate = system.Today() + 3;
      objOpportunity.Description = '987654321';
      objOpportunity.RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID;

      newOpps.add(objOpportunity);
    }
    if (doInsert) {
      Database.insert(newOpps);
    }

    return newOpps;
  }

  /**
   * @description Create Users with employee id
   * @name createUsersWithEmployeeId
   * @param setOfEmployeeId Employee IDs
   * @return `List<User>`
   */
  public static List<User> createUsersWithEmployeeId(
    Set<String> setOfEmployeeId
  ) {
    List<User> newUsers = new List<User>();
    for (String key : setOfEmployeeId) {
      User ccrmUser = (User) FakerFactory.make(new FakerUserFactory());
      ccrmUser.UserRoleId = bankerRole.Id;
      ccrmUser.ProfileId = anzStandardProfileId;
      ccrmUser.Employee_Id__c = key;
      newUsers.add(ccrmUser);
    }
    Database.insert(newUsers);
    return newUsers;
  }

  /**
   * @description Create Controlling Posts with corresponding CPID and Employee ID
   * @name createControllingPosts Map of CPIDs against Employee ID
   * @param mapOfCPIDAndEmployeeId Employee IDs
   * @return `List<Controlling_Post__c>`
   */
  public static List<Controlling_Post__c> createControllingPosts(
    Map<String, String> mapOfCPIDAndEmployeeId
  ) {
    List<Controlling_Post__c> newCPs = new List<Controlling_Post__c>();
    for (String key : mapOfCPIDAndEmployeeId.keySet()) {
      String employeeId = mapOfCPIDAndEmployeeId.get(key);
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID__c = key;
      cp1.Name = key;
      cp1.Responsible_Employee_Id__c = employeeId;
      newCPs.add(cp1);
    }
    Database.insert(newCPs);
    return newCPs;
  }
}
