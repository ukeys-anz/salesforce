/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Favouree external query class
 */
public with sharing class CCRMFavoureeQuery extends CCRMFinancialAccountQueryBase {
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
  public CCRMFavoureeQuery() {
    this.productCategory = 'indemnity-guarantees';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'GUARANTEES_FAVOUREES';
    this.externalField = 'compositeGuaranteesFavoureesId';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (FavoureeCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FavoureeCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Favouree records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      FavoureeModel favouree : ((FavoureeCalloutResponse) this.calloutResponse)
        .guaranteesFavourees
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', favouree.compositeGuaranteesFavoureesId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        favouree.compositeGuaranteesFavoureesId
      );
      List<String> values = favouree.compositeGuaranteesFavoureesId != null
        ? favouree.compositeGuaranteesFavoureesId.split('-')
        : null;
      String parentId = values != null
        ? values[0] + '-' + values[1] + '-' + values[2]
        : null;
      row.put(this.parent, parentId);
      row.put('ABN', favouree.abn);
      row.put('Name', favouree.name);
      result.queryResult.add(row);
    }
    return result;
  }
}
