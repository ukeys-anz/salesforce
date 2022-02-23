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
 * Suppressing warning for CyclomaticComplexity as this class has a method to check current Trigger Context
 */
@SuppressWarnings('PMD.EmptyStatementBlock, PMD.CyclomaticComplexity')
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
   * @description Trigger context
   */
  private enum TriggerContext {
    BEFORE_INSERT,
    BEFORE_UPDATE,
    BEFORE_DELETE,
    AFTER_INSERT,
    AFTER_UPDATE,
    AFTER_DELETE,
    AFTER_UNDELETE
  }
  /**
   * @description Static map of handlername, times object event was invoked
   */
  private static Map<String, LoopCount> loopCountMap;
  /**
   * @description Unique transaction id
   */
  private static String contextId;
  /**
   * @description The current context of the trigger, overridable in tests
   */
  private TriggerContext context;
  /**
   * @description Flag to track recursion logging
   */
  private static Boolean recursionLogged;
  /**
   * @description Returns concatenated trigger object and trigger context
   */
  public String objectEventName { get; private set; }
  /**
   * @description Static variable initialization
   */
  static {
    loopCountMap = new Map<String, LoopCount>();
    contextId = UniqueIdUtil.getTraceId();
    recursionLogged = false;
  }
  /**
   * @description Constructs the domain class with the data on which to apply the behaviour implemented within the sObject including Record Type
   */
  public Lib_TriggerHandler() {
    this(null);
  }
  /**
   * @description Constructs the domain class with the custom defined max loop count per event handler
   * @param maxLoopCount max loop count allowed for an handler
   */
  public Lib_TriggerHandler(Integer maxLoopCount) {
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

    setObjectEventName();

    addToLoopCount(maxLoopCount);

    triggerHandler();

    this.log.insertLog();
  }

  /***************************************
   * private instance methods
   ***************************************/

  /**
   * @description increase the loop count for each trigger event handler
   * @param maxLoopCount max loop count allowed for an handler
   */
  private void addToLoopCount(Integer maxLoopCount) {
    if (Lib_TriggerHandler.loopCountMap.containsKey(this.objectEventName)) {
      Boolean exceeded = Lib_TriggerHandler.loopCountMap.get(
          this.objectEventName
        )
        .increment();

      if (exceeded && Lib_TriggerHandler.recursionLogged) {
        this.logTriggerRecursion();
        Lib_TriggerHandler.recursionLogged = true;
      }
    } else {
      Lib_TriggerHandler.loopCountMap.put(
        this.objectEventName,
        new LoopCount(maxLoopCount)
      );
    }
  }
  /**
   * @description set current trigger handler and event (context) name
   * Suppressing warning for CyclomaticComplexity as this method has too many if conditon to check Trigger Context
   */
  @SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
  private void setObjectEventName() {
    // set current trigger execution context
    if (Trigger.isExecuting) {
      if (Trigger.isBefore && Trigger.isInsert) {
        this.context = TriggerContext.BEFORE_INSERT;
      } else if (Trigger.isBefore && Trigger.isUpdate) {
        this.context = TriggerContext.BEFORE_UPDATE;
      } else if (Trigger.isBefore && Trigger.isDelete) {
        this.context = TriggerContext.BEFORE_DELETE;
      } else if (Trigger.isAfter && Trigger.isInsert) {
        this.context = TriggerContext.AFTER_INSERT;
      } else if (Trigger.isAfter && Trigger.isUpdate) {
        this.context = TriggerContext.AFTER_UPDATE;
      } else if (Trigger.isAfter && Trigger.isDelete) {
        this.context = TriggerContext.AFTER_DELETE;
      } else if (Trigger.isAfter && Trigger.isUndelete) {
        this.context = TriggerContext.AFTER_UNDELETE;
      }
    }

    this.objectEventName = this.objectType + '-' + this.context;
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
   * @description Get LIMIT INFO and send log with contextId as traceId and loopCountMap
   */
  private void logTriggerRecursion() {
    lib_systemLog log = new lib_systemLog(
      Lib_TriggerHandler.class.getName(),
      'logTriggerRecursion'
    );

    log.info(
      'CPU Time: ' +
      System.Limits.getCpuTime() +
      '; Limit CPU Time: ' +
      System.Limits.getLimitCpuTime() +
      '; Heap Size: ' +
      System.Limits.getHeapSize() +
      '; Limit Heap Size: ' +
      System.Limits.getLimitHeapSize() +
      '; Loop Count Map: ' +
      JSON.serialize(Lib_TriggerHandler.loopCountMap) +
      '; Reason for logging: Trigger handler exceeds max loop count',
      Lib_TriggerHandler.contextId
    );
    log.insertLogAsync();
  }

  /***************************************
   * context methods for override
   ***************************************/

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

  /**
   * @description inner class for managing the loop count per handler
   */
  private class LoopCount {
    private Integer max;
    private Integer count;

    /**
     * @description default constructor to initialize a new loop count in current transaction, default max loop count set to 10
     */
    public LoopCount() {
      this(10);
    }

    /**
     * @description constructor to initialize a new loop count with user defined max count in current transaction
     * @param max max loop count allowed for an handler
     */
    public LoopCount(Integer max) {
      this.max = max;
      this.count = 1;
    }

    /**
     * @description increse current loop count for a givien handler event
     * @return Boolean current handler event loop status, if has exceeded defined max count
     */
    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    /**
     * @description decide current handler event loop status, if has exceeded defined max count
     * @return Boolean true if exceeded defined max loop count
     */
    public Boolean exceeded() {
      return this.max >= 0 && this.count > this.max;
    }

    /**
     * @description get defined max loop count
     * @return Integer max loop count defined in one transcation
     */
    public Integer getMax() {
      return this.max;
    }

    /**
     * @description get current loop count for a given handler event
     * @return Integer current handler event loop count in one transcation
     */
    public Integer getCount() {
      return this.count;
    }

    /**
     * @description set custom max loop count
     * @param max max loop count
     */
    public void setMax(Integer max) {
      this.max = max;
    }
  }
}
