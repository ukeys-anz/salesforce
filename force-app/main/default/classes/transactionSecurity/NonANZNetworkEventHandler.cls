/**
 * @description       : Transaction Security Policies Handler class for Non ANZ Network (Salesforce PAC-303)
 * @author            : Hannah Sainumkheaw
 * @last modified     : 18-06-2024
 **/
global with sharing class NonANZNetworkEventHandler implements TxnSecurity.EventCondition, TxnSecurity.AsyncCondition {
  private static final Boolean ALLOWED = false;
  private static final Boolean NOT_ALLOWED = true;

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
    return isAllowedSourceIp(event);
  }

  @testVisible
  /**
   * @description to validate isAllowedSourceIp
   * @param  event `ApiEvent` ApiEvent for non ANZ Network policy
   * @return result `Boolean` isAllowedSourceIp
   */
  private static Boolean isAllowedSourceIp(ApiEvent event) {
    Decimal sourceIpAsDecimal = ipToDecimal(event.sourceIp);
    if (isIPInRange(sourceIpAsDecimal)) {
      return ALLOWED;
    }

    String logMessage =
      'Non ANZ network has been detected on ApiEvent, performed by ' +
      event.Username +
      '( Id:' +
      event.UserId +
      ') ' +
      'with sourceIp: ' +
      event.sourceIp;

    Logger.info(logMessage);
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
    if (ip.size().equals(0)) {
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
}
