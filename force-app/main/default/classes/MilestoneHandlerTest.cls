@isTest
public with sharing class MilestoneHandlerTest {
  @isTest
  static void testUpdateGeneralEnquiryEntitlementAEMSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;
    System.assert(
      MilestoneHandler.isGeneralEnquiryValidCase(oldRecord, newRecord),
      'This should be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateGeneralEnquiryEntitlementAEMFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.FRAUD_RT_ID;
    System.assert(
      !MilestoneHandler.isGeneralEnquiryValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }
  @isTest
  static void testUpdateGeneralEnquiryEntitlementStatusSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(9);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.status = GetHelpConstants.CLOSED_STATUS;
    System.assert(
      MilestoneHandler.isGeneralEnquiryValidCase(oldRecord, newRecord),
      'This should be a valid case.'
    );
    Test.stopTest();
  }
  @isTest
  static void testUpdateGeneralEnquiryEntitlementStatusFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(9);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    System.assert(
      !MilestoneHandler.isGeneralEnquiryValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateANZPlusComplaintEntitlementAEMSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID;
    System.assert(
      MilestoneHandler.isANZPlusComplaintValidCase(oldRecord, newRecord),
      'This should be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateANZPlusComplaintEntitlementAEMFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.FRAUD_RT_ID;
    System.assert(
      !MilestoneHandler.isANZPlusComplaintValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateANZXComplaintEntitlementStatusSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(8);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.status = GetHelpConstants.CLOSED_STATUS;
    System.assert(
      MilestoneHandler.isANZPlusComplaintValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateANZXComplaintEntitlementStatusFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(8);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    System.assert(
      !MilestoneHandler.isANZPlusComplaintValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateDisputeEntitlementStatusSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(7);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = false;
    oldRecord.RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.status = GetHelpConstants.CLOSED_STATUS;
    System.assert(
      MilestoneHandler.isDisputeValidCase(oldRecord, newRecord),
      'This should be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateDisputeEntitlementStatusFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(7);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = false;
    oldRecord.RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.Origin = 'Phone';
    System.assert(
      !MilestoneHandler.isDisputeValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateNonCustomerComplaintEntitlementAEMSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    System.assert(
      MilestoneHandler.isNonCustomerComplaintValidCase(oldRecord, newRecord),
      'This should be a valid case.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUpdateNonCustomerComplaintEntitlementAEMFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.IDR_Product_Category__c = 'Not product related';
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.FRAUD_RT_ID;
    System.assert(
      !MilestoneHandler.isNonCustomerComplaintValidCase(oldRecord, newRecord),
      'This should not be a valid case.'
    );
    Test.stopTest();
  }
}
