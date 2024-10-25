/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Favouree external query class
 */
public with sharing class FavoureeExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Favouree Model class
   */
  public class FavoureeModel extends CCRMFinancialAccountModelBase {
    public String compositeGuaranteesFavoureesId;
    public String name;
    public String abn;
  }

  /**
   * @description Favouree API callout response
   */
  public class FavoureeCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FavoureeModel> guaranteesFavourees;
  }

  /**
   * @description class constructor
   */
  public FavoureeExternalQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'GUARANTEES_FAVOUREES';
    this.externalField = 'compositeGuaranteesFavoureesId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse API response
   */
  @TestVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (FavoureeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FavoureeCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Favouree records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @TestVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    Integer index = 0;
    for (
      FavoureeModel favouree : ((FavoureeCalloutResponse) this.calloutResponse)
        .guaranteesFavourees
    ) {
      index++;
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => favouree.compositeGuaranteesFavoureesId,
        'DisplayUrl' => getDisplayUrl(favouree.compositeGuaranteesFavoureesId),
        this.parentField => this.parentId,
        'ABN' => favouree.abn,
        'Name' => favouree.name,
        'Seq' => index
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
