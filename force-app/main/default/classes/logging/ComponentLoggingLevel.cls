/**
 * @description       : A DTO object used for passing `LoggingLevel` details to lightning components
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/

public class ComponentLoggingLevel {
  /**
   * @description The name of the `LoggingLevel` enum value
   */
  @AuraEnabled
  public String name { get; set; }

  /**
   * @description The ordinal of the `LoggingLevel` enum value
   */
  @AuraEnabled
  public Integer ordinal { get; set; }

  /**
   * @description Constructor for the ComponentLoggingLevel class
   * @param loggingLevel The Logging level to map the name and ordinal
   */

  public ComponentLoggingLevel(LoggingLevel loggingLevel) {
    this.name = loggingLevel.name();
    this.ordinal = loggingLevel.ordinal();
  }
}
