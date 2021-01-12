/**
 * @author Himabindu Nekkanti
 * @since 2021
 * @description  Test class for CreateCommsController
 */
@isTest
public class TestCreateCommsController {
  /**
   * @description This method is used to set up test data that will used across the test class.
   */
  @testSetup
  static void setup() {
    List<IDR_Template_Detail__c> tdList = new List<IDR_Template_Detail__c>();

    IDR_Template_Detail__c td1 = new IDR_Template_Detail__c(
      IDR_Template__c = '21 Day Letter',
      IDR_Template_Field_Name__c = 'CaseNumber',
      IDR_Case_Field_Name__c = 'CaseNumber'
    );
    tdlist.add(td1);

    IDR_Template_Detail__c td2 = new IDR_Template_Detail__c(
      IDR_Template__c = '21 Day Letter',
      IDR_Template_Field_Name__c = 'StaffFullName',
      IDR_Case_Field_Name__c = 'Owner.Name'
    );
    tdList.add(td2);

    IDR_Template_Detail__c td3 = new IDR_Template_Detail__c(
      IDR_Template__c = 'Unable to Contact',
      IDR_Template_Field_Name__c = 'StaffFullName',
      IDR_Case_Field_Name__c = 'OwnerId'
    );
    tdList.add(td3);

    IDR_Template_Detail__c td4 = new IDR_Template_Detail__c(
      IDR_Template__c = 'Unable to Contact',
      IDR_Template_Field_Name__c = 'Description',
      IDR_Case_Field_Name__c = 'Description',
      IDR_Is_Free_Text__c = true
    );
    tdList.add(td4);

    IDR_Template_Detail__c td5 = new IDR_Template_Detail__c(
      IDR_Template__c = 'Unable to Contact',
      IDR_Template_Field_Name__c = 'Input Text 1',
      IDR_Is_Free_Text__c = true
    );
    tdList.add(td5);

    insert tdList;

    Case testCase = new Case(
      RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
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
    system.assertEquals(2, returnedList.size());
  }
  /**
   * @description This method is used to test fetchTemplateFields method from CreateCommsController
   */
  @istest
  static void testfetchTemplateFields() {
    case testCase = new case();
    testCase = [SELECT Id FROM Case LIMIT 1];
    list<CreateCommsData.TemplateFieldsData> returnList = CreateCommsController.fetchTemplateFields(
      'Unable to Contact',
      testCase.Id
    );
    system.assertEquals(2, returnedList.size());
  }

  /**
   * @description This method is used to test  creation of comms from CreateCommsController
   */
  @istest
  static void testcreateComms1() {
    case testCase = new case();
    testCase = [SELECT Id FROM Case LIMIT 1];
    list<object> lineItems = new List<object>();
    string returnedId = CreateCommsController.createComms(
      testCase.Id,
      false,
      true,
      '21 Day Letter',
      lineItems
    );
    system.assertNotEquals(null, returnedId);
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
    string returnedId = CreateCommsController.createComms(
      testCase.Id,
      false,
      true,
      'Unable to Contact',
      lineItems
    );
    system.assertNotEquals(null, returnedId);
  }
}
