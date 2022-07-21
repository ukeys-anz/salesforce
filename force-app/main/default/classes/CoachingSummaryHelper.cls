/**
 * @author Adam Smith
 * @since 20220411
 * @description test class for helper methods regarding Coaching Summary
 */
public with sharing class CoachingSummaryHelper {
  /**
   * @description Goes through a list of Interactions and assigns the current owner of interaction to the coaching summary.
   * @param interactions List<Interaction> list of the interaction through which to iterate.
   * @return List<Coaching_Summary> list of coaching summary records updated with new owner.
   */

  public static List<Coaching_Summary__c> assignCoachingSummaryOwner(
    List<Interaction> interactions
  ) {
    List<Coaching_Summary__c> coachingSummaryList = new List<Coaching_Summary__c>();
    for (Interaction interact : interactions) {
      Coaching_Summary__c coachSummary = new Coaching_Summary__c(
        Id = interact.Coaching_Summary__c
      );
      coachSummary.OwnerId = interact.OwnerId;
      coachingSummaryList.add(coachSummary);
    }
    return coachingSummaryList;
  }

  /**
   * @description Creates a new coaching summary record based on the interaction
   * @param interactions List<Interaction> list of the interaction records based on which coaching summary records need to be created.
   * @return List<Coaching_Summary__c> list of coaching summary records to be created.
   */

  public static List<Coaching_Summary__c> createCoachingSummaryfromInteraction(
    List<Interaction> interactions
  ) {
    List<Coaching_Summary__c> newCoachingSummaries = new List<Coaching_Summary__c>();
    for (Interaction interact : interactions) {
      Coaching_Summary__c coachSummary = new Coaching_Summary__c();
      coachSummary.Name__c =
        interact.Interaction_Purpose__c +
        InteractionConstants.COACHING_SUMMARY_LABEL;
      coachSummary.Status__c = InteractionConstants.NEW_STATUS;
      coachSummary.OwnerId = interact.OwnerId;
      coachSummary.Account__c = interact.AccountId;
      coachSummary.Lead__c = interact.Lead__c;
      coachSummary.Reason__c = interact.Interaction_Purpose__c;
      newCoachingSummaries.add(coachSummary);
    }

    return newCoachingSummaries;
  }

  /**
   * @description does the database call to insert Coaching Summary
   * @param coachingSummaries List<Coaching_Summary__c> list of coaching summary.
   */
  public static void insertCoachingSummary(
    List<Coaching_Summary__c> coachingSummaries
  ) {
    if (
      coachingSummaries != null &&
      Coaching_Summary__c.SObjectType.getDescribe().isCreateable()
    ) {
      List<Database.SaveResult> results = Database.Insert(coachingSummaries);

      lib_systemLog log = new lib_systemLog(
        'CoachingSummaryHelper',
        'insertCoachingSummary'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Coaching_Summary__c',
        results,
        coachingSummaries
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'CoachingSummaryHelper',
        'insertCoachingSummary',
        'Not enough permissions to insert coaching summary.'
      );
    }
  }

  /**
   * @description Method to update the coaching summary records
   * @param coachingSummaries The list of coaching summary records to be updated
   */
  public static void updateCoachingSummary(
    List<Coaching_Summary__c> coachingSummaries
  ) {
    if (Coaching_Summary__c.SObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(coachingSummaries);
      lib_systemLog log = new lib_systemLog(
        'CoachingSummaryHelper',
        'updateCoachingSummary'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Coaching_Summary__c',
        results,
        coachingSummaries
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'CoachingSummaryHelper',
        'updateCoachingSummary',
        'Not enough permissions to update Coaching Summary object.'
      );
    }
  }

  /**
   * @description Method to assign the coaching summary record to the interaction record
   * @param interactions The list of interactions to be updated with the coaching summary record
   * @param coachingSummaries The list of coaching summaries to be associated with interaction record.
   */
  public static void assignSummaryToInteraction(
    List<Interaction> interactions,
    List<Coaching_Summary__c> coachingSummaries
  ) {
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 0; i < interactions.size(); i++) {
      Interaction interact = new Interaction(Id = interactions[i].Id);
      interact.Coaching_Summary__c = coachingSummaries[i].Id;
      interactionList.add(interact);
    }
    InteractionDMLHelper.updateInteractions(interactionList);
  }
}
