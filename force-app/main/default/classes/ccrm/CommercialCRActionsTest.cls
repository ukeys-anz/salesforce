/**
 * @author       : Naman Garg
 * @since        : July 2025
 * @description  : This is test class for CommercialCRActions
 **/
@isTest
public class CommercialCRActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void restrictImagesInRichTextFieldsTest() {
    //GIVEN records, oldMap
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = crId,
        Account_Plan__c = '<img>Google.com</img>'
      )
    };

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      crId => new Customer_Relationship__c(
        Id = crId,
        Account_Plan__c = '<img>anz.com</img>'
      )
    };
    List<Database.Error> errors;
    Database.Error error;

    //WHEN calling a method
    Test.startTest();
    CommercialCRActions.restrictImagesInRichTextFields(records, oldMap);
    Test.stopTest();

    //THEN it should throw any error
    errors = records[0].getErrors();
    Assert.isFalse(errors.isEmpty(), 'Error not found');
    error = errors.get(0);
    Assert.areEqual(
      CommercialCommonUtil.RESTRICT_IMAGE_TEXT,
      error.getMessage(),
      'Image attached successfully'
    );
  }

  @isTest
  static void formInteractionListTest() {
    //GIVEN filteredCRRecords
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    List<Customer_Relationship__c> filteredCRRecords = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = crId,
        Account_Plan__c = '<img>Google.com</img>'
      )
    };

    //WHEN calling a method
    Test.startTest();
    List<Interaction> interactionList = CommercialCRActions.formInteractionList(
      filteredCRRecords
    );
    Test.stopTest();

    //THEN it should form a list of Interaction
    Assert.isNotNull(interactionList, 'Interaction list should be empty');
    Assert.areEqual(
      crId,
      interactionList[0].Customer_Relationship__c,
      'Values are not same'
    );
  }

  @isTest
  static void autoCreateInteractionTest() {
    registerMocks();
    //GIVEN records, oldMap
    Id crId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );
    List<Customer_Relationship__c> records = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = crId,
        Account_Plan__c = 'Sample Account Plan',
        Status__c = 'Inactive'
      )
    };

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      crId => new Customer_Relationship__c(
        Id = crId,
        Account_Plan__c = 'Sample Account Plan',
        Status__c = 'Active'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialCRActions.autoCreateInteraction(records, oldMap);
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    List<Interaction> insertedRecords = (List<Interaction>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    //THEN it should create interaction record
    Assert.isNotNull(insertedRecords[0], 'New interaction should be created');
    Assert.areEqual(
      crId,
      insertedRecords[0].Customer_Relationship__c,
      'Values are not same'
    );
    Assert.areEqual(
      'General',
      insertedRecords[0].Category__c,
      'Values are not same'
    );
    Assert.areEqual(
      RTInteraction.commercialInteraction,
      insertedRecords[0].RecordTypeId,
      'Values are not same'
    );
  }
}
