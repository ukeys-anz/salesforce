/**
 * @description       : Transaction Security Policies Handler class for Non ANZ Network (Salesforce PAC-303)
 * @last modified     : July 2025
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
        return evaluateEvent(apiEventNonANZNetworkPolicy);
      }
      when LoginEvent loginIPEvent {
        return evaluateEvent(loginIPEvent);
      }
    }
    return ALLOWED;
  }

  /**
   * @description evaluating events for non ANZ network condition(s)
   * @param event SObject which is the name of the event.
   * @return `Boolean` ALLOWED if exempted profile or source IP is allowed, otherwise NOT_ALLOWED
   */
  @testVisible
  private static Boolean evaluateEvent(SObject event) {
    Id userId = (Id) event.get('userId');
    String sourceIP = (String) event.get('sourceIP');
    String username = (String) event.get('Username');
    String eventType = event.getSObjectType().getDescribe().getName();
    try {
      User eventUser = TSP_REPOSITORY.queryProfilebyEventUserId(userId);
      String userProfile = eventUser.Profile.Name;
      //scenario 1 - allowed IP Resticted Profile to be exempted for non ANZ Network Policy
      if (isAllowedProfile(userProfile)) {
        return ALLOWED;
      }
      //scenario 2 - allowed Masked IP Address to be exempted for non ANZ Network Policy
      if (isAllowedMaskedIP(sourceIP)) {
        return ALLOWED;
      }
      //scenario 3 - allowed Source IP Address to be exempted for non ANZ Network Policy

      Decimal sourceIpAsDecimal = ipToDecimal(sourceIP);
      if (isIPInRange(sourceIpAsDecimal)) {
        return ALLOWED;
      }
      String logMessage =
        'Non ANZ network has been detected on' +
        eventType +
        ' performed by ' +
        username +
        '( Id:' +
        userId +
        ') ' +
        'with sourceIp: ' +
        sourceIP;
      Logger.error(logMessage, Logger.Severity.HIGH);
    } catch (Exception e) {
      String logMessage =
        'Error while processing Non ANZ network event for user: ' +
        username +
        '( Id:' +
        userId +
        ') ' +
        'with sourceIp: ' +
        sourceIP;
      Logger.error(logMessage, e, Logger.Severity.HIGH);
    }
    Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
    return NOT_ALLOWED;
  }

  @testVisible
  /**
   * @description to validate profiles with ip restricted to be exempted for non ANZ Network Policy
   * @param  userProfile `String` incoming (Sobject) Event
   * @return result `Boolean` isAllowedProfile; return TRUE for allowedProfile; FALSE for not allowed profile
   */
  public static Boolean isAllowedProfile(String userProfile) {
    Set<String> allowedProfiles = new Set<String>{
      'Integration User (External Apps)',
      'Minimum Access - External Apps'
    };
    return allowedProfiles.contains(userProfile);
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
