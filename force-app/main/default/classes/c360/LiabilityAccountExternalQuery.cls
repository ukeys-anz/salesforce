/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description Liability Account external query class
 * @runTests LiabilityAccountExternalQueryTest
 */
public with sharing class LiabilityAccountExternalQuery extends CacheFinancialAccountQueryBase {
  /**
   * @description LiabilityAccount API callout response
   */
  public class LiabilityAccountCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<LiabilityAccountModel> accounts;
  }

  /**
   * @description constructor
   */
  public LiabilityAccountExternalQuery() {
    this.productCategory = 'liability';
    this.productTypes = new Set<String>{ 'CACHE:LA' };
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @param tableSelection DataSource.TableSelection
   * @return QueryMode Enum
   **/
  @testVisible
  protected override ExternalObjectCalloutRequestBase prepareCallout(
    DataSource.QueryContext queryContext,
    DataSource.TableSelection tableSelection
  ) {
    ExternalObjectQueryBase.ExternalObjectCalloutRequestBase calloutRequest = super.prepareCallout(
      queryContext,
      queryContext.TableSelection
    );

    //set productCategory based on Product Code for FM/SSI in Liability account
    this.productCategory = 'liability';

    return calloutRequest;
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

    if (this.queryMode == QueryModeEnum.RELATED_LIST) {
      this.calloutResponse = (LiabilityAccountCalloutResponse) CalloutModel.deserialize(
        responseBody,
        LiabilityAccountCalloutResponse.class
      );
    } else {
      this.calloutResponse = (LiabilityAccountModel) CalloutModel.deserialize(
        responseBody,
        LiabilityAccountModel.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to LiabilityAccount records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    if (this.queryMode == QueryModeEnum.RELATED_LIST) {
      for (
        LiabilityAccountModel fa : ((LiabilityAccountCalloutResponse) calloutResponse)
          .accounts
      ) {
        result.externalRecords.add(createExternalRec(fa));
      }
    } else {
      LiabilityAccountModel fa = ((LiabilityAccountModel) calloutResponse);
      result.externalRecords.add(createExternalRec(fa));
    }
    return result;
  }
  private Map<String, Object> createExternalRec(LiabilityAccountModel fa) {
    if (String.isNotBlank(fa.error)) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => UUID.randomUUID().toString(),
        'AccountName' => 'Error: ' +
        FinancialAccountQueryHelper.formatAccountNumber(fa.accountNumber) +
        ' ' +
        fa.error
      };
      return row;
    }
    Map<String, Object> row = new Map<String, Object>{
      this.parentField => this.parentId,
      'ExternalId' => getExternalId(
        fa.getCacheFinancialAccountModel(),
        this.accountRoleMap
      ),
      'DisplayUrl' => getDisplayUrl(fa.productCode + '-' + fa.accountNumber),
      'AccountName' => fa.accountName,
      'AccountNumber' => FinancialAccountQueryHelper.formatAccountNumber(
        fa.accountNumber
      ),
      'AccountStatus' => FinancialAccountQueryHelper.getAccountStatus(
        fa.accountNumber,
        this.accountRoleMap
      ),
      'Balance' => fa.balance,
      'Limit' => fa.accountLimit,
      'AccountNameLine1' => fa.accountNameLines?.accountNameLine1,
      'AccountNameLine2' => fa.accountNameLines?.accountNameLine2,
      'AccountNameLine3' => fa.accountNameLines?.accountNameLine3,
      'AccountTitle' => fa.accountTitle,
      'AccountSecuritisationIndicator' => fa.accountSecuritisationIndicator,
      'AccountTitle' => fa.accountTitle,
      'AnnualReviewDate' => fa.annualReviewDate,
      'ANZSIC' => fa.anzsic,
      'BankingCodeOfPractice' => fa.bankingCodeOfPractice,
      'Code' => fa.code,
      'Commitment' => fa.commitment,
      'CostCentre' => fa.costCentre,
      'CreditRating' => fa.creditRating,
      'DomicileBranch' => fa.domicileBranch,
      'FacilityStartDate' => fa.facilityStartDate,
      'FacilityType' => fa.facilityType,
      'LastOpportunityToReprice' => fa.lastOpportunityToReprice,
      'LimitExpiryDate' => fa.limitExpiryDate,
      'NextOpportunityToReprice' => fa.nextOpportunityToReprice,
      'OwnershipCode' => fa.ownershipCode,
      'ProductCode' => fa.productCode,
      'PurposeCode' => fa.purposeCode,
      'RefinanceAlterationAdditionalIndicator' => fa.refinanceAlterationAdditionalIndicator,
      'RIINC' => fa.riinc,
      'ServiceBranch' => fa.serviceBranch,
      'ShortName' => fa.shortName,
      'SecurityIndicator' => fa.securityIndicator,
      'SubProductCode' => fa.subProductCode,
      'UnavailableFunds' => fa.unavailableFunds,
      'Relationship' => FinancialAccountQueryHelper.getAccountRelationship(
        fa.accountNumber,
        this.roleTypes,
        this.accountRoleMap
      )
    };
    return row;
  }
}
