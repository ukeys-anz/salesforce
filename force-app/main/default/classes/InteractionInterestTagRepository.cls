/**
 * @author Hrushikesh
 * @since 14/2025
 * @description Reposiory class for all SOQL of Interaction Interest Tag
 */
public with sharing class InteractionInterestTagRepository {
  /**
   * @param interactionIds
   * @return List of interactions
   * @description Fetch all the interactions by the ids
   */
  public List<Interaction> getInteractionByIds(Set<Id> interactionIds) {
    if (interactionIds.isEmpty()) {
      return new List<Interaction>();
    }
    return [
      SELECT Id, Actual_Topic__c, Reason_For_Visit__c, Products__c, RecordTypeId
      FROM Interaction
      WHERE Id IN :interactionIds
      WITH USER_MODE
    ];
  }

  /**
   * @param interactionIds
   * @return List of topic assignments
   * @description Fetch all the topic assignments by entity ids
   */
  public List<TopicAssignment> getTopicAssignments(Set<Id> interactionIds) {
    if (interactionIds.isEmpty()) {
      return new List<TopicAssignment>();
    }
    return [
      SELECT Id, Topic.Name, TopicId, EntityId
      FROM TopicAssignment
      WHERE EntityId IN :interactionIds
      WITH USER_MODE
      ORDER BY CreatedDate, Id ASC
    ];
  }
}
