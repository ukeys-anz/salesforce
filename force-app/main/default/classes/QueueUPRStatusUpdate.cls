/**
 * @author Boobalakrishnan Duraisamy
 * @since  09/2020
 * @description QueueUPRStatusUpdate class is called in UserTriggerHandler to update User Provisioning Request status Asynchronously to avoid Mixed_DML_Error
 */
public class QueueUPRStatusUpdate implements Queueable {
  Map<String, Boolean> updateUPRMap;

  /**
   * @description Constructor
   * @param triggerUPRMap Map from User Trigger
   */
  public QueueUPRStatusUpdate(Map<String, Boolean> triggerUPRMap) {
    updateUPRMap = triggerUPRMap;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */
  public void execute(QueueableContext context) {
    Map<String, User_Provisioning_Request__c> uprMap = UserProvisioningBeforeActions.getUPRRecords(
      updateUPRMap.keySet()
    );

    for (User_Provisioning_Request__c upr : uprMAP.values()) {
      upr.Requestor__r = new user(FederationIdentifier = upr.Requestor_UUID__c);
      upr.Status__c = (updateUPRMap.get(upr.Requestor_UUID__c)
        ? 'Completed'
        : 'Error');
    }

    List<Database.SaveResult> updateUPRResult = Database.update(
      uprMap.values(),
      false
    );
  }
}
