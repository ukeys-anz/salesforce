/**
 * @description This class is to provide generic setups configs for unit tests.
 * @group Utils
 */
public without sharing class TestDataFactory {
  /**
   * @description Create Case record
   * @param caseRecordTypeName the Case record type
   * @return Case
   */
  public static Case createCase(String caseRecordTypeName) {
    Case newCase = new Case();
    newCase.Amount_Of_Authorised_Transaction__c = 1000.00;
    newCase.Amount_Of_Credit_Due__c = 1000.00;
    newCase.Card_In_Possession_During_Transaction__c = 'Yes';
    newCase.Card_Token_Number__c = '0123456789';
    newCase.Correct_Customer_Reference_Number__c = 'CCRN_Test_20';
    newCase.Customer_Contacted_Merchant__c = 'Yes';
    newCase.Customer_Reference_Number__c = 'CRN_Text_20';
    newCase.Date_Of_Expected_Delivery_Service__c = Date.today();
    newCase.Effective_Date__c = Date.today();
    newCase.Description = 'Description 0123456789 Text Test';
    newCase.Has_The_Card_Been_Stopped__c = 'Yes';
    newCase.IDR_Account_Card_Policy_Number__c = '0123456789';
    newCase.IDR_Complainant_Desired_Outcome__c = 'IDR_Complainant_Desired_Outcome__c 0123 4567 8901 Text Test';
    newCase.IDR_Description_of_Outcome__c = 'IDR_Description_of_Outcome__c 0123456789 Text Test';
    newCase.IDR_Systemic_Issue_Description__c = 'IDR_Systemic_Issue_Description__c 0123456789 Text Test';
    newCase.IDR_Customer_Number__c = '0123456789';
    newCase.Intended_Account_BSB__c = '012345';
    newCase.Intended_Account_Name__c = 'Intended_Account_Name_Text_255';
    newCase.Intended_Account_Number__c = '0123456789';
    newCase.Intended_Amount__c = 1000.00;
    newCase.Intended_Pay_Id_Type__c = 'ABN';
    newCase.Intended_Pay_Id_Value__c = 'Intended_Pay_Id_Value_Text_255';
    newCase.Is_The_Card_Lost_Stolen__c = 'Lost';
    newCase.Is_this_a_Business_Customer__c = 'Yes';
    newCase.Merchant_Description__c = 'Merchant_Description_Text_255';
    newCase.Received_Amount__c = 1200.00;
    newCase.Refund_Request_Date__c = Date.today();
    newCase.Regular_Payment_Cancellation_Date__c = Date.today();
    newCase.Transaction_Id__c = 'Transaction_Id_Text_255';
    newCase.Transaction_UUID__c = 'Transaction_UUID_Text_255';
    newCase.Submitted__c = false;
    newCase.Status = 'Open';

    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(caseRecordTypeName)
      .getRecordTypeId();
    return newCase;
  }

  /**
   * @description get Dispute reason respective to the type of Dispute Cae
   * @param caseRecordTypeName the Case record type
   * @return List<String>
   */
  public static List<String> getDisputeReason(String caseRecordTypeName) {
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
    return reasonsByRecordtype.get(caseRecordTypeName);
  }

  /**
   * @description modify the values of Case's fields
   * @param theCase the Case record
   * @param caseMap the Case data with fields and values
   * @return Case
   */
  public static Case modifyCase(Case theCase, Map<String, Object> caseMap) {
    Map<String, Schema.SObjectField> fieldSchemaMap = Schema.Case.SObjectType.getDescribe()
      .fields.getMap();
    for (String fieldName : caseMap.keySet()) {
      Schema.SObjectField fieldAPI = fieldSchemaMap.get(fieldName);
      theCase.put(fieldAPI, caseMap.get(fieldName));
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
   * @description insert the Dispute Case
   * @param caseRecordTypeName the Case record type
   * @param relatedAccountOCVId the OCV ID to identify the Account and Financial Account
   * @return Case
   */
  public static Case insertDisputeCase(
    String caseRecordTypeName,
    String relatedAccountOCVId
  ) {
    Account account = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = :relatedAccountOCVId
      LIMIT 1
    ];
    FinServ__FinancialAccount__c financialAccount = [
      SELECT Id, FinServ__PrimaryOwner__c, OCV_ID__c
      FROM FinServ__FinancialAccount__c
      WHERE OCV_ID__c = :relatedAccountOCVId
      LIMIT 1
    ];
    Case newCase = createCase(caseRecordTypeName);
    newCase.AccountId = account.Id;
    newCase.FinServ__FinancialAccount__c = financialAccount.Id;
    newCase.Dispute_Reason__c = getDisputeReason(caseRecordTypeName)[0];
    insert newCase;
    return newCase;
  }
}
