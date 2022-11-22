/**
 * @description       : A DTO object used to create log entries for lightning components
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/
public class ComponentLogEntry {
  /**
   * @description The name of the `LoggingLevel` enum value
   */
  @AuraEnabled
  public String loggingLevel { get; set; }

  /**
   * @description The name of the component
   */
  @AuraEnabled
  public String componentName { get; set; }

  /**
   * @description The name of the browser
   */
  @AuraEnabled
  public String browserName { get; set; }

  /**
   * @description The value to use as the log entry's message
   */
  @AuraEnabled
  public String message { get; set; }

  /**
   * @description (Optional) The record ID to relate to the log entry
   */
  @AuraEnabled
  public Id recordId { get; set; }

  /**
   * @description (Optional) The record to relate to the log entry - the record's JSON is also stored
   */
  @AuraEnabled
  public SObject record { get; set; }

  /**
   * @description The JavaScript stack trace from when the log entry was created
   */
  @AuraEnabled
  public String stack { get; set; }

  /**
   * @description The datetime that the log entry was created in the lightning component
   */
  @AuraEnabled
  public Datetime timestamp { get; set; }

  /**
   * @description (Optional) A JavaScript Error to log
   */
  @AuraEnabled
  public ComponentError error { get; set; }
}
