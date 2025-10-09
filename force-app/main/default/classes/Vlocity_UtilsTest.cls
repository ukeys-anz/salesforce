/**
 *
 * @author Laxmi
 * @since Dec 2021
 * @description Test class for Vlocity_Utils
 */
@IsTest
public class Vlocity_UtilsTest {
  static Lib_MockProvider complaintsMock;
  static Lib_MockProvider queryAppDefinitionMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    complaintsMock = Lib_MockProvider.forType(ComplaintsRepository.class);
    queryAppDefinitionMock = Lib_MockProvider.forType(QueryAppDefinition.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
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
    Assert.isTrue(obj.call(action, args) != null, 'Method should be called');
  }
  /**
   * @description to test disable omni flag
   */
  @IsTest
  static void testDisableOmni() {
    Assert.isTrue(
      !Vlocity_Utils.getDisableOmni(),
      'Omni should not be disabled'
    );
  }

  /**
   * @description to test create complaint resolutions
   */
  @IsTest
  static void testCreateCR() {
    registerMocks();
    Vlocity_Utils obj = new Vlocity_Utils();
    List<Map<String, Object>> cr = new List<Map<String, Object>>();
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
        'ComplaintId' => Lib_FakeIdGenerator.getMockId(Case.SObjectType)
      }
    );
    test.startTest();
    obj.call(action, args);
    test.stopTest();
    List<Complaint_Resolution__c> upsertedEvents = (List<Complaint_Resolution__c>) dmlRepoMock.getHistory(
        'doUpsert'
      )
      .getParam('records');
    Assert.isTrue(!upsertedEvents.isEmpty(), 'Resolution should be updated');
  }
  /**
   * @description : To test the Last Modified Date count of a particualr field on Case.
   */
  @isTest
  static void testGetLastModifiedDateOfField() {
    registerMocks();
    Case csObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      CreatedDate = System.today()
    );
    CaseHistory hsObj = new CaseHistory(CaseId = csObj.Id, Field = 'Status');

    complaintsMock.mock('getCreatedDate', csObj);
    complaintsMock.mock('getComplaintHistory', hsObj);
    Map<String, Object> input = new Map<String, Object>{
      'FieldName' => 'Status',
      'recordId' => csObj.Id
    };
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Vlocity_Utils obj = new Vlocity_Utils();
    obj.invokeMethod('getLastModifiedDateOfField', input, output, options);
    Integer expectedDays = Math.abs(
      Datetime.now().date().daysBetween(System.today())
    );
    Assert.areEqual(
      expectedDays + ' Days',
      output.get('lastModifiedDateStatus'),
      'LastModifed Date Should be Same'
    );
    input = new Map<String, Object>{
      'FieldName' => 'Type',
      'recordId' => csObj.Id
    };
    obj.invokeMethod('getLastModifiedDateOfField', input, output, options);
    expectedDays = Math.abs(Datetime.now().date().daysBetween(System.today()));
    Assert.areEqual(
      expectedDays + ' Days',
      output.get('lastModifiedDateStatus'),
      'LastModifed Status Should be Same'
    );
  }
  @isTest
  static void testGetCurrentAppInvoke() {
    registerMocks();
    Vlocity_Utils obj = new Vlocity_Utils();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Id appdefinitionId = Lib_FakeIdGenerator.getMockId(
      AppDefinition.SObjectType
    );
    AppDefinition testAppDefinition = (AppDefinition) TestUtil.setFields(
      new AppDefinition(Id = appdefinitionId),
      new Map<String, Object>{
        'Label' => 'Complaint Mgt',
        'DurableId' => appdefinitionId
      }
    );
    UserAppInfo testUserInfo = new UserAppInfo(
      Id = Lib_FakeIdGenerator.getMockId(UserAppInfo.SObjectType),
      AppDefinitionId = appdefinitionId
    );
    complaintsMock.mock('getUserAppInfoForUser', testUserInfo);
    QueryAppDefinition.appsByDurableId = new Map<Id, AppDefinition>{
      testAppDefinition.Id => testAppDefinition
    };
    obj.getCurrentAppName(input, output, options);
    Assert.isTrue(
      obj.invokeMethod('getCurrentAppName', input, output, options),
      'getCurrentAppName Method is Invoked'
    );
  }
  @isTest
  static void testDeleteResolutionRemedy() {
    registerMocks();
    Vlocity_Utils obj = new Vlocity_Utils();
    List<Map<String, String>> cr = new List<Map<String, String>>();
    cr.add(
      new Map<String, String>{
        'Id' => Lib_FakeIdGenerator.getMockId(
          Complaint_Resolution__c.SObjectType
        ),
        'Remedy' => null
      }
    );
    String action = 'deleteComplaintResolution';
    Map<String, Object> args = new Map<String, Object>();
    args.put('input', new Map<String, Object>{ 'ComplaintResolution' => cr });
    obj.call(action, args);
    Test.startTest();
    List<Complaint_Resolution__c> caseUpdated = (List<Complaint_Resolution__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Test.stopTest();
    Assert.isTrue(!caseUpdated.isEmpty(), 'Resolution is deleted');
  }
  @isTest
  static void testDeleteResolutionRemedyOffer() {
    registerMocks();
    Vlocity_Utils obj = new Vlocity_Utils();
    List<Map<String, String>> cr = new List<Map<String, String>>();
    cr.add(
      new Map<String, String>{
        'Id' => Lib_FakeIdGenerator.getMockId(
          Complaint_Resolution__c.SObjectType
        ),
        'remedyOffered' => null
      }
    );
    String action = 'deleteComplaintResolution';
    Map<String, Object> args = new Map<String, Object>();
    args.put('input', new Map<String, Object>{ 'ComplaintResolution' => cr });
    obj.call(action, args);
    Test.startTest();
    List<Complaint_Resolution__c> caseUpdated = (List<Complaint_Resolution__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Test.stopTest();
    Assert.isTrue(!caseUpdated.isEmpty(), 'Resolution is deleted');
  }
}
