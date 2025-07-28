/**
 * @author Hannah Sainumkheaw
 * @last modified:   July 2025
 * @description Test class for {@link NonANZNetworkEventHandler}
 */

@isTest
public with sharing class NonANZNetworkEventHandlerTest {
  static Faker faker = new Faker('AU');
  static String anzxUserProfile = 'ANZx Standard User';
  static String externalAppProfile = 'Minimum Access - External Apps';
  static String allowedIPAddress = '165.225.226.251';
  static String allowedMaskedIPAddress = 'Salesforce.com IP';
  static String nonANZAddress = '255.255.255.255';
  static String invalidIPFormat = '233.1680.0';
  static String unknownMaskIPAddress = 'Sales.force.com.ip';

  //Mockdata required for Salesforce Transaction Security Policy
  static Lib_MockProvider testUserMock = Lib_MockProvider.forType(
    TSPRepository.class
  );

  static User anzxUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Alias = 'anzxUser',
    Username = 'anzxUser TestUser',
    Profile = CommonUtil.getProfileByName(anzxUserProfile)
  );

  static User externalAppUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Alias = 'externalAppUser',
    Username = 'externalAppUser TestUser',
    Profile = CommonUtil.getProfileByName(externalAppProfile)
  );

  @IsTest
  static void testIrrelevantTSPEvent() {
    //GIVEN Event that is not currently in NonANZNetworkEvent TSP
    ReportAnomalyEventStore reportAnomalyEventStore = new ReportAnomalyEventStore();

    Test.startTest();
    Boolean result = NonANZNetworkEventHandler.evaluate(
      reportAnomalyEventStore
    );
    Test.stopTest();

    Assert.isFalse(
      result,
      'irrelevant TSP events to NonANZNetworkEvent should be allowed'
    );
  }

  @IsTest
  static void testEvaluate() {
    //GIVEN non exemted Profile - ANZxStandard User Profile
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    //Api Events
    ApiEvent testApiEvent1AllowIP = new ApiEvent();
    testApiEvent1AllowIP.sourceIp = allowedIPAddress;
    ApiEvent testApiEvent2NotAllowIP = new ApiEvent();
    testApiEvent2NotAllowIP.sourceIp = nonANZAddress;
    ApiEvent testApiEvent3ExemptedMaskedIP = new ApiEvent();
    testApiEvent3ExemptedMaskedIP.sourceIp = allowedMaskedIPAddress;
    ApiEvent testApiEvent4invalidIPFormat = new ApiEvent();
    testApiEvent4invalidIPFormat.sourceIp = invalidIPFormat;
    //LoginEvents
    LoginEvent testLoginEvent1AllowIP = new LoginEvent();
    testLoginEvent1AllowIP.SourceIp = allowedIPAddress;
    LoginEvent testLoginEvent2NotAllowIP = new LoginEvent();
    testLoginEvent2NotAllowIP.SourceIp = nonANZAddress;
    LoginEvent testLoginEvent3ExemptedMaskedIP = new LoginEvent();
    testLoginEvent3ExemptedMaskedIP.SourceIp = allowedMaskedIPAddress;
    LoginEvent testLoginEvent4invalidIPFormat = new LoginEvent();
    testLoginEvent4invalidIPFormat.SourceIp = invalidIPFormat;

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    //Api Events
    Boolean testApiEvent1AllowIPResult = NonANZNetworkEventHandler.evaluate(
      testApiEvent1AllowIP
    );
    Boolean testApiEvent2NotAllowIPResult = NonANZNetworkEventHandler.evaluate(
      testApiEvent2NotAllowIP
    );
    Boolean testApiEvent3ExemptedMaskedIPResult = NonANZNetworkEventHandler.evaluate(
      testApiEvent3ExemptedMaskedIP
    );
    Boolean testApiEvent4invalidIPFormatResult = NonANZNetworkEventHandler.evaluate(
      testApiEvent4invalidIPFormat
    );
    //Login Events
    Boolean testLoginEvent1AllowIPResult = NonANZNetworkEventHandler.evaluate(
      testLoginEvent1AllowIP
    );
    Boolean testLoginEvent2NotAllowIPResult = NonANZNetworkEventHandler.evaluate(
      testLoginEvent2NotAllowIP
    );
    Boolean testLoginEvent3ExemptedMaskedIPResult = NonANZNetworkEventHandler.evaluate(
      testLoginEvent3ExemptedMaskedIP
    );
    Boolean testLoginEvent4invalidIPFormatResult = NonANZNetworkEventHandler.evaluate(
      testLoginEvent4invalidIPFormat
    );
    Test.stopTest();

    // THEN evalute method for TSP & policycheck with following expected results:
    // **** Api Events
    // testApiEvent1AllowIPResult should return FALSE(ALLOWED)
    Assert.isFalse(
      testApiEvent1AllowIPResult,
      'ApiEvent for anz network should be marked as allowed and return FALSE'
    );
    //testApiEvent2NotAllowIPResult should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      testApiEvent2NotAllowIPResult,
      'ApiEvent for non anz network should be detected and returned TRUE'
    );
    //testApiEvent3ExemptedMaskedIPResult should return FALSE(ALLOWED)
    Assert.isFalse(
      testApiEvent3ExemptedMaskedIPResult,
      'ApiEvent for anz network should be marked as allowed and return FALSE'
    );
    //testApiEvent4invalidIPFormatResult should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      testApiEvent4invalidIPFormatResult,
      'ApiEvent for non anz network should be detected and returned TRUE'
    );
    // *** Login Events
    //testLoginEvent1AllowIPResult should return FALSE(ALLOWED)
    Assert.isFalse(
      testLoginEvent1AllowIPResult,
      'LoginEvent for anz network should be marked as allowed and return FALSE'
    );
    //testLoginEvent2NotAllowIPResult should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      testLoginEvent2NotAllowIPResult,
      'LoginEvent for non anz network should be detected and returned TRUE'
    );
    //testLoginEvent3ExemptedMaskedIPResult should return FALSE(ALLOWED)
    Assert.isFalse(
      testLoginEvent3ExemptedMaskedIPResult,
      'LoginEvent for anz network should be marked as allowed and return FALSE'
    );
    //testLoginEvent4invalidIPFormatResult should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      testLoginEvent4invalidIPFormatResult,
      'LoginEvent for non anz network should be detected and returned TRUE'
    );
  }

  @isTest
  static void testApiEventAtBraodCastIPAllowed() {
    //GIVEN IP Address at a known ZScaler Australia's Broadcast Ip of 165.225.0.0
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '165.225.0.0';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);

    // THEN evalute method for TSP & policycheck for AllowList should return FALSE(ALLOWED)
    Assert.isFalse(
      tspResult,
      'ApiEvent for anz network should be marked as allowed for CIDR/32 Range and return FALSE(ALLOWED)'
    );
  }

  @isTest
  static void testIpToDecimal() {
    //GIVEN 2 x IPV4 address format
    String sourceIp1 = '165.225.226.251';
    Decimal expectedDecimal1 = 2783044347.0;

    String maxSourceIp = '255.255.255.255';
    Decimal maxDecimalIp = 4294967295.0;

    String nonIpFormat = '233.1680.0';
    Decimal nonIPDecimal = 0;

    //WHEN IPv4 converse to decimal format
    Test.startTest();
    Decimal decimalIPTest = NonANZNetworkEventHandler.ipToDecimal(sourceIp1);
    Decimal maxDecimalTest = NonANZNetworkEventHandler.ipToDecimal(maxSourceIp);
    Decimal nonIPFormatTest = NonANZNetworkEventHandler.ipToDecimal(
      nonIpFormat
    );
    Test.stopTest();

    //THEN
    //1. Check given sourceIP with expectedDecimal 1
    Assert.areEqual(
      expectedDecimal1,
      decimalIPTest,
      'Conversion Method should return correct decimal ip of the given IPv4' +
      sourceIp1
    );
    //2. Check possible maximum source Ip 255.255.255.255
    Assert.areEqual(
      maxDecimalIp,
      maxDecimalTest,
      'Conversion Method should return correct decimal ip of' + maxDecimalIp
    );
    //3. Check incorrect pormat IP Address
    Assert.areEqual(
      nonIPDecimal,
      nonIPFormatTest,
      'Conversion Method should return zero for decimal ip of' + nonIpFormat
    );
  }

  @isTest
  static void testIsIPInRange() {
    //GIVEN Decimal IP addresses
    Decimal inRangeDecimal = 2783044347.0;
    Decimal notInRangeDecimal = 167772400.0;

    //WHEN validates if an IPs are in allowed ranges
    Test.startTest();
    Boolean inRange = NonANZNetworkEventHandler.isIPInRange(inRangeDecimal);
    Boolean notInRange = NonANZNetworkEventHandler.isIPInRange(
      notInRangeDecimal
    );
    Test.stopTest();

    // THEN validate
    Assert.isTrue(inRange, 'Known IP Address should be accepted');
    Assert.isFalse(notInRange, 'Unknown IP Address should NOT be accepted');
  }
  @isTest
  static void testIsAllowedMaskedIP() {
    // WHEN validating the source IPs
    Test.startTest();
    Boolean isAllowed = NonANZNetworkEventHandler.isAllowedMaskedIP(
      allowedMaskedIPAddress
    );
    Boolean isNotAllowed = NonANZNetworkEventHandler.isAllowedMaskedIP(
      unknownMaskIPAddress
    );
    Test.stopTest();

    // THEN verify the results
    Assert.isTrue(isAllowed, 'The allowed masked IP should return TRUE');
    Assert.isFalse(
      isNotAllowed,
      'The not allowed masked IP should return FALSE'
    );
  }
  @isTest
  static void testIsAllowedProfile() {
    //GIVEN exempted profile and un-exempted profile to validate isAllowedProfile
    //WHEN Validate the isAllowedProfile & non ANZ Network TSP Evaluation Methods
    Test.startTest();
    Boolean testAllowedProfile = NonANZNetworkEventHandler.isAllowedProfile(
      externalAppProfile
    );
    Boolean testNotAllowedProfile = NonANZNetworkEventHandler.isAllowedProfile(
      anzxUserProfile
    );

    //THEN check the results of isAllowedProfile and  main evaluation method of non ANZ Network Policy
    Assert.isTrue(
      testAllowedProfile,
      'IP Restricted Profile should be exempted for ApiEvent and isAllowedProfile should return True'
    );

    Assert.isFalse(
      testNotAllowedProfile,
      'Non IP Restricted Profile should NOT be exempted and isAllowedProfile return False'
    );
  }
  @isTest
  static void testEvaluateEventExceptionHandling() {
    // GIVEN an invalid source IP format to trigger the exception block
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent invalidApiEvent = new ApiEvent();
    invalidApiEvent.sourceIp = 'invalidIPFormat';
    invalidApiEvent.userId = anzxUser.Id;
    invalidApiEvent.Username = anzxUser.Username;

    // WHEN evaluateEvent is called
    Test.startTest();
    Boolean result = NonANZNetworkEventHandler.evaluateEvent(invalidApiEvent);
    Test.stopTest();

    // THEN the result should be NOT_ALLOWED (true) and no unhandled exceptions should occur
    Assert.isTrue(
      result,
      'Invalid IP format should result in NOT_ALLOWED (true) and be handled by the exception block'
    );
  }

  @isTest
  static void testEvaluateEventExceptionHandlingForNullSourceIP() {
    // GIVEN a null source IP to trigger the exception block
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent nullSourceIpEvent = new ApiEvent();
    nullSourceIpEvent.sourceIp = null;
    nullSourceIpEvent.userId = anzxUser.Id;
    nullSourceIpEvent.Username = anzxUser.Username;

    // WHEN evaluateEvent is called
    Test.startTest();
    Boolean result = NonANZNetworkEventHandler.evaluateEvent(nullSourceIpEvent);
    Test.stopTest();

    // THEN the result should be NOT_ALLOWED (true) and no unhandled exceptions should occur
    Assert.isTrue(
      result,
      'Null source IP should result in NOT_ALLOWED (true) and be handled by the exception block'
    );
  }

  @isTest
  static void testEvaluateEventExceptionHandlingForInvalidDecimalConversion() {
    // GIVEN an invalid source IP format that causes decimal conversion failure
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent invalidDecimalEvent = new ApiEvent();
    invalidDecimalEvent.sourceIp = '999.999.999.999'; // Invalid IP format
    invalidDecimalEvent.userId = anzxUser.Id;
    invalidDecimalEvent.Username = anzxUser.Username;

    // WHEN evaluateEvent is called
    Test.startTest();
    Boolean result = NonANZNetworkEventHandler.evaluateEvent(
      invalidDecimalEvent
    );
    Test.stopTest();

    // THEN the result should be NOT_ALLOWED (true) and no unhandled exceptions should occur
    Assert.isTrue(
      result,
      'Invalid decimal conversion should result in NOT_ALLOWED (true) and be handled by the exception block'
    );
  }
}
