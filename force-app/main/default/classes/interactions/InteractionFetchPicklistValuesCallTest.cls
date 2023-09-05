/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesCallTest is the Mock class to cover tests for {@link InteractionFetchPickValuesForCall}
 */
@isTest
public class InteractionFetchPicklistValuesCallTest {
  private static final String API_RESPONSE_CALL_RT = '{"eTag":"3b7fc3ebdc91f8ec695b48558f0933b6","picklistFieldValues":{"Authentication_Method__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"687ce79aff116f82f2c8baf984034698","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Authentication_Method__c","values":[{"attributes":null,"label":"Call Transfer - Authenticated","validFor":[0,3],"value":"Call Transfer - Authenticated"},{"attributes":null,"label":"Could not authenticate","validFor":[0,2,3],"value":"Could not authenticate"},{"attributes":null,"label":"Manually Authenticated","validFor":[0,3],"value":"Manually Authenticated"},{"attributes":null,"label":"Not Required","validFor":[0,1,2,3],"value":"Not Required"},{"attributes":null,"label":"Sighted App Profile","validFor":[2],"value":"Sighted App Profile"},{"attributes":null,"label":"Sighted ID","validFor":[2],"value":"Sighted ID"},{"attributes":null,"label":"SMS - OTP","validFor":[0,3],"value":"SMS - OTP"}]},"Channel_Booked__c":{"controllerValues":{},"defaultValue":null,"eTag":"d08047356876ebf312ded240e3a54ccd","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Channel_Booked__c","values":[{"attributes":null,"label":"App","validFor":[],"value":"App"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Store","validFor":[],"value":"Store"}]},"Direction__c":{"controllerValues":{},"defaultValue":null,"eTag":"4222be36bdd23236d57ee29a8c21cc32","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Direction__c","values":[{"attributes":null,"label":"Inbound","validFor":[],"value":"Inbound"},{"attributes":null,"label":"Outbound","validFor":[],"value":"Outbound"}]},"InteractionType":{"controllerValues":{},"defaultValue":null,"eTag":"1ba55e05227bf77a03a0583050be373f","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/InteractionType","values":[{"attributes":null,"label":"Call","validFor":[],"value":"Call"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Coaching Lab","validFor":[],"value":"Store"},{"attributes":null,"label":"Video","validFor":[],"value":"Video"}]},"Interaction_Purpose__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"408fcca515d78fbc54f6e8fd6eb484fb","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Interaction_Purpose__c","values":[{"attributes":null,"label":"Customer","validFor":[0,1,2,3],"value":"Customer"},{"attributes":null,"label":"Non-Customer","validFor":[0,1,2,3],"value":"Non-Customer"},{"attributes":null,"label":"Testing","validFor":[0,1,2,3],"value":"Testing"},{"attributes":null,"label":"Wrong Number","validFor":[0,1,3],"value":"Wrong Number"},{"attributes":null,"label":"Existing ANZ Customer","validFor":[2],"value":"Existing ANZ Customer"}]},"Place__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"3168c070c072e879f0747bf1b25c3319","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Place__c","values":[{"attributes":null,"label":"Potts Point","validFor":[2],"value":"Potts Point"},{"attributes":null,"label":"Richmond","validFor":[2],"value":"Richmond"}]},"Referred_To__c":{"controllerValues":{"Did not Answer":0,"Follow-up Required":1,"Referred":2,"Resolved":3,"Voice Mail":4,"Assisted App download":5,"No Action":6},"defaultValue":null,"eTag":"3cf69ff1bdaaa4a17a352049b91b2f53","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Referred_To__c","values":[{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"},{"attributes":null,"label":"Business","validFor":[2],"value":"Business"},{"attributes":null,"label":"Contact Centre","validFor":[2],"value":"Contact Centre"},{"attributes":null,"label":"Mobile Lending","validFor":[2],"value":"Mobile Lending"},{"attributes":null,"label":"Other","validFor":[2],"value":"Other"}]},"Resolution__c":{"controllerValues":{"Customer":0,"Non-Customer":1,"Testing":2,"Wrong Number":3,"Existing ANZ Customer":4},"defaultValue":null,"eTag":"058d69c5ad6147e16171f755aa8f4d3c","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Resolution__c","values":[{"attributes":null,"label":"Did not Answer","validFor":[0,1,4],"value":"Did not Answer"},{"attributes":null,"label":"Follow-up Required","validFor":[0,4],"value":"Follow-up Required"},{"attributes":null,"label":"Referred","validFor":[0,1,4],"value":"Referred"},{"attributes":null,"label":"Resolved","validFor":[0,1,4],"value":"Resolved"},{"attributes":null,"label":"Voice Mail","validFor":[0,1,4],"value":"Voice Mail"},{"attributes":null,"label":"Assisted App download","validFor":[0,1,2,3,4],"value":"Assisted App download"},{"attributes":null,"label":"No Action","validFor":[0,1,2,3,4],"value":"No Action"}]},"Status__c":{"controllerValues":{},"defaultValue":null,"eTag":"76beffb71e7de56c1996508148e80776","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Status__c","values":[{"attributes":null,"label":"Created","validFor":[],"value":"Created"},{"attributes":null,"label":"Linked","validFor":[],"value":"Linked"}]},"Support_Topics__c":{"controllerValues":{},"defaultValue":null,"eTag":"37c16a506ca40881f24c02491964ccc4","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AeMWAA0/Support_Topics__c","values":[{"attributes":null,"label":"Transaction Disputes","validFor":[],"value":"Transaction Disputes"}]}}}';

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
