/**
 * @author Ashwin Mohan
 * @since  May 2025
 * @description Create ANZ Plus Loanapp JSON request model wrapper.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public class ANZPlusLoanAppModel {
  public LoanApplication loanApplication;
  public String requestId;
  public String target;

  /**
   * @description model for LoanApplication
   */
  public class LoanApplication {
    public LoanWriter loanWriter;
    public List<String> external_references;
    public Originator originator;
    public String OCVId;
  }

  /**
   * @description model for Originator
   */
  public class Originator {
    public String sao;
    public String tpmi;
  }

  /**
   * @description model for LoanWriter
   */
  public class LoanWriter {
    public String lanId;
  }

  /**
   * @description parameterised constructor for ANZPlusLoanAppModel
   * @param oppRecord Opportuniy record
   * @param ut User Terriitory record
   */
  public ANZPlusLoanAppModel(Opportunity oppRecord, User_Territory__c ut) {
    if (oppRecord == null) {
      return;
    }

    LoanWriter lwDetail = new LoanWriter();
    lwDetail.lanId = oppRecord.Owner.Lan_Id__c;

    Originator origDetail = new Originator();
    origDetail.sao = ut?.SAO__c;
    origDetail.tpmi = oppRecord.TPMI__c;

    LoanApplication laDetail = new LoanApplication();
    laDetail.external_references = new List<String>{
      'opportunity/' + oppRecord.Opportunity_Id__c
    };
    laDetail.loanWriter = lwDetail;
    laDetail.originator = origDetail;
    laDetail.OCVId = oppRecord.Account.OCV_ID__c;

    this.loanApplication = laDetail;
    this.requestId = UUID.randomUUID().toString();
    this.target = 'TARGET_ANZ_PLUS';
  }
}
