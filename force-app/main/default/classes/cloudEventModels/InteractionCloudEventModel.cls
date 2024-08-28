/**
 * @author       : Advait Yermalkar
 * @since        : 06/2024
 * @description  : Wrapper Class for Interaction metadata and data
 **/
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList'
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
    public String opportunityId { get; set; }
    public String optionalNotes { get; set; }
    public InteractionModel interactionDetail { get; set; }

    // For Cap Interactions
    public Boolean permanent { get; set; }
    public FabricType.FabricDate expiryDate { get; set; }
    public String comment { get; set; }
    public FinancialAccountModel financialAccount { get; set; }

    // Constructor For General Interaction Data Model
    public InteractionCloudEventDataModel(
      Interaction theInteraction,
      Account theCustomer,
      Opportunity theOpportunity,
      CloudEventModel.UserModel theOwner
    ) {
      this.owner = theOwner;
      this.customer = new AccountModel(theCustomer);

      this.interactionDetail = new InteractionModel(theInteraction);
      this.opportunityId = theOpportunity?.opp_Id__c;
      this.optionalNotes = theInteraction?.optional_notes__c;

      this.financialAccount = null;
      this.permanent = null;
      this.expiryDate = null;
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

      this.financialAccount = theFinAccount == null
        ? null
        : new FinancialAccountModel(theFinAccount);
      this.permanent = theInteraction?.permanent__c;
      this.expiryDate = new FabricType.FabricDate(
        theInteraction?.expiry_Date__c
      );
      this.comment = theInteraction?.comment__c;

      this.interactionDetail = null;
      this.opportunityId = null;
      this.optionalNotes = null;
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
    public String accountName { get; set; }
    public String branchCode { get; set; }

    /**
     * @description get an instance of FinancialAccountModel
     * @param theAccount the Account record
     */
    public FinancialAccountModel(FinServ__FinancialAccount__c theAccount) {
      this.accountNumber = theAccount?.FinServ__FinancialAccountNumber__c;
      this.productCode = theAccount?.Product_Code_Display__c;
      this.accountName = theAccount?.Name;
      this.branchCode = theAccount?.Branch_Code__c;
    }
  }

  /**
   * @description Inner Wrapper Class for the Interaction data
   */
  public class InteractionModel {
    public String type { get; set; }
    public String name { get; set; }
    public String interactionNumber { get; set; }
    public String category { get; set; }
    public String startTime { get; set; }

    /**
     * @description get an instance of FinancialAccountModel
     * @param theInteraction the Account record
     */
    public InteractionModel(Interaction theInteraction) {
      this.type = theInteraction?.interactionType;
      this.name = theInteraction?.name;
      this.interactionNumber = theInteraction?.interaction_Auto_Number__c;
      this.category = theInteraction?.category__c;
      this.startTime = theInteraction
        ?.startTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    }
  }
}
