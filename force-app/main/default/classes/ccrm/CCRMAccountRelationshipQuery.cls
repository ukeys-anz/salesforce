/**
 * @author Ian Huang
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description AccountRelationship external query class
 * @runTests CCRMAccountRelationshipQueryTest
 */
public with sharing class CCRMAccountRelationshipQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description AccountRelationship Model class
   */
  public class AccountRelationshipModel extends CCRMFinancialAccountModelBase {
    public String compositeAccountRelationshipId;
    public String relatedPartyCustomerId;
    public String relationshipType;
  }

  /**
   * @description AccountRelationship callout response
   */
  public class AccountRelationshipCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AccountRelationshipModel> accountRelationships;
  }

  /**
   * @description constructor
   */
  public CCRMAccountRelationshipQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ACCOUNT_RELATIONSHIPS';
    this.externalField = 'compositeAccountRelationshipId';
  }

  /**
   * @description Parse query filters and prepare for API callout
   */
  protected virtual override void prepareCallout() {
    super.prepareCallout();
    updateProductCategory();
  }

  /**
   * @description update productCategory base on parent / external Id
   */
  private void updateProductCategory() {
    if (String.isNotBlank(this.externalId)) {
      String productCode = this.externalId.left(3).remove(':');
      switch on productCode {
        when 'DDA', 'FM', 'SSI', 'RSV', 'CDA' {
          this.productCategory = 'deposit';
        }
        when 'ILS' {
          this.productCategory = 'loan';
        }
        when 'PTF' {
          this.productCategory = 'ptf';
        }
        when else {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
        }
      }
    } else {
      switch on this.parent {
        when 'DepositAccount', 'TermDepositId' {
          this.productCategory = 'deposit';
        }
        when 'LoanAccount' {
          this.productCategory = 'loan';
        }
        when 'AMBITId' {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
        }
        when else {
          this.productCategory = 'ptf';
        }
      }
    }
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (AccountRelationshipCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AccountRelationshipCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to AccountRelationship records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      AccountRelationshipModel relationship : ((AccountRelationshipCalloutResponse) this.calloutResponse)
        .accountRelationships
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', relationship.compositeAccountRelationshipId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          relationship.compositeAccountRelationshipId
      );
      row.put(this.parent, this.parentId);
      row.put('RelatedPartyNames', relationship.relatedPartyCustomerId);
      row.put('Relationship', relationship.relationshipType);
      result.queryResult.add(row);
    }
    return result;
  }
}
