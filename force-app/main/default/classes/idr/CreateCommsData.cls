/**
 *
 * @author Himabindu Nekkanti
 * @since 2021
 * @description CreateCommsData is the data class for CreateCaseComms LWC
 */
public class CreateCommsData {
  @AuraEnabled
  public string fieldLabel;
  @AuraEnabled
  public string fieldValue;
  @AuraEnabled
  public string fieldId;
  @AuraEnabled
  public string fieldDesc;

  /**
   * @description contructor.
   * @param fieldLabel Label of the field used in template
   * @param fieldValue Value of the field used in template
   * @param fieldId Id of the field used in template
   * @param fieldDesc Description of the field used in template
   */
  public CreateCommsData(
    String fieldLabel,
    String fieldValue,
    String fieldId,
    String fieldDesc
  ) {
    this.fieldLabel = fieldLabel;
    this.fieldValue = fieldValue;
    this.fieldId = fieldId;
    this.fieldDesc = fieldDesc;
  }
}
