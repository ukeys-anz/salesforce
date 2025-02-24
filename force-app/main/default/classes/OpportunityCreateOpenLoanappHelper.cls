/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group Platform
 * @description Helper class for OpportunityCreateOpenLoanappController
 */
public with sharing class OpportunityCreateOpenLoanappHelper {
  private static final OpportunityCreateOpenLoanappRepository LOANAPP_CTRL_REPOSITORY = (OpportunityCreateOpenLoanappRepository) Lib_InstanceProvider.forType(
    OpportunityCreateOpenLoanappRepository.class
  );

  private static final Map<String, String> MAP_CUSTOMER_NEEDS_TO_LENDING_PURPOSE = new Map<String, String>{
    'Home Loan - Bridging Finance' => 'RBA_LENDING_PURPOSE_FURTHER_ADVANCE',
    'Home Loan - Refinance' => 'RBA_LENDING_PURPOSE_REFINANCE',
    'Home Loan - Refinance + Purchase' => 'RBA_LENDING_PURPOSE_REFINANCE',
    'Home Loan - Construction' => 'RBA_LENDING_PURPOSE_CONSTRUCTION',
    'Home Loan - Purchase' => 'RBA_LENDING_PURPOSE_PURCHASE_EXISTING_DWELLING',
    'Home Loan - Other' => 'RBA_LENDING_PURPOSE_PURCHASE_OTHER'
  };

  /**
   * @description create Loanapp request body
   * @param opp Opportunity
   * @param isOpen boolean to know if this is an Open Loanapp request
   * @return LoanappModel
   */
  public static LoanappModel createOpenLoanAppRequestBody(
    Opportunity opp,
    Boolean isOpen
  ) {
    if (opp == null) {
      return null;
    }
    LoanappModel sm = new LoanappModel();
    //populate application
    LoanappModel.Loan_application app = new LoanappModel.Loan_application();
    app.name = isOpen
      ? 'loanapplications/' + opp.Loanapp_Reference__c
      : ('loanapplications/MLCRM-' +
        (String.isNotBlank(opp.Opportunity_ID__c)
          ? String.valueOf(Integer.valueOf(opp.Opportunity_ID__c))
          : ''));

    //populate target
    sm.loan_application = app;
    sm.target = 'TARGET_SIMPOLOGY';

    //populate request ID
    sm.request_id = UUID.randomUUID().toString();

    //populate branch
    LoanappModel.Branch brn = new LoanappModel.Branch();
    brn.bsb = '01' + opp.Servicing_Branch__c;
    sm.loan_application.branch = brn;

    //populate applicants
    List<LoanappModel.Applicants> applicantList = populateApplicants(opp);
    LoanappModel.Households hh = new LoanappModel.Households();
    hh.applicants = applicantList;
    sm.loan_application.households = new List<LoanappModel.Households>{ hh };

    //populate preferences
    LoanappModel.Preferences pref = new LoanappModel.Preferences();
    pref.expected_settlement_date = getExpectedSettlementDate(opp);
    pref.funds = new List<LoanappModel.Funds>{ getFunds(opp) };
    pref.rba_lending_purpose = MAP_CUSTOMER_NEEDS_TO_LENDING_PURPOSE.get(
      opp.Customer_Needs__c
    ) ?? 'RBA_LENDING_PURPOSE_PURCHASE_OTHER';
    sm.loan_application.preferences = new List<LoanappModel.Preferences>{
      pref
    };

    //populate originator
    LoanappModel.Originator orig = new LoanappModel.Originator();
    orig.tpmi = opp.TPMI__c;
    sm.loan_application.originator = orig;

    //populate properties
    LoanappModel.Properties prop = new LoanappModel.Properties();
    prop.approval_in_principle = opp.AIP_Requested__c ? true : false;
    sm.loan_application.properties = new List<LoanappModel.Properties>{ prop };

    //populate loan writer
    User currUser = LOANAPP_CTRL_REPOSITORY.getCurrentUser();
    LoanappModel.Loan_writer lw = new LoanappModel.Loan_writer();
    lw.lan_id = currUser?.Lan_Id__c;
    lw.uid = generateRandomUid();
    sm.loan_application.loan_writer = lw;
    return sm;
  }

  /**
   * @description get expected settlement date object
   * @param opp Opportunity
   * @return LoanappModel
   */
  @TestVisible
  private static LoanappModel.Expected_settlement_date getExpectedSettlementDate(
    Opportunity opp
  ) {
    LoanappModel.Expected_settlement_date esd = new LoanappModel.Expected_settlement_date();
    LoanappModel.Year year = new LoanappModel.Year();
    LoanappModel.Month month = new LoanappModel.Month();
    LoanappModel.Day day = new LoanappModel.day();
    year.value = opp.Expected_Settlement_Date__c?.year();
    month.value = opp.Expected_Settlement_Date__c?.month();
    day.value = opp.Expected_Settlement_Date__c?.day();
    esd.year = year;
    esd.month = month;
    esd.day = day;
    return esd;
  }

  /**
   * @description get funds object
   * @param opp Opportunity
   * @return LoanappModel
   */
  @TestVisible
  private static LoanappModel.Funds getFunds(Opportunity opp) {
    LoanappModel.Funds fund = new LoanappModel.Funds();
    LoanappModel.Amount amt = new LoanappModel.Amount();
    amt.currency_code = 'AUD';
    amt.units = opp.Amount;
    fund.amount = amt;
    return fund;
  }

  /**
   * @description populate applicants for Simpology payload
   * @param opp Opportunity
   * @return List<LoanappModel.Applicants>
   */
  @TestVisible
  private static List<LoanappModel.Applicants> populateApplicants(
    Opportunity opp
  ) {
    List<LoanappModel.Applicants> applicantList = new List<LoanappModel.Applicants>();
    List<OpportunityContactRole> ocrListReorder = opp.OpportunityContactRoles;
    Integer indexOfCustomer = -1;
    for (Integer i = 0; i < ocrListReorder.size(); i++) {
      if (
        ocrListReorder[i].Source_System_Id__c == opp.Account.Source_System_ID__c
      ) {
        indexOfCustomer = i;
        break;
      }
    }
    if (indexOfCustomer != -1 && ocrListReorder.size() > 1) {
      OpportunityContactRole ocrFirst = ocrListReorder.remove(indexOfCustomer);
      ocrListReorder.add(0, ocrFirst);
    }
    for (OpportunityContactRole ocr : ocrListReorder) {
      LoanappModel.Applicants applicant = new LoanappModel.Applicants();
      applicant.uid = generateRandomUid();
      applicant.type = (ocr.Role == 'Applicant')
        ? 'APPLICANT_TYPE_BORROWER'
        : 'APPLICANT_TYPE_GUARANTOR';
      applicant.external_references = new List<String>{
        'capcisid/' + ocr.Source_System_Id__c
      };
      applicantList.add(applicant);
    }
    return applicantList;
  }

  /**
   * @description get random Uid expected by lex
   * @return String
   */
  public static String generateRandomUid() {
    Blob randomBlobMiddle = Crypto.generateAesKey(128);
    Blob randomBlobEnd = Crypto.generateAesKey(128);
    String middlePart = EncodingUtil.base64Encode(randomBlobMiddle);
    middlePart = middlePart.replace('+', '-')
      .replace('/', '_')
      .replace('=', '')
      .substring(0, 22);
    String endPart = EncodingUtil.base64Encode(randomBlobEnd);
    endPart = endPart.replace('+', '-')
      .replace('/', '_')
      .replace('=', '')
      .substring(0, 15);
    return 'I-' + middlePart + '-' + endPart;
  }
}
