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
}
