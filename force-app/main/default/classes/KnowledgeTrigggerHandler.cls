/**
 * @author Lance Shi
 * @since 06/2020
 * @description  KnowledgeTrigggerHandler is the handler class for Knowledge Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */
public with sharing class KnowledgeTrigggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public KnowledgeTrigggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults to set default values for all newly created Knowledge Article Version records
   */
  public override void onApplyDefaults() {
    for (Knowledge__kav article : (List<Knowledge__kav>) records) {
      article.Reason_for_Change__c = '';
      article.UrlName = article.UrlName.toLowerCase();
    }
  }

  /**
   * @description onBeforeUpdate do the settings before the update is happening
   * @param oldMap old sobject map of previous records data
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (Knowledge__kav article : (List<Knowledge__kav>) records) {
      article.UrlName = article.UrlName.toLowerCase();
    }
  }
}
