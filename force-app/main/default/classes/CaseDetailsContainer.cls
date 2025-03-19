/**
 * @author Aman Gupta
 * @since February 2025
 * @description Model class for UI component
 * @group Models
 * @note ExcessivePublicCount suppressed: FinancialAccModelUpdateResponseCoP consolidates all public methods and attributes.
 */
public class CaseDetailsContainer {
  @AuraEnabled
  public List<CaseDetailsWithCoPStatus> successList;
  @AuraEnabled
  public List<CaseDetailsWithCoPStatus> failureList;

  /**
   * @description CaseDetailsContainer constructor
   */
  public CaseDetailsContainer() {
    this.successList = new List<CaseDetailsWithCoPStatus>();
    this.failureList = new List<CaseDetailsWithCoPStatus>();
  }

  /**
   * @description Represents case details with Confirmation of Payee (CoP) status.
   */
  public class CaseDetailsWithCoPStatus {
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String accountNumber;
    @AuraEnabled
    public String accountType;
    @AuraEnabled
    public String caseCoPStatus;
    @AuraEnabled
    public String caseId;
    @AuraEnabled
    public String caseNumber;
    @AuraEnabled
    public String childCaseNumberUrl;
    @AuraEnabled
    public String requestedByName;
    @AuraEnabled
    public String modifiedByName;
    @AuraEnabled
    public String statusChangeDateTime;
    public List<String> linkedCustomers;
  }
}
