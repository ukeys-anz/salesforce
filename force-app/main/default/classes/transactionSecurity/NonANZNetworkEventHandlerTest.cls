/**
 * @author Hannah Sainumkheaw
 * @last modified:   19 June 2024
 * @description Test class for {@link NonANZNetworkEventHandler}
 */

@isTest
public with sharing class NonANZNetworkEventHandlerTest {
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
  static void testApiEventAllowListIpNotAllowed() {
    //GIVEN ApiEvent with for non ANZ Network
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '165.225.222';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Boolean policyCheckResult = NonANZNetworkEventHandler.isAllowedSourceIp(
      testevent
    );
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return TRUE(NOT ALLOWED)
    Assert.isTrue(
      tspResult,
      'ApiEvent for non anz network should be detected and returned TRUE'
    );
    Assert.isTrue(
      policyCheckResult,
      'the non ANZ network Ip should be detected and returned TRUE'
    );
  }

  @isTest
  static void testApiEventAllowListIpAllowed() {
    //GIVEN ApiEvent with for non ANZ Network and known ZScaler IP Address for ANZ
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '165.225.226.251';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Boolean policyCheckResult = NonANZNetworkEventHandler.isAllowedSourceIp(
      testevent
    );
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return FALSE(ALLOWED)
    Assert.isFalse(
      tspResult,
      'ApiEvent for anz network should be marked as allowed and return FALSE'
    );
    Assert.isFalse(
      policyCheckResult,
      'the known ZScaler of ANZ network Ip should be allowed and returned FALSE'
    );
  }

  @isTest
  static void testApiEventAtBraodCastIPAllowed() {
    //GIVEN IP Address at a known ZScaler Australia's Broadcast Ip of 203.110.235.0
    ApiEvent testevent = new ApiEvent();
    testevent.sourceIp = '203.110.235.0';

    //WHEN evalute for TSP & policycheck for AllowList is called
    Test.startTest();
    Boolean tspResult = NonANZNetworkEventHandler.evaluate(testevent);
    Boolean policyCheckResult = NonANZNetworkEventHandler.isAllowedSourceIp(
      testevent
    );
    Test.stopTest();

    // THEN evalute method for TSP & policycheck for AllowList should return FALSE(ALLOWED)
    Assert.isFalse(
      tspResult,
      'ApiEvent for anz network should be marked as allowed for CIDR/32 Range and return FALSE(ALLOWED)'
    );
    Assert.isFalse(
      policyCheckResult,
      'the known ZScaler of ANZ network Ip should be allowed and returned FALSE'
    );
  }

  @isTest
  static void testIpToDecimal() {
    //GIVEN 2 x IPV4 address format
    String sourceIp1 = '165.225.226.251';
    Decimal expectedDecimal1 = 2783044347.0;

    String maxSourceIp = '255.255.255.255';
    Decimal maxDecimalIp = 4294967295.0;

    //WHEN IPv4 converse to decimal format
    Test.startTest();
    Decimal decimalIPTest = NonANZNetworkEventHandler.ipToDecimal(sourceIp1);
    Decimal maxDecimalTest = NonANZNetworkEventHandler.ipToDecimal(maxSourceIp);
    Test.stopTest();

    //THEN
    //1. Check given sourceIP with expectedDecimal 1
    Assert.areEqual(
      expectedDecimal1,
      decimalIPTest,
      'Conversion Method should return correct decimal ip of the given IPv4' +
      maxSourceIp
    );
    //2. Check possible maximum source Ip 255.255.255.255
    Assert.areEqual(
      maxDecimalIp,
      maxDecimalTest,
      'Conversion Method should return correct decimal ip of' + sourceIp1
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
}
