/**
 * @description       :
 * @author            : Tranformers Squad
 * @group             :
 * @created on        : 03-04-2024
 * @last modified by  : TFM Squad - Anuj
 **/
@isTest
public with sharing class TFMDataINPaginationControllerTest {
  public static final String ACTIVECONSENTLIST = Service.getStaticResource(
    'mock_DataINActiveConsents'
  );
  public static final String ARCHIEVECONSENTLIST = Service.getStaticResource(
    'mock_DataINArchivedConsents'
  );
  public static final String ACTIVECONSENTLIST1 = Service.getStaticResource(
    'mock_DataINActiveConsents1'
  );
  @isTest
  static void testPaginationMethod1() {
    Test.startTest();
    Map<String, Object> returnMap = testPerformPagination(
      ACTIVECONSENTLIST,
      ARCHIEVECONSENTLIST,
      'performPaginationForDataIN'
    );
    Assert.areEqual(
      true,
      Boolean.valueOf(returnMap.get('isInvoked')),
      'Method not invoked.'
    );

    String dataJSON = JSON.serializePretty(returnMap.get('payload'));
    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(
      dataJSON
    );
    Map<String, Object> page0 = (Map<String, Object>) jsonResponse.get('page0');
    List<Object> parentActiveConsentList = (List<Object>) page0.get(
      'parentActiveConsentList'
    );
    Integer parentActiveConsentListSize = parentActiveConsentList.size();
    List<Object> parentArchiveConsentList = (List<Object>) page0.get(
      'parentArchiveConsentList'
    );
    Integer parentArchiveConsentListSize = parentArchiveConsentList.size();
    Assert.areEqual(
      25,
      parentActiveConsentListSize,
      'Active consents are 25 records'
    );
    Assert.areEqual(
      25,
      parentArchiveConsentListSize,
      'Archive consents are 25 records'
    );
    Test.stopTest();
  }

  @isTest
  static void testPaginationMethod2() {
    Test.startTest();
    Map<String, Object> returnMap = testPerformPagination(
      ACTIVECONSENTLIST1,
      ARCHIEVECONSENTLIST,
      'performPaginationForDataIN'
    );
    Assert.areEqual(
      true,
      Boolean.valueOf(returnMap.get('isInvoked')),
      'Method not invoked.'
    );

    String dataJSON = JSON.serializePretty(returnMap.get('payload'));
    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(
      dataJSON
    );
    Map<String, Object> page0 = (Map<String, Object>) jsonResponse.get('page0');
    List<Object> parentActiveConsentList = (List<Object>) page0.get(
      'parentActiveConsentList'
    );
    Integer parentActiveConsentListSize = parentActiveConsentList.size();
    List<Object> parentArchiveConsentList = (List<Object>) page0.get(
      'parentArchiveConsentList'
    );
    Integer parentArchiveConsentListSize = parentArchiveConsentList.size();
    Assert.areEqual(
      18,
      parentActiveConsentListSize,
      'Active consents are 18 records'
    );
      System.debug('parentArchiveConsentListSize===='+parentArchiveConsentListSize);
    Assert.areEqual(
      32,
      parentArchiveConsentListSize,
      'Archive consents are 32 records'
    );
    Test.stopTest();
  }

  @isTest
  static void testPaginationMethod3() {
    Test.startTest();
    Map<String, Object> returnMap = testPerformPagination(
      ACTIVECONSENTLIST1,
      ARCHIEVECONSENTLIST,
      'performPaginationForTest'
    );
    Assert.areEqual(
      false,
      Boolean.valueOf(returnMap.get('isInvoked')),
      'Method not invoked.'
    );
    Test.stopTest();
  }

  /**
   * @param activeConsentListTesting active list
   * @param archiveConsentListTesting archive list
   * @param methodName name
   * @return `Map<String, Object>`
   * @description flex card invokeable method overridden by callable interface
   */
  public static Map<String, Object> testPerformPagination(
    String activeConsentListTesting,
    String archiveConsentListTesting,
    String methodName
  ) {
    Map<String, Object> returnMap = new Map<String, Object>();
    TFMDataINPaginationController controller = new TFMDataINPaginationController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put(
      'recordId',
      Lib_FakeIdGenerator.getMockId(PersonDigitalIdentity__x.getSObjectType())
    );
    input.put(
      'activeConsentList',
      (List<Object>) JSON.deserializeUntyped(activeConsentListTesting)
    );
    input.put(
      'archiveConsentList',
      (List<Object>) JSON.deserializeUntyped(archiveConsentListTesting)
    );
    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call(methodName, args);
    Map<String, Object> payload = (Map<String, Object>) output.get(
      'consentList'
    );
    returnMap.put('isInvoked', isInvoked);
    returnMap.put('payload', payload);
    returnMap.put('output', output);
    system.debug('test' + returnMap);
    return returnMap;
  }
}