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
@SuppressWarnings('PMD.CyclomaticComplexity')
public virtual with sharing class Lib_TriggerHandler {
  /**
   * @description The current context of the trigger, overrideable in tests
   */
  @TestVisible
  private TriggerOperation context {
    get {
      if (context != null) {
        return context;
      }
      if (Trigger.isExecuting == false) {
        return context;
      }
      if (Trigger.isBefore && Trigger.isInsert) {
        context = TriggerOperation.BEFORE_INSERT;
      } else if (Trigger.isBefore && Trigger.isUpdate) {
        context = TriggerOperation.BEFORE_UPDATE;
      } else if (Trigger.isBefore && Trigger.isDelete) {
        context = TriggerOperation.BEFORE_DELETE;
      } else if (Trigger.isAfter && Trigger.isInsert) {
        context = TriggerOperation.AFTER_INSERT;
      } else if (Trigger.isAfter && Trigger.isUpdate) {
        context = TriggerOperation.AFTER_UPDATE;
      } else if (Trigger.isAfter && Trigger.isDelete) {
        context = TriggerOperation.AFTER_DELETE;
      } else if (Trigger.isAfter && Trigger.isUndelete) {
        context = TriggerOperation.AFTER_UNDELETE;
      }
      return context;
    }
    private set;
  }

  /**
   * @description Unfiltered list of records from trigger context
   */
  @TestVisible
  public List<SObject> allRecords {
    get {
      if (allRecords != null) {
        return allRecords;
      }
      if (Trigger.isDelete) {
        allRecords = Trigger.old;
      } else {
        allRecords = Trigger.new;
      }
      return allRecords;
    }
    set;
  }

  /**
   * @description Filtered list of records from trigger context
   */
  @TestVisible
  public List<SObject> records {
    get {
      if (records != null) {
        return records;
      }
      //retains the ability to use `records.getSObjectType()`
      records = (List<SObject>) Type.forName('List<' + this.objectName + '>')
        .newInstance();

      for (SObject record : allRecords) {
        if (isValidRecord(record) == false) {
          continue;
        }
        records.add(record);
      }
      return records;
    }
    private set;
  }

  /**
   * @description Filtered new map from trigger context
   */
  @TestVisible
  public Map<Id, SObject> newMap {
    get {
      if (newMap != null) {
        return newMap;
      }
      newMap = new Map<Id, SObject>(records);
      return newMap;
    }
    private set;
  }

  /**
   * @description Filtered old map from trigger context
   */
  public Map<Id, SObject> oldMap {
    get {
      if (Trigger.oldMap == null) {
        return null;
      }
      if (oldMap != null) {
        return oldMap;
      }
      /**
       * Dynamic Map initiation is required to fix a bug with Map downcasting. More details here: https://salesforce.stackexchange.com/questions/106068/apex-string-instanceOf-object/125891#125891
       * Without this, when you pass filtered oldMap into handleBeforeUpdate() or handleAfterUpdate(), `System.TypeException: Invalid conversion from runtime type Map<Id,SObject> to Map<Id,Case>` will throw */
      oldMap = (Map<Id, SObject>) Type.forName('Map<Id, ' + objectName + ' >')
        .newInstance();
      for (Id recordId : newMap.keySet()) {
        oldMap.put(recordId, Trigger.oldMap.get(recordId));
      }
      return oldMap;
    }
    private set;
  }

  /**
   * @description Returns the SObjectType this Domain class represents
   */
  @TestVisible
  private String objectName {
    get {
      return allRecords.getSObjectType().toString();
    }
  }

  /**
   * @description Name of the object and trigger context
   */
  @TestVisible
  private String objectEventName {
    get {
      return this.objectName + '-' + this.context;
    }
  }

  /**
   * @description Contains settings used by Salesforce Library classes
   */
  private Salesforce_Library_Settings__c settings = Salesforce_Library_Settings__c.getInstance(
    UserInfo.getUserId()
  );

  /**
   * @description Custom settings for bypassing triggers
   */
  private Salesforce_Bypass_Trigger_Actions__c bypassActions = Salesforce_Bypass_Trigger_Actions__c.getInstance(
    UserInfo.getUserId()
  );

  /**
   * @description Disables the triggers based on Custom Settings
   */
  public Boolean disableTriggers {
    get {
      return settings.Disable_Triggers__c;
    }
    private set;
  }

  /**
   * @description Disables the delete trigger on the object based on Custom Settings
   */
  public Boolean bypassDelete {
    get {
      return (bypassActions.Object_API_Name__c == this.objectName) &&
        (bypassActions.Bypass_Delete__c == true);
    }
    private set;
  }

  /**
   * @description Disables the edit trigger on the object based on Custom Settings
   */
  public Boolean bypassUpdate {
    get {
      return (bypassActions.Object_API_Name__c == this.objectName) &&
        (bypassActions.Bypass_Update__c == true);
    }
    private set;
  }

  /**
   * @description Returns the record type represented by this domain class
   */
  public Map<String, Schema.RecordTypeInfo> objectRecordTypes {
    get {
      return allRecords[0]
        .getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByName();
    }
  }

  /**
   * @description Return the System log represented by this domain class
   */
  public lib_SystemLog log { get; set; }

  /**
   * @description Static map of handlername, times object event was invoked
   */
  @TestVisible
  private static Map<String, LoopCount> loopCountMap = new Map<String, LoopCount>();

  /**
   * @description Unique transaction id
   */
  private static String contextId = UniqueIdUtil.getTraceId();

  /**
   * @description Flag to track recursion logging
   */
  @TestVisible
  private static Boolean recursionLogged = false;

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
    if (Trigger.isExecuting == false) {
      return;
    }
    addToLoopCount(maxLoopCount);
    triggerHandler();
    insertLog();
  }

  /***************************************
   * private instance methods
   ***************************************/

  /**
   * @description increase the loop count for each trigger event handler
   * @param maxLoopCount max loop count allowed for an handler
   */
  @TestVisible
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
   * @description Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
   **/
  private void triggerHandler() {
    if (this.records.isEmpty() || this.disableTriggers) {
      return;
    }
    // Invoke the applicable handler
    if (context == TriggerOperation.BEFORE_INSERT) {
      handleBeforeInsert();
    } else if (context == TriggerOperation.BEFORE_UPDATE && !bypassUpdate) {
      handleBeforeUpdate(oldMap);
    } else if (context == TriggerOperation.BEFORE_DELETE && !bypassDelete) {
      handleBeforeDelete();
    } else if (context == TriggerOperation.AFTER_INSERT) {
      handleAfterInsert();
    } else if (context == TriggerOperation.AFTER_UPDATE && !bypassUpdate) {
      handleAfterUpdate(oldMap);
    } else if (context == TriggerOperation.AFTER_DELETE && !bypassDelete) {
      handleAfterDelete();
    } else if (context == TriggerOperation.AFTER_UNDELETE) {
      handleAfterUndelete();
    }
  }

  /**
   * @description Get LIMIT INFO and send log with contextId as traceId and loopCountMap
   */
  private void logTriggerRecursion() {
    Logger.info(
      JSON.serialize(Lib_TriggerHandler.loopCountMap) +
      '; Reason for logging: Trigger handler exceeds max loop count'
    );
    Logger.saveLog();
  }

  /**
   * @description Insert the System log represented by this domain class
   */
  private void insertLog() {
    this.log = new lib_SystemLog(this.objectName + ' Trigger');
    this.log.insertLog();
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
    onValidateBefore();
  }

  /**
   * @description Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void handleBeforeUpdate(Map<Id, SObject> oldMap) {
    onBeforeUpdate(oldMap);
    onValidateBefore();
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
   * @description Override this to apply general validation to be performed during insert or update, called by the handleBeforeInsert and handleBeforeUpdate methods
   **/
  protected virtual void onValidateBefore() {
  }

  /**
   * @description Override this to apply general validation to be performed during insert or update, called by the handleBeforeInsert and handleBeforeUpdate methods
   * @param oldMap Trigger's oldMap
   **/
  protected virtual void onValidateBefore(Map<Id, SObject> oldMap) {
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
   * @description Check if a record is relevant to the trigger handler based on certain conditions
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  @TestVisible
  protected virtual Boolean isValidRecord(SObject record) {
    return true;
  }

  /**
   * @description inner class for managing the loop count per handler
   */
  @TestVisible
  private class LoopCount {
    @TestVisible
    private Integer max;
    @TestVisible
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
     * @return Integer max loop count defined in one transaction
     */
    public Integer getMax() {
      return this.max;
    }

    /**
     * @description get current loop count for a given handler event
     * @return Integer current handler event loop count in one transaction
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
