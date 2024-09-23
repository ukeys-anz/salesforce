/**
 * @author Hannah Sainumkheaw
 * @last modified:   19 July 2024
 * @description Test class for {@link NonANZNetworkEventHandler}
 */

@isTest
public with sharing class NonANZNetworkEventHandlerTest {
  static Faker faker = new Faker('AU');
  static String anzxUserProfile = 'ANZx Standard User';
  static String externalAppProfile = 'Minimum Access - External Apps';

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

  @isTest
  // ** Suppress UnusedLocalVariable due to anzxUserMock is required for user context in TSP with no varariable assignment required
  @SuppressWarnings('PMD.UnusedLocalVariable')
  static void testApiEventAllowListIpNotAllowed() {
    //GIVEN ApiEvent with for non ANZ Network with non-ip exempted profile (ANZxStandard User)
    Lib_MockProvider anzxUserMock = Lib_MockProvider.forType(
        TSPRepository.class
      )
      .mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '165.225.222';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      tspResult,
      'ApiEvent for non anz network should be detected and returned TRUE'
    );
  }

  @isTest
  // ** Suppress UnusedLocalVariable due to anzxUserMock is required for user context in TSP with no varariable assignment required
  @SuppressWarnings('PMD.UnusedLocalVariable')
  static void testApiEventWithExemptedProfile() {
    //GIVEN ApiEvent with for non ANZ Network with exempted profile
    Lib_MockProvider anzxUserMock = Lib_MockProvider.forType(
        TSPRepository.class
      )
      .mock('queryProfilebyEventUserId', externalAppUser);
    ApiEvent testevent = new ApiEvent();

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return TRUE(NOT ALLOWED)
    Assert.isFalse(
      tspResult,
      'ApiEvent for IP Retricted Profile should be allowed and TSP should return FLASE(NOT ALLOWED)'
    );
  }

  @isTest
  //Suppress UnusedLocalVariable due to anzxUserMock is required for user context in TSP with no varariable assignment required
  @SuppressWarnings('PMD.UnusedLocalVariable')
  static void testApiEventAllowListIpAllowed() {
    //GIVEN ApiEvent with for non ANZ Network and known ZScaler IP Address for ANZ
    Lib_MockProvider anzxUserMock = Lib_MockProvider.forType(
        TSPRepository.class
      )
      .mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '165.225.226.251';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return FALSE(ALLOWED)
    Assert.isFalse(
      tspResult,
      'ApiEvent for anz network should be marked as allowed and return FALSE'
    );
  }

  @isTest
  // ** Suppress UnusedLocalVariable due to anzxUserMock is required for user context in TSP with no varariable assignment required
  @SuppressWarnings('PMD.UnusedLocalVariable')
  static void testApiEventAtBraodCastIPAllowed() {
    //GIVEN IP Address at a known ZScaler Australia's Broadcast Ip of 165.225.0.0
    Lib_MockProvider anzxUserMock = Lib_MockProvider.forType(
        TSPRepository.class
      )
      .mock('queryProfilebyEventUserId', anzxUser);
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
  static void testIsAllowedSourceIpAllowed() {
    //GIVEN IP Address at a known ZScaler Australia's Broadcast Ip of 165.225.0.0 & Exception IP for Internal Salesforce IP
    String testKnownAnzIPeventSourceIp = '165.225.0.0';
    String testSalesforceIPeventSourceIp = 'Salesforce.com IP';

    //WHEN validate incoming source IPs
    Test.startTest();
    Boolean testKnownAnzIP = NonANZNetworkEventHandler.isAllowedSourceIp(
      testKnownAnzIPeventSourceIp,
      anzxUser.Id,
      anzxUser.Username
    );
    Boolean testKnownSalesforceIP = NonANZNetworkEventHandler.isAllowedSourceIp(
      testSalesforceIPeventSourceIp,
      anzxUser.Id,
      anzxUser.Username
    );
    Test.stopTest();

    // THEN evalute method for AllowList should return FALSE(ALLOWED)
    Assert.isFalse(
      testKnownAnzIP,
      'ApiEvent for anz network should be marked as allowed for CIDR/32 Range and return FALSE(ALLOWED)'
    );
    Assert.isFalse(
      testKnownSalesforceIP,
      'Internal Salesforce IP should be allowed and return FALSE(ALLOWED)'
    );
  }

  @isTest
  static void testIsAllowedSourceIpNotAllowed() {
    //GIVEN IP Address at a unknown ZScaler Australia's Broadcast Ip of 255.255.255.255 & unknown masked IP
    String knownAnzIpEventSourceIp = '255.255.255.255';
    String unknownMaskIpEventSourceIp = 'Sales.force.com.ip';

    //WHEN validate incoming source IPs
    Test.startTest();
    Boolean testUnknownANZip = NonANZNetworkEventHandler.isAllowedSourceIp(
      knownAnzIpEventSourceIp,
      anzxUser.Id,
      anzxUser.Username
    );
    Boolean testUnknownMaskedIp = NonANZNetworkEventHandler.isAllowedSourceIp(
      unknownMaskIpEventSourceIp,
      anzxUser.Id,
      anzxUser.Username
    );
    Test.stopTest();

    // THEN evalute method for AllowList should return TRUE(NOT_ALLOWED)
    Assert.isTrue(
      testUnknownANZip,
      'ApiEvent for non anz network should be marked as not allowed TRUE(NOT_ALLOWED)'
    );
    Assert.isTrue(
      testUnknownMaskedIp,
      'Unknknown masked IP should be not be allowed and return TRUE(NOT_ALLOWED)'
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
    //GIVEN API Event with known & unknown masked IP
    String knownIPEventSourceIP = 'Salesforce.com IP';
    String unknownIPEventSourceIP = 'Salesforce.com.ip';

    //WHEN validates if an IPs are in allowed masked IP list
    Test.startTest();
    Boolean knownMaskedIPTest = NonANZNetworkEventHandler.isAllowedMaskedIP(
      knownIPEventSourceIP
    );
    Boolean unknownMaskedIPTest = NonANZNetworkEventHandler.isAllowedMaskedIP(
      unknownIPEventSourceIP
    );
    Test.stopTest();

    // THEN validate
    Assert.isTrue(knownMaskedIPTest, 'Known masked IP should be accepted');
    Assert.isFalse(
      unknownMaskedIPTest,
      'Unknown masked IP should NOT be accepted'
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
}
