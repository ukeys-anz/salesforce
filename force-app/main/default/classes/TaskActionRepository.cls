/**
 * @author Ashish Kumar
 * @since 12/2024
 * @description This class provide SOQL for Task related queries.
 */
public with sharing class TaskActionRepository {
  /**
   * @description getTaskResponse method return Task associated to the given whoids
   * @param whoids Id of the object records(e.g lead)
   * @return List<Task> Task List
   */
  public List<Task> getTaskResponse(Set<ID> whoids) {
    if (whoids.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT ActivityDate, WhoId, Response_Status__c
      FROM Task
      WHERE whoId = :whoids
      WITH USER_MODE
      ORDER BY createddate ASC
    ];
  }
}
