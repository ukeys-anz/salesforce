/**
 * @description Test class for {@link LoanPreferenceHelper}
 * @author Raman Gupta
 * @since Jan 2025
 */
@isTest
public with sharing class LoanPreferenceHelperTest {
  static Lib_MockProvider loanPrefErrorMappingMock;
  static void registerMocks() {
    loanPrefErrorMappingMock = Lib_MockProvider.forType(
        ErrorCodeMessageMappingRepository.class
      )
      .mock('queryErrorCodeMessageMapping', getLoanPrefErrorCodeMapping);
  }

  @isTest
  static void getErrorCodeMapping() {
    Integer errorCode = 340204;
    Test.startTest();
    String message = LoanPreferenceHelper.getErrorCodeMapping(errorCode);
    Test.stopTest();
    Assert.areEqual(
      message,
      'The Additional funds amount must be less than the current loan. Please review and try again.',
      'Error is not mapped'
    );
  }

  @isTest
  static void getErrorCodeMappingException() {
    registerMocks();
    loanPrefErrorMappingMock.mock('queryErrorCodeMessageMapping', null);
    Test.startTest();
    String message = LoanPreferenceHelper.getErrorCodeMapping(123456);
    Test.stopTest();
    Assert.areEqual(message, '', 'Error is not mapped');
  }

  /**
   * @description Static method to return ErrorCode_Message_Mapping__mdt metadata Record
   */
  static List<ErrorCode_Message_Mapping__mdt> getLoanPrefErrorCodeMapping {
    get {
      List<ErrorCode_Message_Mapping__mdt> mappingList = new List<ErrorCode_Message_Mapping__mdt>();
      ErrorCode_Message_Mapping__mdt mapping = new ErrorCode_Message_Mapping__mdt();
      mapping.MasterLabel = '340204';
      mapping.Message__c = 'The Additional funds amount must be less than the current loan. Please review and try again.';
      mappingList.add(mapping);
      return mappingList;
    }
  }
}
