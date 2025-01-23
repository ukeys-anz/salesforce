/**
 * @description       : Transaction Security Policies Handler class for Non ANZ Network (Salesforce PAC-303)
 * @author            : Hannah Sainumkheaw
 * @last modified     : 19 July 2024
 **/
global with sharing class NonANZNetworkEventHandler implements TxnSecurity.EventCondition, TxnSecurity.AsyncCondition {
  private static final Boolean ALLOWED = false;
  private static final Boolean NOT_ALLOWED = true;
  private static final TSPRepository TSP_REPOSITORY = (TSPRepository) Lib_InstanceProvider.forType(
    TSPRepository.class
  );

  /**
   * @description Used to check what is the event that has been triggered and
   * according to that, will run the private evaluation method
   * @param event SObject which is the name of the event.
   * @return `Boolean` according to different conditions on different events for non ANZ network policy
   */
  public static Boolean evaluate(SObject event) {
    switch on event {
      when ApiEvent apiEventNonANZNetworkPolicy {
        return evaluateApiEvent(apiEventNonANZNetworkPolicy);
      }
    }
    return ALLOWED;
  }

  /**
   * @description evaluating Apievent type of non anz network condition(s)
   * @param event SObject which is the name of the event.
   * @return `Boolean` evaluation results, based on condition added to apiEvent for non ANZ Network policy
   */
  @testVisible
  private static Boolean evaluateApiEvent(ApiEvent event) {
    //check if ApiEvent is called by user with exempted profile for Non ANZ network policy before checking sourceIp
    User eventUser = TSP_REPOSITORY.queryProfilebyEventUserId(event.userId);
    String userProfile = eventUser.Profile.Name;
    if (isAllowedProfile(userProfile)) {
      return ALLOWED;
    }
    return isAllowedSourceIp(event.sourceIP, event.userId, event.Username);
  }

  @testVisible
  /**
   * @description to validate profiles with ip restricted to be exempted for non ANZ Network Policy
   * @param  userProfile `String` incoming ApiEvent
   * @return result `Boolean` isAllowedProfile; return TRUE for allowedProfile; FALSE for not allowed profile
   */
  public static Boolean isAllowedProfile(String userProfile) {
    Set<String> allowedProfiles = new Set<String>{
      'System Administrator CyberArk',
      'Integration User (External Apps)',
      'Minimum Access - External Apps'
    };
    return allowedProfiles.contains(userProfile);
  }

  @testVisible
  /**
   * @description to validate isAllowedSourceIp
   * @param  eventSourceIp `String` of the incoming ApiEvent
   * @param eventUserId `Id` of the incoming ApiEvent
   * @param eventUsername `String` of the incoming ApiEvent
   * @return result `Boolean` isAllowedSourceIp: return FALSE (ALLOWED) if sourceIP is allowed, otherwise RETURN TRUE(not allowed) and TSP is triggered.
   */
  public static Boolean isAllowedSourceIp(
    String eventSourceIp,
    Id eventUserId,
    String eventUsername
  ) {
    if (isAllowedMaskedIP(eventSourceIp)) {
      return ALLOWED;
    }

    try {
      Decimal sourceIpAsDecimal = ipToDecimal(eventSourceIp);
      if (isIPInRange(sourceIpAsDecimal)) {
        return ALLOWED;
      }

      String logMessage =
        'Non ANZ network has been detected on ApiEvent, performed by ' +
        eventUsername +
        '( Id:' +
        eventUserId +
        ') ' +
        'with sourceIp: ' +
        eventSourceIp;

      Logger.error(logMessage, Logger.Severity.HIGH);
    } catch (Exception e) {
      String logMessage =
        'Failed to process ANZ Network Security Policy or IP Address is invalid for ' +
        eventSourceIp +
        ' performed by ' +
        eventUsername +
        ' ( Id:' +
        eventUserId +
        ')';
      Logger.error(logMessage, e, Logger.Severity.HIGH);
    }
    Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
    return NOT_ALLOWED;
  }

  @testVisible
  /**
   * @description to convert inciming sourceIp to decimal format
   * @param sourceIp Strting which is the name of the event.
   * @return `Decimal` Decimal IP of incoming sourceIp
   * Decimal IP = (A x 256^3) + (B x 256^2) + (C x 256^1) + (D x 256^0)
   */
  public static Decimal ipToDecimal(String sourceIp) {
    List<String> ip = sourceIp.split('\\.');
    //Allowed IP Address Format is  is x.x.x.x, where each x can be any value between 0 and 255
    if (ip.size() != 4) {
      return 0;
    }

    Decimal incomingDecimal = 0;
    for (Integer i = 0; i < ip.size(); i++) {
      incomingDecimal +=
        Decimal.ValueOf(ip[i]) * (Math.pow(256, ip.size() - 1 - i));
    }
    return incomingDecimal;
  }

  /**
   * @description validates if an ip is in allowed ranges
   * @param  decimalIp `Decimal` Decimal IP of incoming sourceIp
   * @return result `Boolean` isAllowedSourceIp
   */
  @testVisible
  public static Boolean isIPInRange(Decimal decimalIp) {
    List<ANZ_Network_Allow_List__mdt> allowRanges = ANZ_Network_Allow_List__mdt.getall()
      .values();
    for (ANZ_Network_Allow_List__mdt ipRange : allowRanges) {
      if (
        decimalIp >= ipRange.First_Decimal__c &&
        decimalIp <= ipRange.Last_Decimal__c
      ) {
        return true;
      }
    }
    return false;
  }

  @testVisible
  /**
   * @description to validate isAllowedMaskedIP Address
   * @param  eventSourceIp `String` of incoming Apivent
   * @return result `Boolean` isAllowedMaskedIP
   */
  private static Boolean isAllowedMaskedIP(String eventSourceIp) {
    Set<String> allowedMaskedIP = new Set<String>{ 'Salesforce.com IP' };
    return allowedMaskedIP.contains(eventSourceIp);
  }
}
