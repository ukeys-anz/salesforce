/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP Debt
 * @group Models
 * Suppressing public count and too many fields since it is model class
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public class SOPDebt {
  public static final List<String> TYPE_LIST = new List<String>{
    ResidentialLoanApplicationModel.LINE_OF_CREDIT_LIABILITY,
    ResidentialLoanApplicationModel.MARGIN_LOAN,
    ResidentialLoanApplicationModel.OVERDRAFT
  };

  public String id;
  public String sopId;
  public String type;
  public Boolean hasRefinance = false;
  public Boolean showEditDebtBtn;
  public Boolean allowdelete;
  public String name;
  public String termType;
  public String uid;
  public Boolean paidOffAndClosed;
  public Boolean evidenceProvided;
  public Boolean validatedOutstandingBalance;
  public SOPInstitutionalLiability institutionalLiability;
  public SOPAccounts account;
  public List<SOPOwnership> ownership;
  public String createTime;
  public Datetime updateTime;
  public String etag;
  public Boolean showDeleteDebtBtn;
  /**
   * @description return readable value of term type
   */
  public String readableTermType {
    get {
      switch on termType {
        when 'LIABILITY_TERM_TYPE_FIXED' {
          return 'Fixed';
        }
        when 'LIABILITY_TERM_TYPE_VARIABLE' {
          return 'Variable';
        }
        when else {
          //LIABILITY_TERM_TYPE_UNSPECIFIED handled here too
          return 'Unspecified';
        }
      }
    }
  }
  /**
   * @description return the debt type
   */
  public String debtType {
    get {
      String readableType = getReadableType(type);
      if (
        readableType == ResidentialLoanApplicationModel.LEASE_HIRE_PURCHASE_TYPE
      ) {
        readableType = ResidentialLoanApplicationModel.LEASE_HIRE_PURCHASE_LABEL;
      }
      return readableType;
    }
  }

  public List<String> sources;
  /**
   * @description return the source type
   */
  public String sourceType {
    get {
      if (!sources.isEmpty()) {
        if (sources[0] == ResidentialLoanApplicationModel.LIABILITY_ANZ) {
          return ResidentialLoanApplicationModel.SAVINGS_ANZ;
        }
        if (sources[0] == ResidentialLoanApplicationModel.LIABILITY_BUREAU) {
          return ResidentialLoanApplicationModel.CREDIT_BUREAU;
        }
        if (sources[0] == ResidentialLoanApplicationModel.LIABILITY_MANUAL) {
          return ResidentialLoanApplicationModel.MANUAL;
        }
      }
      return ResidentialLoanApplicationModel.OTHER;
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
  /**
   * @description return update time in the expected format
   */
  public String updateTimeStr {
    get {
      return BOHService.getFormatedDate(updateTime);
    }
  }
  public String updatedBy;
  public SOPMoney originalOutstandingBalance;
  public SOPMoney outstandingBalance;

  /**
   * @description check if outstandingBalance has a positive or a negative value
   */
  public Boolean isBalanceNegative {
    get {
      if (
        type == ResidentialLoanApplicationModel.OVERDRAFT &&
        outstandingBalance?.units != null &&
        Integer.valueof(outstandingBalance?.units) < 0
      ) {
        return true;
      } else {
        return false;
      }
    }
  }

  /**
   * @description overdraft balance when the source is ANZ
   */
  public String overdraftBalance {
    get {
      if (
        type == ResidentialLoanApplicationModel.OVERDRAFT &&
        outstandingBalance?.units != null &&
        Integer.valueof(outstandingBalance?.units) < 0
      ) {
        return String.valueOf(outstandingBalance.minusValue);
      }
      return '0';
    }
  }
  /**
   * @description return the transformed value of outstandingbalance based on its value from payload
   */
  public String actualOutstandingBalance {
    get {
      if (outstandingBalance != null && outstandingBalance.units != null) {
        return String.valueOf(outstandingBalance.minusValue);
      } else {
        return ResidentialLoanApplicationModel.CREDIT_CARD_UI_MESSAGE;
      }
    }
  }
  public SOPStudentLoan studentLoan;
  public SOPMoney verifiedOutstandingBalance;

  /**
   * @description return the ownership size
   */
  public Integer ownershipSize {
    get {
      return this.ownership.size();
    }
  }

  /**
   * @description return the owner name of the debt
   */
  public string ownerName {
    get {
      if (this.ownership.size() > 1) {
        return ResidentialLoanApplicationModel.JOINT_ACCOUNT;
      }
      if (Integer.valueOf(this.ownership[0].proportion.value) == 50) {
        return this.ownership[0].ownerName +
          ResidentialLoanApplicationModel.SOMEONE_ELSE;
      }
      return this.ownership[0].ownerName;
    }
  }

  /**
   * @description return the owner name of the debt in case of joint (For Student loan, Buy now Pay later Facility
   * and Credit card)
   */
  public String jointOwnerName {
    get {
      if (this.ownership.size() == 1) {
        return this.ownership[0].ownerName;
      }
      if (this.ownership[0].ownerName != null) {
        return this.ownership[0].ownerName;
      }
      return this.ownership[1].ownerName;
    }
  }

  /**
   * @description return the paymentType
   */
  public string paymentType {
    get {
      if (this.debtType == ResidentialLoanApplicationModel.BNPL_FACILITY) {
        return ResidentialLoanApplicationModel.BNPL_FACILITY_TYPE;
      } else if (this.debtType == ResidentialLoanApplicationModel.BNPL_LOAN) {
        return ResidentialLoanApplicationModel.BNPL_LOAN_TYPE;
      }
      return '';
    }
  }

  /**
   * @description Class to compare OutstandingBalance where the debt utilises balance
   */
  public class OutstandingBalanceCompare implements Comparator<SOPDebt> {
    /**
     * @description compare Debts by outstanding balance
     * @param debt1 SOPDebt to compare
     * @param debt2 Other SOPDebt to compare
     * @return `Integer`
     */
    public Integer compare(SOPDebt debt1, SOPDebt debt2) {
      try {
        if (
          (TYPE_LIST.contains(debt1.type) && TYPE_LIST.contains(debt2.type)) ||
          debt1.outstandingBalance?.minusValue == null &&
          debt2.outstandingBalance?.minusValue == null
        ) {
          return 0;
        }

        if (
          debt1.outstandingBalance.minusValue >
          debt2.outstandingBalance.minusValue
        ) {
          return 1;
        }
        return -1;
      } catch (Exception e) {
        Logger.error(e.getMessage());
        Logger.saveLog();
      }

      return 0;
    }
  }

  /**
   * @description Class to compare debts by limit amount where the debt utilises credit
   */
  public class InstitutionalLiabilityCompare implements Comparator<SOPDebt> {
    /**
     * @description compare debts by limit amount
     * @param debt1 SOPDebt to compare
     * @param debt2 Other SOPDebt to compare
     * @return `Integer`
     */
    public Integer compare(SOPDebt debt1, SOPDebt debt2) {
      try {
        if (
          (!TYPE_LIST.contains(debt1.type) &&
          !TYPE_LIST.contains(debt2.type)) ||
          (debt1.institutionalLiability?.limitAmount?.value == null &&
          debt2.institutionalLiability?.limitAmount?.value == null)
        ) {
          return 0;
        }

        if (
          debt1.institutionalLiability?.limitAmount?.value <
          debt2.institutionalLiability?.limitAmount?.value
        ) {
          return 1;
        }
        return -1;
      } catch (Exception e) {
        Logger.error(e.getMessage());
        Logger.saveLog();
      }

      return 0;
    }
  }
}
