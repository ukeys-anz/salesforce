/**
 * @author       : Advait Yermalkar
 * @since        : 06/2024
 * @description  : Wrapper Class for Interaction metadata and data
 **/
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList ,PMD.PropertyNamingConventions'
)
public without sharing class InteractionCloudEventModel extends CloudEventModel {
  public static final String INTERACTION_CE_SOURCE = 'com.anzx.salesforce.interaction.v1alpha1';
  /**
   * @description constructor for InteractionCloudEventModel
   * @param theInteraction
   * @param theDataModel takes either a cap data model or general data model
   * @param systemdata
   * @param actionCode
   **/
  public InteractionCloudEventModel(
    Interaction theInteraction,
    InteractionCloudEventDataModel theDataModel,
    CloudEventModel.CloudEventSystemModel systemdata,
    String actionCode
  ) {
    super();
    this.ce_subject =
      'InteractionNumber/' + theInteraction.Interaction_Auto_Number__c;
    this.ce_partitionkey =
      'InteractionNumber/' + theInteraction.Interaction_Auto_Number__c;
    this.systemData = systemdata;
    this.ce_source = INTERACTION_CE_SOURCE;
    this.ce_type =
      (theInteraction.category__c == CCRMConstants.INTER_CAT_CAPDIARYCOMMENTS
        ? System.Label.CCRM_CAP_DAIRY_EVENT_CE_TYPE
        : System.Label.CCRM_INTERACTION_EVENT_CE_TYPE) +
      actionCode.toLowerCase();
    this.ce_data = theDataModel;
  }

  /**
   * @description the model for Interaction cloud event data part
   */
  public virtual class InteractionCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    public CloudEventModel.UserModel owner { get; set; }
    public AccountModel customer { get; set; }

    // For General Interaction
    public String opportunity_id { get; set; }
    public String optional_notes { get; set; }
    public InteractionModel interaction_detail { get; set; }

    // For Cap Interactions
    public Boolean permanent { get; set; }
    public String expiry_date { get; set; }
    public String comment { get; set; }
    public FinancialAccountModel financial_account { get; set; }

    // Constructor For General Interaction Data Model
    public InteractionCloudEventDataModel(
      Interaction theInteraction,
      Account theCustomer,
      Opportunity theOpportunity,
      CloudEventModel.UserModel theOwner
    ) {
      this.owner = theOwner;
      this.customer = new AccountModel(theCustomer);

      this.interaction_detail = new InteractionModel(theInteraction);
      this.opportunity_id = theOpportunity?.Opp_Id__c;
      this.optional_notes = theInteraction?.optional_notes__c;

      this.financial_account = null;
      this.permanent = null;
      this.expiry_date = null;
      this.comment = null;
    }

    // Constructor For Cap Diary Comments Data Model
    public InteractionCloudEventDataModel(
      Interaction theInteraction,
      Account theCustomer,
      FinServ__FinancialAccount__c theFinAccount,
      CloudEventModel.UserModel theOwner
    ) {
      this.owner = theOwner;
      this.customer = new AccountModel(theCustomer);

      this.financial_account = theFinAccount == null
        ? null
        : new FinancialAccountModel(theFinAccount);
      this.permanent = theInteraction?.Permanent__c;
      this.expiry_date = String.valueOf(theInteraction?.Expiry_Date__c);
      this.comment = theInteraction?.Comment__c;

      this.interaction_detail = null;
      this.opportunity_id = null;
      this.optional_notes = null;
    }
  }

  /**
   * @description Inner Wrapper Class for the account data
   */
  public class AccountModel {
    public String sourceSystem { get; set; }
    public String sourceSystemId { get; set; }
    public String name { get; set; }
    public String ocvId { get; set; }

    /**
     * @description get an instance of AccountModel
     * @param theCustomer the Account record
     */
    public AccountModel(Account theCustomer) {
      this.name = theCustomer?.name;
      this.sourceSystem = theCustomer?.Source_System_Name__c;
      this.sourceSystemId = theCustomer?.Source_System_ID__c;
      this.ocvId = theCustomer?.OCV_ID__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the Financial account data
   */
  public class FinancialAccountModel {
    public String accountNumber { get; set; }
    public String productCode { get; set; }
    public String name { get; set; }
    public String branchCode { get; set; }

    /**
     * @description get an instance of FinancialAccountModel
     * @param theAccount the Account record
     */
    public FinancialAccountModel(FinServ__FinancialAccount__c theAccount) {
      this.accountNumber = theAccount?.FinServ__FinancialAccountNumber__c;
      this.productCode = theAccount?.Product_Code_Display__c;
      this.name = theAccount?.name;
      this.branchCode = theAccount?.Branch_Code__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the Interaction data
   */
  public class InteractionModel {
    public String type { get; set; }
    public String name { get; set; }
    public String interaction_number { get; set; }
    public String category { get; set; }
    public String startTime { get; set; }

    /**
     * @description get an instance of FinancialAccountModel
     * @param theInteraction the Account record
     */
    public InteractionModel(Interaction theInteraction) {
      this.type = theInteraction?.InteractionType;
      this.name = theInteraction?.Name;
      this.interaction_number = theInteraction?.Interaction_Auto_Number__c;
      this.category = theInteraction?.Category__c;
      this.startTime = String.valueOf(theInteraction?.StartTime);
    }
  }
}
