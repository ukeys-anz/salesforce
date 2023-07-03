/**
 * @author Shivam Swaraj
 * @since June 2022
 * @description Test Class for FetchRecordTypeName
 */
@isTest
public with sharing class FetchRecordTypeNameTest {
  /**
   * @description get recordtype name on create
   */
  @isTest
  static void getRecordTypeDeveloperNameTest() {
    String recordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Store')
      .getRecordTypeId();
    String recordTypeNameJson = FetchRecordTypeName.getRecordTypeDeveloperName(
      recordTypeId
    );
    String expectedJsonString = 'Store';
    Boolean isStoreExist = recordTypeNameJson.contains(expectedJsonString);
    System.assertEquals(true, isStoreExist, 'Store record type should exist');
  }

  /**
   * @description recordtype name on edit
   */
  @isTest
  static void getRecordTypeDeveloperNameEditTest() {
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    DateTime startTime = DateTime.newInstance(DateTime.now().year(), 1, 1);

    Interaction testInteraction = new Interaction(
      Status__c = InteractionConstants.UNASSIGNED_STATUS,
      Interaction_Purpose__c = InteractionConstants.OTHER_PURPOSE_NAME,
      InteractionType = InteractionConstants.CALL,
      RecordTypeId = GetHelpConstants.INTERACTION_STORE_RT_ID,
      StartTime = startTime,
      AccountId = testAccount.Id,
      Name = 'Test Interaction'
    );

    insert testInteraction;

    Interaction interactionRecord = [
      SELECT id
      FROM Interaction
      WHERE Name = 'Test Interaction'
      LIMIT 1
    ];
    String recordTypeNameJson = FetchRecordTypeName.getRecordTypeDeveloperNameEdit(
      interactionRecord.id
    );
    String expectedJsonString = 'Store';
    Boolean isStoreExist = recordTypeNameJson.contains(expectedJsonString);
    System.assertEquals(true, isStoreExist, 'Store record type should exist');
  }

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId
  ) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.PersonMobilePhone = '7868968758';
    testAccount.RecordTypeId = personAccountRecordTypeId;

    return testAccount;
  }
}
