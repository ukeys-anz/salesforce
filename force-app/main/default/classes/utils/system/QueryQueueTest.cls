/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Test class for {@link QueryQueue}
 */
@IsTest
public with sharing class QueryQueueTest {
  @isTest
  static void testGet() {
    List<Group> queues = [
      SELECT Id, DeveloperName
      FROM Group
      WHERE Type = :QueryQueue.GROUP_TYPE_QUEUE
      LIMIT 2
    ];

    Group queue = QueryQueue.get(queues[0].Developername);
    Map<String, Group> mapQueueByDevNames = QueryQueue.get(
      new Set<String>{ queues[0].Developername, queues[1].Developername }
    );

    Assert.areEqual(
      queues[0].Id,
      queue.Id,
      'Queue ID should be retrieved by DeveloperName'
    );
    Assert.areEqual(
      queues[0].Id,
      mapQueueByDevNames.get(queues[0].DeveloperName).Id,
      'Queue ID should be retrieved by DeveloperName'
    );
    Assert.areEqual(
      queues[1].Id,
      mapQueueByDevNames.get(queues[1].DeveloperName).Id,
      'Queue ID should be retrieved by DeveloperName'
    );
  }
}
