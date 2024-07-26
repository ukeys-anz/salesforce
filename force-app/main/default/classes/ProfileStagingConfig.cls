/**
 * @author Tan Phan
 * @since 06/2024
 * @description Provide a baseline framework for capturing and tracking changes made to customer-related records.
 * The class contains several configurable properties and methods that allow customization of the change capture process.
 *  - revertOnDone: A boolean indicating whether to revert changes made to a record once the capturing phase is complete. Default to true.
 *  - trackedFields: A set of field names that should be tracked for changes.
 *  - copyFields: A set of field names that should always be captured, regardless of changes (only done when there are changes captured in tracked fields).
 *  - fieldGroups: A list of sets of field names that are tracked as groups. When a field in a group is changed, all other fields in the group will be automatically captured eg. Address fields
 * @usage
 *  - Extend the class to implement domain-specific logics.
 *  - "finalise" method must be overriden and can be used to assign fields values to Customer_Profile_Updates__c as required.
 *    > Customer_Profile_Updates__c.Customer_Name__c is required for platform event to publish successfully.
 *    > Name, Object_Name__c, TriggerFrom__c, Customer_Name__c etc. have default values, but could be overriden according to domain requirements.
 *  - Example of methods that could be overriden to customise captured data includes (but not limited to)
 *    > getFieldName: override to transform field API name stored in AsIsValue__c and ToBeValue__c
 *    > getFieldLabel: override to transform field label stored in OldValue__c and NewValue__c
 *    > getFieldValue: override to transform field value stored in AsIsValue__c and ToBeValue__c. Useful for mapping from parent ID to parent field.
 *    > getFieldUiValue: override to transform field front-end value stored in OldValue__c and NewValue__c.
 *    > canCapture: override FLS check
 */
