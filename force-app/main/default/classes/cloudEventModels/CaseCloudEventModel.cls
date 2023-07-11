/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for Cases' metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public virtual without sharing class CaseCloudEventModel extends CloudEventModel {
  public CaseCloudEventModel(Case theCase) {
    super();
    ce_source = 'case.salesforce.anzx';
    ce_subject = 'CaseNumber/' + theCase.CaseNumber;
    ce_partitionkey = 'CaseNumber/' + theCase.CaseNumber;
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
    public Datetime disputeClosedDate { get; set; }

    public CaseCloudEventDataModel(Case theCase) {
      this.caseNumber = theCase.CaseNumber;
      this.origin = theCase.Origin;
      this.priority = theCase.Priority;
      this.status = theCase.Status;
      this.subject = theCase.Subject;
      this.disputeClosedDate = theCase.ClosedDate;
    }
  }
}
