/**
 * @author davidbrowaeys[SMS]
 * @group Core
 * @description Base class aiding in the implementation of a Domain Model around SObject collections
 *
 * Domain (software engineering). “a set of common requirements, terminology, and functionality
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”,
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...”
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 *
 * @example
 *
 *   public with sharing class ContactTriggerHandler extends Lib_TriggerHandler{
 *
 *              public ContactTriggerHandler() {
 *                  super();
 *              }
 *
 *              public override void onBeforeInsert(){
 *              }
 *          }
 * @group Library
 */
@SuppressWarnings('PMD.EmptyStatementBlock')
public virtual with sharing class Lib_TriggerHandler {
  /**
   * @description Provides access to the data represented by this domain class
   */
  public SObject[] records { get; private set; }
  /**
   * @description Disables the triggers based on Custom Settings
   */
  public Boolean disableTriggers { get; private set; }

  /**
   * @description Disables the delete trigger on the object based on Custom Settings
   */
  public Boolean bypassDelete { get; private set; }

  /**
   * @description Disables the edit trigger on the object based on Custom Settings
   */
  public Boolean bypassUpdate { get; private set; }
  /**
   * @description Derived from the records provided during construction, provides the native describe for the standard or custom object
   */
  public Schema.DescribeSObjectResult objectDescribe { get; private set; }
  /**
   * @description Returns the SObjectType this Domain class represents
   */
  public SObjectType objectType { get; private set; }
  /**
   * @description Returns the record type represented by this domain class
   */
  public Map<String, Schema.RecordTypeInfo> objectRecordTypes {
    get;
    private set;
  }
  /**
   * @description Return the System log represented by this domain class
   */
  public lib_SystemLog log { get; set; }
  /**
   * @description Constructs the domain class with the data on which to apply the behaviour implemented within the sObject including Record Type
   *
   */
  public Lib_TriggerHandler() {
    if (Trigger.isDelete) {
      this.records = Trigger.old.clone();
    } else {
      this.records = Trigger.new.clone();
    }

    Salesforce_Library_Settings__c settings = Salesforce_Library_Settings__c.getInstance(
      UserInfo.getUserId()
    );

    Salesforce_Bypass_Trigger_Actions__c bypassActions = Salesforce_Bypass_Trigger_Actions__c.getInstance(
      UserInfo.getUserId()
    );

    this.objectType = records.getSObjectType();
    this.objectDescribe = objectType.getDescribe();
    this.bypassDelete =
      bypassActions.Object_API_Name__c == objectDescribe.getName() &&
      bypassActions.Bypass_Delete__c;
    this.bypassUpdate =
      bypassActions.Object_API_Name__c == objectDescribe.getName() &&
      bypassActions.Bypass_Update__c;
    this.objectRecordTypes = objectDescribe.getRecordTypeInfosByName();
    this.disableTriggers = settings.Disable_Triggers__c;
    this.log = new lib_SystemLog(objectType + ' Trigger');

    triggerHandler();
    this.log.insertLog();
  }
  /**
   * @description Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
   **/
  private void triggerHandler() {
    // Invoke the applicable handler
    if (!disableTriggers) {
      if (Trigger.isBefore == true) {
        handleBeforeTriggers();
      } else {
        handleAfterTriggers();
      }
    }
  }

  /**
   * @description Handle the before trigger calls
   */
  private void handleBeforeTriggers() {
    if (Trigger.isInsert == true) {
      handleBeforeInsert();
    } else if (Trigger.isUpdate == true && !bypassUpdate) {
      handleBeforeUpdate(Trigger.oldMap);
    } else if (Trigger.isDelete == true && !bypassDelete) {
      handleBeforeDelete();
    }
  }
  /**
   * @description Handle after trigger calls
   */
  private void handleAfterTriggers() {
    if (Trigger.isInsert == true) {
      handleAfterInsert();
    } else if (Trigger.isUpdate == true && !bypassUpdate) {
      handleAfterUpdate(Trigger.oldMap);
    } else if (Trigger.isDelete == true && !bypassDelete) {
      handleAfterDelete();
    } else if (Trigger.isUndelete == true) {
      handleAfterUndelete();
    }
  }
  /**
   * @description Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
   **/
  protected virtual void handleBeforeInsert() {
    onApplyDefaults();
    onBeforeInsert();
  }
  /**
   * @description Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void handleBeforeUpdate(Map<Id, SObject> oldMap) {
    onBeforeUpdate(oldMap);
  }
  /**
   * @description Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
   **/
  protected virtual void handleBeforeDelete() {
    onBeforeDelete();
  }
  /**
   * @description Base handler for the Apex Trigger event After Insert, calls the onValidate and onAfterInsert methods
   **/
  protected virtual void handleAfterInsert() {
    onValidate();
    onAfterInsert();
  }
  /**
   * @description Base handler for the Apex Trigger event After Update, checks object security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void handleAfterUpdate(Map<Id, SObject> oldMap) {
    onValidate(oldMap);
    onAfterUpdate(oldMap);
  }
  /**
   * @description Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
   **/
  protected virtual void handleAfterDelete() {
    onAfterDelete();
  }
  /**
   * @description Base handler for the Apex Trigger event After Undelete, checks object security and calls the onAfterUndelete method
   **/
  protected virtual void handleAfterUndelete() {
    onAfterUndelete();
  }
  /**
   * @description Override this to apply defaults to the records, this is called by the handleBeforeInsert method
   **/
  protected virtual void onApplyDefaults() {
  }
  /**
   * @description Override this to apply general validation to be performed during insert or update, called by the handleAfterInsert and handleAfterUpdate methods
   **/
  protected virtual void onValidate() {
  }
  /**
   * @description Override this to apply validation to be performed during update, called by the handleAfterUpdate method
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void onValidate(Map<Id, SObject> oldMap) {
  }
  /**
   * @description Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
   **/
  protected virtual void onBeforeInsert() {
  }
  /**
   * @description Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void onBeforeUpdate(Map<Id, SObject> oldMap) {
  }
  /**
   * @description Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
   **/
  protected virtual void onBeforeDelete() {
  }
  /**
   * @description Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
   **/
  protected virtual void onAfterInsert() {
  }
  /**
   * @description Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void onAfterUpdate(Map<Id, SObject> oldMap) {
  }
  /**
   * @description Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
   **/
  protected virtual void onAfterDelete() {
  }
  /**
   * @description Override this to perform processing during the after undelete phase, this is called by the handleAfterDelete method
   **/
  protected virtual void onAfterUndelete() {
  }

  /**
   * @description Validate if the Disable_Triggers__c is turned on/off for the given user
   * @return `Boolean` returns true if the Disable_Triggers__c is true for the user
   */
  private static Boolean validateDisableTriggers() {
    Salesforce_Library_Settings__c settings = Salesforce_Library_Settings__c.getInstance(
      UserInfo.getUserId()
    );
    return settings.Disable_Triggers__c;
  }
}
