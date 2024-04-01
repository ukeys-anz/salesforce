/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description CardHolder external query class
 * @runTests CCRMCardHolderQueryTest
 */
public with sharing class CCRMCardHolderQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description CardHolder Model class
   */
  public class CardHolderModel extends CCRMFinancialAccountModelBase {
    public String compositeCardHolderId;
    public String cardHolderName;
    public Integer cardNumberLast4Digits;
  }

  /**
   * @description CardHolder callout response
   */
  public class CardHolderCalloutResponse extends FinancialAccountCalloutResponse {
    public List<CardHolderModel> cardHolders;
  }

  /**
   * @description constructor
   */
  public CCRMCardHolderQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'CARD_HOLDERS';
    this.externalField = 'compositeCardHolderId';
    this.productCategory = 'credit-card';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (CardHolderCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CardHolderCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to CardHolder records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      CardHolderModel cardHolder : ((CardHolderCalloutResponse) this.calloutResponse)
        .cardHolders
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', cardHolder.compositeCardHolderId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        cardHolder.compositeCardHolderId
      );
      row.put(this.parent, this.parentId);
      row.put('CardholderName', cardHolder.cardHolderName);
      row.put('CardNumber', cardHolder.cardNumberLast4Digits);
      result.queryResult.add(row);
    }
    return result;
  }
}
