/**
 * @author Prasanjeet Dutta
 * @since jan 12 2026
 * @description Builds a consolidated Account Snapshot for Prompt Builder consumers.
 *              This class queries multiple ANZx CCRM external objects by Account External Id
 *              and summarizes active/open items into category rows with counts and detail lines.
 *              The output is serialized JSON suitable for LLM prompts or UI rendering.
 *
 *              Security:
 *              - Class runs with sharing to respect org sharing rules.
 *              - Repository layer is expected to enforce field-level security as appropriate.
 *
 *              Design:
 *              - Implements a Builder pattern per account category (Deposit, Loan, etc.).
 *              - Uses an internal context to compute date windows (today, +30, +180).
 *              - Filters records by normalized status: 'active', 'open', 'complete activated'.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMAgentAccountSnapshot {
  private static final CCRMAgentAccountSnapshotRepository REPO = (CCRMAgentAccountSnapshotRepository) Lib_InstanceProvider.forType(
    CCRMAgentAccountSnapshotRepository.class
  );

  private static final String CAT_DEPOSIT = 'Deposit Accounts';
  private static final String CAT_LOAN = 'Loan Accounts';
  private static final String CAT_TERM_DEPOSIT = 'Term Deposits';
  private static final String CAT_CREDIT_CARD = 'Credit Cards';
  private static final String CAT_PORTFOLIO_LOANS = 'Portfolio of Loans';
  private static final String CAT_OTHER_LIMITS = 'Other Limits and Liabilities';
  private static final String CAT_COMMERCIAL_BILLS = 'Commercial Bills';
  private static final String CAT_INDEMNITY = 'Indemnity Guarantees';
  private static final String CAT_AMBIT = 'Asset Finance AMBIT Contract';
  private static final String CAT_ELS = 'Asset Finance (ELS)';

  private static final String RL_DEPOSIT = 'Deposit_Account__r';
  private static final String RL_LOAN = 'Loan_Account__r';
  private static final String RL_TERM_DEPOSIT = 'Term_Deposits__r';
  private static final String RL_CREDIT_CARD = 'Credit_Cards__r';
  private static final String RL_PORTFOLIO_LOANS = 'Portfolio_Of_Loans__r';
  private static final String RL_OTHER_LIMITS = 'Other_Limits_and_Liabilities__r';
  private static final String RL_COMMERCIAL_BILLS = 'Commercial_Bills__r';
  private static final String RL_INDEMNITY = 'Indemnity_Guarantees__r';
  private static final String RL_AMBIT = 'Asset_Finance_AMBIT_Contract__r';
  private static final String RL_ELS = 'Asset_Finances_ELS__r';
  private static final Set<String> ACTIVE_OPEN_STATUSES = new Set<String>{
    'active',
    'open',
    'complete activated',
    'approved'
  };

  /**
   * @description Request wrapper for the invocable method.
   *              Pass the Account SObject so we can read External_Id__c.
   */
  public class Request {
    @InvocableVariable(required=true)
    public Account accountObj;
  }

  /**
   * @description Response wrapper for the invocable method containing the JSON snapshot.
   */
  public class Response {
    @InvocableVariable
    public String Prompt;
  }

  /**
   * @description Row structure returned per account category summarizing counts and details.
   */
  public class SnapshotRow {
    @InvocableVariable
    public String accountCategory;
    @InvocableVariable
    public String accountCategoryRelatedListName;
    @InvocableVariable
    public Integer activeOpenCount;
    @InvocableVariable
    public String detailLines;
  }
  /**
   * @description Execution context carrying External Id and precomputed date ranges.
   */
  private class SnapshotContext {
    String externalId;
    Date today;
    Date in30;
    Date in180;

    SnapshotContext(String ext) {
      externalId = ext;
      today = Date.today();
      in30 = today.addDays(30);
      in180 = today.addDays(180);
    }
  }

  /**
   * @description Invocable entry point that generates an Account Snapshot JSON for a given Account.
   * @param requests List<Request> requests from Flow; the first element must contain accountObj with External_Id__c populated.
   * @return List<Response> size 1; Response.Prompt contains JSON array of SnapshotRow objects.
   */
  @InvocableMethod(label='Get Account Snapshot')
  public static List<Response> getSnapshot(List<Request> requests) {
    Response response = new Response();
    String externalId = extractExternalId(requests);

    if (String.isBlank(externalId)) {
      return new List<Response>{ response };
    }

    SnapshotContext ctx = new SnapshotContext(externalId);
    List<SnapshotRow> rows = new List<SnapshotRow>();

    for (SnapshotBuilder builder : snapshotBuilders()) {
      SnapshotRow row = builder.build(ctx);
      if (row != null) {
        rows.add(row);
      }
    }

    response.Prompt = JSON.serializePretty(rows);
    Logger.debug('CCRMAgentAccountSnapshot.getSnapshot: ')
      .setPayload(response.Prompt)
      .save();
    return new List<Response>{ response };
  }

  /**
   * @description Contract for all per-category snapshot builders.
   */
  private interface SnapshotBuilder {
    /**
     * @description Build a SnapshotRow for the provided context or return null if no active/open records.
     * @param ctx SnapshotContext containing externalId and date windows.
     * @return SnapshotRow populated for the category or null when no qualifying records found.
     */
    SnapshotRow build(SnapshotContext ctx);
  }

  /**
   * @description Base builder implementing common flow: fetch -> filter by status -> collect details -> row.
   */
  private abstract class BaseSnapshotBuilder implements SnapshotBuilder {
    /**
     * @description Fetch records for this category by Account External Id.
     * @param externalId String Account External_Id__c value.
     * @return Iterable<SObject> records to evaluate.
     */
    protected abstract Iterable<SObject> fetch(String externalId);

    /**
     * @description Extract status field value from a concrete record.
     * @param record SObject concrete record instance.
     * @return String raw status value to evaluate.
     */
    protected abstract String getStatus(SObject record);

    /**
     * @description Append one or more detail lines for a qualifying record into details.
     * @param record Concrete record instance.
     * @param ctx SnapshotContext including date windows.
     * @param details List<String> to which formatted lines should be added.
     */
    protected abstract void collectDetails(
      SObject record,
      SnapshotContext ctx,
      List<String> details
    );

    /**
     * @description Category display label.
     * @return String category name.
     */
    protected abstract String category();

    /**
     * @description Related list API name on Account used by UI navigation.
     * @return String related list relationship name.
     */
    protected abstract String relatedList();

    /**
     * @description Orchestrates building SnapshotRow for this category.
     * @param ctx SnapshotContext containing externalId and date windows.
     * @return SnapshotRow if any active/open records exist; otherwise null.
     */
    public SnapshotRow build(SnapshotContext ctx) {
      Integer active = 0;
      List<String> details = new List<String>();

      for (SObject record : fetch(ctx.externalId)) {
        if (!isActiveOrOpen(getStatus(record))) {
          continue;
        }

        active++;
        collectDetails(record, ctx, details);
      }

      return active > 0
        ? buildRow(category(), relatedList(), active, details)
        : null;
    }
  }

  /**
   * @description Builder for Deposit Accounts category.
   */
  private class DepositBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchDepositAccountsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Deposit_Account__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Deposit_Account__x a = (Deposit_Account__x) r;

      if (a.Balance_Available__c != null && a.Balance_Available__c < 0) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is overdrawn')
              .build()
          )
        );
      }

      Date expiry = toDate(a.Expiry_Date__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('limit expiring ' + expiry.format())
              .build()
          )
        );
      }

      Date odExpiry = toDate(a.Overdraft_Expiry_Date__c);
      if (isBetween(odExpiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage(
                'Temporary overdraft limit expiring ' + odExpiry.format()
              )
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_DEPOSIT;
    }
    protected override String relatedList() {
      return RL_DEPOSIT;
    }
  }

  /**
   * @description Builder for Loan Accounts category.
   */
  private class LoanBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchLoanAccountsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Loan_Account__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Loan_Account__x a = (Loan_Account__x) r;
      Date expiry = toDate(a.Expires__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is expiring ' + expiry.format())
              .build()
          )
        );
      }
      if (
        a.Repayment_Details_Days_Delinquent__c != null &&
        a.Repayment_Details_Days_Delinquent__c > 3
      ) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('has a delinquent amount')
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_LOAN;
    }
    protected override String relatedList() {
      return RL_LOAN;
    }
  }

  /**
   * @description Builder for Term Deposits category.
   */
  private class TermDepositBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchTermDepositsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Term_Deposit__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Term_Deposit__x a = (Term_Deposit__x) r;
      Date m = toDate(a.Maturity_Date__c);
      if (isBetween(m, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is maturing ' + m.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_TERM_DEPOSIT;
    }
    protected override String relatedList() {
      return RL_TERM_DEPOSIT;
    }
  }

  /**
   * @description Builder for Credit Cards category.
   */
  private class CreditCardBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchCreditCardsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Credit_Card__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Credit_Card__x a = (Credit_Card__x) r;
      if (a.Available_Funds__c != null && a.Available_Funds__c < 0) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is overdrawn')
              .build()
          )
        );
      }
      if (a.Days_Delinquent__c != null && a.Days_Delinquent__c > 0) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('has a delinquent amount')
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_CREDIT_CARD;
    }
    protected override String relatedList() {
      return RL_CREDIT_CARD;
    }
  }

  /**
   * @description Builder for Portfolio of Loans category.
   */
  private class PortfolioLoansBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchPortfolioOfLoansByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Portfolio_Of_Loan__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Portfolio_Of_Loan__x a = (Portfolio_Of_Loan__x) r;
      Date expiry = toDate(a.Expires__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is expiring ' + expiry.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_PORTFOLIO_LOANS;
    }
    protected override String relatedList() {
      return RL_PORTFOLIO_LOANS;
    }
  }

  /**
   * @description Builder for Other Limits and Liabilities category.
   */
  private class OtherLimitsBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchOtherLimitsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Other_Limits_and_Liabilities__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
    }
    protected override String category() {
      return CAT_OTHER_LIMITS;
    }
    protected override String relatedList() {
      return RL_OTHER_LIMITS;
    }
  }

  /**
   * @description Builder for Asset Finance AMBIT Contract category.
   */
  private class AmbitBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchAssetFinanceAmbitByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Asset_Finance_AMBIT_Contract__x) r).Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Asset_Finance_AMBIT_Contract__x a = (Asset_Finance_AMBIT_Contract__x) r;
      if (isBetween(a.Expiry_Date__c, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Contract_Number__c)
              .withName(null)
              .withProduct(a.Product_Name__c)
              .withMessage('is expiring ' + a.Expiry_Date__c.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_AMBIT;
    }
    protected override String relatedList() {
      return RL_AMBIT;
    }
  }

  /**
   * @description Builder for Asset Finance (ELS) category.
   */
  private class ElsBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchAssetFinanceELSByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Asset_Finance_ELS__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Asset_Finance_ELS__x a = (Asset_Finance_ELS__x) r;
      Date expiry = toDate(a.Expires__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(a.Product_Name__c)
              .withMessage('is expiring ' + expiry.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_ELS;
    }
    protected override String relatedList() {
      return RL_ELS;
    }
  }

  /**
   * @description Builder for Commercial Bills category.
   */
  private class CommercialBillsBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchCommercialBillsByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Commercial_Bill__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Commercial_Bill__x a = (Commercial_Bill__x) r;
      Date expiry = toDate(a.Expires__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(null)
              .withMessage('is expiring ' + expiry.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_COMMERCIAL_BILLS;
    }
    protected override String relatedList() {
      return RL_COMMERCIAL_BILLS;
    }
  }

  /**
   * @description Builder for Indemnity Guarantees category.
   */
  private class IndemnityBuilder extends BaseSnapshotBuilder {
    protected override Iterable<SObject> fetch(String ext) {
      return REPO.fetchIndemnityGuaranteesByExternalId(ext);
    }
    protected override String getStatus(SObject r) {
      return ((Indemnity_Guarantee__x) r).Account_Status__c;
    }
    protected override void collectDetails(
      SObject r,
      SnapshotContext ctx,
      List<String> d
    ) {
      Indemnity_Guarantee__x a = (Indemnity_Guarantee__x) r;

      Date expiry = toDate(a.Expiry_Date__c);
      if (isBetween(expiry, ctx.today, ctx.in180)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(null)
              .withMessage('is expiring ' + expiry.format())
              .build()
          )
        );
      }

      List<Facility_Fee__x> feeList = REPO.fetchFacilityFeeNextDueDateByIGExternalId(
        a.ExternalId
      );

      Date feeDue = (feeList != null && !feeList.isEmpty())
        ? toDate(feeList[0].Next_Due_Date__c)
        : null;

      if (isBetween(feeDue, ctx.today, ctx.in30)) {
        d.add(
          line(
            new AccountLineBuilder()
              .withId(a.Id)
              .withNum(a.Account_Number__c)
              .withName(a.Account_Name__c)
              .withProduct(null)
              .withMessage('facility fee due ' + feeDue.format())
              .build()
          )
        );
      }
    }
    protected override String category() {
      return CAT_INDEMNITY;
    }
    protected override String relatedList() {
      return RL_INDEMNITY;
    }
  }

  /**
   * @description Provides the ordered list of category builders used to compose the snapshot.
   * @return List<SnapshotBuilder> sequence of builders.
   */
  private static List<SnapshotBuilder> snapshotBuilders() {
    return new List<SnapshotBuilder>{
      new DepositBuilder(),
      new LoanBuilder(),
      new TermDepositBuilder(),
      new CreditCardBuilder(),
      new PortfolioLoansBuilder(),
      new OtherLimitsBuilder(),
      new AmbitBuilder(),
      new ElsBuilder(),
      new CommercialBillsBuilder(),
      new IndemnityBuilder()
    };
  }

  /**
   * @description Represents a single detail line for an account in the CCRMAgentAccountSnapshot.
   *              Encapsulates the record Id, account number, name, product, and a message describing a condition.
   *              Intended to be constructed via {@link AccountLineBuilder} to avoid long parameter lists.
   */
  public class AccountLine {
    public Id id;
    public String num;
    public String name;
    public String product;
    public String message;

    // Default constructor is package-private
    AccountLine() {
    }
  }

  /**
   * @description Builder class for constructing AccountLine instances.
   *
   */
  public class AccountLineBuilder {
    private AccountLine line = new AccountLine();

    /**
     * @description Sets the Id of the AccountLine record.
     * @param v Id of the record.
     * @return AccountLineBuilder for method chaining.
     */
    public AccountLineBuilder withId(Id v) {
      line.id = v;
      return this;
    }

    /**
     * @description Sets the account number for the AccountLine.
     * @param v Account number string.
     * @return AccountLineBuilder for method chaining.
     */
    public AccountLineBuilder withNum(String v) {
      line.num = v;
      return this;
    }

    /**
     * @description Sets the account name for the AccountLine.
     * @param v Account name string.
     * @return AccountLineBuilder for method chaining.
     */
    public AccountLineBuilder withName(String v) {
      line.name = v;
      return this;
    }

    /**
     * @description Sets the product name for the AccountLine.
     * @param v Product name string.
     * @return AccountLineBuilder for method chaining.
     */
    public AccountLineBuilder withProduct(String v) {
      line.product = v;
      return this;
    }

    /**
     * @description Sets the message or condition description for the AccountLine.
     * @param v Message string.
     * @return AccountLineBuilder for method chaining.
     */
    public AccountLineBuilder withMessage(String v) {
      line.message = v;
      return this;
    }

    /**
     * @description Builds the AccountLine instance after all properties have been set.
     * @return AccountLine fully constructed instance.
     */
    public AccountLine build() {
      return line;
    }
  }

  /**
   * @description Formats a single account detail line into a string suitable for display.
   *              Generates a clickable link to the record and joins fields with ' - '.
   * @param l AccountLine instance containing Id, number, name, product, and message.
   * @return String formatted HTML-safe line combining link, name, product, and message.
   */
  private static String line(AccountLine l) {
    String link =
      '<a href="/' +
      l.id +
      '" target="_blank">' +
      safe(l.num) +
      '</a>';

    return String.join(
      new List<String>{ link, safe(l.name), safe(l.product), l.message },
      ' - '
    );
  }

  /**
   * @description Evaluates if a status value should be considered active/open.
   * @param status String raw status value.
   * @return Boolean true when status matches configured active states.
   */
  private static Boolean isActiveOrOpen(String status) {
    if (String.isBlank(status)) {
      return false;
    }
    String s = status.trim().toLowerCase();
    return ACTIVE_OPEN_STATUSES.contains(s);
  }

  /**
   * @description Checks if a date is within inclusive range.
   * @param d Date to evaluate.
   * @param startDate Date lower bound inclusive.
   * @param endDate Date upper bound inclusive.
   * @return Boolean true if d is non-null and in range.
   */
  private static Boolean isBetween(Date d, Date startDate, Date endDate) {
    return d != null && d >= startDate && d <= endDate;
  }

  /**
   * @description Null-safe string helper.
   * @param v String value or null.
   * @return String empty when null, otherwise original value.
   */
  private static String safe(String v) {
    return v == null ? '' : v;
  }

  /**
   * @description Attempts to parse a date string in ISO (yyyy-MM-dd) or dd/MM/yyyy formats.
   * @param value String date value.
   * @return Date parsed date or null when unparseable.
   */
  public static Date toDate(String value) {
    if (String.isBlank(value)) {
      return null;
    }
    try {
      return Date.valueOf(value);
    } catch (Exception e) {
      Logger.error('Failed to parse as Date', e);
    }
    if (value.contains('/')) {
      List<String> p = value.split('/');
      if (p.size() == 3) {
        return Date.newInstance(
          Integer.valueOf(p[2]),
          Integer.valueOf(p[1]),
          Integer.valueOf(p[0])
        );
      }
    }
    return null;
  }

  /**
   * @description Builds a SnapshotRow DTO.
   * @param cat Category label.
   * @param rl Related list relationship API name.
   * @param c Active/open count.
   * @param d Detail lines collected.
   * @return SnapshotRow populated instance.
   */
  private static SnapshotRow buildRow(
    String cat,
    String rl,
    Integer c,
    List<String> d
  ) {
    SnapshotRow r = new SnapshotRow();
    r.accountCategory = cat;
    r.accountCategoryRelatedListName = rl;
    r.activeOpenCount = c == null ? 0 : c;
    r.detailLines = (d == null || d.isEmpty()) ? '' : String.join(d, '\n');
    return r;
  }

  /**
   * @description Safely extracts External_Id__c from invocable requests.
   * @param requests List<Request> from Flow.
   * @return String External_Id__c or null if unavailable/blank.
   */
  private static String extractExternalId(List<Request> requests) {
    if (requests.isEmpty()) {
      return null;
    }
    if (requests[0].accountObj == null) {
      return null;
    }
    String ext = (String) requests[0].accountObj.get('External_Id__c');
    return String.isBlank(ext) ? null : ext;
  }
}
