/**
 * @author CMOS
 * @since 04/2025
 * @description Test class for {@link ComplaintResolutionController}
 */
@isTest
private with sharing class ComplaintResolutionControllerTest {
  static Lib_MockProvider complaintResRepoMock;
  static Lib_MockProvider userMock; 
  static void registerMocks() {
    complaintResRepoMock = Lib_MockProvider.forType(
      ComplaintResolutionControllerRepo.class
      );
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }
  
  static Account testAcc = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
  
  
  
  @isTest
  static void testgetCustomerCases() {
    registerMocks();
    
    Case testCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.customerComplaint,
    IDR_Complaint_Outcome__c = '1',
    Status = IDRConstants.OPEN_STATUS,
    AccountId = testAcc.Id,
    Type = '20',
    IDR_Is_Written_Resp_Requested__c = 'No',
    IDR_Is_Written_Resp_Required__c = 'No',
    IDR_Subsequent_Issue__c = '90'
      );
    
    complaintResRepoMock.mock('getCustomerCases', new List<Case>{ testCase });
    
    Test.startTest();
    List<Case> result = ComplaintResolutionController.getComplaintResolution(
      testAcc.Id
      );
    Test.stopTest();
    Assert.areEqual(!result.isEmpty(), true, 'Case List should not be empty');
  }
  
  @isTest
  static void testZeroCasesReturned() {
    Test.startTest();
    List<Case> result = ComplaintResolutionController.getComplaintResolution(
      testAcc.Id
      );
    Test.stopTest();
    Assert.areEqual(result.isEmpty(), true, 'Case List should be empty');
  }
  
  @isTest
  static void testgetPermissionSetGroupTrueCase() {
    registerMocks();
    
    userMock.mock('checkPermission',true);
    
    Test.startTest();
    Boolean result = ComplaintResolutionController.hasPermissionSet();
    Test.stopTest();
      
    Assert.areEqual(result, true, 'Permission Set Group is assigned to User');
  }
  
  @isTest
  static void testgetPermissionSetGroupFalseCase() {
    
    Test.startTest();
    Boolean result = ComplaintResolutionController.hasPermissionSet();
    Test.stopTest();
      
    Assert.areEqual(result, false, 'Permission Set Group is not assigned to User');
  }
}