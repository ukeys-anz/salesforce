/**
 * @author Ian Huang
 * @since  12/2024
 * @group Platform
 * @description Financial Account Entity classes
 */
public with sharing class FinancialAccountEntities {
  /**
   * @description FinancialAccount Payload class
   */
  public class FinancialAccountPayload extends ExternalObjectQueryBase.PayloadBase {
    //Summary request payload
    public Set<String> capCustomerIds;
    public Set<String> accounts;
    public String offSet;
    public String pageSize;
    public String nextPageId;
    //Detail request payload
    public String accountNumber;
    public String compositeAccountNumber;
    public String fieldSet;
    public String type;
    public String compositeBalanceHistoryId;
  }

  /**
   * @description abstract FinancialAccount Summary callout response class
   */
  public virtual class FinancialAccountCalloutRequest extends ExternalObjectQueryBase.ExternalObjectCalloutRequestBase {
    public String productCategory;
    public Set<String> accounts = new Set<String>();
    public QueryModeEnum queryMode;
    /**
     * @description abstract FinancialAccount callout response class
     * @param queryContext DataSource QueryContext
     * @param queryMode Query Mode Enum
     * @param productCategory productCategory
     * @param fieldSet fieldSet
     * @param accountNumbers accountNumbers
     */
    public FinancialAccountCalloutRequest(
      DataSource.QueryContext queryContext,
      QueryModeEnum queryMode,
      String productCategory,
      String fieldSet,
      Set<String> accountNumbers
    ) {
      super(queryContext, queryMode);
      this.productCategory = productCategory;
      this.payload = new FinancialAccountPayload();
      if (this.isSummaryRequest()) {
        ((FinancialAccountPayload) this.payload).offSet = String.valueOf(
          queryContext.offSet
        );
        ((FinancialAccountPayload) this.payload).pageSize = String.valueOf(
          queryContext.maxResults
        );
        ((FinancialAccountPayload) this.payload).fieldSet = fieldSet;
        if (accountNumbers != null) {
          ((FinancialAccountPayload) this.payload).accounts = new Set<String>(
            accountNumbers
          );
        }
      }
    }
    public override String getEndpoint() {
      return this.productCategory + '-accounts';
    }
  }

  /**
   * @description abstract FinancialAccount callout response class
   */
  public abstract class FinancialAccountCalloutResponse extends ExternalObjectQueryBase.ExternalObjectCalloutResponse {
    public String customerId;
    public List<FinancialAccountModelBase> accounts;
    public Customer customer;
  }
}
