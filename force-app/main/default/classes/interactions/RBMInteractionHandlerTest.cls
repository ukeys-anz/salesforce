@isTest
public class RBMInteractionHandlerTest {
  static Lib_MockProvider interactionRepoMock = Lib_MockProvider.forType(
    RBMInteractionRepository.class
  );
  static Lib_MockProvider associatedLoanApplicationRepoMock = Lib_MockProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  static Lib_MockProvider dmlRepoMock = Lib_MockProvider.forType(
    DMLRepository.class
  );
  /*
   * @description unit test to validate RBM Interaction recordtype
   */
  @IsTest
  static void testisValidRecord() {
    Interaction mockInteractions = TestDataFactory.createInteraction(
      RTInteraction.rbmBrokerInteraction,
      '',
      '',
      (System.now() + 2),
      false
    );
    RBMInteractionHandler interactionHandler = new RBMInteractionHandler();
    Test.startTest();
    Boolean isValidRecord = interactionHandler.isValidRecord(mockInteractions);
    Test.stopTest();
    Assert.isTrue(
      isValidRecord,
      'Interaction record must be RBM_Broker_Interaction type'
    );
  }
  /*
   * @description unit test to Insert context
   */
  @IsTest
  static void testCoverageForInsert() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    mockInteractions[0].Id = null;
    mockInteractions[0].StartTime = null;
    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = mockInteractions[0].Office_Group__c;
    officeGroup.Name = 'Test OfficeGroup';
    Contact brokerContact = (Contact) JSON.deserialize(
      '{"Id":"' +
        mockInteractions[0].Broker__c +
        '","Name":"Sample Broker Contact"}',
      Contact.class
    );
    interactionRepoMock.mock(
      'queryBrokerContacts',
      new List<Contact>{ brokerContact }
    );
    interactionRepoMock.mock(
      'queryOfficeGroups',
      new List<Broker_Relation__c>{ officeGroup }
    );
    RBMInteractionHandler interactionHandler = new RBMInteractionHandler();
    interactionHandler.records = mockInteractions;
    Test.startTest();
    interactionHandler.onBeforeInsert();
    Test.stopTest();
    Assert.areNotEqual(
      mockInteractions[0].StartTime,
      null,
      'Interaction StartTime and event StartDateTime must be same'
    );
    String interactionName =
      brokerContact.Name +
      '-' +
      mockInteractions[0].Interaction_Type__c;
    Assert.areNotEqual(
      mockInteractions[0].Name,
      interactionName,
      'Interaction name must match with as ' + interactionName
    );
  }
  /*
   * @description unit test to Insert context
   */
  @IsTest
  static void testCoverageForAfterInsert() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    Contact brokerContact = new Contact(
      Office_Group__c = mockInteractions[0].Office_Group__c,
      Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType)
    );
    interactionRepoMock.mock(
      'queryBrokersFromOfficeGroups',
      new List<Contact>{ brokerContact }
    );
    RBMInteractionHandler interactionHandler = new RBMInteractionHandler();
    interactionHandler.records = mockInteractions;
    Test.startTest();
    interactionHandler.onAfterInsert();
    Test.stopTest();
    List<ContentNote> contentNotes = (List<ContentNote>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      contentNotes[0].Title,
      'Closed - Completed Note',
      'ContentNote title must match'
    );
  }
  /*
   * @description unit test to Insert context
   */
  @IsTest
  static void testCoverageForBeforeUpdate() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[0].Status__c = 'Open';
    Map<Id, Interaction> oldRecord = convertRecordsToOldMap(mockInteractions);
    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = mockInteractions[0].Office_Group__c;
    officeGroup.Name = 'Test OfficeGroup';
    Contact brokerContact = (Contact) JSON.deserialize(
      '{"Id":"' +
        mockInteractions[1].Broker__c +
        '","Name":"Sample Broker Contact"}',
      Contact.class
    );
    interactionRepoMock.mock(
      'queryBrokerContacts',
      new List<Contact>{ brokerContact }
    );
    interactionRepoMock.mock(
      'queryOfficeGroups',
      new List<Broker_Relation__c>{ officeGroup }
    );
    RBMInteractionHandler interactionHandler = new RBMInteractionHandler();
    interactionHandler.records = mockInteractions;
    Test.startTest();
    interactionHandler.onBeforeUpdate(oldRecord);
    Test.stopTest();
    Assert.areNotEqual(
      mockInteractions[0].Name,
      mockInteractions[1].Name,
      'Interaction Name must change'
    );
    String relatedName =
      brokerContact.Name +
      ' - ' +
      mockInteractions[0].Interaction_Type__c;
    Assert.areNotEqual(
      mockInteractions[0].Name,
      relatedName,
      'Expected Interaction Name Change must be ' + relatedName
    );
    Assert.areNotEqual(
      mockInteractions[0].Closing_Notes__c,
      'Test Closing Note',
      'Interaction Closing Note should have initial value'
    );
    Assert.areEqual(
      mockInteractions[0].Closing_Notes__c,
      '',
      'Interaction Closing Note must be cleared'
    );
  }
  /*
   * @description unit test to Insert context
   */
  @IsTest
  static void testCoverageForAfterUpdate() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[0].Status__c = 'Open';
    Map<Id, Interaction> oldRecord = convertRecordsToOldMap(mockInteractions);
    Associated_Loan_Application__c associatedLoanApplication = new Associated_Loan_Application__c();
    associatedLoanApplication.Residential_Loan_Application__c = mockInteractions[1]
      .Loan_Application__c;
    associatedLoanApplication.Interaction__c = mockInteractions[1].Id;
    associatedLoanApplication.Id = Lib_FakeIdGenerator.getMockId(
      Associated_Loan_Application__c.SObjectType
    );
    associatedLoanApplicationRepoMock.mock(
      'getRelatedLoanApplication',
      new List<Associated_Loan_Application__c>{ associatedLoanApplication }
    );
    if (!oldRecord.isEmpty()) {
      ((List<Interaction>) oldRecord.values())[0]
        .Loan_Application__c = associatedLoanApplication.Residential_Loan_Application__c;
    }

    RBMInteractionHandler interactionHandler = new RBMInteractionHandler();
    interactionHandler.records = mockInteractions;
    Test.startTest();
    interactionHandler.onAfterUpdate(oldRecord);
    Test.stopTest();
    List<Associated_Loan_Application__c> newassociatedLoans = (List<Associated_Loan_Application__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<Associated_Loan_Application__c> deleteAssociatedLoans = (List<Associated_Loan_Application__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      newassociatedLoans.size(),
      1,
      'Must have one new Associated Loan Application for creation'
    );
    Assert.areEqual(
      deleteAssociatedLoans.size(),
      1,
      'Must have one Associated Loan Applications to delete'
    );
  }
  /**
   * @description createMockInteraction
   * @param reqRecords Integer value for limit the number of mock records to create
   * @return List<Interaction>
   */
  private static List<Interaction> createMockInteraction(Integer reqRecords) {
    List<Interaction> interactions = new List<Interaction>();
    for (Integer i = 0; i < reqRecords; i++) {
      Interaction mockInteraction = new Interaction();
      mockInteraction.Id = Lib_FakeIdGenerator.getMockId(
        Interaction.SObjectType
      );
      mockInteraction.RecordTypeId = RTInteraction.rbmBrokerInteraction;
      mockInteraction.Name = 'Test Interaction';
      mockInteraction.Broker__c = Lib_FakeIdGenerator.getMockId(
        Contact.SObjectType
      );
      mockInteraction.StartTime = DateTime.newInstance(
        DateTime.now().year() + 1,
        1,
        1
      );
      mockInteraction.Interaction_Purpose__c = InteractionConstants.OTHER_PURPOSE_NAME;
      mockInteraction.Status__c = RBMInteractionConstants.INTERACTION_STATUS_CLOSED_COMPLETED;
      mockInteraction.Interaction_Type__c = 'Phone';
      mockInteraction.Optional_Notes__c = 'Open';
      mockInteraction.Attendee_Category__c = 'Office Group';
      mockInteraction.Closing_Notes__c = 'Test Closing Note';
      mockInteraction.Office_Group__c = Lib_FakeIdGenerator.getMockId(
        Broker_Relation__c.SObjectType
      );
      mockInteraction.Loan_Application__c = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      interactions.add(mockInteraction);
    }
    return interactions;
  }
  /*
   * @description  Method to create Test Record oldMap
   */
  static Map<Id, Interaction> convertRecordsToOldMap(
    List<Interaction> accList
  ) {
    List<Interaction> oldInteractionList = accList.deepClone(true);
    for (Interaction record : oldInteractionList) {
      record.Interaction_Type__c = 'Online/Virtual';
    }
    oldInteractionList[0]
      .Status__c = RBMInteractionConstants.INTERACTION_STATUS_CLOSED_COMPLETED;
    oldInteractionList[1].Interaction_Type__c = 'Phone';
    return new Map<Id, Interaction>(oldInteractionList);
  }
}
