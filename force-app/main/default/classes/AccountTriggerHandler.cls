/**
 * @author David Dawson
 * @since 08/2020
 * @description  AccountTriggerHandler is the handler class for Account Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @runTests AccountTriggerHandlerTest
 */

public with sharing class AccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public AccountTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to update the list of records which were identified in onValidate() method
   */
  public override void onBeforeInsert() {
    AccountCommonActions.populateFieldsValue(records);
    MLCRMAccountActions.validateDateOfBirth(records);
    CCRMAccountActions.setControllingPost(records, null);
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    AccountCommonActions.createEntitlement(records);
    if (!CCRMLeadConversionActions.manualLeadConversionInitiated) {
      AccountCommonActions.findAndConvertLead(records);
    }
    AccountCommonActions.linkKYCQACasesToAccount(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    MLCRMAccountActions.validateDateOfBirth(records);
    CCRMAccountActions.AccountWrapper existingOrProspectAccounts = new CCRMAccountActions.AccountWrapper(
      records
    );
    Boolean isAllowedProfileCheck = CCRMCustomerProfileUpdateHelper.doesProfileAllowCustStaging();
    if (isAllowedProfileCheck) {
      MLCRMAccountActions.revertShellProspectBillingAddress(records);
      CCRMAccountActions.preventEditShellProspect(
        records,
        (Map<Id, Account>) oldMap
      ); //CC-5050

      CCRMCustomerProfileUpdateHelper.restrictEdit(
        existingOrProspectAccounts.existingAccounts.values(),
        (Map<Id, Account>) oldMap
      );
      CCRMAccountActions.validateCustomerInformation(
        records,
        (Map<Id, Account>) oldMap
      );
    }
    AccountCommonActions.populateFieldsValue(records);

    CCRMAccountActions.setControllingPost(records, (Map<Id, Account>) oldMap);
    AccountCommonActions.revertAccountChanges(records, oldMap);

    if (isAllowedProfileCheck) {
      CCRMAccountActions.revertAccountChanges(records, oldMap);

      CCRMAccountActions.validateAndFormatProspectAbnAcnArbn(
        existingOrProspectAccounts.prospectAccounts.values(),
        (Map<Id, Account>) oldMap
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccounts.prospectAccounts.values(),
        (Map<Id, Account>) oldMap,
        true
      );
      CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates(
        existingOrProspectAccounts.existingAccounts.values(),
        (Map<Id, Account>) oldMap,
        false
      );
    }
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AccountCommonActions.updateEntitlement(records, oldMap);
    CustomerEventActions.publishEventForCustomers(
      records,
      (Map<Id, Account>) oldMap,
      GCPEventConfigs.GCP_EVENT_UPDATE
    );
  }
}
