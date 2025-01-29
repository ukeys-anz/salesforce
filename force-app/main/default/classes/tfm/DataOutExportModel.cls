/**
 * @description       : DataOutExportModel for creating CSV
 * @author            : Shivraj / Hinduja
 * @group             :
 * @last modified on  : Nov-2024
 * @last modified by  : Shivraj / Hinduja
 **/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.PropertyNamingConventions')
public class DataOutExportModel extends CalloutModel {
  /**
   * @description consentIdValue
   */
  public String consentIdValue { get; set; }
  /**
   * @description IDValue
   */
  public String IDValue { get; set; }
  /**
   * @description accountsValue
   */
  public List<TFMExportConsentModel.AccountInfo> accountsValue { get; set; }
  /**
   * @description dataScopesValue
   */
  public List<String> dataScopesValue { get; set; }
  /**
   * @description brandNameValue
   */
  public String brandNameValue { get; set; }
  /**
   * @description statusValue
   */
  public String statusValue { get; set; }
  /**
   * @description clientNameValue
   */
  public String clientNameValue { get; set; }
  /**
   * @description createTimeValue
   */
  public String createTimeValue { get; set; }
  /**
   * @description expireTimeValue
   */
  public String expireTimeValue { get; set; }
  /**
   * @description stoppedValue
   */
  public String stoppedValue { get; set; }
  /**
   * @description amendedValue
   */
  public String amendedValue { get; set; }
  /**
   * @description originalCreateTimeValue
   */
  public String originalCreateTimeValue { get; set; }
  /**
   * @description originalExpireTimeValue
   */
  public String originalExpireTimeValue { get; set; }

  /**
   * @description Represents details body for CSV
   * @param json details body for CSV
   * @return `DataOutExportModel` api response is serialised into DataOutExportModel
   */
  public static DataOutExportModel parse(String json) {
    return (DataOutExportModel) deserialize(json, DataOutExportModel.class);
  }
}