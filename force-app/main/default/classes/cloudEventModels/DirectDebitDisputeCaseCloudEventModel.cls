/**
 * @author Hrushikesh Pathak
 * @since  05/2024
 * @description Wrapper Class for Direct Debit Dispute metadata and data
 */
public with sharing class DirectDebitDisputeCaseCloudEventModel extends DisputeCaseCloudEventModelV2 {
  /**
   * @description Constructor
   * @param theCase Case record
   * @param theAccount Account record
   * @param action action if created or updated
   * @param theUser User record
   * @param theOwner Owner record
   */
  public DirectDebitDisputeCaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner
  ) {
    super(theCase, theAccount);
    ce_type =
      System.Label.ANZX_Disputes_event_ce_type_v1beta1 +
      'directdebit.' +
      action;
    ce_dataschema =
      System.Label.ANZX_Disputes_Event_Proto_Data_Schema_v1beta1 +
      '#DirectDebitDispute';
    this.ce_data = new DirectDebitDisputeCaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theUser
    );
  }

  /**
   * @description the model for DD Dispute Case cloud event data part
   */
  public class DirectDebitDisputeCaseCloudEventDataModel extends DisputeCaseCloudEventModelV2.DisputeCaseCloudEventDataModelV2 {
    /**
     * @description crediting account
     */
    public String creditingTraceLine { get; set; }

    /**
     * @description Constructor
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     * @param theUser Owner record
     */
    public DirectDebitDisputeCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      User theUser
    ) {
      super(theCase, theAccount, theOwner, theUser);
      this.creditingTraceLine = theCase.Crediting_Trace_Line__c;
    }
  }
}
