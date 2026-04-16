/**
 * @description This class represents the Profile Staging Cloud Event Model.
 */
public virtual without sharing class ProfileStagingCloudEventModel extends CloudEventModel {
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final Map<String, FormulaEval.FormulaInstance> FORMULA_BUILDERS = new Map<String, FormulaEval.FormulaInstance>();

  /**
   * @description Constructor for ProfileStagingCloudEventModel.
   * @param staging The staging object containing profile update details.
   * @param triggerConfig The trigger configuration metadata.
   */
  public ProfileStagingCloudEventModel(
    Customer_Profile_Updates__c staging,
    ProfileStagingEventConfig__mdt triggerConfig
  ) {
    super();
    ce_source = triggerConfig.Source__c;
    ce_subject = computePattern(triggerConfig.Subject__c, staging);
    ce_partitionkey = computePattern(triggerConfig.PartitionKey__c, staging);
    ce_xtargets = getXTargets(staging);
    ce_type = triggerConfig.EventType__c;
    ce_dataschema = triggerConfig.DataSchema__c;
    ce_data = new DataModel(staging, triggerConfig);
  }

  /**
   * @description Computes the pattern for the given staging record.
   * @param pattern The pattern to compute.
   * @param staging The staging record.
   * @return The computed pattern string.
   */
  private String computePattern(
    String pattern,
    Customer_Profile_Updates__c staging
  ) {
    FormulaEval.FormulaInstance builder = FORMULA_BUILDERS.get(pattern);
    if (builder == null) {
      builder = Formula.builder()
        .withType(Customer_Profile_Updates__c.class)
        .withReturnType(FormulaEval.FormulaReturnType.STRING)
        .withFormula(pattern)
        .build();
      FORMULA_BUILDERS.put(pattern, builder);
    }
    return (String) builder.evaluate(staging);
  }

  /**
   * @description Constructs the xTargets string for the given staging record.
   * @param staging The staging record.
   * @return The constructed xTargets string.
   */
  private string getXTargets(Customer_Profile_Updates__c staging) {
    List<String> targets = new List<String>{ 'ocv/' + staging.OCV_ID__c };
    if (
      staging.Source_System_Name__c != null &&
      staging.Source_System_ID__c != null
    ) {
      targets.add(
        staging.Source_System_Name__c.toLowerCase() +
          '/' +
          staging.Source_System_ID__c
      );
    }
    return String.join(targets, ',');
  }

  /**
   * @description Represents the data model for profile staging cloud events.
   */
  public virtual class DataModel extends CloudEventModel.CloudEventDataModel {
    public ProfileUpdate data;

    /**
     * @description private Constructor for DataModel.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    private DataModel(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      this.data = (ProfileUpdate) Type.forName(triggerConfig.PayloadModel__c)
        .newInstance();
      data.init(staging, triggerConfig);
    }
  }

  /**
   * @description Represents the party change data model for profile staging cloud events.
   */
  public virtual class PartyChange extends ProfileUpdate {
    public Map<String, Object> partyChange;
    public Map<String, Object> oldPartyChange;

    /**
     * @description Initializes the PartyChange instance.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    protected override void init(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      super.init(staging, triggerConfig);
      this.partyChange = (Map<String, Object>) JSON.deserializeUntyped(
        staging.ToBeValue__c
      );
      this.oldPartyChange = (Map<String, Object>) JSON.deserializeUntyped(
        staging.AsIsValue__c
      );
    }
  }

  /**
   * @description Represents the restraint change data model for profile staging cloud events.
   */
  public virtual class RestraintChange extends ProfileUpdate {
    public Map<String, Object> restraintChange;

    /**
     * @description Initializes the RestraintChange instance.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    protected override void init(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      super.init(staging, triggerConfig);
      this.restraintChange = (Map<String, Object>) JSON.deserializeUntyped(
        staging.ToBeValue__c
      );
    }
  }

  /**
   * @description Represents the legal name change data model for profile staging cloud events.
   */
  public virtual class LegalNameChange extends ProfileUpdate {
    public Map<String, Object> legalNameChange;

    /**
     * @description Initializes the LegalNameChange instance.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    protected override void init(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      super.init(staging, triggerConfig);
      this.legalNameChange = (Map<String, Object>) JSON.deserializeUntyped(
        staging.ToBeValue__c
      );
    }
  }

  /**
   * @description ProfileUpdate
   */
  public virtual class ProfileUpdate {
    public String id;
    public String action;
    public String status;
    public Integer occurrenceNumber;
    public DateTime submittedTime;
    public TriggeredFrom triggeredFrom;
    public CloudEventModel.UserModel triggeredBy;
    public AccountModel customer;

    /**
     * @description Constructor for ProfileUpdate.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    protected virtual void init(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      this.id = staging.Id;
      this.action = staging.Action__c;
      this.status = staging.Status__c;
      this.occurrenceNumber = (Integer) staging.Occurrence_Number__c;
      this.submittedTime = System.now();
      this.triggeredFrom = new TriggeredFrom(staging, triggerConfig);
      this.customer = new AccountModel(staging.Customer_Name__r);
      this.triggeredBy = new CloudEventModel.UserModel(USER_INFO.getUser());
    }
  }

  /**
   * @description Represents the triggered from details.
   */
  public virtual class TriggeredFrom {
    public String id;
    public String name;
    public String objectType;

    /**
     * @description Constructor for TriggeredFrom.
     * @param staging The staging object containing triggered from details.
     * @param triggerConfig The trigger configuration metadata.
     */
    public TriggeredFrom(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      this.name = staging.TriggeredFrom__c;
      this.objectType = staging.Object_Name__c;
      this.id = String.isNotBlank(triggerConfig.RelatedIdField__c)
        ? (String) staging.get(triggerConfig.RelatedIdField__c)
        : null;
    }
  }
}
