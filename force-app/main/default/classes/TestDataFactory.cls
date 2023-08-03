/**
 * @description This class is to provide generic setups configs for unit tests.
 * @group Utils
 */
@isTest
public without sharing class TestDataFactory {
  public static User thisUser = [
    SELECT Id
    FROM User
    WHERE Id = :UserInfo.getUserId()
  ];

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
    }
    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(recordTypeDeveloperName)
      .getRecordTypeId();
    newCase.Dispute_Reason__c = getDisputeReason(recordTypeDeveloperName)[0];
    return newCase;
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
        'Incorrect Customer Reference Number',
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
}
