/** 
@author Hinduja Upadhyay
* @since Aug 2024
* @description Model class for ADR datatable
* @group TFM
*/
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class ADRDataTableResponseWrapper {
  /**
   * @description id
   */
  @AuraEnabled
  public String id { get; set; }
  /**
   * @description string created by concatinating name and brand name
   */
  @AuraEnabled
  public String nameBrandConcat { get; set; }
  /**
   * @description class string created by concatinating status and date
   */
  @AuraEnabled
  public String statusUpdateConcat { get; set; }
  /**
   * @description status field
   */
  @AuraEnabled
  public String status { get; set; }
  /**
   * @description error variable to catch all  error
   */
  @AuraEnabled
  public String isError { get; set; }
  /**
   * @description Represents wrapper
   * @param id
   * @param nameBrandConcat
   * @param statusUpdateConcat
   * @param status
   * @param isError
   */
  public ADRDataTableResponseWrapper(
    String id,
    String nameBrandConcat,
    String statusUpdateConcat,
    String status,
    String isError
  ) {
    this.id = id;
    this.nameBrandConcat = nameBrandConcat;
    this.statusUpdateConcat = statusUpdateConcat;
    this.status = status;
    this.isError = isError;
  }
  /**
   * @description Represents empty wrapper
   */
  public ADRDataTableResponseWrapper() {
  }
}
