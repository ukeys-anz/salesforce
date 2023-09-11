/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesTest is the Mock class to cover tests for {@link InteractionFetchPickValues}
 */
@isTest
public class InteractionFetchPicklistValuesTest {
  private static final String API_RESPONSE_STORE_RT = ([
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_APIResponseStoreRecordType'
    ])
    .body.toString();

  @TestSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');

    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestCoachInter567',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coachUser;

    //Assign Permission set group as coach
    PermissionSetGroup psgCoach = [
      SELECT Id
      FROM PermissionSetGroup
      WHERE DeveloperName = 'Coach'
      LIMIT 1
    ];

    Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });

    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coachUser.Id,
      PermissionSetGroupId = psgCoach.Id
    );

    insert psa;
  }

  @IsTest
  private static void testPopulateWhoForStorePositive() {
    String methodName = 'populateWhoForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_STORE_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      3,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 3'
    );
    List<Map<String, Object>> whoStoreMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Store'
    );
    System.assertEquals(
      true,
      whoStoreMapValues.size() > 0,
      'Who field of store record type should not be empty'
    );
  }

  @IsTest
  private static void testpopulateAuthMethodForStorePositive() {
    String methodName = 'populateAuthMethodForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_STORE_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      3,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 3'
    );
    List<Map<String, Object>> authStoreMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Store'
    );
    System.assertEquals(
      true,
      authStoreMapValues.size() > 0,
      'auth field of store map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateActionTakenForStorePositive() {
    String methodName = 'populateActionTakenForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_STORE_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      8,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 8'
    );
    List<Map<String, Object>> actiontakenStoreMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Digital Support'
    );
    System.assertEquals(
      true,
      actiontakenStoreMapValues.size() > 0,
      'action taken field of store map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateReferredToForStorePositive() {
    String methodName = 'populateReferredToForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_STORE_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      7,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 7'
    );
  }

  /** @description Variable initialization method with common usage across other methods
   * @param methodName FField and record type requiring field mapping
   * @return  Dynamic Value Field Mapping
   */

  public static Map<String, Object> initializeVariables(string methodName) {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Map<String, Object> args = new Map<String, Object>();
    args.put('input', inputMap);
    args.put('output', outMap);
    args.put('options', options);
    Test.startTest();
    Boolean success = (Boolean) new InteractionFetchPicklistValues()
      .call(methodName, args);
    Test.stopTest();
    Map<String, Object> outputResponse = (Map<String, Object>) args.get(
      'output'
    );

    return outputResponse;
  }
}
