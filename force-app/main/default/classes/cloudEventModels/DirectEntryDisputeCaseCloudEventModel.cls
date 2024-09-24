/**
 * @author Hrushikesh Pathak
 * @since  05/2024
 * @description Wrapper Class for Direct Entry Dispute metadata and data
 */
public with sharing class DirectEntryDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public DirectEntryDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'directentry.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#DirectEntryDispute';
    this.ce_data = new DirectEntryDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for DE Dispute Case cloud event data part
   */
  public class DirectEntryDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description Amount of authorised transaction (TBF)
     */
    public FabricType.FabricMoney authorisedTransactionAmount { get; set; }
    /**
     * @description is this a business customer (TBF)
     */
    public String isBusinessCustomer { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public DirectEntryDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      if (theCase.Amount_Of_Authorised_Transaction__c != null) {
        this.authorisedTransactionAmount = new FabricType.FabricMoney(
          null,
          theCase.Amount_Of_Authorised_Transaction__c
        );
      }
      this.isBusinessCustomer = theCase.Is_this_a_Business_Customer__c;
    }
  }
}
