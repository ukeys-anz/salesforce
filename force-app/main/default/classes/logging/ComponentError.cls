/**
 * @description       : A DTO object used to log details about a JavaScript error
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/

public class ComponentError {
  /**
   * @description The error's message
   */
  @AuraEnabled
  public String message { get; set; }

  /**
   * @description The error's stack trace
   */
  @AuraEnabled
  public String stack { get; set; }

  /**
   * @description The type of JavaScript error
   */
  @AuraEnabled
  public String type { get; set; }
}
