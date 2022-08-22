/**
 * @author Adam Smith
 * @since 20220811
 * @description class without sharing to allow deletion of events.
 * Without Sharing needs to be on, as there is a use case where when one
 * user takes ownership of an interaction, any event related previously needs
 * to be deleted. In Salesforce only the owner can delete an event.
 * So we need this to bypass that issue.
 */
public without sharing class EventDeleteHelper {
  /**
   * @description deletes a list of events
   * @param events to delete.
   */
  public static void deleteEvents(List<Event> events) {
    if (PermissionUtils.canDelete('Event')) {
      List<Database.DeleteResult> results = Database.Delete(events);
      lib_systemLog log = new lib_systemLog('EventHelper', 'deleteEvents');
      Boolean hasError = log.addDatabaseDeleteResult('Events', results, events);
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'EventHelper',
        'deleteEvents',
        'Not enough permissions to delete Events'
      );
    }
  }
}
