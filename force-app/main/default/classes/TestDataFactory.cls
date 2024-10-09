/**
 * @description This class is to provide generic setups configs for unit tests.
 * @group Utils
 * Note ExcessivePublicCount Surpressed : The count of the public count here is 25. Since this is a TestDataFactory class,we need to add generic data creation logic so suppressing this wrarning in order to create the pr.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity')
@isTest
public without sharing class TestDataFactory {
  public static User thisUser = new User(Id = UserInfo.getUserId());

  public static Id anzxStandardProfileId = CommonUtil.getProfileByName(
      'ANZx Standard User'
    )
    .Id;
  private static User anzxUser;

  /**
   * @description Gets the card dispute agent user. If the user does not exist, it creates a new user with role and p/s of Card_Dispute_Agent.
   * @return The card dispute agent user.
   */
  public static User cardDisputeAgentUser {
    public get {
      if (cardDisputeAgentUser == null) {
        System.runAs(thisUser) {
          cardDisputeAgentUser = getANZxUser('Card_Dispute_Agent');
        }
      }
      return cardDisputeAgentUser;
    }
    private set;
  }

  /**
   * @description Shares a Case record with the current user with edit access level.
   * @param theCase The Case record to be shared.
   */
  public static void shareCaseWithUser(Case theCase) {
    insert new CaseShare(
      CaseId = theCase.Id,
      UserOrGroupId = UserInfo.getUserId(),
      CaseAccessLevel = 'Edit'
    );
  }

  /**
   * @description Create Account record
   * @param doInsert the Account record type
   * @return Account
   */
  public static Account createAccount(Boolean doInsert) {
    return createAccount('TestAccount', doInsert);
  }

  /**
   * @description Create Account record
   * @param name Name of the Account
   * @param doInsert Insert record or just initialise
   * @return Account
   */
  public static Account createAccount(String name, Boolean doInsert) {
    Faker faker = new Faker('AU');
    Account accnt = new Account(
      Name = name,
      Display_Name__c = faker.randomString(5),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(15)
    );
    if (doInsert) {
      insert accnt;
    }
    return accnt;
  }

  /**
   * @description Create Person Account record
   *    * @param ocvId OCV Id of the customer
   * @param doInsert Insert record or just initialise
   * @return Person Account
   */
  public static Account createPersonAccount(String ocvId, Boolean doInsert) {
    Faker faker = new Faker('AU');
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account personAcc = new Account();
    personAcc.RecordTypeId = personAccountRecordTypeId;
    personAcc.FirstName = faker.randomString(5);
    personAcc.LastName = faker.randomString(5);
    personAcc.OCV_ID__c = String.isNotBlank(ocvId)
      ? ocvId
      : faker.randomString(10);
    personAcc.ANZx_Customer__c = true;
    personAcc.External_Id__c = faker.randomString(15);
    if (doInsert) {
      insert personAcc;
    }

    return personAcc;
  }

  /**
   * @description Create Financial Account record
   * @param count Number of records to create
   * @param doInsert Insert record or just initialise
   * @return Account
   */
  public static List<FinServ__FinancialAccount__c> createFinancialAccount(
    Integer count,
    Boolean doInsert
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    Account acc = createAccount(true);
    for (Integer i = 0; i < count; i++) {
      FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
        Name = 'Everyday Account' + i,
        FinServ__Balance__c = 200,
        FinServ__CurrentPostedBalance__c = 200,
        FinServ__Status__c = 'Active',
        RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
        FinServ__PrimaryOwner__c = acc.Id,
        Account_Key__c = '342490981' + i,
        FinServ__FinancialAccountNumber__c = '000000000'
      );

      financialAccounts.add(finAccount);
    }
    if (doInsert) {
      insert financialAccounts;
    }
    return financialAccounts;
  }

  /**
   * @description map to store the schema map of Case Fields
   */
  public static Map<String, Schema.SObjectField> caseFieldSchemaMap {
    get {
      if (caseFieldSchemaMap != null) {
        return caseFieldSchemaMap;
      }
      caseFieldSchemaMap = Schema.Case.SObjectType.getDescribe()
        .fields.getMap();
      return caseFieldSchemaMap;
    }
    set;
  }

  /**
   * @description Create Case record
   * @param recordTypeDeveloperName the Case record type
   * @return Case
   */
  public static Case createCase(String recordTypeDeveloperName) {
    Case newCase;
    switch on recordTypeDeveloperName {
      when 'ATM_Dispute' {
        newCase = createATMDisputeCase();
      }
      when 'BPAY_Dispute' {
        newCase = createBPAYDisputeCase();
      }
      when 'Card_Dispute' {
        newCase = createCardDisputeCase();
      }
      when 'Direct_Debit_Dispute' {
        newCase = createDirectDebitDisputeCase();
      }
      when 'Direct_Entry_Dispute' {
        newCase = createDirectEntryDisputeCase();
      }
      when 'NPP_Dispute' {
        newCase = createNPPDisputeCase();
      }
      when 'Credit_Referral' {
        newCase = createCreditReferralCase();
      }
      when 'PayTo_Dispute' {
        newCase = TestHelper.createPayToDispute();
      }
    }
    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(recordTypeDeveloperName)
      .getRecordTypeId();
    List<String> listDispute = getDisputeReason(recordTypeDeveloperName);
    newCase.Dispute_Reason__c = listDispute == null ? '' : listDispute[0];
    return newCase;
  }

  /**
   * @description Populate Recordtype object
   * @param record SObject record
   * @param rt RecordType record
   * @return SObject
   */
  public static SObject populateRecordType(SObject record, RecordType rt) {
    String objString = JSON.serialize(record);
    Integer index = objString.indexOf('"RecordTypeId":');
    if (index != -1) {
      objString = objString.replace(
        '"RecordTypeId":',
        '"RecordType":' + JSON.serialize(rt) + ',"RecordTypeId":'
      );
    }
    switch on record.getSObjectType().toString() {
      when 'Case' {
        return (Case) JSON.deserialize((objString), Case.class);
      }
      when 'Account' {
        return (Account) JSON.deserialize((objString), Account.class);
      }
    }

    return null;
  }

  /**
   * @description Create Case record with fields relevant to ATM_Dispute
   * @return Case
   */
  public static Case createATMDisputeCase() {
    Case theCase = new Case();
    theCase.Card_In_Possession_During_Transaction__c = 'NA';
    theCase.Description = 'ATM Dispute Case Description Test_Text_32k';
    theCase.Has_The_Card_Been_Stopped__c = 'NA';
    theCase.Received_Amount__c = 1000.00;
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_ATM_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_ATM_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to BPAY_Dispute
   * @return Case
   */
  public static Case createBPAYDisputeCase() {
    Case theCase = new Case();
    theCase.Correct_Customer_Reference_Number__c = 'CCRN_Text_20';
    theCase.Customer_Reference_Number__c = 'CRN_Text_20';
    theCase.Description = 'BPAY Dispute Case Description Test_Text_32k';
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction BPAY Id Test_BPAY_Text_255';
    theCase.Transaction_UUID__c = 'Transaction BPAY UUID Test_BPAY_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to Card_Dispute
   * @return Case
   */
  public static Case createCardDisputeCase() {
    Case theCase = new Case();
    theCase.Amount_Of_Credit_Due__c = 1000.00;
    theCase.Card_In_Possession_During_Transaction__c = 'Yes';
    theCase.Customer_Contacted_Merchant__c = 'Yes';
    theCase.Date_Goods_Were_Returned_Or_Services_can__c = Date.today();
    theCase.Date_Of_Expected_Delivery_Service__c = Date.today();
    theCase.Description = 'Card Dispute Case Description Test_Text_32k';
    theCase.Goods_Or_Services_Returned__c = 'Yes';
    theCase.Has_The_Card_Been_Stopped__c = 'Yes';
    theCase.Is_The_Card_Lost_Stolen__c = 'No';
    theCase.Merchant_Description__c = 'Merchant Description Test_Card_Text_255';
    theCase.Refund_Request_Date__c = Date.today();
    theCase.Regular_Payment_Cancellation_Date__c = Date.today();
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_Card_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_Card_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to Direct_Debit_Dispute
   * @return Case
   */
  public static Case createDirectDebitDisputeCase() {
    Case theCase = new Case();
    theCase.Description = 'Direct Debit Dispute Case Description Test_Text_32k';
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_DD_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_DD_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to Credit_Referral
   * @return Case
   */
  public static Case createCreditReferralCase() {
    Case theCase = new Case();
    theCase.Description = 'Credit Referral Case Description Test_Text_32k';
    theCase.Status = 'Open';
    theCase.Origin = 'ANZ Plus App';
    theCase.Transaction_Id__c = 'Transaction Id Test_DD_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_DD_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to Direct_Entry_Dispute
   * @return Case
   */
  public static Case createDirectEntryDisputeCase() {
    Case theCase = new Case();
    theCase.Amount_Of_Authorised_Transaction__c = 1000.00;
    theCase.Description = 'Direct Entry Dispute Case Description Test_Text_32k';
    theCase.Intended_Account_BSB__c = '012345';
    theCase.Intended_Account_Name__c = 'Intended Account Name Test_Text_255';
    theCase.Intended_Account_Number__c = '0123456789';
    theCase.Is_this_a_Business_Customer__c = 'Yes';
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_DE_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_DE_Text_255';
    return theCase;
  }

  /**
   * @description Create Case record with fields relevant to NPP_Dispute
   * @return Case
   */
  public static Case createNPPDisputeCase() {
    Case theCase = new Case();
    theCase.Description = 'NPP Dispute Case Description Test_Text_32k';
    theCase.Intended_Account_BSB__c = '012345';
    theCase.Intended_Account_Name__c = 'Intended Account Name Test_Text_255';
    theCase.Intended_Account_Number__c = '0123456789';
    theCase.Intended_Amount__c = 1000.00;
    theCase.Intended_Pay_Id_Type__c = 'ABN';
    theCase.Intended_Pay_Id_Value__c = 'Intended Pay Id Value Test_Text_255';
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_NPP_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_NPP_Text_255';
    return theCase;
  }

  /**
   * @description get Dispute reason respective to the type of Dispute Cae
   * @param recordTypeDeveloperName the Case record type
   * @return List<String>
   */
  public static List<String> getDisputeReason(String recordTypeDeveloperName) {
    Map<String, List<String>> reasonsByRecordtype = new Map<String, List<String>>{
      'ATM_Dispute' => new List<String>{
        'Duplicate Transaction',
        'Unauthorised Transaction',
        'Cash Dispensing Error'
      },
      'BPAY_Dispute' => new List<String>{
        'Duplicate Transaction',
        'Unauthorised Transaction',
        'Incorrect Amount',
        'Incorrect Biller Code',
        'Unintended Payment',
        'Payment not received by biller'
      },
      'Card_Dispute' => new List<String>{
        'Don\'t recognise the transaction',
        'Didn\'t authorise transaction',
        'Charged more than once',
        'Charged Incorrect Amount',
        'Charged for a cancelled payment',
        'Refund error',
        'Product Didn\'t Arrive',
        'Product Defective or Unsatisfactory'
      },
      'Direct_Debit_Dispute' => new List<String>{
        'Unauthorised Transaction',
        'Fraudulent transaction',
        'Payment debited after debit authority cancelled',
        'Payment Duplicated',
        'Payment Overdrawn',
        'Claim not for value'
      },
      'Direct_Entry_Dispute' => new List<String>{
        'Duplicate Transaction',
        'Unauthorised Transaction',
        'Incorrect BSB/ Account number',
        'Incorrect Amount',
        'Payee has not received funds'
      },
      'NPP_Dispute' => new List<String>{
        'Amount not received by payee',
        'Duplicate Transaction',
        'Unauthorised Transaction',
        'Incorrect Account Details',
        'Incorrect Amount Transferred',
        'Return money received from an unknown person'
      },
      'PayTo_Dispute' => new List<String>{
        'Wrong Amount',
        'Duplicate Transaction',
        'Not as per agreement'
      }
    };
    return reasonsByRecordtype.get(recordTypeDeveloperName);
  }

  /**
   * @description modify the values of Case's fields
   * @param theCase the Case record
   * @param caseMap the Case data with fields and values
   * @return Case
   */
  public static Case modifyCase(Case theCase, Map<String, Object> caseMap) {
    for (String fieldName : caseMap.keySet()) {
      Schema.SObjectField fieldAPI = caseFieldSchemaMap.get(fieldName);
      theCase.put(fieldAPI, caseMap.get(fieldName));
    }
    return theCase;
  }

  /**
   * @description modify the values of Case's fields
   * @param theCase the Case record
   * @param fieldName field to be changed
   * @param value value the field needs to be updated with
   * @return Case
   */
  public static Case modifyCase(Case theCase, String fieldName, Object value) {
    try {
      Schema.SObjectField fieldAPI = caseFieldSchemaMap.get(fieldName.trim());
      theCase.put(fieldAPI, value);
    } catch (Exception e) {
      System.debug('fieldName: ' + fieldName);
      System.debug('value: ' + value);
      throw e;
    }
    return theCase;
  }

  /**
   * @description update the Case with modified values
   * @param theCase the Case record
   * @param caseDataMap the Case data with fields and values
   * @return Case
   */
  public static Case updateCase(Case theCase, Map<String, Object> caseDataMap) {
    String fieldsToBeQueried = '';
    List<String> fieldsList = new List<String>(caseDataMap.keySet());
    for (Integer i = 0; i < fieldsList.size(); i++) {
      fieldsToBeQueried += fieldsList[i];
      if (i != fieldsList.size() - 1) {
        fieldsToBeQueried += ', ';
      }
    }
    String query =
      'Select Id, ' +
      fieldsToBeQueried +
      ' From Case Where Id = \'' +
      theCase.Id +
      '\'';
    theCase = Database.query(query);
    theCase = modifyCase(theCase, caseDataMap);
    update theCase;
    return theCase;
  }

  /**
   * @description create the Account Record for Dispute Cases
   * @param suffix String
   * @return Account
   */
  public static Account createTestAccountForDisputeCases(String suffix) {
    Account newAccount = new Account();
    newAccount.Name = 'Test Account ' + suffix;
    newAccount.Display_Name__c = 'Test Account ' + suffix;
    newAccount.OCV_ID__c = 'OCV00000000' + suffix;
    newAccount.ANZx_Customer__c = true;
    newAccount.External_Id__c = 'EXTERNALID_00' + suffix;
    return newAccount;
  }

  /**
   * @description create the Account Record for Dispute Cases
   * @return Account
   */
  public static Account createTestAccountForDisputeCases() {
    return createTestAccountForDisputeCases('0');
  }

  /**
   * @description create the FinServ__FinancialAccount__c Record for Dispute Cases
   * @param suffix String
   * @return FinServ__FinancialAccount__c
   */
  public static FinServ__FinancialAccount__c createTestFinAccountForDisputeCases(
    String suffix
  ) {
    FinServ__FinancialAccount__c newFinServFinancialAccount = new FinServ__FinancialAccount__c();
    newFinServFinancialAccount.Name = 'Test Account ' + suffix;
    newFinServFinancialAccount.FinServ__Balance__c = 400;
    newFinServFinancialAccount.FinServ__CurrentPostedBalance__c = 400;
    newFinServFinancialAccount.FinServ__Status__c = 'Active';
    newFinServFinancialAccount.RecordTypeId = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;
    newFinServFinancialAccount.Account_Key__c = 'OCV00000000' + suffix;
    return newFinServFinancialAccount;
  }

  /**
   * @description create the FinServ__FinancialAccount__c Record for Dispute Cases
   * @return FinServ__FinancialAccount__c
   */
  public static FinServ__FinancialAccount__c createTestFinAccountForDisputeCases() {
    return createTestFinAccountForDisputeCases('0');
  }

  /**
   * @description create the Loan Application Records
   * @param suffix String
   * @return ResidentialLoanApplication
   */
  public static ResidentialLoanApplication createTestResidentialLoanApplication(
    String suffix
  ) {
    return new ResidentialLoanApplication(
      Name = 'Test Loan Application ' + suffix
    );
  }

  /**
   * @description create a ResidentialLoanApplication Record
   * @return ResidentialLoanApplication
   */
  public static ResidentialLoanApplication createTestResidentialLoanApplication() {
    return createTestResidentialLoanApplication('0');
  }

  /**
   * @description Create Interaction Record
   * @param recordTypeId recordTypeId of the interaction
   * @param interactionPurpose recordTypeId of the interaction
   * @param customerName recordTypeId of the interaction
   * @param startTime recordTypeId of the interaction
   * @param doInsert Insert record or just initialise
   * @return Interaction
   */
  public static Interaction createInteraction(
    Id recordTypeId,
    String interactionPurpose,
    String customerName,
    Datetime startTime,
    Boolean doInsert
  ) {
    Faker faker = new Faker('AU');
    Interaction newInteraction = new Interaction();
    newInteraction.RecordTypeId = recordTypeId;
    newInteraction.Name = String.isBlank(customerName)
      ? faker.randomString(10)
      : customerName;
    newInteraction.StartTime = startTime == null ? System.now() : startTime;
    newInteraction.Interaction_Purpose__c = interactionPurpose;

    if (doInsert) {
      insert newInteraction;
    }

    return newInteraction;
  }

  /**
   * @description Create ANZx User
   * @name createANZxUser
   * @param roleDevName User Role Developer Name
   * @param psgDevName Permission Set Group Developer Name
   * @return ANZx User
   */
  public static User createANZxUser(String roleDevName, String psgDevName) {
    anzxUser = (User) FakerFactory.make(new FakerUserFactory());
    anzxUser.FirstName = roleDevName;
    anzxUser.UserRoleId = CommonUtil.getUserRoleByDevName(roleDevName).Id;
    anzxUser.ProfileId = anzxStandardProfileId;
    insert anzxUser;

    // get the PSG by name (may have been modified in deployment)
    PermissionSetGroup psg = [
      SELECT Id, Status
      FROM PermissionSetGroup
      WHERE DeveloperName = :psgDevName
    ];

    // force calculation of the PSG if it is not already Updated
    if (psg.Status != 'Updated') {
      Test.calculatePermissionSetGroup(psg.Id);
    }

    // assign PSG to current user (this fails if PSG is Outdated)
    insert new PermissionSetAssignment(
      PermissionSetGroupId = psg.Id,
      AssigneeId = anzxUser.Id
    );

    return anzxUser;
  }

  /**
   * @description Create ANZx User with User Role Developer Name and Permission Set Group Developer Name are same
   * @name createANZxUser
   * @param roleOrPSGDevName User Role Developer Name or Permission Set Group Developer Name
   * @return ANZx User
   */
  public static User createANZxUser(String roleOrPSGDevName) {
    return createANZxUser(roleOrPSGDevName, roleOrPSGDevName);
  }

  /**
   * @description Get a ANZx User, if such user not exists yet then create one
   * @name getANZxUser
   * @param roleDevName User Role Developer Name
   * @return Integration User with ANZx User Permission Set.
   */
  public static User getANZxUser(String roleDevName) {
    if (anzxUser == null) {
      List<User> users = [
        SELECT Id
        FROM User
        WHERE ProfileId = :anzxStandardProfileId AND FirstName = :roleDevName
        LIMIT 1
      ];
      if (users.isEmpty()) {
        anzxUser = createANZxUser(roleDevName);
      } else {
        anzxUser = users[0];
      }
    }
    return anzxUser;
  }

  /**
   * @description create the Settlement records
   * @param loanAppId Loan app id to link to settlement
   * @return Settlement__c
   */
  public static Settlement__c createSettlement(String loanAppId) {
    return new Settlement__c(
      Loan_Application_Number__c = loanAppId,
      Type__c = 'TYPE_REFINANCE_OFI'
    );
  }

  /**
   * @description create the POI records
   * @param settlementId Settlement id to link
   * @return Proof_of_Insurance__c
   */
  public static Proof_of_Insurance__c createPOI(String settlementId) {
    return new Proof_of_Insurance__c(Settlement_ID__c = settlementId);
  }
  /**
   * @description create Business Record Type Account
   * @param externalId String
   * @param recordTypeId Id
   * @param ocvId String
   * @return Account
   */
  public static Account createBusinessRecordTypeAccount(
    String externalId,
    Id recordTypeId,
    String ocvId
  ) {
    Account acct = new Account();
    acct.Name = 'John Citizen Pty Ltd';
    acct.External_Id__c = externalId;
    acct.RecordTypeId = recordTypeId;
    acct.OCV_ID__c = ocvId;
    insert acct;
    return acct;
  }
  /**
   * @description create C360 Financial Account
   * @param recordTypeId Id
   * @param productType String
   * @param accountId Id
   * @param accountKey String
   * @param accountNum String
   * @return FinServ__FinancialAccount__c
   */
  public static FinServ__FinancialAccount__c createC360FinancialAccount(
    Id recordTypeId,
    String productType,
    Id accountId,
    String accountKey,
    String accountNum
  ) {
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      Name = 'Test',
      FinServ__Balance__c = 200,
      FinServ__CurrentPostedBalance__c = 200,
      FinServ__Status__c = 'Active',
      FinServ__FinancialAccountType__c = 'Savings',
      FinServ__PrimaryOwner__c = accountId,
      Account_Key__c = accountKey,
      FinServ__FinancialAccountNumber__c = accountNum,
      RecordTypeId = recordTypeId,
      Product_Type__c = productType
    );
    insert finAccount;
    return finAccount;
  }

  /**
   * @description To create test data for FinServ__FinancialAccount__c
   * @param recordTypeId Record type Id for the record
   * @param accountId Account Id for the relation
   * @param isInsert Boolean value to indicate if the record needs to be inserted or not
   * @return FinServ__FinancialAccount__c record
   */
  public static FinServ__FinancialAccount__c createFinancialAccountRecord(
    Id recordTypeId,
    Id accountId,
    Boolean isInsert
  ) {
    Faker faker = new Faker('AU');
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = faker.randomString(20);
    finAccount.FinServ__Balance__c = faker.randomInteger(3);
    finAccount.FinServ__CurrentPostedBalance__c = faker.randomInteger(3);
    finAccount.FinServ__Status__c = 'Active';
    finAccount.RecordTypeId = recordTypeId;
    finAccount.FinServ__PrimaryOwner__c = accountId;
    finAccount.Account_Key__c = faker.randomString(9);
    finAccount.FinServ__FinancialAccountNumber__c = '123';
    finAccount.Number_Of_Signatures__c = '1';

    if (isInsert) {
      insert finAccount;
    } else {
      finAccount.Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      );
    }
    return finAccount;
  }

  /**
   * @description To create test data for Customer_Action__c
   * @param recordTypeId Record type Id for the record
   * @param accountId Account Id for the relation
   * @param financialAccountId Financial Account Id for the relation
   * @param isInsert Boolean value to indicate if the record needs to be inserted or not
   * @return Customer_Action__c record
   */
  public static Customer_Action__c createCustomerActionRecord(
    Id recordTypeId,
    Id accountId,
    Id financialAccountId,
    Boolean isInsert
  ) {
    Faker faker = new Faker('AU');
    Customer_Action__c ca = new Customer_Action__c();
    ca.RecordTypeId = recordTypeId;
    ca.Action__c = 'Update';
    ca.Customer__c = accountId;
    ca.Financial_Account__c = financialAccountId;
    ca.New_Value__c = '2';
    ca.Old_Value__c = '1';
    ca.Status__c = GetHelpFinancialAccountActions.CUSTOMER_ACTION_STATUS_PEDING;
    ca.Triggered_From__c = faker.randomString(10);

    if (isInsert) {
      insert ca;
    } else {
      ca.Id = Lib_FakeIdGenerator.getMockId(Customer_Action__c.SObjectType);
    }
    return ca;
  }

  /**
   * @description to create task record
   * @param recordTypeId Id
   * @param whoId Id
   * @param whatId Id
   * @param ownerId Id
   * @param isInsert Boolean
   * @return Task record
   */
  public static Task createTaskRecord(
    Id recordTypeId,
    Id whoId,
    Id whatId,
    Id ownerId,
    Boolean isInsert
  ) {
    Faker faker = new Faker('AU');
    Task tsk = new Task();
    tsk.recordtypeId = recordTypeId;
    tsk.Status = 'Not Started';
    tsk.Priority = 'Low';
    tsk.Subject = faker.randomString(15);
    tsk.WhatId = whatId;
    tsk.WhoId = whoId;
    tsk.OwnerId = ownerId;
    tsk.ActivityDate = null;
    tsk.Description = faker.randomString(30);

    if (isInsert) {
      insert tsk;
    } else {
      tsk.Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType);
    }
    return tsk;
  }

  /**
   * @description create the LoanApplicationFinancial records
   * @param loanAppId Loan app id to link to LoanApplicationFinancial
   * @return LoanApplicationFinancial
   */
  public static LoanApplicationFinancial createLoanApplicationFinancial(
    String loanAppId
  ) {
    Faker faker = new Faker('AU');
    return new LoanApplicationFinancial(
      LoanApplicationId = loanAppId,
      Name = Faker.randomString(10),
      LoanExclFinMortInsAmt = Faker.randomDecimal(16, 2)
    );
  }

  /**
   * @description create the action plan for external/internal settlement records
   */
  public static void createSettlementActionPlans() {
    List<ActionPlanTemplate> apTemplateList = new List<ActionPlanTemplate>();
    String extTemplateName = 'External Settlement Action Plan';
    String intTemplateName = 'Internal Settlement Action Plan';

    ActionPlanTemplate apTempExt = new ActionPlanTemplate();
    apTempExt.Name = extTemplateName;
    apTempExt.TargetEntityType = 'Settlement__c';
    apTempExt.ActionPlanType = 'Industries';
    apTemplateList.add(apTempExt);

    ActionPlanTemplate apTempInt = new ActionPlanTemplate();
    apTempInt.Name = intTemplateName;
    apTempInt.TargetEntityType = 'Settlement__c';
    apTempInt.ActionPlanType = 'Industries';
    apTemplateList.add(apTempInt);

    insert apTemplateList;

    createActionPlanItems(extTemplateName);
    createActionPlanItems(intTemplateName);
  }

  /**
   * @description create the action plan items
   * @param actionPlanName the action plan name to create items for
   */
  private static void createActionPlanItems(String actionPlanName) {
    ActionPlanTemplateVersion apTempVer = [
      SELECT Id, Status
      FROM ActionPlanTemplateVersion
      WHERE Name = :actionPlanName
      LIMIT 1
    ];

    //Create template items for action plan
    ActionPlanTemplateItem apTempItems = new ActionPlanTemplateItem();
    apTempItems.ActionPlanTemplateVersionId = apTempVer.Id;
    apTempItems.Name = 'Test';
    apTempItems.IsActive = true;
    apTempItems.IsRequired = false;
    apTempItems.ItemEntityType = 'Task';
    insert apTempItems;

    //Create action plan item values
    ActionPlanTemplateItemValue apTempItemValue = new ActionPlanTemplateItemValue();
    apTempItemValue.ActionPlanTemplateItemId = apTempItems.Id;
    apTempItemValue.ItemEntityFieldName = 'Task.Subject';
    apTempItemValue.Name = 'Test Name';
    apTempItemValue.ValueLiteral = 'Test Sample';
    insert apTempItemValue;

    //Set status to Final to "publish"
    apTempVer.Status = 'Final';
    update apTempVer;
  }

  /**
   * @description Create Loan Account summary test context
   * @name createLoanAccountSummaryContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createLoanAccountSummaryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new TestDataFactory.CCRMLoanAccountSummaryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'LoanAccount'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }

  /**
   * @description Create Loan Account detail test context
   * @name createLoanAccountDetailContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createLoanAccountDetailContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new TestDataFactory.CCRMLoanAccountDetailTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContextWithExternalId(
      'LoanAccount'
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
  public class CCRMLoanAccountSummaryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_loanAccountResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'ils-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMLoanAccountDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_loanDetailResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'ils-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
