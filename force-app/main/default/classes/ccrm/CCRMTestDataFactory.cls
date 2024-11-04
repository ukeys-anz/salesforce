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
      'ANZ CCRM Standard User'
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
  public static Id minAccessExternalProfileId = CommonUtil.getProfileByName(
      'Minimum Access - External Apps'
    )
    .Id;
  public static UserRole commercialBankerRole = CommonUtil.getUserRoleByDevName(
    'Commercial_Banking'
  );
  public static UserRole relationshipManager = CommonUtil.getUserRoleByDevName(
    'Relationship_Manager'
  );

  public static UserRole smallBBRole = CommonUtil.getUserRoleByDevName(
    'Small_Business_Banking'
  );

  public static UserRole arcRole = CommonUtil.getUserRoleByDevName('AR_C');

  private static User adminUser;
  private static User ccrmBaseUser;
  private static User ccrmIntegrationUser;
  private static User twilioIntegrationUser;
  private static User ocvIntegrationUser;
  private static User sailPointUser;
  private static User batchUser;

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
    adminUser.UserRoleId = commercialBankerRole.Id;
    adminUser.ProfileId = adminProfileId;
    insert adminUser;

    TestUtil.assignPermissionSets(
      new List<String>{
        'Customer_Relationships_Read_Write',
        'Read_Write_Customer_Details',
        'CCRM_User_Base'
      },
      new List<User>{ adminUser }
    );

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
   * @description Get a CCRM System Admin User, if such user not exists yet then create one
   * @name getAdminUser
   * @return System Administrator User
   */
  public static User getBatchUser() {
    if (batchUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :integrationProfileId AND LastName = 'CCRM Batch'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        batchUser = createBatchUser();
      } else {
        batchUser = users[0];
      }
    }
    return batchUser;
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
    ccrmBaseUser.UserRoleId = commercialBankerRole.Id;
    ccrmBaseUser.ProfileId = anzStandardProfileId;
    insert ccrmBaseUser;
    addCCRMUserPS(ccrmBaseUser.id, 'CCRM_User_Base');
    addCCRMUserPS(ccrmBaseUser.id, 'Financial_Accounts_Read_and_Edit');
    return ccrmBaseUser;
  }

  /**
   * @description Create a Sailpoint User
   * @name createSailPointUser
   * @return Sailpoint User with API Only And User Provisioning permission set.
   */
  public static User createSailPointUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    sailPointUser = (User) FakerFactory.make(new FakerUserFactory());
    sailPointUser.FirstName = 'Sailpoint' + staticNumber;
    sailPointUser.LastName = 'Integration User';
    sailPointUser.ProfileId = minAccessExternalProfileId;
    insert sailPointUser;
    addCCRMUserPS(sailPointUser.id, 'API_Only');
    addCCRMUserPS(sailPointUser.id, 'User_Provisioning');
    return sailPointUser;
  }

  /**
   * @description Create a Batch User
   * @name createSailPointUser
   * @return Sailpoint User with API Only And User Provisioning permission set.
   */
  public static User createBatchUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    batchUser = (User) FakerFactory.make(new FakerUserFactory());
    batchUser.FirstName = 'User' + staticNumber;
    batchUser.LastName = 'CRM Batch';
    batchUser.ProfileId = integrationProfileId;
    batchUser.UserRoleId = arcRole.Id;
    insert batchUser;
    addCCRMUserPS(batchUser.id, 'API_Only');
    addCCRMUserPS(batchUser.id, 'CCRM_User_Base');
    addCCRMUserPS(batchUser.id, 'MLCRM_Base_Read_Only');
    addCCRMUserPS(batchUser.id, 'Validation_Bypass');
    return batchUser;
  }

  /**
   * @description Create a CCRM Base User
   * @name createCCRMRelManagerUser
   * @return ANZ Standard User with CCRM Relationship_ManagerUser User Permission Set.
   */
  public static User createCCRMRelManagerUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    ccrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmBaseUser.FirstName = 'BaseUser' + staticNumber;
    ccrmBaseUser.LastName = 'CCRM';
    ccrmBaseUser.UserRoleId = relationshipManager.Id;
    ccrmBaseUser.ProfileId = anzStandardProfileId;
    insert ccrmBaseUser;
    addCCRMUserPS(ccrmBaseUser.id, 'CCRM_User_Base');
    return ccrmBaseUser;
  }

  /**
   * @description Create a CCRM Base User
   * @name createCCRMSmallBusinessBankingUser
   * @return ANZ Standard User with CCRM Permission Set.
   */
  public static User createCCRMSmallBusinessBankingUser() {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    ccrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmBaseUser.FirstName = 'BaseUser' + staticNumber;
    ccrmBaseUser.LastName = 'CCRM';
    ccrmBaseUser.UserRoleId = smallBBRole.Id;
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
   * @description Get a CCRM Base User, if such user not exists yet then create one
   * @name getSailPointUser
   * @return ANZ Standard User with CCRM Base User Permission Set.
   */
  public static User getSailPointUser() {
    if (sailPointUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE
          ProfileId = :minAccessExternalProfileId
          AND LastName = 'Integration User'
          AND FirstName = 'Sailpoint'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        sailPointUser = createSailPointUser();
      } else {
        sailPointUser = users[0];
      }
    }
    return sailPointUser;
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
    ccrmIntegrationUser.UserRoleId = commercialBankerRole.Id;
    ccrmIntegrationUser.ProfileId = integrationProfileId;
    insert ccrmIntegrationUser;

    TestUtil.assignPermissionSets(
      new List<String>{
        'CCRM_Marketing_Integration_User',
        'Read_Write_Customer_Details',
        'CCRM_User_Base'
      },
      new List<User>{ ccrmIntegrationUser }
    );

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
   * @description Create Twilio Integration User
   * @name createTwilioIntegrationUser
   * @return Twilio Integration User.
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
   * @description Create OCV Integration User
   * @name createOCVIntegrationUser
   * @return OCV Integration User
   */
  public static User createOCVIntegrationUser() {
    ocvIntegrationUser = (User) FakerFactory.make(new FakerUserFactory());
    ocvIntegrationUser.FirstName = 'IntegrationUserOCV';
    ocvIntegrationUser.UserRoleId = CommonUtil.getUserRoleByDevName('ANZx').Id;
    ocvIntegrationUser.ProfileId = CommonUtil.getProfileByName(
        'Integration User'
      )
      .Id;
    insert ocvIntegrationUser;
    TestUtil.assignPermissionSets(
      new List<String>{
        'Read_Write_Customer_Details',
        'Moderate_Chatter',
        'Customer_Relationships_Read_Write',
        'FinancialServicesCloudStandard',
        'CCRM_Marketing_Integration_User'
      },
      new List<User>{ ocvIntegrationUser }
    );
    return ocvIntegrationUser;
  }

  /**
   * @description Get a OCV Integration User, if such user not exists yet then create one
   * @name getOcvIntegrationUser
   * @return Integration User with OCV Integration User Permission Set.
   */
  public static User getOcvIntegrationUser() {
    if (ocvIntegrationUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE
          ProfileId = :integrationProfileId
          AND FirstName = 'IntegrationUserOCV'
        LIMIT 1
      ];
      if (users.isEmpty()) {
        ocvIntegrationUser = createOCVIntegrationUser();
      } else {
        ocvIntegrationUser = users[0];
      }
    }
    return ocvIntegrationUser;
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
    adobeUser.UserRoleId = commercialBankerRole.Id;
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
    unicaUser.UserRoleId = commercialBankerRole.Id;
    unicaUser.ProfileId = integrationProfileId;
    insert unicaUser;
    addCCRMUserPS(unicaUser.id, 'CCRM_User_Base');
    addCCRMUserPS(unicaUser.id, 'CCRM_Marketing_Integration_User');
    addCCRMUserPS(unicaUser.id, 'MLCRM_Marketing_Integration_User');
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
      TotalPrice = 1000.00,
      Funding_purpose__c = 'Property Purchase or Construction'
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
   * @description Create Reciprocal Role
   * @name createReciprocalRole
   * @param name Name of Role
   * @param inverseRole Inverse Role
   * @param recordTypeId Record Type
   * @return FinServ__ReciprocalRole__c Reciprocal Role
   */
  public static FinServ__ReciprocalRole__c createReciprocalRole(
    String name,
    String inverseRole,
    Id recordTypeId
  ) {
    List<FinServ__ReciprocalRole__c> roles = new List<FinServ__ReciprocalRole__c>();
    FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c(
      Name = name,
      OCV_Role__c = name,
      RecordTypeId = recordTypeId,
      FinServ__InverseRole__c = inverseRole,
      FinServ__CreateInverseRole__c = false
    );
    roles.add(reciprocalRole);
    if (name != inverseRole) {
      roles.add(
        new FinServ__ReciprocalRole__c(
          Name = inverseRole,
          OCV_Role__c = inverseRole,
          RecordTypeId = recordTypeId,
          FinServ__InverseRole__c = name,
          FinServ__CreateInverseRole__c = false
        )
      );
    }
    insert roles;
    if (name != inverseRole) {
      roles[0].FinServ__InverseRelationship__c = roles[1].Id;
      roles[1].FinServ__InverseRelationship__c = roles[0].Id;
      update roles;
    }
    return reciprocalRole;
  }

  /**
   * @description Create non-reciprocal role records
   * @name createNonReciprocalRole
   * @param name [Optional] the name of the reciprocal role
   * @param recordTypeId Record Type
   * @return FinServ__ReciprocalRole__c the newly created record
   */
  public static FinServ__ReciprocalRole__c createNonReciprocalRole(
    String name,
    Id recordTypeId
  ) {
    name = name == null ? new Faker('AU').randomString(10) : name;
    FinServ__ReciprocalRole__c nonReciprocalRole = new FinServ__ReciprocalRole__c(
      RecordTypeId = recordTypeId,
      Name = name,
      FinServ__InverseRole__c = name,
      OCV_Role__c = name,
      FinServ__CreateInverseRole__c = false
    );
    insert nonReciprocalRole;
    return nonReciprocalRole;
  }

  /**
   * @description Create Account With CLG Relationship
   * @name createAccountToAccountWithClgRelationship
   * @param accountId Account Id
   * @param relatedAccountId Related Account Id
   * @param role Reciprocal Role Id
   * @return FinServ__AccountAccountRelation__c accToAccRelationship
   */
  public static FinServ__AccountAccountRelation__c createAccountToAccountWithClgRelationship(
    Id accountId,
    Id relatedAccountId,
    Id role
  ) {
    FinServ__AccountAccountRelation__c accToAccRelationship = new FinServ__AccountAccountRelation__c();
    accToAccRelationship.FinServ__Account__c = accountId;
    accToAccRelationship.FinServ__RelatedAccount__c = relatedAccountId;
    accToAccRelationship.FinServ__Active__c = true;
    accToAccRelationship.FinServ__Role__c = role;
    insert accToAccRelationship;
    return accToAccRelationship;
  }

  /**
   * @description Create CLG Account
   * @name createClgAccount
   * @return Account CLG Account
   */
  public static Account createClgAccount() {
    Account clgAccount = new Account();
    clgAccount.Name = 'Clg Account';
    clgAccount.OCV_ID__c = 'OCV7861';
    clgAccount.FinServ__KYCStatus__c = 'Completed - Valid';
    clgAccount.FinServ__Status__c = 'Active';
    clgAccount.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    insert clgAccount;
    return clgAccount;
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
      accnt.BillingCountry = 'AUS';
      accnt.FinServ__Status__c = 'Prospect';
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
    accnt.ANZx_Customer__c = false;
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
    leadRecord.Registered_Company__c = 'No';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam' + staticNumber;
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'No';
    leadRecord.Campaign_Code__c = staticNumber;
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Business_ID__c = '012345';
    leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;
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
    accnt.External_Id__c = faker.randomString(10);
    accnt.Industry = createIndustries[0].Code__c;
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.ABN__c = '50 110 219 460';
    accnt.Phone = '+61333333333';
    accnt.BillingStreet = '833 Collins Street';
    accnt.BillingCity = 'Docklands';
    accnt.BillingPostalCode = '3008';
    accnt.BillingState = 'VIC';
    accnt.BillingCountry = 'Australia';
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = System.Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Active';
    insert accnt;

    Contact contact = new Contact();
    contact.recordTypeId = CCRMConstants.CONTACT_BUSINESS_RT_ID;
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
   * @description Create a System Customer and save ID to custom setting Financial_Account_Settings__c.System_Customer_Id__c
   * @name createSystemCustomer
   * @return The System Customer record
   */
  public static Account createSystemCustomer() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'System Customer';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    insert accnt;

    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    faSettings.System_Customer_Id__c = accnt.Id;
    upsert faSettings;

    return accnt;
  }

  /**
   * @description Create a Prospect Business Account with contact
   * @name createProspectBusinessAccount
   * @param ownerId Id of the owner user
   * @return Prospect Business Account Business account
   */
  public static Account createProspectBusinessAccount(Id ownerId) {
    Faker faker = new Faker('AUS');

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
    accnt.BillingCountry = 'AUS';
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
    contact.Name__c = faker.randomString(10);
    contact.Email = faker.internet.companyEmail();
    contact.MobilePhone = faker.person.phone(true, true);
    contact.Phone = faker.person.phone(true, false);
    contact.AccountId = accnt.Id;
    contact.RecordTypeId = CCRMConstants.CONTACT_BUSINESS_RT_ID;
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
    accnt.BillingCountry = 'AUS';
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
      leadRecord.Registered_Company__c = 'No';
      leadRecord.Expiry_Date__c = System.today() + 10;
      leadRecord.FinServ__ExpressedInterest__c = 'Purchasing Property';
      leadRecord.FinServ__PotentialValue__c = 12000;
      leadRecord.FirstName = 'Sam' + staticNumber;
      leadRecord.LastName = 'Jacob';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Campaign_Code__c = staticNumber;
      leadRecord.Lead_Originator__c = 'Adobe';
      leadRecord.Business_ID__c = '012345';
      leadRecord.Status = CCRMConstants.STATUS_ASSIGNED;
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
    //Default Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;

    Account objAccount = new Account();
    objAccount.Name = 'Test Account';
    objAccount.OCV_ID__c = faker.randomString(10);
    objAccount.FinServ__KYCStatus__c = 'Completed - Valid';
    objAccount.FinServ__Status__c = 'Active';
    objAccount.RecordTypeId = RTAccount.businessAccount;
    insert objAccount;

    List<Opportunity> newOpps = new List<Opportunity>();
    for (Integer i = 1; i <= count; i++) {
      Opportunity objOpportunity = new Opportunity();
      objOpportunity.Name = 'Test Opp ' + i;
      objOpportunity.Accountid = objAccount.id;
      objOpportunity.StageName = 'New';
      objOpportunity.CloseDate = DateTimeUtils.getNextWeekdayDate(3);
      objOpportunity.Description = '987654321';
      objOpportunity.RecordTypeId = RTOpportunity.commercialOpportunity;
      if (ownerUser != null) {
        objOpportunity.OwnerId = ownerUser.Id;
      }
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
      ccrmUser.UserRoleId = commercialBankerRole.Id;
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

  /**
   * @description Create Commercial Contacts
   * @name createContacts
   * @param count Count of contacts to be created
   * @param withContactDetails create contact with contat details - Mobile/Fax/Phone/Email
   * @return List<Contact> Contacts created
   */
  public static List<Contact> createContacts(
    Integer count,
    Boolean withContactDetails
  ) {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = faker.randomString(10);
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.Phone = faker.person.phone(true, false);
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = System.Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Dormant';
    insert accnt;

    List<Contact> conList = new List<Contact>();
    for (Integer i = 1; i <= count; i++) {
      Contact contact = new Contact();
      contact.RecordTypeId = CCRMConstants.CONTACT_BUSINESS_RT_ID;
      contact.FirstName = faker.person.firstName();
      contact.LastName = faker.randomString(10);
      if (withContactDetails) {
        contact.Email = 'testenddate@anz.com';
        contact.MobilePhone = faker.person.phone(true, true);
        contact.Phone = faker.person.phone(true, false);
        contact.Fax = '+61233334444';
      }
      contact.AccountId = accnt.Id;
      conList.add(contact);
    }
    insert conList;
    return conList;
  }

  /**
   * @description Create actionPlan
   * @name createActionPlans
   */
  public static void createActionPlans() {
    ActionPlanTemplate apTemp = new ActionPlanTemplate();
    apTemp.Name = CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP;
    apTemp.TargetEntityType = 'Opportunity';
    apTemp.ActionPlanType = 'Industries';
    insert apTemp;

    ActionPlanTemplateVersion apTempVer = [
      SELECT Id, Status
      FROM ActionPlanTemplateVersion
      WHERE Name = :CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP
      LIMIT 1
    ];

    List<ActionPlanTemplateItem> apTempItems = new List<ActionPlanTemplateItem>();
    ActionPlanTemplateItem apTempItem1 = new ActionPlanTemplateItem();
    apTempItem1.ActionPlanTemplateVersionId = apTempVer.Id;
    apTempItem1.Name = 'Google';
    apTempItem1.IsActive = true;
    apTempItem1.IsRequired = false;
    apTempItem1.ItemEntityType = 'Task';
    apTempItems.add(apTempItem1);

    ActionPlanTemplateItem apTempItem2 = new ActionPlanTemplateItem();
    apTempItem2.ActionPlanTemplateVersionId = apTempVer.Id;
    apTempItem2.Name = 'Test';
    apTempItem2.IsActive = true;
    apTempItem2.IsRequired = true;
    apTempItem2.ItemEntityType = 'Task';
    apTempItems.add(apTempItem2);
    insert apTempItems;

    List<ActionPlanTemplateItemValue> values = new List<ActionPlanTemplateItemValue>();
    ActionPlanTemplateItemValue apTempItemValue1 = new ActionPlanTemplateItemValue();
    apTempItemValue1.ActionPlanTemplateItemId = apTempItems[0].Id;
    apTempItemValue1.ItemEntityFieldName = 'Task.Subject';
    apTempItemValue1.Name = 'Test';
    apTempItemValue1.ValueLiteral = 'Sample';
    values.add(apTempItemValue1);

    ActionPlanTemplateItemValue apTempItemValue2 = new ActionPlanTemplateItemValue();
    apTempItemValue2.ActionPlanTemplateItemId = apTempItems[1].Id;
    apTempItemValue2.ItemEntityFieldName = 'Task.Subject';
    apTempItemValue2.Name = 'Subject';
    apTempItemValue2.ValueLiteral = 'Search';
    values.add(apTempItemValue2);
    insert values;

    apTempVer.Status = 'Final';
    update apTempVer;
  }

  /**
   * @description Create Business Account with owner and contact
   * @name createBusinessAccount
   * @param ownerId Id of Owner
   * @return Account Business account
   */
  public static Account createBusinessAccountWithOwner(Id ownerId) {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'Test Pty Ltd';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.ABN__c = '50 110 219 460';
    accnt.Phone = '+61333333333';
    accnt.BillingStreet = '833 Collins Street';
    accnt.BillingCity = 'Docklands';
    accnt.BillingPostalCode = '3008';
    accnt.BillingState = 'VIC';
    accnt.BillingCountry = 'Australia';
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = System.Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Active';
    if (ownerId != null) {
      accnt.OwnerId = ownerId;
    }
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
   * @description Create a account share record to provide access to business user
   * @name createAccountShare
   * @param accId Account record to be share
   * @param userId User to be share with
   */
  @future
  public static void createAccountShare(Id accId, Id userId) {
    AccountShare shareAccount = new AccountShare();
    shareAccount.AccountId = accId;
    shareAccount.AccountAccessLevel = 'Edit';
    shareAccount.ContactAccessLevel = 'Edit';
    shareAccount.CaseAccessLevel = 'Read';
    shareAccount.OpportunityAccessLevel = 'Read';
    shareAccount.RowCause = 'Manual';
    shareAccount.UserOrGroupId = userId;
    insert shareAccount;
  }
  /**
   * @description Create a account account relation share record to provide access to ccrm user
   * @name createAccountAccountRelationShare
   * @param recordId record Id to share
   * @param userId User to be share with
   */
  @future
  public static void createAccountAccountRelationShare(Id recordId, Id userId) {
    FinServ__AccountAccountRelation__Share sv = new FinServ__AccountAccountRelation__Share();
    sv.ParentId = recordId;
    sv.AccessLevel = 'Read';
    sv.RowCause = 'Manual';
    sv.UserOrGroupId = userId;
    insert sv;
  }
  /**
   * @description Create non-reciprocal role records
   * @name createNonReciprocalRole
   * @param name [Optional] the name of the reciprocal role
   * @return FinServ__ReciprocalRole__c the newly created record
   */
  public static FinServ__ReciprocalRole__c createNonReciprocalRole(
    String name
  ) {
    name = name == null ? new Faker('AU').randomString(10) : name;
    FinServ__ReciprocalRole__c nonReciprocalRole = new FinServ__ReciprocalRole__c(
      RecordTypeId = CCRMConstants.RECIPROCAL_CONTACT_ROLE_RT_ID,
      Name = name,
      FinServ__InverseRole__c = name,
      OCV_Role__c = name,
      FinServ__CreateInverseRole__c = false
    );
    insert nonReciprocalRole;
    return nonReciprocalRole;
  }

  /**
   * @description Create Users with lan id
   * @name createUsersWithLanId
   * @param setOfLanId Lan IDs
   * @return `List<User>`
   */
  public static List<User> createUsersWithLanId(Set<String> setOfLanId) {
    List<User> newUsers = new List<User>();
    for (String key : setOfLanId) {
      User ccrmUser = (User) FakerFactory.make(new FakerUserFactory());
      ccrmUser.UserRoleId = commercialBankerRole.Id;
      ccrmUser.ProfileId = anzStandardProfileId;
      ccrmUser.Lan_Id__c = key;
      newUsers.add(ccrmUser);
    }
    Database.insert(newUsers);
    return newUsers;
  }

  /**
   * @description Create Controlling Posts with Lan ID
   * @name createControllingPostsWithLanId
   * @param setOfLanId Lan IDs
   * @return `List<Controlling_Post__c>`
   */
  public static List<Controlling_Post__c> createControllingPostsWithLanId(
    Set<String> setOfLanId
  ) {
    List<Controlling_Post__c> newCPs = new List<Controlling_Post__c>();
    for (String key : setOfLanId) {
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID_CancelFag__c = false;
      cp1.Name = 'Controlling Post ' + key;
      cp1.CPID_LanID__c = key;
      newCPs.add(cp1);
    }
    Database.insert(newCPs);
    return newCPs;
  }

  /**
   * @description Create a CCRM Base User with commercial Segment
   * @name createCCRMBaseUserWithCS
   * @param commercialSegment commercial segment of the user
   * @return ANZ CCRM Standard User with CCRM Base User Permission Set & Opportunity Access
   */
  public static User createCCRMBaseUserWithCS(String commercialSegment) {
    String staticNumber =
      Datetime.now().format('MMddHHmmss') + (Math.random() * 10);
    ccrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
    ccrmBaseUser.FirstName = 'BaseUser' + staticNumber;
    ccrmBaseUser.LastName = 'CCRM ' + commercialSegment;
    ccrmBaseUser.UserRoleId = commercialBankerRole.Id;
    ccrmBaseUser.ProfileId = anzStandardProfileId;
    ccrmBaseUser.Commercial_Segment__c = commercialSegment;
    insert ccrmBaseUser;
    TestUtil.assignPermissionSetGroups(
      new List<String>{ 'CCRM_Banker' },
      new List<User>{ ccrmBaseUser }
    );
    return ccrmBaseUser;
  }

  /**
   * @description Create a static opp
   * @name createStaticOpportunityData
   * @param oppId opportunity Id
   * @param oppName opportunity name
   * @param recordTypeId opportunity record type Id
   * @param stageName opportunity stage name
   * @return Opportunity
   */
  public static Opportunity createStaticOpportunityData(
    String oppId,
    String oppName,
    String recordTypeId,
    String stageName
  ) {
    Opportunity opp = new Opportunity();
    opp.Id = oppId;
    opp.Name = oppName;
    opp.StageName = stageName;
    opp.RecordTypeId = recordTypeId;
    return opp;
  }

  /**
   * @description Create Deposit Account test context
   * @name createDepositAccountContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createDepositAccountContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.CCRMDepositAccountTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'DepositAccount'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }
  /**
   * @description Create Credit Card test context
   * @name createDepositAccountContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createCreditCardContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.CCRMCreditCardQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'CreditCard'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMDepositAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_depositResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMCreditCardQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_creditCardResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'pcb-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalCustomerBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_totalBalanceResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalTerminalsMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_totalTerminalResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalAssetFinanceBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_totalAssetBalanceResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description Create Financial Account record
   * @param primaryOwner Primary Owner of account
   * @param jointOwner Joint Owner of account
   * @param doInsert Insert record or just initialise
   * @return FinServ__FinancialAccount__c FinServ__FinancialAccount__c record
   */
  public static FinServ__FinancialAccount__c createFinancialAccount(
    Id primaryOwner,
    Id jointOwner,
    Boolean doInsert
  ) {
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      Name = 'Everyday Account',
      FinServ__Balance__c = 200,
      FinServ__CurrentPostedBalance__c = 200,
      FinServ__Status__c = 'Active',
      RecordTypeId = CCRMConstants.FA_RT_ID,
      FinServ__PrimaryOwner__c = primaryOwner,
      FinServ__JointOwner__c = jointOwner,
      Account_Key__c = '342490981',
      Product_Type__c = 'CAP-CIS:DDA',
      FinServ__FinancialAccountNumber__c = '000000000'
    );
    if (doInsert) {
      insert finAccount;
    }
    return finAccount;
  }

  /**
   * @description Create Financial Account Role record
   * @param relatedAccount Id of account
   * @param financialAccount FinServ__FinancialAccount__c record Id
   * @param doInsert Insert record or just initialise
   * @return FinServ__FinancialAccountRole__c FinServ__FinancialAccountRole__c record
   */
  public static FinServ__FinancialAccountRole__c createFinancialAccountRole(
    Id relatedAccount,
    Id financialAccount,
    Boolean doInsert
  ) {
    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = relatedAccount,
      FinServ__Active__c = true,
      FinServ__FinancialAccount__c = financialAccount,
      Role_Type__c = 'BCC',
      RecordTypeId = CCRMConstants.FAR_RT_ID
    );
    if (doInsert) {
      insert finAccountRole;
    }
    return finAccountRole;
  }
  /**
   * @description creates and/or returns list of CCRMA2ZReview records for testing purpose
   * note that the lookup on these records are not populated
   * @param count
   * @param ownerUser
   * @return List<A_Z_Review__c> list of reviews without lookup
   **/
  public static List<A_Z_Review__c> createCCRMA2ZReviews(
    Integer count,
    User ownerUser
  ) {
    count = count == null || count == 0 ? 1 : count;

    List<A_Z_Review__c> listOfReviews = new List<A_Z_Review__c>();
    for (Integer i = 1; i <= count; i++) {
      A_Z_Review__c review = new A_Z_Review__c(
        Name = 'Test' + i,
        Status__c = 'In Progress',
        RecordTypeId = CCRMConstants.AZ_REVIEW_RT_ID,
        Business_Details__c = 'Test 1234123412341234',
        Personal_Banking__c = 'Test 1234123412341234',
        Transaction_Banking__c = 'Test 1234123412341234',
        Borrowing_OFI_Relationship__c = 'Test 1234123412341234'
      );
      if (ownerUser != null) {
        review.OwnerId = ownerUser.Id;
      }
      listOfReviews.add(review);
    }
    return listOfReviews;
  }

  /**
   * @description Create Interaction Data With Opportunity
   * @name createInteractionDataWithOpportunity
   * @param count Count of interaction records needed to be created
   * @param ownerUser User to which created records should be assigned.
   * @param oppId opportunity Id
   * @return Returns List<Interaction>
   */
  public static List<Interaction> createInteractionDataWithOpportunity(
    Integer count,
    User ownerUser,
    Id oppId
  ) {
    //Default Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 1; i <= count; i++) {
      Interaction rec = new Interaction();
      rec.Name = 'Test ' + i;
      rec.recordTypeId = CCRMConstants.INTERACTION_CCRM_RT_ID;
      rec.Category__c = CCRMConstants.INTER_CAT_GENERAL;
      rec.InteractionType = 'Call';
      rec.Opportunity__c = oppId;
      rec.StartTime = System.now();
      rec.Optional_Notes__c = 'Test Optional Notes';
      if (ownerUser != null) {
        rec.OwnerId = ownerUser.Id;
      }
      interactionList.add(rec);
    }
    return interactionList;
  }

  /**
   * @description Create CAP Interaction Data with Account and Customer
   * @param count
   * @param ownerUser
   * @param accId
   * @param finAccId
   * @return List<Interaction>
   **/
  public static List<Interaction> createCapInteractionData(
    Integer count,
    User ownerUser,
    String accId,
    Id finAccId
  ) {
    count = count == null || count == 0 ? 1 : count;
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 1; i <= count; i++) {
      Interaction rec = new Interaction();
      rec.Name = 'Test ' + i;
      rec.Financial_Account__c = finAccId;
      rec.AccountId = accId;
      rec.Comment__c = 'Test Comment';
      rec.Permanent__c = true;
      rec.Expiry_Date__c = System.Today();

      rec.recordTypeId = CCRMConstants.INTERACTION_CCRM_RT_ID;
      rec.Category__c = CCRMConstants.INTER_CAT_CAPDIARYCOMMENTS;
      rec.InteractionType = 'Call';

      if (ownerUser != null) {
        rec.OwnerId = ownerUser.Id;
      }
      interactionList.add(rec);
    }
    return interactionList;
  }

  /**
   * @description create Email Message record Instance
   * @param emId email message Id
   * @return EmailMessage Email message instance
   */
  public static EmailMessage createEmailMessageInstance(Id emId) {
    EmailMessage emRecord = new EmailMessage(
      Id = emId,
      status = '3',
      fromAddress = 'idruser@anz.com',
      fromName = 'Test ANZ',
      toAddress = 'idruser2@anz.com',
      ccAddress = 'idruser@anz.com; testuser2@anz2.com',
      Subject = 'Hello',
      HtmlBody = 'Hello World',
      Incoming = false,
      Attachment_Notes__c = 'This email has no attachments',
      CreatedBy = new User(
        Profile = new Profile(Name = 'ANZ CCRM Standard User')
      )
    );
    return emRecord;
  }

  /**
   * @description Create Account Relationship test context for API
   * @name createAccountRelationshipContextForAPI
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createAccountRelationshipContextForAPI() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.CCRMAccountRelationshipQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'AccountRelationship'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }

  /**
   * @description Create Account Relationship test context for SOQL
   * @name createAccountRelationshipContextForSOQL
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createAccountRelationshipContextForSOQL() {
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContextForSOQL(
      'AccountRelationship'
    );
    conn.query(context);
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMAccountRelationshipQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_accountRelationship');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'account-relationship-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description Create App Form with opportunity
   * @name createAppForm
   * @param count Count of app form records needed to be created
   * @param oppId opportunity Id
   * @return Returns List<ApplicationForm>
   */
  public static List<ApplicationForm> createAppForm(Integer count, Id oppId) {
    //Default Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;
    List<ApplicationForm> appFormList = new List<ApplicationForm>();
    for (Integer i = 1; i <= count; i++) {
      ApplicationForm rec = new ApplicationForm();
      rec.Application_Amount__c = 23 + i;
      rec.OpportunityId = oppId;
      rec.Stage = 'Initiated';
      rec.usageType = 'Other';
      appFormList.add(rec);
    }
    return appFormList;
  }
  /**
   * @description Create App Form product
   * @name createAppFormProduct
   * @param count Count of app form product records needed to be created
   * @param appFormId app form Id
   * @param stage stage name
   * @return Returns List<ApplicationFormProduct>
   */
  public static List<ApplicationFormProduct> createAppFormProduct(
    Integer count,
    Id appFormId,
    String stage
  ) {
    //Default Count to 200 when in excess.
    count = count == null || count == 0 ? 1 : count;
    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>();
    for (Integer i = 1; i <= count; i++) {
      ApplicationFormProduct rec = new ApplicationFormProduct();
      rec.Stage = stage;
      rec.ApplicationFormId = appFormId;
      rec.Close_Date__c = DateTimeUtils.getNextWeekdayDate(4);
      appFormProductList.add(rec);
    }
    return appFormProductList;
  }

  /**
   * @description Create Term Deposit test context for API
   * @name createTermDepositContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createTermDepositContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.CCRMTermDepositTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'TermDeposit'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMTermDepositTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_termDepositResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description Create Balance History test context
   * @name createBalanceHistoryContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createBalanceHistoryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.CCRMBalanceHistoryQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'BalanceHistory'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMBalanceHistoryQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_balanceHistory');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'balance-history-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
