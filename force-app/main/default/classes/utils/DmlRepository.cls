/**
 * @description Provide methods for DML operations and loggings where needed
 * @author Tan Phan
 * @since 06/2024
 * @group Util
 */
public virtual inherited sharing class DmlRepository {
  public static final Boolean ALL_OR_NONE = true;
  public static final Boolean ALLOW_PARTIAL = false;
  public static final Boolean USER_MODE = true;
  public static final Boolean SYSTEM_MODE = false;

  /**
   * @description Method to perform database updates
   * @param records List of records to update
   * @param allOrNone Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.SaveResult> Results of update operation
   */
  public virtual List<Database.SaveResult> updateRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.update(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * @description Method to perform database upserts
   * @param records List of records to insert/update
   * @param allOrNone Boolean value to validate if records should be updated if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UpsertResult> Results of upsert operation
   */
  public virtual List<Database.UpsertResult> upsertRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.UpsertResult> results = new List<Database.UpsertResult>();
    try {
      results = Database.upsert(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * @description Method to perform database insert
   * @param records List of records to insert
   * @param allOrNone Boolean value to validate if records should be inserted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   *  @return List<Database.SaveResult> Results of insert operation
   */
  public virtual List<Database.SaveResult> insertRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
      results = Database.insert(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * @description Method to perform database delete
   * @param records List of records to delete
   * @param allOrNone Boolean value to validate if records should be deleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.DeleteResult> Results of delete operation
   */
  public virtual List<Database.DeleteResult> deleteRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.DeleteResult> results = new List<Database.DeleteResult>();
    try {
      results = Database.delete(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   * @description Method to perform database undelete
   * @param records List of records to undelete
   * @param allOrNone Boolean value to validate if records should be undeleted if there are failures
   * @param userLevel Boolean value to run the DML operation in System Mode or User Mode
   * @return List<Database.UndeleteResult> Results of undelete operation
   */
  public virtual List<Database.UndeleteResult> undeleteRecords(
    List<SObject> records,
    Boolean allOrNone,
    Boolean userLevel
  ) {
    List<Database.UndeleteResult> results = new List<Database.UndeleteResult>();
    try {
      results = Database.undelete(records, allOrNone, accessLevel(userLevel));
      Logger.error('', results);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return results;
  }

  /**
   *
   * @description Publish platform event(s) and create logs if errors occur
   * @param events list of events to publish
   * @return List<sObject> a list of published events
   */
  public virtual List<sObject> publishEvents(List<sObject> events) {
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
      } else {
        Logger.error(
          'Event failed to be published for record: ' + results[i].Id
        );
      }
    }
    return publishedEvents; // Return the platform events that were successfully published
  }

  private System.AccessLevel accessLevel(Boolean userLevel) {
    return userLevel
      ? System.AccessLevel.USER_MODE
      : System.AccessLevel.SYSTEM_MODE;
  }
}
