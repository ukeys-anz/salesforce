/**
 * @author Boobalakrishnan Duraisamy
 * @since 04/2020
 * @description  UserProvisioningRequestHandler is the handler class for User Provisioning Request Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class UserProvisioningRequestHandler extends Lib_TriggerHandler {
  //List to store Modify User provisioning request records
  public List<String> uprModifyList = new List<String>();

  //Set to store Requestor UUIDs of Revoke User provisioning request
  public Set<String> uprRevokeIds = new Set<String>();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public UserProvisioningRequestHandler() {
    super();
  }

  /**
   * @description onValidate() method is called before onAfterInsert to validate records or handle the records for which we need to update the values.
   */
  public override void onValidate() {
    for (
      User_Provisioning_Request__c record : (List<User_Provisioning_Request__c>) records
    ) {
      if (
        String.isNotBlank(record.Business_Function__c) &&
        String.isNotBlank(record.Business_Role__c) &&
        String.isNotBlank(record.Requestor_UUID__c) &&
        record.Type__c == 'Modify'
      ) {
        uprModifyList.add(JSON.serialize(record));
      }
      if (
        String.isNotBlank(record.Requestor_UUID__c) &&
        record.Type__c == 'Revoke'
      ) {
        uprRevokeIds.add(record.Requestor_UUID__c);
      }
    }
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */

  public override void onAfterInsert() {
    if (!uprModifyList.isEmpty()) {
      UPRAfterActions.modifyUserAccess(uprModifyList);
    }
    if (!uprRevokeIds.isEmpty()) {
      UPRAfterActions.revokeUserAccess(uprRevokeIds);
    }
  }
}
