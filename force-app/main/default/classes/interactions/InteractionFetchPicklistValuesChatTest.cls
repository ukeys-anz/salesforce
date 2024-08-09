/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesChatTest is the Mock class to cover tests for {@link InteractionFetchPickValuesForChat}
 */
@isTest
public class InteractionFetchPicklistValuesChatTest {
  private static final String API_RESPONSE_CHAT_RT = ([
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_APIResponseChatRecordType'
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
  private static void testPopulateWhoForChatPositive() {
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachInter567'
    ];
    System.runAs(coachUser) {
      String methodName = 'populateWhoForChat';
      Test.setMock(
        HttpCalloutMock.class,
        new MockInteractionFetchPickValues(API_RESPONSE_CHAT_RT)
      );
      Map<String, Object> outputResponse = initializeVariables(methodName);
      Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
        'dependency'
      );
      List<Map<String, Object>> whoChatMapValues = (List<Map<String, Object>>) dependencyOutput.get(
        'Chat'
      );
      System.assertEquals(
        true,
        whoChatMapValues.size() > 0,
        'Who field of chat record type should not be empty'
      );
    }
  }

  @IsTest
  private static void testpopulateAuthMethodForChatPositive() {
    String methodName = 'populateAuthMethodForChat';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_CHAT_RT)
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
    List<Map<String, Object>> authChatMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Chat'
    );
    System.assertEquals(
      true,
      authChatMapValues.size() > 0,
      'auth field of chat map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateActionTakenForChatPositive() {
    String methodName = 'populateActionTakenForChat';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_CHAT_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    Map<String, Object> dependencyOutput = (Map<String, Object>) outputResponse.get(
      'dependency'
    );
    System.assertEquals(
      6,
      dependencyOutput.keySet().size(),
      'DependencyOutput key size should be 6'
    );
    List<Map<String, Object>> actiontakenChatMapValues = (List<Map<String, Object>>) dependencyOutput.get(
      'Customer'
    );
    System.assertEquals(
      true,
      actiontakenChatMapValues.size() > 0,
      'action taken field of chat map should not be empty'
    );
  }

  @IsTest
  private static void testpopulateChannelForChatPositive() {
    String methodName = 'populateChannelForChat';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_CHAT_RT)
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    List<Map<String, String>> dependencyOutput = (List<Map<String, String>>) outputResponse.get(
      'options'
    );
    System.assertEquals(11, dependencyOutput.size(), 'Channel has 11 values');
  }

  @IsTest
  private static void testpopulateReferredToForChatPositive() {
    String methodName = 'populateReferredToForChat';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(API_RESPONSE_CHAT_RT)
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
    Boolean success = (Boolean) new InteractionFetchPicklistValuesForChat()
      .call(methodName, args);
    Test.stopTest();
    Map<String, Object> outputResponse = (Map<String, Object>) args.get(
      'output'
    );

    return outputResponse;
  }
}
