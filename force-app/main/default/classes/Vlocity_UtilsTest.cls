/**
 *
 * @author Laxmi
 * @since Dec 2021
 * @description Test class for Vlocity_Utils
 */
@IsTest
public class Vlocity_UtilsTest {
  @TestSetup
  static void makeData() {
    Case c = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Status = IDRConstants.OPEN_STATUS,
      Description = 'Test decription',
      IDR_Additional_Correspondence_reviewed__c = false,
      Origin = 'Phone'
    );
    insert c;
    Complaint_Resolution__c cr = new Complaint_Resolution__c(
      IDR_Complaint__c = c.Id
    );
    insert cr;
  }

  /**
   * @description to test customer info with customerId
   */
  @IsTest
  static void testCustomerInfo() {
    Vlocity_Utils obj = new Vlocity_Utils();
    String action = 'getCustomerInfo';
    Map<String, String> input = new Map<String, String>{
      'CustomerId' => '4024865085',
      'CustomerIdentifier' => 'Customer/Business CAP ID'
    };
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => new Map<String, Object>()
    };
    obj.call(action, args);
  }

  /**
   * @description to test delete complaint resolutions
   */
  @IsTest
  static void testDeleteCR() {
    Vlocity_Utils obj = new Vlocity_Utils();
    List<Map<String, String>> cr = new List<Map<String, String>>();
    for (Complaint_Resolution__c cr1 : [
      SELECT Id
      FROM Complaint_Resolution__c
      LIMIT 1
    ]) {
      cr.add(new Map<String, String>{ 'Id' => cr1.Id });
    }
    String action = 'deleteComplaintResolution';
    Map<String, Object> args = new Map<String, Object>();
    args.put('input', new Map<String, Object>{ 'ComplaintResolution' => cr });
    obj.call(action, args);
  }

  /**
   * @description to test disable omni flag
   */
  @IsTest
  static void testDisableOmni() {
    Vlocity_Utils.getDisableOmni();
  }

  /**
   * @description to test create complaint resolutions
   */
  @IsTest
  static void testCreateCR() {
    Vlocity_Utils obj = new Vlocity_Utils();
    List<Map<String, Object>> cr = new List<Map<String, Object>>();
    Case c = [SELECT Id FROM Case LIMIT 1];
    Map<String, Object> inmap = new Map<String, Object>{
      'Remedy' => '4',
      'SubRemedy' => '16',
      'durationOfRemedy' => '5'
    };
    cr.add(inmap);
    inmap.put('SubRemedy', '99');
    inmap.put('otherRemedy', 'test12');
    cr.add(inmap);
    Map<String, Object> args = new Map<String, Object>();
    String action = 'createComplaintResolution';
    args.put(
      'input',
      new Map<String, Object>{
        'ComplaintResolution' => cr,
        'ComplaintId' => c.Id
      }
    );
    obj.call(action, args);
  }
  /**
   * @description : To test the Last Modified Date count of a particualr field on Case.
   */
  @isTest
  static void testGetLastModifiedDateOfField() {
    Case testCase = [SELECT ID, CreatedDate FROM Case LIMIT 1];
    CaseHistory caseHistory = new CaseHistory(
      CaseId = testCase.Id,
      Field = 'Status'
    );
    insert caseHistory;
    caseHistory = [
      SELECT CreatedDate
      FROM CaseHistory
      WHERE CaseId = :testCase.Id AND Field = 'Status'
    ];
    Map<String, Object> input = new Map<String, Object>{
      'FieldName' => 'Status',
      'recordId' => testCase.Id
    };
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Vlocity_Utils obj = new Vlocity_Utils();
    obj.invokeMethod('getLastModifiedDateOfField', input, output, options);
    Integer expectedDays = Math.abs(
      Datetime.now().date().daysBetween(caseHistory.CreatedDate.date())
    );
    System.assertEquals(
      expectedDays + ' Days',
      output.get('lastModifiedDateStatus')
    );
    input = new Map<String, Object>{
      'FieldName' => 'Type',
      'recordId' => testCase.Id
    };
    obj.invokeMethod('getLastModifiedDateOfField', input, output, options);
    expectedDays = Math.abs(
      Datetime.now().date().daysBetween(testCase.CreatedDate.date())
    );
    System.assertEquals(
      expectedDays + ' Days',
      output.get('lastModifiedDateStatus')
    );
  }
}
