@isTest
public class CommercialSurveyRespTriggerHandlerTest {
  private static final String SOURCEID = 'QUnLJCCEhB0';
  private static final Id ACCID = Lib_FakeIdGenerator.getMockId(
    Account.SObjectType
  );

  static Lib_MockProvider surveyRespActRepo;
  static void registerMocks() {
    surveyRespActRepo = Lib_MockProvider.forType(
      CommercialSurveyResponseActionsRepo.class
    );
  }

  private static qualtrics__Survey_Response__c getMockedData() {
    Id srId = Lib_FakeIdGenerator.getMockId(
      qualtrics__Survey_Response__c.SobjectType
    );
    qualtrics__Survey_Response__c sr = new qualtrics__Survey_Response__c(
      Id = srId,
      customer_number__c = SOURCEID,
      qualtrics__Net_Promoter_Score__c = 2,
      Customer_Feedback__c = 'Customer Feedback',
      Other_Feedback__c = 'Some other feedback',
      qualtrics__Overall_Satisfaction__c = 'Satisfied',
      Survey_Name__c = 'A-Z Reviews',
      Survey_Trigger__c = 'Commercial'
    );
    return sr;
  }

  @isTest
  static void testsetFieldsForSurveyResponseOnInsert() {
    registerMocks();
    qualtrics__Survey_Response__c mockData = getMockedData();
    surveyRespActRepo.mock(
      'filterAccounts',
      new List<Account>{
        new Account(Id = ACCID, Source_System_ID__c = SOURCEID)
      }
    );
    Test.startTest();
    CommercialSurveyResponseActions.setFieldsForSurveyResponseOnInsert(
      new List<qualtrics__Survey_Response__c>{ mockData }
    );
    Test.stopTest();
    assert.areEqual(
      mockData.Name,
      'A-Z Reviews - Commercial',
      'Survey Name has been concatenated with Survey_Trigger__c'
    );
  }

  @isTest
  static void testsetSurveyResponseFields() {
    Account acc = new Account(Id = ACCID, Source_System_ID__c = SOURCEID);
    qualtrics__Survey_Response__c mockData = getMockedData();
    Test.startTest();
    CommercialSurveyResponseActionsHelper.setSurveyResponseFields(
      new Map<String, Account>{ mockData.customer_number__c => acc },
      new List<qualtrics__Survey_Response__c>{ mockData }
    );
    Test.stopTest();
    assert.areEqual(
      mockData.qualtrics__Account__c,
      acc.Id,
      'Account Id is matched'
    );
  }

  @isTest
  static void testvalidateSurveyFields() {
    String invalidOCVIdError = 'Provided Customer number could not be found in Salesforce';
    qualtrics__Survey_Response__c mockData = getMockedData();
    try {
      Test.startTest();
      CommercialSurveyResponseActionsHelper.validateSurveyFields(
        new Set<String>{ '1234' },
        new List<qualtrics__Survey_Response__c>{ mockData }
      );
      Test.stopTest();
    } catch (exception e) {
      Boolean expectedExceptionThrown = (e.getMessage()
          .contains(invalidOCVIdError))
        ? true
        : false;
      assert.areEqual(true, expectedExceptionThrown, e.getMessage());
    }
  }
}
