/**
 * @author cruzb
 * @since Nov 2024
 * @description SOP Expense View model
 */
public with sharing class SOPExpenseEditModel {
  /**
   * @description Represents for sop application
   */
  @AuraEnabled
  public String parent { get; set; }

  /**
   * @description List of monthly expenses
   */
  @AuraEnabled
  public List<SOPMonthlyExpenseEditModel> monthlyExpenses { get; set; }

  /**
   * @description MonthlyExpense base class for expense list
   */
  public class SOPMonthlyExpenseEditModel {
    /**
     * @description Name of the expense
     */
    @AuraEnabled
    public String name { get; set; }

    /**
     * @description Unique identifier for the expense
     */
    @AuraEnabled
    public String uid { get; set; }

    /**
     * @description Category ID of the expense
     */
    @AuraEnabled
    public String categoryId { get; set; }

    /**
     * @description Parent expense identifier
     */
    @AuraEnabled
    public String expenseParent { get; set; }

    /**
     * @description Name of the category
     */
    @AuraEnabled
    public String categoryName { get; set; }

    /**
     * @description Control information for the expense
     */
    @AuraEnabled
    public String control { get; set; }

    /**
     * @description Review status of the expense
     */
    @AuraEnabled
    public String review { get; set; }

    /**
     * @description Stated monthly average amount for the expense
     */
    @AuraEnabled
    public FabricType.Fabric_money statedMonthlyAverageAmount { get; set; }

    /**
     * @description Compute statedMonthlyAverageAmount from monthlySpend then nullify
     */
    @AuraEnabled
    public Decimal monthlySpend {
      get;
      set {
        this.monthlySpend = value;
        this.statedMonthlyAverageAmount = new FabricType.Fabric_money(
          'AUD',
          this.monthlySpend
        );
        this.monthlySpend = null;
      }
    }

    /**
     * @description Indicates if this is a leaf node
     */
    @AuraEnabled
    public Boolean leafNode { get; set; }

    /**
     * @description ETag property
     */
    @AuraEnabled
    public String etag { get; set; }

    /**
     * @description State of the HEM
     */
    @AuraEnabled
    public String hemState { get; set; }

    /**
     * @description Justification code for the expense
     */
    @AuraEnabled
    public String justificationCode { get; set; }

    /**
     * @description property Id for the expense
     */
    @AuraEnabled
    public String propertyId { get; set; }
  }
}
