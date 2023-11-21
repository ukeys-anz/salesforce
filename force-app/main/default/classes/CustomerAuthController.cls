/**
 * @author Ayushi Gupta
 * @since 08/2022
 * @description Controller class for Customer Authentication
 */
public with sharing class CustomerAuthController {
  /**
   * @param customerId CustomerId (required)
   * @return String
   * @description get security code API
   */
  @AuraEnabled
  public static String getSecurityCode(Id customerId) {
    CCRMARNCService service = new CCRMARNCService();
    return service.getSecurityCode(customerId);
  }

  /**
   * @param customerId CustomerId (required)
   * @param comment comment (required)
   * @param event name of event (required)
   * @return Boolean
   * @description Write Diary Comment API
   */
  @AuraEnabled
  public static Boolean createDiaryComment(
    Id customerId,
    String comment,
    String event
  ) {
    CCRMARNCService service = new CCRMARNCService();
    return service.createDiaryComment(customerId, comment, event);
  }
  /**
   * @param customerId CustomerId (required)
   * @param securityCode security code (required)
   * @return Boolean
   * @description Update Security Code API
   */
  @AuraEnabled
  public static Boolean updateSecurityCode(Id customerId, String securityCode) {
    CCRMARNCService service = new CCRMARNCService();
    return service.updateSecurityCode(customerId, securityCode);
  }
}
