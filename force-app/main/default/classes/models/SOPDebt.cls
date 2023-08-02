/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP Debt
 * @group Models
 */
public class SOPDebt {
  public String id;
  public String sopId;
  public String type;
  /**
   * @description return the debt type
   */
  public String debtType {
    get {
      return getReadableType(type);
    }
  }

  public List<String> sources;
  /**
   * @description return the source type
   */
  public String sourceType {
    get {
      if (!sources.isEmpty()) {
        if (sources[0] == 'LIABILITY_SOURCE_TYPE_ANZ') {
          return 'ANZ';
        }
        if (sources[0] == 'LIABILITY_SOURCE_TYPE_BUREAU') {
          return 'Bureau';
        }
      }
      return 'Other';
    }
  }

  /**
   * @description return the readable debt type
   * @param inputStr the input type from json
   * @return String the readable debt type
   */
  public String getReadableType(String inputStr) {
    String[] words = inputStr.split('_');
    String result = '';
    words.remove(0);
    words.remove(0);

    for (String word : words) {
      if (word.equalsIgnoreCase('of')) {
        result += 'of ';
      } else {
        result +=
          word.substring(0, 1).toUpperCase() +
          word.substring(1).toLowerCase() +
          ' ';
      }
    }
    return result.trim();
  }
  public SOPInstitutionalLiability institutionalLiability;
  public SOPAccounts account;
  public List<SOPOwnership> ownership;
  public String createTime;
  public String updateTime;
  public String updatedBy;
  public SOPMoney originalOutstandingBalance;
  public SOPMoney outstandingBalance;
  public SOPStudentLoan studentLoan;

  /**
   * @description return the owner name of the debt
   */
  public string ownerName {
    get {
      if (this.ownership.size() == 1) {
        return this.ownership[0].ownerName;
      }
      return ResidentialLoanApplicationModel.JOINT_ACCOUNT;
    }
  }
}
