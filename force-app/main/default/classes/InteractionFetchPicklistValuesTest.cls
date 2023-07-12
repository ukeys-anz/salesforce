/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesTest is the Mock class to cover tests for {@link InteractionFetchPickValues}
 */
@isTest
public class InteractionFetchPicklistValuesTest {
  private static final String API_RESPONSE_STORE_RT = '{"eTag":"c76e6e037d9a5832f203013a32b727dd","picklistFieldValues":{"Authentication_Method__c":{"controllerValues":{"Store":0,"Pop up":1,"Branch":2},"defaultValue":null,"eTag":"bd63bf15f76bccf5dad8bc71b8032b14","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Authentication_Method__c","values":[{"attributes":null,"label":"Could not authenticate","validFor":[0],"value":"Could not authenticate"},{"attributes":null,"label":"Not Required","validFor":[0],"value":"Not Required"},{"attributes":null,"label":"Sighted App Profile","validFor":[0],"value":"Sighted App Profile"},{"attributes":null,"label":"Sighted ID","validFor":[0],"value":"Sighted ID"}]},"Channel_Booked__c":{"controllerValues":{},"defaultValue":null,"eTag":"d08047356876ebf312ded240e3a54ccd","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Channel_Booked__c","values":[{"attributes":null,"label":"App","validFor":[],"value":"App"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Store","validFor":[],"value":"Store"}]},"Direction__c":{"controllerValues":{},"defaultValue":null,"eTag":"4222be36bdd23236d57ee29a8c21cc32","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Direction__c","values":[{"attributes":null,"label":"Inbound","validFor":[],"value":"Inbound"},{"attributes":null,"label":"Outbound","validFor":[],"value":"Outbound"}]},"InteractionType":{"controllerValues":{},"defaultValue":{"attributes":null,"label":"Coaching Lab","validFor":[],"value":"Store"},"eTag":"b057935ed43e5b1b16f9c2add8ca7d7b","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/InteractionType","values":[{"attributes":null,"label":"Coaching Lab","validFor":[],"value":"Store"},{"attributes":null,"label":"Pop up","validFor":[],"value":"Pop up"},{"attributes":null,"label":"Branch","validFor":[],"value":"Branch"}]},"Interaction_Purpose__c":{"controllerValues":{"Store":0,"Pop up":1,"Branch":2},"defaultValue":null,"eTag":"ab7620110d736a04e1d9460e5f167187","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Interaction_Purpose__c","values":[{"attributes":null,"label":"Customer","validFor":[0],"value":"Customer"},{"attributes":null,"label":"Digital Support","validFor":[0],"value":"Digital Support"},{"attributes":null,"label":"Financial Wellbeing","validFor":[0],"value":"Financial Wellbeing"},{"attributes":null,"label":"Non-Customer","validFor":[0],"value":"Non-Customer"},{"attributes":null,"label":"Other","validFor":[0],"value":"Other"},{"attributes":null,"label":"Testing","validFor":[0],"value":"Testing"},{"attributes":null,"label":"Existing ANZ Customer","validFor":[0],"value":"Existing ANZ Customer"}]},"Place__c":{"controllerValues":{"Store":0,"Pop up":1,"Branch":2},"defaultValue":null,"eTag":"1b0b0b070f287e68ec2db783de876543","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Place__c","values":[{"attributes":null,"label":"Potts Point","validFor":[0],"value":"Potts Point"},{"attributes":null,"label":"Richmond","validFor":[0],"value":"Richmond"},{"attributes":null,"label":"ACT","validFor":[1],"value":"ACT"},{"attributes":null,"label":"NSW","validFor":[1],"value":"NSW"},{"attributes":null,"label":"NT","validFor":[1],"value":"NT"},{"attributes":null,"label":"QLD","validFor":[1],"value":"QLD"},{"attributes":null,"label":"SA","validFor":[1],"value":"SA"},{"attributes":null,"label":"TAS","validFor":[1],"value":"TAS"},{"attributes":null,"label":"VIC","validFor":[1],"value":"VIC"},{"attributes":null,"label":"WA","validFor":[1],"value":"WA"},{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"}]},"Referred_To__c":{"controllerValues":{"Did not Answer":0,"Follow-up Required":1,"Referred":2,"Resolved":3,"Voice Mail":4,"Assisted App download":5,"No Action":6},"defaultValue":null,"eTag":"3cf69ff1bdaaa4a17a352049b91b2f53","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Referred_To__c","values":[{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"},{"attributes":null,"label":"Business","validFor":[2],"value":"Business"},{"attributes":null,"label":"Contact Centre","validFor":[2],"value":"Contact Centre"},{"attributes":null,"label":"Mobile Lending","validFor":[2],"value":"Mobile Lending"},{"attributes":null,"label":"Other","validFor":[2],"value":"Other"}]},"Resolution__c":{"controllerValues":{"Customer":0,"Digital Support":1,"Financial Wellbeing":2,"Non-Customer":3,"Other":4,"Testing":5,"Wrong Number":6,"Existing ANZ Customer":7},"defaultValue":null,"eTag":"058d69c5ad6147e16171f755aa8f4d3c","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Resolution__c","values":[{"attributes":null,"label":"Did not Answer","validFor":[0,3,7],"value":"Did not Answer"},{"attributes":null,"label":"Follow-up Required","validFor":[0,7],"value":"Follow-up Required"},{"attributes":null,"label":"Referred","validFor":[0,3,7],"value":"Referred"},{"attributes":null,"label":"Resolved","validFor":[0,3,7],"value":"Resolved"},{"attributes":null,"label":"Voice Mail","validFor":[0,3,7],"value":"Voice Mail"},{"attributes":null,"label":"Assisted App download","validFor":[0,1,2,3,4,5,6,7],"value":"Assisted App download"},{"attributes":null,"label":"No Action","validFor":[0,1,2,3,4,5,6,7],"value":"No Action"}]},"Status__c":{"controllerValues":{},"defaultValue":null,"eTag":"7a5685c85d00d31eea2420f944c12139","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Status__c","values":[{"attributes":null,"label":"Unassigned","validFor":[],"value":"Unassigned"},{"attributes":null,"label":"Scheduled","validFor":[],"value":"Scheduled"},{"attributes":null,"label":"Rescheduled","validFor":[],"value":"Rescheduled"},{"attributes":null,"label":"Walk In","validFor":[],"value":"Walk In"},{"attributes":null,"label":"Cancelled","validFor":[],"value":"Cancelled"},{"attributes":null,"label":"No Show","validFor":[],"value":"No Show"},{"attributes":null,"label":"Completed","validFor":[],"value":"Completed"},{"attributes":null,"label":"Not Completed","validFor":[],"value":"Not Completed"},{"attributes":null,"label":"Created","validFor":[],"value":"Created"},{"attributes":null,"label":"Linked","validFor":[],"value":"Linked"}]},"Support_Topics__c":{"controllerValues":{},"defaultValue":null,"eTag":"37c16a506ca40881f24c02491964ccc4","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000AmEfAAK/Support_Topics__c","values":[{"attributes":null,"label":"Transaction Disputes","validFor":[],"value":"Transaction Disputes"}]}}}';

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
