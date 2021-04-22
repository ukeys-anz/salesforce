@istest
public class LetterApprovalTriggerHandlerTest {
  private static final String SUCCESS_RESPONSE_BODY = '{ "profile": { "customerId": "1006283997", "complainantType": "Individual", "businessName": "ANZ TDM PRIVATISED VALUE", "firstName": "COOPER", "lastName": "KOOLE", "mobile": "+61415184969", "phone": null, "middleName": "", "gender": "M", "aboriginal": "", "email": "rajesh.gunashekaran@gmail.com", "age": "73", "suburb": "TURRAMURRA", "street": "5 MILFORD PL", "state": "NSW", "postCode": "2074", "country": "AUStralia" } }';
  @testSetup
  static void setup() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1006283997'
        )
      );
    }

    insert newCases;

    IDR_Template_Detail__c temDetail = new IDR_Template_Detail__c();
    temDetail.IDR_Template__c = '21 Day Letter';
    temDetail.IDR_Template_Field_Name__c = 'CaseNumber';
    temDetail.IDR_Case_Field_Name__c = 'CaseNumber';
    temDetail.IDR_Is_Free_Text__c = false;

    insert temDetail;
  }

  @isTest
  static void testCustomerData() {
    Case c = [SELECT Id, CaseNumber FROM Case LIMIT 1];
    IDR_Letter_Approval__c lApp = new IDR_Letter_Approval__c();
    lApp.IDR_Case__c = c.Id;
    lApp.IDR_Send_As_Email__c = true;
    lApp.IDR_Status__c = 'Pending Approval';
    lApp.IDR_Template_Name__c = '21 Day Letter';
    lApp.IDR_Auto_Approve__c = true;
    insert lApp;

    List<IDR_Letter_Approval_Details__c> appDetList = new List<IDR_Letter_Approval_Details__c>();

    IDR_Letter_Approval_Details__c appDetails1 = new IDR_Letter_Approval_Details__c();
    appDetails1.IDR_Letter_Approval__c = lApp.Id;
    appDetails1.IDR_Field_Name__c = 'CaseNumber';
    appDetails1.IDR_Value__c = c.CaseNumber;

    IDR_Letter_Approval_Details__c appDetails2 = new IDR_Letter_Approval_Details__c();
    appDetails2.IDR_Letter_Approval__c = lApp.Id;
    appDetails2.IDR_Field_Name__c = 'StaffFullName';
    appDetails2.IDR_Value__c = UserInfo.getName();

    appDetList.add(appDetails1);
    appDetList.add(appDetails2);

    insert appDetList;

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, SUCCESS_RESPONSE_BODY)
    );
    Test.startTest();
    Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
    app.setObjectId(lApp.id);
    Approval.ProcessResult result = Approval.process(app);
    Test.stopTest();
    IDR_Letter_Approval__c letterApp = [
      SELECT id, IDR_Status__c
      FROM IDR_Letter_Approval__c
      WHERE id = :lApp.id
    ];
    System.assertEquals('Approved', letterApp.IDR_Status__c);
    List<IDR_Letter_Approval_Details__c> appDetFinalList = [
      SELECT Id
      FROM IDR_Letter_Approval_Details__c
      WHERE IDR_Letter_Approval__c = :lApp.Id
    ];
    System.assertEquals(7, appDetFinalList.size());
  }
}
