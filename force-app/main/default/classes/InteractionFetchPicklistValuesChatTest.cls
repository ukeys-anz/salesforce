/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description InteractionFetchPicklistValuesChatTest is the Mock class to cover tests for {@link InteractionFetchPickValuesForChat}
 */
@isTest
public class InteractionFetchPicklistValuesChatTest {
  private static final String API_RESPONSE_CHAT_RT = '{"eTag":"cfdd268b8f0de2be60fdb253c6a5abf5","picklistFieldValues":{"Authentication_Method__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"687ce79aff116f82f2c8baf984034698","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Authentication_Method__c","values":[{"attributes":null,"label":"Call Transfer - Authenticated","validFor":[0,3],"value":"Call Transfer - Authenticated"},{"attributes":null,"label":"Could not authenticate","validFor":[0,2,3],"value":"Could not authenticate"},{"attributes":null,"label":"Manually Authenticated","validFor":[0,3],"value":"Manually Authenticated"},{"attributes":null,"label":"Not Required","validFor":[0,1,2,3],"value":"Not Required"},{"attributes":null,"label":"Sighted App Profile","validFor":[2],"value":"Sighted App Profile"},{"attributes":null,"label":"Sighted ID","validFor":[2],"value":"Sighted ID"},{"attributes":null,"label":"SMS - OTP","validFor":[0,3],"value":"SMS - OTP"}]},"Channel_Booked__c":{"controllerValues":{},"defaultValue":null,"eTag":"d08047356876ebf312ded240e3a54ccd","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Channel_Booked__c","values":[{"attributes":null,"label":"App","validFor":[],"value":"App"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Store","validFor":[],"value":"Store"}]},"Direction__c":{"controllerValues":{},"defaultValue":null,"eTag":"4222be36bdd23236d57ee29a8c21cc32","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Direction__c","values":[{"attributes":null,"label":"Inbound","validFor":[],"value":"Inbound"},{"attributes":null,"label":"Outbound","validFor":[],"value":"Outbound"}]},"InteractionType":{"controllerValues":{},"defaultValue":null,"eTag":"1ba55e05227bf77a03a0583050be373f","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/InteractionType","values":[{"attributes":null,"label":"Call","validFor":[],"value":"Call"},{"attributes":null,"label":"Chat","validFor":[],"value":"Chat"},{"attributes":null,"label":"Coaching Lab","validFor":[],"value":"Store"},{"attributes":null,"label":"Video","validFor":[],"value":"Video"}]},"Interaction_Purpose__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"a49743abc1a08972b04de985f4c7a97f","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Interaction_Purpose__c","values":[{"attributes":null,"label":"Customer","validFor":[0,1,2,3],"value":"Customer"},{"attributes":null,"label":"Non-Customer","validFor":[0,1,2,3],"value":"Non-Customer"},{"attributes":null,"label":"Other","validFor":[0,1,2,3],"value":"Other"},{"attributes":null,"label":"Testing","validFor":[0,1,2,3],"value":"Testing"},{"attributes":null,"label":"Wrong Number","validFor":[0,1,3],"value":"Wrong Number"},{"attributes":null,"label":"Existing ANZ Customer","validFor":[2],"value":"Existing ANZ Customer"}]},"Place__c":{"controllerValues":{"Call":0,"Chat":1,"Store":2,"Video":3},"defaultValue":null,"eTag":"3168c070c072e879f0747bf1b25c3319","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Place__c","values":[{"attributes":null,"label":"Potts Point","validFor":[2],"value":"Potts Point"},{"attributes":null,"label":"Richmond","validFor":[2],"value":"Richmond"}]},"Referred_To__c":{"controllerValues":{"Did not Answer":0,"Follow-up Required":1,"Referred":2,"Resolved":3,"Voice Mail":4,"Assisted App download":5,"No Action":6},"defaultValue":null,"eTag":"3cf69ff1bdaaa4a17a352049b91b2f53","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Referred_To__c","values":[{"attributes":null,"label":"Branch","validFor":[2],"value":"Branch"},{"attributes":null,"label":"Business","validFor":[2],"value":"Business"},{"attributes":null,"label":"Contact Centre","validFor":[2],"value":"Contact Centre"},{"attributes":null,"label":"Mobile Lending","validFor":[2],"value":"Mobile Lending"},{"attributes":null,"label":"Other","validFor":[2],"value":"Other"}]},"Resolution__c":{"controllerValues":{"Customer":0,"Non-Customer":1,"Other":2,"Testing":3,"Wrong Number":4,"Existing ANZ Customer":5},"defaultValue":null,"eTag":"058d69c5ad6147e16171f755aa8f4d3c","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Resolution__c","values":[{"attributes":null,"label":"Did not Answer","validFor":[0,1,5],"value":"Did not Answer"},{"attributes":null,"label":"Follow-up Required","validFor":[0,5],"value":"Follow-up Required"},{"attributes":null,"label":"Referred","validFor":[0,1,5],"value":"Referred"},{"attributes":null,"label":"Resolved","validFor":[0,1,5],"value":"Resolved"},{"attributes":null,"label":"Voice Mail","validFor":[0,1,5],"value":"Voice Mail"},{"attributes":null,"label":"Assisted App download","validFor":[0,1,2,3,4,5],"value":"Assisted App download"},{"attributes":null,"label":"No Action","validFor":[0,1,2,3,4,5],"value":"No Action"}]},"Status__c":{"controllerValues":{},"defaultValue":null,"eTag":"76beffb71e7de56c1996508148e80776","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Status__c","values":[{"attributes":null,"label":"Created","validFor":[],"value":"Created"},{"attributes":null,"label":"Linked","validFor":[],"value":"Linked"}]},"Support_Topics__c":{"controllerValues":{},"defaultValue":null,"eTag":"dee836b59493bfdeeca9866ae0c24610","url":"/services/data/v56.0/ui-api/object-info/Interaction/picklist-values/0129h000000Ap9JAAS/Support_Topics__c","values":[{"attributes":null,"label":"Transaction Disputes","validFor":[],"value":"Transaction Disputes"},{"attributes":null,"label":"Add/Edit Details","validFor":[],"value":"Add/Edit Details"},{"attributes":null,"label":"Add Life Event","validFor":[],"value":"Add Life Event"},{"attributes":null,"label":"ANZ Plus Support","validFor":[],"value":"ANZ Plus Support"},{"attributes":null,"label":"App Guide","validFor":[],"value":"App Guide"},{"attributes":null,"label":"App security","validFor":[],"value":"App security"},{"attributes":null,"label":"Bug Report","validFor":[],"value":"Bug Report"},{"attributes":null,"label":"Cancel a Dispute","validFor":[],"value":"Cancel a Dispute"},{"attributes":null,"label":"Card Enquiry","validFor":[],"value":"Card Enquiry"},{"attributes":null,"label":"Card Issue","validFor":[],"value":"Card Issue"},{"attributes":null,"label":"Card Lost/Stolen","validFor":[],"value":"Card Lost/Stolen"},{"attributes":null,"label":"Coaching/Needs based Discussion","validFor":[],"value":"Coaching/Needs based Discussion"},{"attributes":null,"label":"Create or Manage PayID","validFor":[],"value":"Create or Manage PayID"},{"attributes":null,"label":"Credit Reporting","validFor":[],"value":"Credit Reporting"},{"attributes":null,"label":"Device Support","validFor":[],"value":"Device Support"},{"attributes":null,"label":"Digital Support","validFor":[],"value":"Digital Support"},{"attributes":null,"label":"Direct Debit or Recurring Payment","validFor":[],"value":"Direct Debit or Recurring Payment"},{"attributes":null,"label":"Feature Request","validFor":[],"value":"Feature Request"},{"attributes":null,"label":"Fees &amp; Charges","validFor":[],"value":"Fees &amp; Charges"},{"attributes":null,"label":"Fraud","validFor":[],"value":"Fraud"},{"attributes":null,"label":"Hoax Email/SMS","validFor":[],"value":"Hoax Email/SMS"},{"attributes":null,"label":"KYC","validFor":[],"value":"KYC"},{"attributes":null,"label":"New Dispute","validFor":[],"value":"New Dispute"},{"attributes":null,"label":"Overdraft","validFor":[],"value":"Overdraft"},{"attributes":null,"label":"Product Info","validFor":[],"value":"Product Info"},{"attributes":null,"label":"Re-Identification","validFor":[],"value":"Re-Identification"},{"attributes":null,"label":"Re-Joining","validFor":[],"value":"Re-Joining"},{"attributes":null,"label":"Round Ups","validFor":[],"value":"Round Ups"},{"attributes":null,"label":"Savings Goals","validFor":[],"value":"Savings Goals"},{"attributes":null,"label":"Transaction","validFor":[],"value":"Transaction"},{"attributes":null,"label":"About ANZ Plus","validFor":[],"value":"About ANZ Plus"},{"attributes":null,"label":"Privacy","validFor":[],"value":"Privacy"},{"attributes":null,"label":"ANZ branches","validFor":[],"value":"ANZ branches"},{"attributes":null,"label":"Lost or stolen card","validFor":[],"value":"Lost or stolen card"},{"attributes":null,"label":"Damaged card","validFor":[],"value":"Damaged card"},{"attributes":null,"label":"Using card","validFor":[],"value":"Using card"},{"attributes":null,"label":"Using account","validFor":[],"value":"Using account"},{"attributes":null,"label":"Savings and goals","validFor":[],"value":"Savings and goals"},{"attributes":null,"label":"Using tiles","validFor":[],"value":"Using tiles"},{"attributes":null,"label":"Statements","validFor":[],"value":"Statements"},{"attributes":null,"label":"Making payments","validFor":[],"value":"Making payments"},{"attributes":null,"label":"Updating details","validFor":[],"value":"Updating details"},{"attributes":null,"label":"Lost or new phone","validFor":[],"value":"Lost or new phone"},{"attributes":null,"label":"Power of attorney","validFor":[],"value":"Power of attorney"},{"attributes":null,"label":"General fraud enquiry","validFor":[],"value":"General fraud enquiry"},{"attributes":null,"label":"Card/device block enquiry","validFor":[],"value":"Card/device block enquiry"},{"attributes":null,"label":"Falcon transaction confirmation","validFor":[],"value":"Falcon transaction confirmation"},{"attributes":null,"label":"Hardship","validFor":[],"value":"Hardship"},{"attributes":null,"label":"Coaching","validFor":[],"value":"Coaching"},{"attributes":null,"label":"Extra Care","validFor":[],"value":"Extra Care"},{"attributes":null,"label":"Digital wallet provisioning","validFor":[],"value":"Digital wallet provisioning"},{"attributes":null,"label":"Digital wallet issue","validFor":[],"value":"Digital wallet issue"},{"attributes":null,"label":"Raising a concern","validFor":[],"value":"Raising a concern"},{"attributes":null,"label":"Withholding tax refund","validFor":[],"value":"Withholding tax refund"},{"attributes":null,"label":"Large Value Transfer enquiries","validFor":[],"value":"Large Value Transfer enquiries"},{"attributes":null,"label":"Proof of Amount","validFor":[],"value":"Proof of Amount"},{"attributes":null,"label":"General Home Loan Enquiry","validFor":[],"value":"General Home Loan Enquiry"},{"attributes":null,"label":"Managing Repayments","validFor":[],"value":"Managing Repayments"},{"attributes":null,"label":"Close Home Loan","validFor":[],"value":"Close Home Loan"},{"attributes":null,"label":"Loan Statements","validFor":[],"value":"Loan Statements"},{"attributes":null,"label":"Interest Rate","validFor":[],"value":"Interest Rate"},{"attributes":null,"label":"90% Centrelink Payment Request","validFor":[],"value":"90% Centrelink Payment Request"},{"attributes":null,"label":"Account Switching","validFor":[],"value":"Account Switching"},{"attributes":null,"label":"Renewal and Restructures","validFor":[],"value":"Renewal and Restructures"},{"attributes":null,"label":"Customer Onboarding information","validFor":[],"value":"Customer Onboarding information"},{"attributes":null,"label":"TFN exemption (non resident &amp; &lt;16yrs old)","validFor":[],"value":"TFN exemption (non resident &amp; &lt;16yrs old)"},{"attributes":null,"label":"Occupation Updates","validFor":[],"value":"Occupation Updates"},{"attributes":null,"label":"Address Update (overseas)","validFor":[],"value":"Address Update (overseas)"},{"attributes":null,"label":"Citizenship Update","validFor":[],"value":"Citizenship Update"},{"attributes":null,"label":"Statement Requests","validFor":[],"value":"Statement Requests"},{"attributes":null,"label":"Garnishee Orders","validFor":[],"value":"Garnishee Orders"},{"attributes":null,"label":"Freezing Orders","validFor":[],"value":"Freezing Orders"},{"attributes":null,"label":"Account Closure Enquiry","validFor":[],"value":"Account Closure Enquiry"},{"attributes":null,"label":"Legal Name Change","validFor":[],"value":"Legal Name Change"},{"attributes":null,"label":"Direct Debit or Recurring Payments stop request","validFor":[],"value":"Direct Debit or Recurring Payments stop request"},{"attributes":null,"label":"Direct Debit or Recurring Payments 13 month statement","validFor":[],"value":"Direct Debit or Recurring Payments 13 month statement"},{"attributes":null,"label":"Large Value Transfer requests","validFor":[],"value":"Large Value Transfer requests"},{"attributes":null,"label":"EOFY","validFor":[],"value":"EOFY"},{"attributes":null,"label":"Document Request","validFor":[],"value":"Document Request"},{"attributes":null,"label":"Collections","validFor":[],"value":"Collections"},{"attributes":null,"label":"Redraw","validFor":[],"value":"Redraw"},{"attributes":null,"label":"Discharge","validFor":[],"value":"Discharge"},{"attributes":null,"label":"Refer a Friend","validFor":[],"value":"Refer a Friend"}]}}}';

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
    System.assertEquals(6, dependencyOutput.size(), 'Channel has 6 values');
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
