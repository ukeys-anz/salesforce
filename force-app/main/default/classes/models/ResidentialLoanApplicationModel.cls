/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description model for Statement of position
 * @group Models
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveClassLength'
)
public with sharing class ResidentialLoanApplicationModel extends CalloutModel {
  public SOPAssetSummary assetsSummary;
  public SOPDebtSummary liabilitiesSummary;
  public SOPExpenseSummary monthlyExpensesSummary;
  public SOPIncomeSummary incomesSummary;
  public static Map<String, String> employeeIdToPartyIdMap;
  public SOPModel sop;
  public static final String JOINT_ACCOUNT = 'Joint';
  public static Map<String, Account> partyIdToAccountMap;
  public static Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap;
  public List<SOPExpenseNode> expenseNodes;
  public static String currentSopId;
  public Boolean hasError = false;
  public Map<String, SOPExpense> expenseMap;
  public static final String OVERTIME_INCOME = 'INCOME_TYPE_OVERTIME';
  public static final String BASE_INCOME = 'INCOME_TYPE_BASE_SALARY';
  public static final String SALARY_WAGES_INCOME = 'INCOME_TYPE_SALARY_WAGES';
  public static final String COMMISSION_INCOME = 'INCOME_TYPE_COMMISSION';
  public static final String BONUS_INCOME = 'INCOME_TYPE_BONUS';
  public static final String VERIFICATION_METHOD = 'VERIFICATION_METHOD_UNSPECIFIED';
  public static final String UNSPECIFIED = 'UNSPECIFIED';
  public static final String NOT_SPECIFIED = 'Not Specified';
  public static final String ASSET_TYPE_SHARES = 'ASSET_TYPE_SHARES';
  public static final String ASSET_TYPE_HOME_CONTENTS = 'ASSET_TYPE_HOME_CONTENTS';
  public static final String ASSET_TYPE_OTHER = 'ASSET_TYPE_OTHER';
  public static final String ASSET_TYPE_VEHICLE = 'ASSET_TYPE_VEHICLE';
  public static final String ASSET_TYPE_SUPER = 'ASSET_TYPE_SUPER';
  public static final String ASSET_TYPE_BANK_ACCOUNT = 'ASSET_TYPE_BANK_ACCOUNT';
  public static final String SAVINGS_ANZ = 'ANZ';
  public static final String LIABILITY_ANZ = 'LIABILITY_SOURCE_TYPE_ANZ';
  public static final String SAVINGS_ANZ_PLUS = 'ANZ Plus';
  public static final String ASSET_TYPE_CASH = 'ASSET_TYPE_CASH';
  public static final String ASSET_TYPE_PROPERTY = 'ASSET_TYPE_PROPERTY';
  public static final String ASSET_TYPE_VERIFICATION = 'VERIFICATION_METHOD_DOCUMENT';
  public static final String INCOME_TRANSACTION_VERIFICATION = 'VERIFICATION_METHOD_TRANSACTIONS';
  public static final String INCOME_SOURCE_MANUAL = 'Manual';
  public static final String INCOME_SOURCE_TRANSACTIONS = 'Transactions';
  public static final String INCOME_GROSS = 'INCOME_AMOUNT_TYPE_GROSS';
  public static final String INCOME_NET = 'INCOME_AMOUNT_TYPE_NET';
  public static final String Y = 'Yes';
  public static final String N = 'No';
  public static final String BEFORE_TAX = 'Before Tax';
  public static final String AFTER_TAX = 'After Tax';
  public static final String CREDIT_BUREAU = 'Credit Bureau';
  public static final String LIABILITY_BUREAU = 'LIABILITY_SOURCE_TYPE_BUREAU';
  public static final String MANUAL = 'Manual';
  public static final String LIABILITY_MANUAL = 'LIABILITY_SOURCE_TYPE_MANUAL';
  public static final String OTHER = 'Other';
  public static final String LEASE_HIRE_PURCHASE_TYPE = 'Lease Hire Purchase';
  public static final String LEASE_HIRE_PURCHASE_LABEL = 'Lease/Hire Purchase';
  public static final String CREDIT_CARD_UI_MESSAGE = 'To be provided';
  public static final String OVERDRAFT = 'LIABILITY_TYPE_OVERDRAFT';
  public static final String HOME_LOAN = 'LIABILITY_TYPE_HOME_LOAN';
  public static final String OTHER_LOAN_LIABILITY = 'LIABILITY_TYPE_OTHER_LOAN';
  public static final String LEASE_HIRE = 'LIABILITY_TYPE_LEASE_HIRE_PURCHASE';
  public static final String VEHICLE_LOAN = 'LIABILITY_TYPE_VEHICLE_LOAN';
  public static final String STUDENT_LOAN = 'LIABILITY_TYPE_STUDENT_LOAN';
  public static final String CREDIT_CARD_LIABILITY = 'LIABILITY_TYPE_CREDIT_CARD';
  public static final String LINE_OF_CREDIT_LIABILITY = 'LIABILITY_TYPE_LINE_OF_CREDIT';
  public static final String MARGIN_LOAN = 'LIABILITY_TYPE_MARGIN_LOAN';
  public static final String OTHER_LIABILITY = 'LIABILITY_TYPE_OTHER_LIABILITY';
  public static final String PERSONAL_LOAN = 'LIABILITY_TYPE_PERSONAL_LOAN';
  public static final String PROPERTY_LOAN = 'LIABILITY_TYPE_PROPERTY_LOAN'; //property exclude home
  public static final String UNSPECIFIED_LIABILITY = 'LIABILITY_TYPE_UNSPECIFIED';
  public static final String SOMEONE_ELSE = ' & someone else';

  //BNPL
  public static final String BNPL_FACILITY = 'Bpl Facility';
  public static final String BNPL_FACILITY_TYPE = 'Spend Limit';
  public static final String BNPL_LOAN = 'Bpl Loan';
  public static final String BNPL_LOAN_TYPE = 'Fixed Amount';
  public static final String BPL_FACILITY = 'LIABILITY_TYPE_BPL_FACILITY';
  public static final String BPL_LIABILITY = 'LIABILITY_TYPE_BPL_LOAN';
  public static final String BUREAU_STATE_COMPLETE = 'LOAD_BUREAU_LIABILITIES_STATE_COMPLETE';

  public Boolean showAddIncomeBtn;
  public Boolean showEditExpenseBtn;

  /**
   * @description return the debt size attribute to display no debt message on flexcard.
   */
  public Integer debtSize {
    get {
      return liabilitiesSummary.liabilities.size();
    }
  }

  /**
   * @description return the sources size attribute to display no debt message on flexcard.
   */
  public Integer sourceSize {
    get {
      return liabilitiesSummary.sources.size();
    }
  }

  /**
   * @description return the boolean value to check if consent received.
   */
  public boolean consentReceived {
    get {
      boolean value = true;
      for (SOPDebtSources source : liabilitiesSummary.sources) {
        if (source.loadBureauLiabilitiesState != BUREAU_STATE_COMPLETE) {
          return false;
        }
      }
      return true;
    }
  }
  /**
   * @description return the liability source size attribute to display finance and savings flexcard.
   */
  public Integer liabilitySourceSize {
    get {
      return null;
    }
  }
  /**
   * @description initialize the maps
   */
  public void initMaps() {
    initPartyIdToAccountMap();
  }

  /**
   * @description initialize the account Map
   */
  public void initPartyIdToAccountMap() {
    if (ResidentialLoanApplicationModel.partyIdToAccountMap != null) {
      return;
    }
    Map<String, String> partyToOcvMap = new Map<String, String>();
    Map<String, Account> accOcvMap = new Map<String, Account>();
    Set<SOPOwnership> ownershipSet = new Set<SOPOwnership>();
    for (SOPParty party : sop.parties) {
      partyToOcvMap.put(party.id, party.ocvId);
    }

    Set<String> ocvIdSet = new Set<String>();
    if (assetsSummary != null) {
      for (SOPAsset asset : assetsSummary.assets) {
        if (asset.ownership != null) {
          for (SOPOwnership owner : asset.ownership) {
            ocvIdSet.add(partyToOcvMap.get(owner.partyId));
          }
        }
      }
    }
    for (SOPDebt debt : liabilitiesSummary?.liabilities) {
      if (debt.ownership == null) {
        continue;
      }
      ownershipSet.addAll(debt.ownership);
    }

    for (SOPOwnership owner : ownershipSet) {
      ocvIdSet.add(partyToOcvMap.get(owner.partyId));
    }

    for (SOPIncome income : incomesSummary.incomes) {
      ocvIdSet.add(partyToOcvMap.get(income.employment.partyId));
    }

    List<Account> accList = [
      SELECT FirstName, ocv_id__c
      FROM Account
      WHERE ocv_id__c IN :ocvIdSet
    ];
    ResidentialLoanApplicationModel.partyIdToAccountMap = new Map<String, Account>();
    for (Account acc : accList) {
      accOcvMap.put(acc.ocv_id__c, acc);
    }
    for (String partyId : partyToOcvMap.keySet()) {
      ResidentialLoanApplicationModel.partyIdToAccountMap.put(
        partyId,
        accOcvMap.get(partyToOcvMap.get(partyId))
      );
    }
    ResidentialLoanApplicationModel.currentSopId = this.sop.name; // keep the sop Id for later usage
  }

  private Map<String, Expense_Control__c> getExpenseControlMap(
    Set<String> expenseCodeSet
  ) {
    Map<String, Expense_Control__c> expenseControlMap = new Map<String, Expense_Control__c>();
    for (Expense_Control__c ec : [
      SELECT Id, Justification_Code__c, Justification_Description__c
      FROM Expense_Control__c
      WHERE Justification_Code__c IN :expenseCodeSet
    ]) {
      expenseControlMap.put(ec.Justification_Code__c, ec);
    }
    return expenseControlMap;
  }

  /**
   * @description organize expense nodes into a tree structure
   */
  public void organizeExpenseNodes() {
    expenseMap = new Map<String, SOPExpense>();
    Set<String> expenseCodeSet = new Set<String>();
    for (SOPExpense expense : monthlyExpensesSummary.monthlyExpenses) {
      expenseMap.put(expense.categoryName.replaceAll('&', 'and'), expense);
      if (String.isNotBlank(expense.justificationCode)) {
        expenseCodeSet.add(expense.justificationCode);
      }
    }
    Map<String, Expense_Control__c> expenseControlMap = getExpenseControlMap(
      expenseCodeSet
    );

    for (String cateName : expenseMap.keySet()) {
      SOPExpense exp = expenseMap.get(cateName);

      if (expenseControlMap.get(exp.justificationCode) != null) {
        exp.reason = expenseControlMap.get(exp.justificationCode)
          .Justification_Description__c;
      } else {
        exp.reason = '';
      }

      exp.warningReason = exp.reason;
      if (exp.warningReason == 'Other') {
        exp.warningReason += ' - ' + exp.otherJustificationText;
      }

      if (
        exp.control ==
        BOHConstants.EXPENSE_CONTROL.EXPENSE_CONTROL_WARNING.name() &&
        exp.review ==
        BOHConstants.EXPENSE_REVIEW.EXPENSE_REVIEW_COMPLETED.name()
      ) {
        exp.showWarningMessage = true;
        exp.warningMessage = BOHConstants.BIT_LOW_WARNING;
      } else if (
        exp.control ==
        BOHConstants.EXPENSE_CONTROL.EXPENSE_CONTROL_BREACHED.name() &&
        exp.review == BOHConstants.EXPENSE_REVIEW.EXPENSE_REVIEW_REQUIRED.name()
      ) {
        exp.showWarningMessage = true;
        exp.showWarningIcon = true;
        exp.hasReason = false;
        exp.warningMessage = BOHConstants.LOW_WARNING;
        if (String.isNotBlank(exp.expenseParent)) {
          // L2 or L3, Always under Essentials
          expenseMap.get(BOHConstants.EXPENSE_ESSENTIALS)
            .showWarningIcon = true;
        }
      } else if (
        exp.control ==
        BOHConstants.EXPENSE_CONTROL.EXPENSE_CONTROL_JUSTIFIED.name() &&
        exp.review ==
        BOHConstants.EXPENSE_REVIEW.EXPENSE_REVIEW_COMPLETED.name()
      ) {
        exp.showWarningMessage = true;
        exp.showWarningIcon = true;
        exp.hasReason = true;
        exp.warningMessage = BOHConstants.LOW_WARNING;
        if (String.isNotBlank(exp.expenseParent)) {
          // L2 or L3, Always under Essentials
          expenseMap.get(BOHConstants.EXPENSE_ESSENTIALS)
            .showWarningIcon = true;
        }
      }
    }
  }

  /**
   * @description SOPExpenseSummary returns all the sop expense related values and total
   */
  public class SOPExpenseSummary {
    public List<SOPExpense> monthlyExpenses;
    public SOPMoney expensesTotalAmount;
  }

  /**
   * @description SOPASummary returns all the sop asset related values and total assets and savings
   */
  public class SOPAssetSummary {
    /**
     * @description returns cashSavingsExists value to show Cash tile title on Savings flexcard
     */
    public boolean cashSavingsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_CASH) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns propertyAssetsExists value to show Property tile title on Assets flexcard
     */
    public boolean propertyAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_PROPERTY) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsANZPlusExists value to show ANZ Plus tile title on Savings flexcard
     */
    public boolean savingsANZPlusExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset?.account.financialInstitution == SAVINGS_ANZ_PLUS
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsANZExists value to show ANZ tile title on Savings flexcard
     */
    public boolean savingsANZExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset.account.financialInstitution == SAVINGS_ANZ
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns otherInstExists value to show Other Institution tile title on Savings flexcard
     */
    public boolean otherInstExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset?.account.financialInstitution != SAVINGS_ANZ &&
            asset?.account.financialInstitution != SAVINGS_ANZ_PLUS
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns superAssetsExists value to show Super tile title on Assets flexcard
     */
    public boolean superAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_SUPER) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns vehicleAssetsExists value to show Vehicle tile title on Assets flexcard
     */
    public boolean vehicleAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_VEHICLE) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns otherAssetsExists value to show Other tile title on Assets flexcard
     */
    public boolean otherAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_OTHER) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns homeContentsAssetsExists value to show Home Content tile title on Assets flexcard
     */
    public boolean homeContentsAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_HOME_CONTENTS) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns sharesAssetsExists value to show Investment tile title on Assets flexcard
     */
    public boolean sharesAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_SHARES) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsExists value to show the message if none of savings type exists.
     */
    public boolean savingsExists {
      get {
        boolean returnValue = false;
        if (
          this.cashSavingsExists ||
          this.savingsANZPlusExists ||
          this.savingsANZExists ||
          this.otherInstExists
        ) {
          returnValue = true;
        }
        return returnValue;
      }
    }
    public List<SOPAsset> assets;
    public SOPMoney assetsTotalAmount;
    public SOPMoney savingsTotalAmount;
  }

  /**
   * @description SOPIncomeSummary displays all the income related values
   */
  public class SOPIncomeSummary {
    public List<SOPIncome> incomes;
    public SOPMoney incomesTotalAmount;
  }

  /**
   * @description model for general model configuration
   */
  public class SOPModel {
    public List<SOPParty> parties;
    public String name;
    public List<Component> components;

    /**
     * @description sop id of the whole payload
     */
    public String sopId {
      get {
        return this.name;
      }
    }

    /**
     * @description returns party's size
     */
    public Integer partySize {
      get {
        return this.parties.size();
      }
    }

    /**
     * @description return stringified components
     */
    public String componentsToString {
      get {
        return JSON.serialize(this.components);
      }
    }

    /**
     * @description returns first user first name
     */
    public String firstUser {
      get {
        Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          parties[0].id
        );
        if (act != null) {
          return act.FirstName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description returns first user's party id
     */
    public String firstUserPartyId {
      get {
        return parties[0].id;
      }
    }

    /**
     * @description returns second user's first name
     */
    public String secondUser {
      get {
        if (partySize < 2) {
          return null;
        }
        Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          parties[1].id
        );
        if (act != null) {
          return act.FirstName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description returns second user's party id
     */
    public String secondUserPartyId {
      get {
        if (partySize < 2) {
          return null;
        }
        return parties[1].id;
      }
    }
    public List<SOPLiabilitySources> liabilitySources;

    /**
     * @description returns consent as a party
     */
    public Boolean allPartiesConsented {
      get {
        for (SOPParty sop : this.parties) {
          if (sop.confirmedAccountsTime == null) {
            return false;
          }
        }
        return true;
      }
    }
  }

  /**
   * @description model for party
   */
  public class SOPParty {
    public String id;
    public String ocvId;
    public DateTime confirmedAccountsTime;
  }

  /**
   * @description model for component
   */
  public class Component {
    public string type;
    public boolean confirmed;
    public List<Partyconfirmation> partyConfirmations;
  }

  /**
   * @description model for party confirmation
   */
  public class PartyConfirmation {
    public string partyId;
    public string confirmedTime;
  }

  /**
   * @description model for liabilitySources
   */
  public class SOPLiabilitySources {
    public String type;
    public String subType;
    public Datetime retrievedTime;
    public Boolean success;
    public String partyId;
  }

  /**
   * @description Income class for the income node
   */
  public class SOPIncome implements Comparable {
    public String id;
    public String sopId;
    public String uid;
    public List<SOPIncomeDetail> details;
    public SOPEmployment employment;
    public SOPStream stream;
    public string employmentId;
    public Datetime updateTime;
    public String etag;
    public String name;
    public Boolean showEditIncomeBtn;
    public Boolean allowdelete;

    /**
     * @description cache the party list
     */
    public List<String> parties {
      get {
        if (parties == null) {
          parties = new List<String>();
          for (
            String partyId : ResidentialLoanApplicationModel.partyIdToAccountMap.keySet()
          ) {
            parties.add(partyId);
          }
        }

        return parties;
      }
      set {
      }
    }

    /**
     * @description sop id of the whole payload
     */
    public String curSopId {
      get {
        return ResidentialLoanApplicationModel.currentSopId;
      }
    }

    /**
     * @description returns party's size
     */
    public Integer partySize {
      get {
        return this.parties.size();
      }
    }

    /**
     * @description returns first user first name
     */
    public String firstUser {
      get {
        Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          parties[0]
        );
        if (act != null) {
          return act.FirstName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description returns first user's party id
     */
    public String firstUserPartyId {
      get {
        return parties[0];
      }
    }

    /**
     * @description returns second user's first name
     */
    public String secondUser {
      get {
        if (partySize < 2) {
          return null;
        }
        Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          parties[1]
        );
        if (act != null) {
          return act.FirstName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description returns second user's party id
     */
    public String secondUserPartyId {
      get {
        if (partySize < 2) {
          return null;
        }
        return parties[1];
      }
    }

    /**
     * @description return update time in the expected format
     */
    public String updateTimeStr {
      get {
        return BOHService.getFormatedDate(updateTime);
      }
    }
    public SOPverification verification;
    /**
     * @description ownerName for the income card
     */
    public string ownerName {
      get {
        if (employment?.partyId != null) {
          Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
            employment.partyId
          );
          if (act != null) {
            return act.FirstName;
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    }

    /**
     * @description employer name for the income card
     */
    public String employer {
      get {
        if (employment?.businessName != null) {
          return employment.businessName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description startdate for the income card
     */
    public String startDate {
      get {
        if (employment?.startDate != null) {
          return employment.startDate.year +
            '/' +
            employment.startDate.month +
            '/' +
            employment.startDate.day;
        } else {
          return null;
        }
      }
    }

    /**
     * @description startdate for update income card
     */
    public String inputStartDate {
      get {
        if (employment?.startDate != null) {
          String formattedMonth = employment.startDate.month;
          String formattedDay = employment.startDate.day;
          // Add leading zero if month is a single digit
          if (formattedMonth.length() == 1) {
            formattedMonth = '0' + formattedMonth;
          }

          // Add leading zero if day is a single digit
          if (formattedDay.length() == 1) {
            formattedDay = '0' + formattedDay;
          }

          return formattedDay +
            '/' +
            formattedMonth +
            '/' +
            employment.startDate.year;
        } else {
          return null;
        }
      }
    }

    /**
     * @description employment Type for the income card
     */
    public String employmentType {
      get {
        if (employment?.basis != null) {
          String[] words = employment.basis.split('_');
          String result = '';
          words.remove(0);
          words.remove(0);

          for (Integer i = 0; i < words.size(); i++) {
            if (i == 0 && words.size() > 1) {
              result +=
                words[i].substring(0, 1).toUpperCase() +
                words[i].substring(1).toLowerCase() +
                '-';
            } else if (words[i] == UNSPECIFIED) {
              return NOT_SPECIFIED;
            } else {
              result +=
                words[i].substring(0, 1).toUpperCase() +
                words[i].substring(1).toLowerCase() +
                ' ';
            }
          }
          return result.trim();
        }
        return null;
      }
    }

    /**
     * @description condition for transactionIncome
     */
    public Boolean isStreamNull {
      get {
        return stream == null;
      }
    }

    /**
     * @description transactionIncome for the income card
     */
    public SOPStreamDetails transactionIncome {
      get {
        if (stream == null) {
          return null;
        }
        for (SOPStreamDetails detail : stream.details) {
          if (detail?.incomeType == SALARY_WAGES_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description incomeSource for income card
     */
    public String incomeSource {
      get {
        return this.isStreamNull
          ? INCOME_SOURCE_MANUAL
          : INCOME_SOURCE_TRANSACTIONS;
      }
    }

    /**
     * @description baseIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail baseIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (
            detail?.type == BASE_INCOME ||
            detail?.type == SALARY_WAGES_INCOME
          ) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description overTimeIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail overTimeIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == OVERTIME_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description commissionIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail commissionIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == COMMISSION_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description bonusIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail bonusIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == BONUS_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description whether we show overtime section at first place in uupdate dialog
     */
    public Boolean showOvertime {
      get {
        return (overTimeIncome != null);
      }
    }

    /**
     * @description whether we show commission section at first place in uupdate dialog
     */
    public Boolean showCommission {
      get {
        return (commissionIncome != null);
      }
    }

    /**
     * @description whether we show bonus section at first place in uupdate dialog
     */
    public Boolean showBonus {
      get {
        return (bonusIncome != null);
      }
    }

    /**
     * @description compareTo attribute to compare the ownerName for sorting
     * @param compareTo input object
     * @return Integer result which one is greater
     */
    public Integer compareTo(Object compareTo) {
      SOPIncome compareToIncome = (SOPIncome) compareTo;
      Integer returnValue = 0;
      if (
        this.ownerName != null &&
        compareToIncome.ownerName != null &&
        this.ownerName > compareToIncome.ownerName
      ) {
        returnValue = 1;
      } else if (this.ownerName < compareToIncome.ownerName) {
        returnValue = -1;
      }
      return returnValue;
    }

    /**
     * @description income Verified for the income card
     */
    public Boolean incomeVerified {
      get {
        Boolean result = false;
        if (this.verification == null) {
          return result;
        }
        if (
          this.verification.method == ASSET_TYPE_VERIFICATION ||
          (this.incomeSource == INCOME_SOURCE_TRANSACTIONS &&
          this.verification.method == INCOME_TRANSACTION_VERIFICATION)
        ) {
          result = true;
        }

        return result;
      }
    }

    /**
     * @description a static and unchanging value of the income verified
     */
    public String staticIncomeVerified {
      get {
        return incomeVerified ? Y : N;
      }
    }
  }
  /**
   * @description Income detail class
   */

  public class SOPIncomeDetail {
    public String id;
    public String type;
    public String frequency;
    public Integer bonusPayments;
    /**
     *
     * @description income Type
     */
    public String incomeType {
      get {
        String categoryOfIncome;
        if (this.amountType != null && this.amountType == INCOME_GROSS) {
          categoryOfIncome = BEFORE_TAX;
        } else if (this.amountType == INCOME_NET) {
          categoryOfIncome = AFTER_TAX;
        }
        return categoryOfIncome;
      }
    }

    /**
     * @description frequency
     */
    public String readableFrequency {
      get {
        return ResidentialLoanApplicationModel.getReadableFrequency(
          this.frequency
        );
      }
    }

    public SOPMoney amount;
    public String amountType;
  }

  /**
   * @param frequencyProp model frequency attribute
   * @return `Readable String`
   * @description transforms formatted string to readable
   */
  public static String getReadableFrequency(String frequencyProp) {
    if (frequencyProp != null) {
      String result = '';
      String[] words = frequencyProp.split('_');
      words.remove(0);
      words.remove(0);

      for (String word : words) {
        if (word == UNSPECIFIED) {
          result = NOT_SPECIFIED;
        } else {
          result =
            word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase() +
            ' ';
        }
      }
      return result.trim();
    } else {
      return null;
    }
  }

  /**
   * @param json input string to deserialize
   * @return `List of SOP Assets`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static ResidentialLoanApplicationModel parse(String json) {
    ResidentialLoanApplicationModel model = (ResidentialLoanApplicationModel) deserialize(
      json,
      ResidentialLoanApplicationModel.class
    );
    model.initMaps();
    model.organizeExpenseNodes();
    if (model.assetsSummary != null) {
      model.assetsSummary.assets.sort();
    }
    if (model.incomesSummary.incomes != null) {
      model.incomesSummary.incomes.sort();
    }
    if (model.liabilitiesSummary.liabilities != null) {
      SOPDebt.OutstandingBalanceCompare obCompare = new SOPDebt.OutstandingBalanceCompare();
      SOPDebt.InstitutionalLiabilityCompare ilCompare = new SOPDebt.InstitutionalLiabilityCompare();
      model.liabilitiesSummary.liabilities.sort(obCompare);
      model.liabilitiesSummary.liabilities.sort(ilCompare);
    }
    return model;
  }
}