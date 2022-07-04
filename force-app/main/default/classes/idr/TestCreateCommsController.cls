/**
 * @author Himabindu Nekkanti
 * @since 2021
 * @description  Test class for CreateCommsController
 */
@isTest
public class TestCreateCommsController {
  private static final String SUCCESS_RESPONSE_BODY = '{ "profile": { "customerId": "1006283997", "complainantType": "Individual", "businessName": "ANZ TDM PRIVATISED VALUE", "firstName": "COOPER", "lastName": "KOOLE", "mobile": "+61415184969", "phone": null, "middleName": "", "gender": "M", "aboriginal": "", "email": "rajesh.gunashekaran@gmail.com", "age": "73", "suburb": "TURRAMURRA", "street": "5 MILFORD PL", "state": "NSW", "postCode": "2074", "country": "AUStralia" } }';
  /**
   * @description This method is used to set up test data that will used across the test class.
   */
  @testSetup
  static void setup() {
    List<IDR_Template_Detail__c> tdList = new List<IDR_Template_Detail__c>();

    tdlist.addAll(
      new List<IDR_Template_Detail__c>{
        new IDR_Template_Detail__c(
          IDR_Template__c = '21 Day Letter',
          IDR_Template_Field_Name__c = 'CaseNumber',
          IDR_Case_Field_Name__c = 'CaseNumber'
        ),
        new IDR_Template_Detail__c(
          IDR_Template__c = 'Declined Application Letter',
          IDR_Template_Field_Name__c = 'StaffFullName',
          IDR_Case_Field_Name__c = 'OwnerId'
        ),
        new IDR_Template_Detail__c(
          IDR_Template__c = 'Declined Application Letter',
          IDR_Template_Field_Name__c = 'Description',
          IDR_Case_Field_Name__c = 'Description',
          IDR_Is_Free_Text__c = true
        ),
        new IDR_Template_Detail__c(
          IDR_Template__c = 'Declined Application Letter',
          IDR_Template_Field_Name__c = 'Input Text 1',
          IDR_Is_Free_Text__c = true
        )
      }
    );

    insert tdList;

    Case testCase = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      IDR_Customer_Number__c = '12345678901',
      Description = 'Test Description'
    );
    testCase.OwnerId = userinfo.getuserid();
    insert testCase;
  }
  /**
   * @description This method is used to test getTemplateList method from CreateCommsController
   */

  @istest
  static void testgetTemplateList() {
    list<string> returnedList = CreateCommsController.getTemplateList();
    system.assertEquals(
      2,
      returnedList.size(),
      'The size of template list should be as expected.'
    );
  }
  /**
   * @description This method is used to test fetchTemplateFields method from CreateCommsController
   */
  @istest
  static void testfetchTemplateFields() {
    case testCase = new case();
    testCase = [SELECT Id FROM Case LIMIT 1];
    list<CreateCommsData> returnList = CreateCommsController.fetchTemplateFields(
      'Declined Application Letter',
      testCase.Id
    );
    System.assertEquals(
      2,
      returnList.size(),
      'Expetected 2 rows to be returned'
    );
    System.assertEquals(
      returnList[0].fieldLabel,
      'Description',
      'Field Label did not match'
    );
    System.assertEquals(
      returnList[1].fieldLabel,
      'Input Text 1',
      'Field Label did not match'
    );
  }

  /**
   * @description This method is used to test  creation of comms from CreateCommsController
   */
  @istest
  static void testcreateComms1() {
    case testCase = new case();
    testCase = [SELECT Id FROM Case LIMIT 1];
    list<object> lineItems = new List<object>();
    list<Object> otherDetails = new List<Object>();
    Map<Object, Object> mapDetails = new Map<Object, Object>();
    mapDetails.put('caseId', testCase.Id);
    mapDetails.put('isEmail', false);
    mapDetails.put('isLetter', true);
    mapDetails.put('template', '21 Day Letter');
    otherDetails.add(mapDetails);

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, SUCCESS_RESPONSE_BODY)
    );
    Test.startTest();
    string returnedId = CreateCommsController.createComms(
      otherDetails,
      lineItems
    );
    Test.stopTest();
    system.assertNotEquals(null, returnedId, 'The method should return an Id.');
  }

  /**
   * @description This method is used to test  creation of comms from CreateCommsController
   */
  @istest
  static void testcreateComms2() {
    case testCase = new case();
    testCase = [SELECT Id FROM Case LIMIT 1];
    list<Map<Object, Object>> lineItems = new List<Map<Object, Object>>();
    Map<Object, Object> fieldMap = new Map<Object, Object>();
    fieldMap.put('fieldLabel', 'Input Text 1');
    fieldMap.put('fieldValue', 'test input');
    lineItems.add(fieldMap);
    list<Object> otherDetails = new List<Object>();
    Map<Object, Object> mapDetails = new Map<Object, Object>();
    mapDetails.put('caseId', testCase.Id);
    mapDetails.put('isEmail', false);
    mapDetails.put('isLetter', true);
    mapDetails.put('template', 'Unable to Contact');
    otherDetails.add(mapDetails);
    string returnedId = CreateCommsController.createComms(
      otherDetails,
      lineItems
    );
    system.assertNotEquals(null, returnedId, 'The method should return an Id.');
  }
}