public abstract with sharing class ProfileStagingConfig {
  //#region CONFIG PROPERTIES
  /**
   * Indicate whether to revert changes done to record once capturing phase is done
   */
  @TestVisible
  protected Boolean revertOnDone = true;
  /**
   * The fields to track for changes
   */
  @TestVisible
  protected Set<String> trackedFields = new Set<String>();
  /**
   * Fields that are always captured regardless of changes when a change happens in tracked fields
   */
  @TestVisible
  protected Set<String> copyFields = new Set<String>();
  /**
   * Fields that are tracked as group, e.g address fields.
   * When a field in a group is changed, all other fields in the group will be automatically captured.
   */
  @TestVisible
  protected List<Set<String>> fieldGroups = new List<Set<String>>();
  //#endregion

  //#region RECORD PROPERTIES
  @TestVisible
  protected ChangeData data;
  @TestVisible
  protected SObject record;
  @TestVisible
  protected SObject oldRecord;
  @TestVisible
  protected Map<String, DescribeFieldResult> fieldInfoMap = new Map<String, DescribeFieldResult>();

  /**
   * @description Gets the describe result for the SObject associated with the record.
   * @return The describe result for the SObject associated with the record.
   */
  protected Schema.DescribeSObjectResult objectInfo {
    get {
      if (objectInfo == null) {
        objectInfo = this.record.getSObjectType().getDescribe();
      }
      return objectInfo;
    }
    set;
  }
  protected Map<String, SObjectField> fieldMap {
    get {
      if (fieldMap == null) {
        fieldMap = this.objectInfo.fields.getMap();
      }
      return fieldMap;
    }
    set;
  }
  protected Boolean isNew {
    get {
      return this.oldRecord == null;
    }
  }
  protected Boolean isUpdate {
    get {
      return this.oldRecord != null;
    }
  }
  //#endregion

  //#region CORE LOGICS
  /**
   * @description Analyse and capture changes done to the given records, then save to Customer_Profile_Updates__c.
   * @param cpu The Customer_Profile_Updates__c record.
   * @param record The new record.
   * @param oldRecord The old record.
   * @return `Boolean` Indicates whether the processing was successful.
   */
  public virtual Boolean process(
    Customer_Profile_Updates__c cpu,
    SObject record,
    SObject oldRecord
  ) {
    this.init(record, oldRecord);
    this.capture();
    this.report(cpu);
    this.finalise(cpu);
    this.revert();
    return this.hasChanges();
  }

  /**
   * @description Must be overriden. Assign any additional values to Customer_Profile_Updates__c record
   * @param cpu The Customer_Profile_Updates__c object that contains the customer profile updates.
   */
  @TestVisible
  protected abstract void finalise(Customer_Profile_Updates__c cpu);

  /**
   * @description Initializes the change capture process.
   * @param record The new record to be initialized.
   * @param oldRecord The old record to be initialized.
   */
  @TestVisible
  protected virtual void init(SObject record, SObject oldRecord) {
    this.data = new ChangeData();
    this.record = record;
    this.oldRecord = oldRecord;
  }

  /**
   * @description Main logic to capture changes of tracked fields.
   *  * Also capture fields in "copyFields" list regardless of changes IF there is at least 1 change captured
   */
  @TestVisible
  protected virtual void capture() {
    for (String field : this.trackedFields) {
      if (this.canCapture(field)) {
        this.captureField(field);
        this.captureGroup(field);
      }
    }
    if (!this.hasChanges()) {
      return;
    }
    for (String field : this.copyFields) {
      this.captureField(field);
    }
  }

  /**
   * @description Capture the front-end and back-end old/new values of a field and put them into ChangeData
   * @param field The field to capture values
   */
  @TestVisible
  protected virtual void captureField(String field) {
    if (!this.hasChecked(field) && !this.isNullOnInsert(field)) {
      this.writeNewData(field);
      this.writeOldData(field);
    }
  }

  /**
   * @description Captures new data for the specified field.
   * @param field The field to capture new data for.
   */
  @TestVisible
  protected virtual void writeNewData(String field) {
    this.data.newData.put(
      this.getFieldName(field),
      this.getFieldValue(this.record, field)
    );
    this.data.newUiData.put(
      this.getFieldLabel(field),
      this.getFieldUiValue(this.record, field)
    );
  }

  /**
   * @description Captures the old data of a specified field.
   * @param field The field to capture the old data for.
   */
  @TestVisible
  protected virtual void writeOldData(String field) {
    if (this.isUpdate) {
      this.data.oldData.put(
        this.getFieldName(field),
        this.getFieldValue(this.oldRecord, field)
      );
      this.data.oldUiData.put(
        this.getFieldLabel(field),
        this.getFieldUiValue(this.oldRecord, field)
      );
    }
  }

  /**
   * @description Captures the group of fields related to a given field.
   * @param field The field to capture the field group for.
   */
  @TestVisible
  protected virtual void captureGroup(String field) {
    if (this.isNew) {
      return;
    }
    for (Set<String> fieldGroup : this.fieldGroups) {
      if (!fieldGroup.contains(field)) {
        continue;
      }
      for (String groupMember : fieldGroup) {
        this.captureField(groupMember);
      }
    }
  }

  /**
   * @description Applies the change data captured from the current object to the given Customer_Profile_Updates__c record.
   * @param cpu The Customer_Profile_Updates__c record to apply the data to.
   */
  @TestVisible
  protected virtual void report(Customer_Profile_Updates__c cpu) {
    cpu.Name = this.objectInfo.Label;
    cpu.Object_Name__c = this.objectInfo.Label;
    cpu.TriggeredFrom__c = this.objectInfo.Name;
    cpu.OldValue__c = this.data.jsonOldUiData;
    cpu.NewValue__c = this.data.jsonNewUiData;
    cpu.AsIsValue__c = this.data.jsonOldData;
    cpu.ToBeValue__c = this.data.jsonNewData;
  }

  /**
   * @description revert all changes when banker update a prospect related record
   */
  @TestVisible
  protected virtual void revert() {
    if (this.isNew || !this.revertOnDone) {
      return;
    }
    for (String field : this.record.getPopulatedFieldsAsMap().keySet()) {
      if (this.isChanged(field) && this.getFieldInfo(field).isUpdateable()) {
        this.record.put(field, this.oldRecord.get(field));
      }
    }
  }
  //#endregion

  //#region HELPERS
  /**
   * @description Return field API name,
   * 	* Could be overriden to transform to different name.
   * @param field The field API name.
   * @return The field API name.
   */
  @TestVisible
  protected virtual String getFieldName(String field) {
    return field;
  }

  /**
   * @description Returns the label of a given field.
   * 	* Could be overriden to transform to different label.
   * @param field The API name of the field.
   * @return The label of the field.
   */
  @TestVisible
  protected virtual String getFieldLabel(String field) {
    return this.getFieldInfo(field).Label;
  }

  /**
   * @description Return value of a given field from a given record.
   * 	* Could be overriden to map to different value
   * @param record The SObject record containing the field.
   * @param field The name of the field to get value.
   * @return The value.
   */
  @TestVisible
  protected virtual Object getFieldValue(SObject record, String field) {
    return record.get(field);
  }

  /**
   * @description Determines whether the specified field should be captured BASED ON USER PERMISSIONS.
   * 	* Could be overriden to change the rules.
   * @param field The name of the field to check.
   * @return A Boolean value indicating whether the field should be captured.
   */
  @TestVisible
  protected virtual Boolean canCapture(String field) {
    DescribeFieldResult fieldInfo = this.getFieldInfo(field);
    Boolean isCreateable = this.isNew && fieldInfo.isCreateable();
    Boolean isUpdateable = this.isChanged(field) && fieldInfo.isUpdateable();
    return isCreateable || isUpdateable;
  }

  /**
   * @description Determines if the specified field is NULL or FALSE when creating a new record.
   * @param field The name of the field to check.
   * @return `Boolean` True if the field is null or false when creating a new record, false otherwise.
   */
  @TestVisible
  protected virtual Boolean isNullOnInsert(String field) {
    Object value = this.record.get(field);
    return this.isNew && (value == null || value == false);
  }

  /**
   * @description Determines whether there are any changes captured
   * @return `Boolean` - Returns true if there are changes, false otherwise.
   */
  @TestVisible
  protected virtual Boolean hasChanges() {
    return !this.data.newData.isEmpty();
  }

  /**
   * @description Checks if a specific field has been processed.
   * @param field The name of the field to check.
   * @return `Boolean` True if the field has been processed, false otherwise.
   */
  @TestVisible
  protected virtual Boolean hasChecked(String field) {
    Boolean checked = this.data.checkedFields.contains(field);
    this.data.checkedFields.add(field);
    return checked;
  }

  /**
   * @description Retrieves the DescribeFieldResult for a given field.
   * If the field information is already present in the fieldInfoMap, it is returned from the map.
   * Otherwise, it retrieves the field information using the fieldMap and adds it to the fieldInfoMap.
   * @param field The API name of the field.
   * @return The DescribeFieldResult for the given field.
   */
  @TestVisible
  protected DescribeFieldResult getFieldInfo(String field) {
    if (this.fieldInfoMap.containsKey(field)) {
      return this.fieldInfoMap.get(field);
    }
    DescribeFieldResult fieldInfo = this.fieldMap.get(field).getDescribe();
    this.fieldInfoMap.put(field, fieldInfo);
    return fieldInfo;
  }

  /**
   * @description Retrieves the UI value of a field from a given record.
   * @param record The SObject record from which to retrieve the field value.
   * @param field The API name of the field.
   * @return `Object` The UI value of the field.
   */
  protected Object getFieldUiValue(SObject record, String field) {
    String value = String.valueOf(record.get(field));
    if (value == null) {
      return value;
    }
    DescribeFieldResult fieldInfo = getFieldInfo(field);
    if (fieldInfo.Type == DisplayType.PICKLIST) {
      return CommonUtil.getSinglePicklistLabel(fieldInfo.SObjectField, value);
    }
    if (fieldInfo.Type == DisplayType.MULTIPICKLIST) {
      return CommonUtil.getMultiPicklistLabel(fieldInfo.SObjectField, value);
    }
    return getFieldValue(record, field);
  }

  /**
   * @description Checks if a specific field in the record has been changed.
   * @param field The name of the field to check.
   * @return `Boolean` True if the field has been changed, false otherwise.
   */
  @TestVisible
  protected Boolean isChanged(String field) {
    return this.isUpdate && this.record.get(field) != this.oldRecord.get(field);
  }
  //#endregion

  /**
   * @description Represents the state of changes in records based on a tracking configuration
   */
  public class ChangeData {
    public Set<String> checkedFields = new Set<String>();
    public Map<String, Object> oldUiData = new Map<String, Object>();
    public Map<String, Object> newUiData = new Map<String, Object>();
    public Map<String, Object> oldData = new Map<String, Object>();
    public Map<String, Object> newData = new Map<String, Object>();

    /**
     * @description Gets the JSON representation of the oldData
     * @return The JSON string of the oldData
     */
    public String jsonOldData {
      get {
        if (this.oldData.isEmpty()) {
          return null;
        }
        return JSON.serialize(this.oldData);
      }
    }

    /**
     * @description Gets the pretty-printed JSON representation of the oldUiData
     * @return The pretty-printed JSON string of the oldUiData
     */
    public String jsonOldUiData {
      get {
        if (this.oldUiData.isEmpty()) {
          return null;
        }
        return JSON.serializePretty(this.oldUiData);
      }
    }

    /**
     * @description Gets the JSON representation of the newData
     * @return The JSON string of the newData
     */
    public String jsonNewData {
      get {
        if (this.newData.isEmpty()) {
          return null;
        }
        return JSON.serialize(this.newData);
      }
    }

    /**
     * @description Gets the pretty-printed JSON representation of the newUiData
     * @return The pretty-printed JSON string of the newUiData
     */
    public String jsonNewUiData {
      get {
        if (this.newUiData.isEmpty()) {
          return null;
        }
        return JSON.serializePretty(this.newUiData);
      }
    }
  }
}
