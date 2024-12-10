/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group Platform
 * @description CardHolder external query class
 * @runTests CardHolderExternalQueryTest
 */
public with sharing class CardHolderExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description CardHolder Model class
   */
  public class CardHolderModel extends FinancialAccountModelBase {
    public String compositeCardHolderId;
    public String cardHolderName;
    public String cardNumberLast4Digits;
    public String cardHolderType;
    public String cardStatus;
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
  public CardHolderExternalQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'CARD_HOLDERS';
    this.externalField = 'compositeCardHolderId';
    this.productCategory = 'credit-card';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (CardHolderCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CardHolderCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CardHolder records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    for (
      CardHolderModel cardHolder : ((CardHolderCalloutResponse) calloutResponse)
        .cardHolders
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => cardHolder.compositeCardHolderId,
        'DisplayUrl' => getDisplayUrl(cardHolder.compositeCardHolderId),
        this.parentField => this.parentId,
        'CardholderName' => cardHolder.cardHolderName,
        'CardNumber' => '************' + cardHolder.cardNumberLast4Digits,
        'Relationship' => cardHolder.cardHolderType,
        'Status' => cardHolder.cardStatus
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
