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
    if (events == null || events.size() == 0) {
      return new List<SObject>();
    }
    List<sObject> publishedEvents = new List<sObject>();

    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(events);

    // Inspect publishing result for each event that failed
    for (Integer i = 0; i < results.size(); i++) {
      if (results[i].isSuccess()) {
        publishedEvents.add(events[i]); // Add the successfully published platform event to published events list
      }
    }
    return publishedEvents; // Return the platform events that were successfully published
  }
}
