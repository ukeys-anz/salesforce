/**
 * @author Tan Phan
 * @since 11/2022
 * @description Contains configurations and helpers to track and log changes made to a prospect customer
 * @runTests CCRMCustomerProfileUpdateHelperTest
 */
public with sharing class CCRMCustomerProfileUpdateConfig {
  public static final String NAME_SUFFIX = ' Detail Update';
  public static final User CURRENT_USER = [
    SELECT Lan_Id__c
    FROM User
    WHERE Id = :UserInfo.getUserId()
    WITH SECURITY_ENFORCED
  ];

  public static final Map<String, Map<String, String>> TRANSFORM_CONFIGS = new Map<String, Map<String, String>>{
    Schema.SObjectType.ContactPointAddress.Name => new Map<String, String>{
      Schema.SObjectType.ContactPointAddress.fields.Street.Name => 'addressLine1',
      Schema.SObjectType.ContactPointAddress.fields.Delivery_Identifier__c.Name => 'deliveryIdentifier'
    }
  };

  public static final Map<String, MappingConfig> MAPPING_CONFIGS = new Map<String, MappingConfig>{
    Schema.SObjectType.Account.Name => new MappingConfig(
      Schema.SObjectType.Account.fields.Id.Name
    ),
    Schema.SObjectType.Contact.Name => new MappingConfig(
        Schema.SObjectType.Contact.fields.AccountId.Name
      )
      .copyField(
        Schema.SObjectType.Customer_Profile_Updates__c.fields.Occurrence_Number__c.Name,
        Schema.SObjectType.Contact.fields.Occurrence_Number__c.Name
      ),
    Schema.SObjectType.ContactPointEmail.Name => new MappingConfig(
        Schema.SObjectType.ContactPointEmail.fields.Customer_Name__c.Name
      )
      .copyField(
        Schema.SObjectType.Customer_Profile_Updates__c.fields.Occurrence_Number__c.Name,
        Schema.SObjectType.ContactPointEmail.fields.Occurrence_Number__c.Name
      ),
    Schema.SObjectType.ContactPointAddress.Name => new MappingConfig(
      Schema.SObjectType.ContactPointAddress.fields.Customer_Name__c.Name
    )
  };

  static final Map<String, List<TrackingConfig>> TRACKING_CONFIGS = new Map<String, List<TrackingConfig>>{
    Schema.SObjectType.Account.Name => new List<TrackingConfig>{
      new TrackingConfig(Schema.SObjectType.Account.Label + NAME_SUFFIX)
        .name('Account.TaxDetails')
        .trackFields(
          Schema.SObjectType.Account.fieldSets.CCRMProspectTrackedTaxFields
        ),
      new TrackingConfig(Schema.SObjectType.Account.Label + NAME_SUFFIX)
        .trackFields(
          Schema.SObjectType.Account.fieldSets.CCRMProspectTrackedOtherFields
        )
    },
    Schema.SObjectType.Contact.Name => new List<TrackingConfig>{
      new TrackingConfig(Schema.SObjectType.Contact.Label + NAME_SUFFIX)
        .trackFields(
          Schema.SObjectType.Contact.fieldSets.CCRMProspectTrackedFields
        )
    },
    Schema.SObjectType.ContactPointEmail.Name => new List<TrackingConfig>{
      new TrackingConfig(
          Schema.SObjectType.ContactPointEmail.Label + NAME_SUFFIX
        )
        .trackFields(
          Schema.SObjectType.ContactPointEmail.fieldSets.CCRMProspectTrackedFields
        )
    },
    Schema.SObjectType.ContactPointAddress.Name => new List<TrackingConfig>{
      new TrackingConfig(
          Schema.SObjectType.ContactPointAddress.Label + NAME_SUFFIX
        )
        .trackFields(
          Schema.SObjectType.ContactPointAddress.fieldSets.CCRMProspectTrackedFields
        )
        .copyFields(
          Schema.SObjectType.ContactPointAddress.fieldSets.CCRMProspectCopyFields
        )
    }
  };

  /**
   * @description Wrapper class for prospect field mapping configuration
   */
  public class MappingConfig {
    public String accountLookupField;
    public Map<String, String> copyFields;

    /**
     * @description constructor
     * @param accountLookupField the API name of account lookup field
     */
    MappingConfig(String accountLookupField) {
      this.accountLookupField = accountLookupField;
      this.copyFields = new Map<String, String>();
    }

    /**
     * @description specify which field from the tracked object to copy to Customer_Profile_Updates__c
     * @param targetField API name of the field on Customer_Profile_Updates__c to copy to
     * @param copyFrom API name of the field on tracked object to copy from
     * @return MappingConfig class instance
     */
    MappingConfig copyField(String targetField, String copyFrom) {
      this.copyFields.put(targetField, copyFrom);
      return this;
    }
  }

  /**
   * @description Wrapper class for prospect field tracking configuration
   */
  public class TrackingConfig {
    //The value to be stored in Customer_Profile_Updates__c.Name
    public String label;
    //Custom value for Customer_Profile_Updates__c.TriggeredFrom__c (object API name by default if this is left blank)
    public String name;
    //The fields of prospect-related objects that will be tracked for changes and create Customer_Profile_Updates__c/Customer_Profile_Update_Event__c accordingly
    public Set<String> trackedFields;
    //When a field in a group is changed, all other fields are automatically added to Customer_Profile_Updates__c
    public List<Set<String>> fieldGroups;
    //The fields that must always be included Customer_Profile_Updates__c
    public Set<String> copyFields;

    /**
     * @description constructor
     * @param label the API name of the object for this tracking configuration
     */
    TrackingConfig(String label) {
      this.label = label;
      this.trackedFields = new Set<String>();
      this.fieldGroups = new List<Set<String>>();
      this.copyFields = new Set<String>();
    }

    /**
     * @description set custom object name
     * @param name the value to be set to "name"
     * @return TrackingConfig class instance
     */
    TrackingConfig name(String name) {
      this.name = name;
      return this;
    }

    /**
     * @description set trackedFields
     * @param fieldset the fieldSet to add to trackedFields
     * @return TrackingConfig class instance
     */
    TrackingConfig trackFields(Schema.FieldSet fieldset) {
      this.trackedFields = getFieldSet(fieldSet);
      return this;
    }

    /**
     * @description add field group to fieldGroups
     * @param fieldset the fieldSet to add to fieldGroups
     * @return TrackingConfig class instance
     */
    TrackingConfig groupFields(Schema.FieldSet fieldset) {
      this.fieldGroups.add(getFieldSet(fieldSet));
      return this;
    }

    /**
     * @description set copyFields
     * @param fieldset the fieldSet to add to copyFields
     * @return TrackingConfig class instance
     */
    TrackingConfig copyFields(Schema.FieldSet fieldset) {
      this.copyFields = getFieldSet(fieldSet);
      return this;
    }

    /**
     * @description extract field API names from a fieldset
     * @param fieldset the fieldSet to extract
     * @return Set<String> set of field API names
     */
    Set<String> getFieldSet(Schema.FieldSet fieldset) {
      Set<String> fields = new Set<String>();
      for (Schema.FieldSetMember field : fieldset.getFields()) {
        fields.add(field.fieldpath);
      }
      return fields;
    }
  }

  /**
   * @description Encapsulate logics to extract changes to a record
   */
  public class TrackingRequest {
    SObject record;
    SObject oldRecord;
    Schema.DescribeSObjectResult objectInfo;
    MappingConfig mappingConfig;
    TrackingConfig config;
    Map<String, String> transformConfig;
    Map<String, Object> oldValues;
    Map<String, Object> newValues;
    Map<String, Object> oldBackEndValues;
    Map<String, Object> newBackEndValues;
    Map<String, SObjectField> fieldMap;

    /**
     * @description constructor
     * @param record the record to check for changes
     * @param oldRecord previous values of the record
     */
    public TrackingRequest(SObject record, SObject oldRecord) {
      this.record = record;
      this.oldRecord = oldRecord;
      this.objectInfo = this.record.getSObjectType().getDescribe();
      this.fieldMap = this.objectInfo.fields.getMap();
      this.mappingConfig = MAPPING_CONFIGS.get(this.objectInfo.Name);
      this.transformConfig = TRANSFORM_CONFIGS.containsKey(this.objectInfo.Name)
        ? TRANSFORM_CONFIGS.get(this.objectInfo.Name)
        : new Map<String, String>();
    }

    /**
     * @description generate Customer_Profile_Updates__c from a given record
     * @return List<Customer_Profile_Updates__c> the generated records
     */
    public List<Customer_Profile_Updates__c> getUpdates() {
      List<Customer_Profile_Updates__c> results = new List<Customer_Profile_Updates__c>();
      for (TrackingConfig config : TRACKING_CONFIGS.get(this.objectInfo.Name)) {
        Customer_Profile_Updates__c cpu = this.getUpdateByConfig(config);
        if (cpu != null) {
          results.add(cpu);
        }
      }

      this.revertAllChanges();

      return results;
    }

    /**
     * @description Check for any changes to a record, and create a Customer_Profile_Updates__c record accordingly, then revert any changes made to the record
     * @param config the field tracking configuration to extract change data
     * @return Customer_Profile_Updates__c - record to contain old and new values of the record. null if no changes detected.
     */
    Customer_Profile_Updates__c getUpdateByConfig(TrackingConfig config) {
      this.config = config;
      this.oldValues = new Map<String, Object>();
      this.newValues = new Map<String, Object>();
      this.oldBackEndValues = new Map<String, Object>();
      this.newBackEndValues = new Map<String, Object>();

      for (String field : this.config.trackedFields) {
        if (this.newBackEndValues.containsKey(field)) {
          continue;
        }

        Schema.DescribeFieldResult fieldInfo = fieldMap.get(field)
          .getDescribe();

        if (this.oldRecord == null && fieldInfo.isCreateable()) {
          this.extractField(field);
        } else if (
          this.oldRecord != null &&
          this.oldRecord.get(field) != this.record.get(field) &&
          fieldInfo.isUpdateable()
        ) {
          this.extractField(field);
          this.extractFieldGroup(field);
        }
      }

      if (this.newBackEndValues.isEmpty()) {
        return null;
      }

      for (String field : this.config.copyFields) {
        this.extractField(field);
      }

      return this.generateCustomerProfileUpdate(config);
    }

    /**
     * @description revert all changes when banker update a prospect related record
     */
    void revertAllChanges() {
      if (this.oldRecord == null) {
        return;
      }
      for (String field : this.fieldMap.keySet()) {
        if (this.fieldMap.get(field).getDescribe().isUpdateable()) {
          this.record.put(field, this.oldRecord.get(field));
        }
      }
    }

    /**
     * @description Extract the front-end and back-end old/new values of a field and put them in respective variables
     * @name extractField
     * @param field The field to extract values
     */
    void extractField(String field) {
      Schema.DescribeFieldResult fieldInfo = fieldMap.get(field).getDescribe();
      //on updated records we want to log the null values, but not on new records
      if (
        this.oldRecord != null ||
        (this.record.get(field) != null &&
        this.record.get(field) != false)
      ) {
        this.addFieldToMap(
          this.newValues,
          fieldInfo.label,
          this.record.get(field)
        );
        this.addFieldToMap(
          this.newBackEndValues,
          field,
          this.record.get(field)
        );
      }
      if (this.oldRecord != null) {
        this.addFieldToMap(
          this.oldValues,
          fieldInfo.label,
          this.oldRecord.get(field)
        );
        this.addFieldToMap(
          this.oldBackEndValues,
          field,
          this.oldRecord.get(field)
        );
      }
    }

    /**
     * @description add a key-value pair into a given map, but first check if the key in configured in transformConfig to map as a different text
     * @param values the map to put the key-value pair into
     * @param field the key
     * @param value the value
     */
    void addFieldToMap(Map<String, Object> values, String field, Object value) {
      if (this.transformConfig.containsKey(field)) {
        field = this.transformConfig.get(field);
      }
      values.put(field, value);
    }

    /**
     * @description check whether a field is part of a field group that needs to be processed together
     * @name extractFieldGroup
     * @param field The field to check
     */
    void extractFieldGroup(String field) {
      for (Set<String> fieldGroup : this.config.fieldGroups) {
        if (!fieldGroup.contains(field)) {
          continue;
        }
        for (String groupMember : fieldGroup) {
          if (groupMember != field) {
            this.extractField(groupMember);
          }
        }
      }
    }

    /**
     * @description generate a Customer_Profile_Updates__c record from extracted old and new values
     * @param config the field tracking configuration to extract change data
     * @return Customer_Profile_Updates__c the generated record
     */
    Customer_Profile_Updates__c generateCustomerProfileUpdate(
      TrackingConfig config
    ) {
      Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c(
        Action__c = this.oldRecord == null ? 'Add' : 'Update',
        Customer_Name__c = (Id) this.record.get(
          this.mappingConfig.accountLookupField
        ),
        TriggeredFrom__c = config.name == null
          ? this.objectInfo.Name
          : config.name,
        Name = this.config.label,
        UserLanId__c = CURRENT_USER.Lan_Id__c,
        Status__c = 'Pending',
        OldValue__c = this.oldValues.isEmpty()
          ? null
          : JSON.serializePretty(this.oldValues),
        NewValue__c = JSON.serializePretty(this.newValues),
        AsIsValue__c = this.oldBackEndValues.isEmpty()
          ? null
          : JSON.serialize(this.oldBackEndValues),
        ToBeValue__c = JSON.serialize(this.newBackEndValues)
      );

      for (String targetField : this.mappingConfig.copyFields.keySet()) {
        cpu.put(
          targetField,
          this.record.get(this.mappingConfig.copyFields.get(targetField))
        );
      }

      return cpu;
    }
  }
}
