/**
 * @author CMOS
 * @since 04/2025
 * @description This class is used for testing ComplaintResolutionController
 */
@isTest
public class ComplaintResolutionControllerTest {
    static Lib_MockProvider complaintResRepoMock;
    static void registerMocks() {
        complaintResRepoMock = Lib_MockProvider.forType(ComplaintResolutionControllerRepo.class);
    }
    
    @isTest
    static void testgetCustomerCases() {
        registerMocks();
        
        Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
        Account testAcc = new Account(Id = accId);
        
        Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
        Case testCase = new Case(Id=caseId,
        RecordTypeId= RTCase.customerComplaint,
        IDR_Complaint_Outcome__c = '1',
        Status = IDRConstants.OPEN_STATUS,
        AccountId = testAcc.Id,
        Type = '20',
        IDR_Is_Written_Resp_Requested__c ='No',
        IDR_Is_Written_Resp_Required__c = 'No',
        IDR_Subsequent_Issue__c = '90');
        
        Id comResId = Lib_FakeIdGenerator.getMockId(Complaint_Resolution__c.SObjectType);
        Complaint_Resolution__c testCompRes = new Complaint_Resolution__c(Id=comResId,
        IDR_Complaint__c =testCase.Id,
        IDR_Complaint_Remedy__c = '2' );
        
        complaintResRepoMock.mock('getCustomerCases', new List<Case>{ testCase });
        
        Test.startTest();
        List<Case> caseList= ComplaintResolutionController.getComplaintResolution(accId);
        Test.stopTest();
        
        Assert.areEqual(!caseList.isEmpty(),true,'Case List should not be empty');
        
    }
    
}