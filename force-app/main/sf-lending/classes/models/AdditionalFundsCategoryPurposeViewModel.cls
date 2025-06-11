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
  public List<PurposeViewModel> purpose;

  /**
   * @description Constructor
   * @param category String value of category
   * @param purposes List of purposes
   */
  public AdditionalFundsCategoryPurposeViewModel(
    String category,
    List<PurposeViewModel> purposes
  ) {
    this.category = category;
    this.purpose = purposes;
  }
  /**
   * @description PurposeViewModel class
   */
  public class PurposeViewModel implements GenericObject {
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;

    /**
     * @description Returns the value of the specified field.
     * @param fieldName The name of the field to retrieve the value for.
     * @return The value of the specified field.
     */
    public Object get(String fieldName) {
      switch on fieldName {
        when 'category' {
          return this.category;
        }
        when 'value' {
          return this.value;
        }
        when 'label' {
          return this.label;
        }
      }
      throw new IllegalArgumentException(
        'Field not yet supported: ' + fieldName
      );
    }

    /**
     * @description Constructor
     * @param metadataValue metadata record
     */
    public PurposeViewModel(
      Additional_Fund_Purpose_Mapping__mdt metadataValue
    ) {
      this.value = metadataValue.Purpose_Name__c;
      this.label = metadataValue.Purpose_Label__c;
      this.category = metadataValue.Category__c;
    }
  }

  /**
   * @description To get the category and purpose mapping
   * @param categoryPurposeMap metadata records grouped by category
   * @return List<AdditionalFundsCategoryPurposeViewModel> List of Category to Purpose for Additional Funds
   */
  public static List<AdditionalFundsCategoryPurposeViewModel> convertToViewModel(
    Map<String, List<PurposeViewModel>> categoryPurposeMap
  ) {
    List<AdditionalFundsCategoryPurposeViewModel> viewModelList = new List<AdditionalFundsCategoryPurposeViewModel>();

    for (String key : categoryPurposeMap.keySet()) {
      viewModelList.add(
        new AdditionalFundsCategoryPurposeViewModel(
          key,
          categoryPurposeMap.get(key)
        )
      );
    }

    return viewModelList;
  }
}
