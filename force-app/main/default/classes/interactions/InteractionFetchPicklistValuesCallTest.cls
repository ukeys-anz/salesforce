/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesCallTest is the Mock class to cover tests for {@link InteractionFetchPickValuesForCall}
 */
@isTest
public class InteractionFetchPicklistValuesCallTest {
  private static final String API_RESPONSE_CALL_RT = ([
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_APIResponseCallRecordType'
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
  private static void testPopulateWhoForCallPositive() {
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachInter567'
    ];
    System.runAs(coachUser) {
      String methodName = 'populateWhoForCall';
      Test.setMock(
        HttpCalloutMock.class,
        new MockInteractionFetchPickValues(API_RESPONSE_Call_RT)
      );
      Map<String, Object> outputResponse = initializeVariables(methodName);
      Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
        'dependency'
      );
      List<Map<String, Object>> whoCallMapValues = (List<Map<String, Object>>) dependencyOutput.get(
        'Call'
      );
      System.assertEquals(
        true,
        whoCallMapValues.size() > 0,
        'Who field of call record type should not be empty'
      );
    }
  }

  @IsTest
  private static void testpopulateAuthMethodForCallPositive() {
    String methodName = 'populateAuthMethodForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_Call_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      4,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 4'
    );
    List<Map<String, Object>> authCallMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Call'
    );
    System.assertEquals(
      true,
      authCallMapValues.size() > 0,
      'auth field of call map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateActionTakenForCallPositive() {
    String methodName = 'populateActionTakenForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_Call_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      5,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 5'
    );
    List<Map<String, Object>> actiontakenCallMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Customer'
    );
    System.assertEquals(
      true,
      actiontakenCallMapValues.size() > 0,
      'action taken field of call map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateChannelForCallPositive() {
    String methodName = 'populateChannelForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_Call_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    List<Map<String, String>> dependencyOutput = (List<Map<String, String>>) outputResponse.get(
      'options'
    );
    System.assertEquals(6, dependencyOutput.size(), 'Channel has 6 values');
  }

  @IsTest
  private static void testpopulateReferredToForCallPositive() {
    String methodName = 'populateReferredToForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_Call_RT)
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
   * @param methodName Field and record type requiring field mapping
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
    Boolean success = (Boolean) new InteractionFetchPicklistValuesForCall()
      .call(methodName, args);
    Test.stopTest();
    Map<String, Object> outputResponse = (Map<String, Object>) args.get(
      'output'
    );

    return outputResponse;
  }
}
