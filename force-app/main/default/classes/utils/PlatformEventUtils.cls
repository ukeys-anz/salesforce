/**
 *
 * @author Jasmine Nguyen
 * @since 11/2021
 * @description Utility class for platform events
 */

public with sharing class PlatformEventUtils {
  @TestVisible
  public static Boolean throwException = false;

  /**
   *
   * @description Publish platform event(s) and create logs if errors occur
   * @param events list of events to publish
   * @return List<sObject> a list of published events
   */
  public static List<sObject> publishEvents(List<sObject> events) {
    if (events != null) {
      List<sObject> publishedEvents = new List<sObject>();

      // Creat logs before sending events
      Lib_SystemLog.createSingleLog(
        PlatformEventUtils.class.getName(),
        'publishEvents',
        null,
        'Publishing events: ' + JSON.serialize(events),
        Lib_SystemLog.Severity.DEBUG
      );

      // Call method to publish events
      List<Database.SaveResult> results = EventBus.publish(events);

      // Get event name for logging purposes
      String eventName = events[0].getSobjectType().getDescribe().getName();

      // Inspect publishing result for each event that failed
      for (Integer i = 0; i < results.size(); i++) {
        if (!results[i].isSuccess() || throwException == true) {
          Integer statusCode = (throwException)
            ? 1 // Explicitly set the status code if throwException is true for testing purpose
            : Integer.valueOf(results[i].getErrors()[0].getStatusCode());
          Lib_SystemLog.logAPIError(
            PlatformEventUtils.class.getName(),
            'publishEvents',
            results[i].getErrors()[0].getMessage(),
            null,
            JSON.serialize(events[i]),
            null,
            null,
            null,
            statusCode
          );
        } else {
          publishedEvents.add(events[i]); // Add the successfully published platform event to published events list
        }
      }
      return publishedEvents; // Return the platform events that were successfully published
    }
    return null;
  }
}
