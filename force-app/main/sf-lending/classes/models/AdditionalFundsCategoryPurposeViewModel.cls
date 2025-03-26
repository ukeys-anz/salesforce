/**
 * @description Additional Funds Category and Purpose MApping View model
 * @author Arpit Pittie
 * @since  Nov 2024
 * @group Models
 */
public class AdditionalFundsCategoryPurposeViewModel {
  @AuraEnabled
  public String category;
  @AuraEnabled
  public List<PicklistEntryViewModel> purpose;

  /**
   * @description Constructor
   * @param category String value of category
   * @param picklistEntryList List of PicklistEntryView Model
   */
  public AdditionalFundsCategoryPurposeViewModel(
    String category,
    List<PicklistEntryViewModel> picklistEntryList
  ) {
    this.category = category;
    this.purpose = picklistEntryList;
  }

  /**
   * @description PicklistEntryViewModel class
   */
  public class PicklistEntryViewModel {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    /**
     * @description Constructor
     * @param peSelf PicklistEntry object
     */
    public PicklistEntryViewModel(PicklistEntry peSelf) {
      this.label = peSelf.getLabel();
      this.value = peSelf.getValue();
    }
  }
}
