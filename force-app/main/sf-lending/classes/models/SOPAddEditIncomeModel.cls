/**
 * @description sop add/edit income api model
 * @author @fangl6
 * @since 11/2024
 */
public with sharing class SOPAddEditIncomeModel extends CalloutModel {
  /**Add income attributes**/
  /**
   * @description The parent of the income.
   */
  @AuraEnabled
  public String parent { get; set; }

  /**
   * @description The income details to be added.
   */
  @AuraEnabled
  public AddIncome income { get; set; }

  /**Edit income attributes**/
  /**
   * @description The name of the income.
   */
  @AuraEnabled
  public String name { get; set; }

  /**
   * @description The unique identifier of the income.
   */
  @AuraEnabled
  public String uid { get; set; }

  /**
   * @description The employment details associated with the income.
   */
  @AuraEnabled
  public SOPEmploymentDetail employment { get; set; }

  /**
   * @description The linked property asset name.
   */
  @AuraEnabled
  public String asset { get; set; }

  /**
   * @description The list of income items.
   */
  @AuraEnabled
  public List<SOPIncomeItem> details { get; set; }

  /**Shared attributes**/

  /**
   * @description The entity tag for the income.
   */
  @AuraEnabled
  public String etag { get; set; }

  /**Extra attributes as parameters**/

  /**
   * @description Indicates if the income is verified.
   */
  @AuraEnabled
  public Boolean incomeVerified { get; set; }

  /**
   * @description Indicates if the income verification status has changed.
   */
  @AuraEnabled
  public Boolean incomeVerifiedChanged { get; set; }

  /**
   * @description AddIncome model of the income information.
   */
  public class AddIncome {
    /**
     * @description The employment details for the income.
     */
    @AuraEnabled
    public SOPEmploymentDetail employment { get; set; }

    /**
     * @description The linked property asset for the income.
     */
    @AuraEnabled
    public String asset { get; set; }

    /**
     * @description The list of income item details.
     */
    @AuraEnabled
    public List<SOPIncomeItem> details { get; set; }
  }

  /**
   * @description SOPIncomeItem information of each income.
   */
  public class SOPIncomeItem {
    /**
     * @description The type of income.
     */
    @AuraEnabled
    public String type { get; set; }

    /**
     * @description The frequency of the income.
     */
    @AuraEnabled
    public String frequency { get; set; }

    /**
     * @description The amount of the income.
     */
    @AuraEnabled
    public FabricType.Fabric_money amount { get; set; }

    /**
     * @description amount value
     */
    @AuraEnabled
    public Decimal amountValue {
      get;
      set {
        this.amountValue = value;
        this.amount = new FabricType.Fabric_money('AUD', this.amountValue);
        this.amountValue = null;
      }
    }

    /**
     * @description The type of amount (e.g., gross, net).
     */
    @AuraEnabled
    public String amountType { get; set; }

    /**
     * @description The number of bonus payments.
     */
    @AuraEnabled
    public Integer bonusPayments { get; set; }
  }

  /**
   * @description SOPEmploymentDetail information of general income.
   */
  public class SOPEmploymentDetail {
    /**
     * @description The party ID associated with the employment.
     */
    @AuraEnabled
    public String partyId { get; set; }

    /**
     * @description The business name of the employer.
     */
    @AuraEnabled
    public String businessName { get; set; }

    /**
     * @description The basis of employment (e.g., full-time, part-time).
     */
    @AuraEnabled
    public String basis { get; set; }

    /**
     * @description The start date of the employment.
     */
    @AuraEnabled
    public SOPDate startDate { get; set; }

    /**
     * @description The type of employment.
     */
    @AuraEnabled
    public String type { get; set; }
  }

  /**
   * @description SOPDate information of date information to send to mule.
   */
  public class SOPDate {
    /**
     * @description The year component of the date.
     */
    @AuraEnabled
    public Integer year { get; set; }

    /**
     * @description The month component of the date.
     */
    @AuraEnabled
    public Integer month { get; set; }

    /**
     * @description The day component of the date.
     */
    @AuraEnabled
    public Integer day { get; set; }
  }
}
