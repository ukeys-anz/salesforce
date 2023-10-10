/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for Cases' metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public virtual without sharing class CaseCloudEventModel extends CloudEventModel {
  public CaseCloudEventModel(Case theCase, Account theAccount) {
    super();
    ce_source = 'case.salesforce.anzx';
    ce_subject = 'CaseNumber/' + theCase.CaseNumber;
    ce_partitionkey = 'CaseNumber/' + theCase.CaseNumber;
    String sourceSystemName = '';
    if (
      theAccount?.Source_System_Name__c != null &&
      theAccount?.Source_System_ID__c != null
    ) {
      sourceSystemName =
        ',' +
        theAccount.Source_System_Name__c.toLowerCase() +
        '/' +
        theAccount?.Source_System_ID__c;
    }
    ce_xtargets = 'ocv/' + theAccount?.OCV_ID__c + sourceSystemName;
  }

  /**
   * @description the model for Case cloud event data part
   */
  public virtual class CaseCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    public String caseNumber { get; set; }
    public String origin { get; set; }
    public String priority { get; set; }
    public String status { get; set; }
    public String subject { get; set; }
    public String description { get; set; }
    public AccountModel customer { get; set; }
    public UserModel owner { get; set; }

    /**
     * @description get an instance of CaseCloudEventDataModel
     * @param theCase the Case record
     * @param theAccount the Account record
     * @param theOwner the User/Group record
     */
    public CaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner
    ) {
      this.caseNumber = theCase.CaseNumber;
      this.origin = theCase.Origin;
      this.priority = theCase.Priority;
      this.status = theCase.Status;
      this.subject = theCase.Subject;
      this.description = theCase.Description;
      this.customer = new AccountModel(theAccount);
      this.owner = theOwner;
    }
  }

  /**
   * @description Inner Wrapper Class for the account data
   */
  public class AccountModel {
    public String ocvId { get; set; }
    public String sourceSystem { get; set; }
    public String sourceSystemId { get; set; }

    /**
     * @description get an instance of AccountModel
     * @param theAccount the Account record
     */
    public AccountModel(Account theAccount) {
      this.ocvId = theAccount?.OCV_ID__c;
      this.sourceSystem = theAccount?.Source_System_Name__c;
      this.sourceSystemId = theAccount?.Source_System_ID__c;
    }
  }
}
