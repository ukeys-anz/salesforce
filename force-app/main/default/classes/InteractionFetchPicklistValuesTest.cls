/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesTest is the Mock class to cover tests for {@link InteractionFetchPickValues}
 */
@isTest
public class InteractionFetchPicklistValuesTest {
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

    List<String> coachPSs = new List<String>{
      'Case_Read_Write_Get_Help',
      'Customer_Read_Only',
      'Quality_Assessment_Read_Only',
      'Case_Read_Write_Dispute',
      'Salesforce_Internal_API'
    };
    List<PermissionSet> coachPsList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :coachPSs
    ];
    List<PermissionSetAssignment> coachPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : coachPsList) {
      coachPsaList.add(TestUtil.createPSAssignment(coachUser.id, ps.Id));
    }
    insert coachPsaList;
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
        new MockInteractionFetchPickValues(
          '{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"408fcca515d78fbc54f6e8fd6eb484fb","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0122P0000004RefQAE/Interaction_Purpose__c","values":[{"attributes":null,"label":"Customer","validFor":[0,1,2,3],"value":"Customer"},{"attributes":null,"label":"Non-Customer","validFor":[0,1,2,3],"value":"Non-Customer"},{"attributes":null,"label":"Testing","validFor":[0,1,2,3],"value":"Testing"},{"attributes":null,"label":"Wrong Number","validFor":[0,1,3],"value":"Wrong Number"},{"attributes":null,"label":"Existing ANZ Customer","validFor":[2],"value":"Existing ANZ Customer"}]}'
        )
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
  private static void testPopulateWhoForStorePositive() {
    String methodName = 'populateWhoForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Store":0,"Pop up":1,"Branch":2},"defaultValue":null,"eTag":"ab7620110d736a04e1d9460e5f167187","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0129j000000JJJBAA4/Interaction_Purpose__c","values":[{"attributes":null,"label":"Customer","validFor":[0],"value":"Customer"},{"attributes":null,"label":"Digital Support","validFor":[0],"value":"Digital Support"},{"attributes":null,"label":"Financial Wellbeing","validFor":[0],"value":"Financial Wellbeing"},{"attributes":null,"label":"Non-Customer","validFor":[0],"value":"Non-Customer"},{"attributes":null,"label":"Other","validFor":[0],"value":"Other"},{"attributes":null,"label":"Testing","validFor":[0],"value":"Testing"},{"attributes":null,"label":"Existing ANZ Customer","validFor":[0],"value":"Existing ANZ Customer"}]}'
      )
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
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Store":0,"Pop up":1,"Branch":2},"defaultValue":null,"eTag":"bd63bf15f76bccf5dad8bc71b8032b14","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0129j000000JJJBAA4/Authentication_Method__c","values":[{"attributes":null,"label":"Could not authenticate","validFor":[0],"value":"Could not authenticate"},{"attributes":null,"label":"Not Required","validFor":[0],"value":"Not Required"},{"attributes":null,"label":"Sighted App Profile","validFor":[0],"value":"Sighted App Profile"},{"attributes":null,"label":"Sighted ID","validFor":[0],"value":"Sighted ID"}]}'
      )
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
  private static void testpopulateAuthMethodForCallPositive() {
    String methodName = 'populateAuthMethodForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"687ce79aff116f82f2c8baf984034698","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0122P0000004RefQAE/Authentication_Method__c","values":[{"attributes":null,"label":"Call Transfer - Authenticated","validFor":[0,3],"value":"Call Transfer - Authenticated"},{"attributes":null,"label":"Could not authenticate","validFor":[0,2,3],"value":"Could not authenticate"},{"attributes":null,"label":"Manually Authenticated","validFor":[0,3],"value":"Manually Authenticated"},{"attributes":null,"label":"Not Required","validFor":[0,1,2,3],"value":"Not Required"},{"attributes":null,"label":"Sighted App Profile","validFor":[2],"value":"Sighted App Profile"},{"attributes":null,"label":"Sighted ID","validFor":[2],"value":"Sighted ID"},{"attributes":null,"label":"SMS - OTP","validFor":[0,3],"value":"SMS - OTP"}]}'
      )
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
  private static void testpopulateActionTakenForStorePositive() {
    String methodName = 'populateActionTakenForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Customer":0,"Digital Support":1,"Financial Wellbeing":2,"Non-Customer":3,"Other":4,"Testing":5,"Wrong Number":6,"Existing ANZ Customer":7},"defaultValue":null,"eTag":"058d69c5ad6147e16171f755aa8f4d3c","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0129j000000JJJBAA4/Resolution__c","values":[{"attributes":null,"label":"Did not Answer","validFor":[0,3,7],"value":"Did not Answer"},{"attributes":null,"label":"Follow-up Required","validFor":[0,7],"value":"Follow-up Required"},{"attributes":null,"label":"Referred","validFor":[0,3,7],"value":"Referred"},{"attributes":null,"label":"Resolved","validFor":[0,3,7],"value":"Resolved"},{"attributes":null,"label":"Voice Mail","validFor":[0,3,7],"value":"Voice Mail"},{"attributes":null,"label":"Assisted App download","validFor":[0,1,2,3,4,5,6,7],"value":"Assisted App download"},{"attributes":null,"label":"No Action","validFor":[0,1,2,3,4,5,6,7],"value":"No Action"}]}'
      )
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
  private static void testpopulateActionTakenForCallPositive() {
    String methodName = 'populateActionTakenForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Customer":0,"Non-Customer":1,"Testing":2,"Wrong Number":3,"Existing ANZ Customer":4},"defaultValue":null,"eTag":"058d69c5ad6147e16171f755aa8f4d3c","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0122P0000004RefQAE/Resolution__c","values":[{"attributes":null,"label":"Did not Answer","validFor":[0,1,4],"value":"Did not Answer"},{"attributes":null,"label":"Follow-up Required","validFor":[0,4],"value":"Follow-up Required"},{"attributes":null,"label":"Referred","validFor":[0,1,4],"value":"Referred"},{"attributes":null,"label":"Resolved","validFor":[0,1,4],"value":"Resolved"},{"attributes":null,"label":"Voice Mail","validFor":[0,1,4],"value":"Voice Mail"},{"attributes":null,"label":"Assisted App download","validFor":[0,1,2,3,4],"value":"Assisted App download"},{"attributes":null,"label":"No Action","validFor":[0,1,2,3,4],"value":"No Action"}]}'
      )
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
      new MockInteractionFetchPickValues(
        '{"controllerValues":{},"defaultValue":null,"eTag":"1ba55e05227bf77a03a0583050be373f","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0122P0000004RefQAE/InteractionType","values":[{"attributes":null,"label":"Call","validFor":[],"value":"Call"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Coaching Lab","validFor":[],"value":"Store"},{"attributes":null,"label":"Video","validFor":[],"value":"Video"}]}'
      )
    );
    Map<String, Object> outputResponse = initializeVariables(methodName);
    List<Map<String, String>> dependencyOutput = (List<Map<String, String>>) outputResponse.get(
      'options'
    );
    System.assertEquals(6, dependencyOutput.size(), 'Channel has 6 values');
  }

  @IsTest
  private static void testpopulateReferredToForStorePositive() {
    String methodName = 'populateReferredToForStore';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Did not Answer":0,"Follow-up Required":1,"Referred":2,"Resolved":3,"Voice Mail":4,"Assisted App download":5,"No Action":6},"defaultValue":null,"eTag":"3cf69ff1bdaaa4a17a352049b91b2f53","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0129j000000JJJBAA4/Referred_To__c","values":[{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"},{"attributes":null,"label":"Business","validFor":[2],"value":"Business"},{"attributes":null,"label":"Contact Centre","validFor":[2],"value":"Contact Centre"},{"attributes":null,"label":"Mobile Lending","validFor":[2],"value":"Mobile Lending"},{"attributes":null,"label":"Other","validFor":[2],"value":"Other"}]}'
      )
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

  @IsTest
  private static void testpopulateReferredToForCallPositive() {
    String methodName = 'populateReferredToForCall';
    Test.setMock(
      HttpCalloutMock.class,
      new MockInteractionFetchPickValues(
        '{"controllerValues":{"Did not Answer":0,"Follow-up Required":1,"Referred":2,"Resolved":3,"Voice Mail":4,"Assisted App download":5,"No Action":6},"defaultValue":null,"eTag":"3cf69ff1bdaaa4a17a352049b91b2f53","url":"/services/data/v56.0/ui-api/object-info/interaction/picklist-values/0129j000000JJJBAA4/Referred_To__c","values":[{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"},{"attributes":null,"label":"Business","validFor":[2],"value":"Business"},{"attributes":null,"label":"Contact Centre","validFor":[2],"value":"Contact Centre"},{"attributes":null,"label":"Mobile Lending","validFor":[2],"value":"Mobile Lending"},{"attributes":null,"label":"Other","validFor":[2],"value":"Other"}]}'
      )
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
