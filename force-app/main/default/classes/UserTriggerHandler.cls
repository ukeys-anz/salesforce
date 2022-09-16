/**
 * @author Boobalakrishnan Duraisamy
 * @since 02/2020
 * @description  UserTriggerHandler is the handler class for User Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class UserTriggerHandler extends Lib_TriggerHandler {
  public Set<String> businessFuncAndRoles = new Set<String>();

  public Set<String> oldBusinessFuncAndRoles = new Set<String>();

  public List<Id> userIds = new List<Id>();

  public List<User> userList = new List<User>();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public UserTriggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  public override void onApplyDefaults() {
    for (User record : (List<User>) records) {
      if (UserProvisioningCommonActions.isValidRecordForProcessing(record)) {
        businessFuncAndRoles.add(
          UserProvisioningCommonActions.generateKey(record)
        );
      }
    }
    if (!businessFuncAndRoles.isEmpty()) {
      UserProvisioningBeforeActions.assignProfileAndRole(
        records,
        businessFuncAndRoles
      );
    }
  }

  /**
   * @description onValidate() method is called before onAfterInsert to validate records or handle the records for which we need to update the values.
   */
  public override void onValidate() {
    for (User record : (List<User>) records) {
      if (UserProvisioningCommonActions.isValidRecordForProcessing(record)) {
        userList.add(record);
        businessFuncAndRoles.add(
          UserProvisioningCommonActions.generateKey(record)
        );
      }
    }
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    if (!businessFuncAndRoles.isEmpty()) {
      UserProvisioningAfterActions.assignMembership(
        userList,
        businessFuncAndRoles
      );
    }

    CCRMRegionSharingUtil.addUsersToRegion(this.records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (User record : (List<User>) records) {
      User oldRecord = (User) oldMap.get(record.id);
      if (
        UserProvisioningCommonActions.isValidRecordForProcessing(record) &&
        UserProvisioningCommonActions.isValidRecordForUpdate(record, oldRecord)
      ) {
        businessFuncAndRoles.add(
          UserProvisioningCommonActions.generateKey(record)
        );
      }
    }

    if (!businessFuncAndRoles.isEmpty()) {
      UserProvisioningBeforeActions.assignProfileAndRole(
        records,
        businessFuncAndRoles
      );
    }
  }

  /**
   * @description onValidate(oldMap) is called before onAfterUpdate and all the required record updates are handled here
   * @param oldMap old trigger values
   */
  public override void onValidate(Map<Id, SObject> oldMap) {
    for (User record : (List<User>) records) {
      User oldRecord = (User) oldMap.get(record.id);
      if (
        UserProvisioningCommonActions.isValidRecordForProcessing(record) &&
        UserProvisioningCommonActions.isValidRecordForUpdate(record, oldRecord)
      ) {
        userIds.add(record.Id);
        if (
          UserProvisioningCommonActions.isValidRecordForProcessing(oldRecord)
        ) {
          oldBusinessFuncAndRoles.add(
            UserProvisioningCommonActions.generateKey(oldRecord)
          );
        }
        userList.add(record);
        businessFuncAndRoles.add(
          UserProvisioningCommonActions.generateKey(record)
        );
      }
    }
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (!oldBusinessFuncAndRoles.isEmpty()) {
      UserProvisioningAfterActions.revokeMembership(
        userIds,
        oldBusinessFuncAndRoles
      );
    }

    if (!businessFuncAndRoles.isEmpty()) {
      UserProvisioningAfterActions.assignMembership(
        userList,
        businessFuncAndRoles
      );
    }

    CCRMRegionSharingUtil.updateUserRegion(
      this.records,
      (Map<Id, User>) oldMap
    );
  }
}
