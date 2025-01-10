/**
 * @author Shivam Swaraj
 * @since 11/2024
 * @description  AccountClosureMessageComposer this class will be used to format the data based on failure actions
 */
public with sharing class AccountClosureMessageComposer {
  /**
   * @description post failure message on the sobject id passed
   * @param actionsList list of failure actions
   * @return richText to be posted on chatter
   */
  public static String composeRichTextMessage(
    List<AccountClosureErrorMetadata__mdt> actionsList
  ) {
    String message = '';

    //Seperate constants and failure-specific actions

    List<String> constantMessages = new List<String>();
    Map<String, List<String>> reasonToActions = new Map<String, List<String>>();
    Map<String, String> reasonToActionLabelMap = new Map<String, String>();

    for (AccountClosureErrorMetadata__mdt actions : actionsList) {
      if (actions.Type__c == 'Constant') {
        constantMessages.add(actions.Chatter_Post__c);
      } else {
        if (!reasonToActions.containsKey(actions.Failure_Reason__c)) {
          reasonToActions.put(actions.Failure_Reason__c, new List<String>());
          reasonToActionLabelMap.put(actions.Failure_Reason__c, actions.Label);
        }

        List<String> actionsBullet = actions.Chatter_Post__c.split('\n');
        reasonToActions.get(actions.Failure_Reason__c).addAll(actionsBullet);
      }
    }

    //Add constant messages

    for (String constant : constantMessages) {
      message += constant + '\n\n';
    }

    //Add failure specific actions grouped by reason
    for (String reason : reasonToActions.keySet()) {
      message += reasonToActionLabelMap.get(reason) + '\n';

      for (String action : reasonToActions.get(reason)) {
        message += '• ' + action.trim() + '\n';
      }

      message += '\n';
    }

    return message.trim();
  }
}
