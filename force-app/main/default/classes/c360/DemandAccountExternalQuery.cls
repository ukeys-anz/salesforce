/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description Demand Account external query class
 * @runTests DemandAccountExternalQueryTest
 */
public with sharing class DemandAccountExternalQuery extends CacheFinancialAccountQueryBase {
  private static final String DEFAULT_MAILING_CODE = 'Default code - Normal address';

  /**
   * @description DemandAccount API callout response
   */
  public class DemandAccountCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<DemandAccountModel> accounts;
  }

  /**
   * @description constructor
   */
  public DemandAccountExternalQuery() {
    this.productCategory = 'demand';
    this.productTypes = new Set<String>{ 'CACHE:DDA' };
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

    //set productCategory based on Product Code for FM/SSI in Demand account
    this.productCategory = 'demand';

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
      this.calloutResponse = (DemandAccountCalloutResponse) CalloutModel.deserialize(
        responseBody,
        DemandAccountCalloutResponse.class
      );
    } else {
      this.calloutResponse = (DemandAccountModel) CalloutModel.deserialize(
        responseBody,
        DemandAccountModel.class
      );
    }
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to DemandAccount records
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
        DemandAccountModel fa : ((DemandAccountCalloutResponse) calloutResponse)
          .accounts
      ) {
        result.externalRecords.add(createExternalRec(fa));
      }
    } else {
      DemandAccountModel fa = ((DemandAccountModel) calloutResponse);
      result.externalRecords.add(createExternalRec(fa));
    }
    return result;
  }

  private Map<String, Object> createExternalRec(DemandAccountModel fa) {
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
      'ShortName' => fa.shortName,
      'SecurityIndicator' => fa.securityIndicator,
      'DirectExcessFeeTo' => fa.directExcessFeeTo,
      'DirectExcessFeeToAlternativeDDA' => fa.directExcessFeeToAlternativeDda,
      'CreditRating' => fa.creditRating,
      'ExcessFeeAmount' => fa.excessFeeAmount,
      'OutOfBoundsProCode' => fa.outOfBoundsProObpCode,
      'AgentCollectionItems' => fa.agentCollectionItems,
      'PenaltyInterestApplicable' => fa.penaltyInterestApplicable,
      'AgentCredits' => fa.agentCredits,
      'ElectronicCredits' => fa.electronicCredits,
      'NextStatementDate' => fa.nextStatementDate,
      'ElectronicDebits' => fa.electronicDebits,
      'MailingCode' => String.isBlank(fa.mailingCode)
        ? DEFAULT_MAILING_CODE
        : fa.mailingCode,
      'PaperCollectionItems' => fa.paperCollectionItems,
      'NumberOfCopies' => fa.numberOfCopies,
      'PaperCredits' => fa.paperCredits,
      'Commitment' => fa.commitment,
      'PaperDebits' => fa.paperDebits,
      'AnnualBaseFee' => fa.annualBaseFee,
      'WaiveCode' => fa.waiveCode,
      'DirectBankFeesTo' => fa.directBankFeesTo,
      'CreditInterestTo' => fa.creditInterestTo,
      'ServiceChargeTypeCode' => fa.serviceChargeTypeCode,
      'CurrentInterestBasis' => fa.currentInterestBasis,
      'BankFeeCycleCode' => fa.bankFeeCycleCode,
      'EffectiveDate' => fa.effectiveDate,
      'NegativeInterestApplicable' => fa.negativeInterestApplicable,
      'CreditInterestCycle' => fa.creditInterestCycle,
      'FacilityStartDate' => fa.facilityStartDate,
      'CreditInterestCode' => fa.creditInterestCode,
      'LastOpportunityToReprice' => fa.lastOpportunityToReprice,
      'AccountCategory' => fa.accountCategory,
      'NextOpportunityToReprice' => fa.nextOpportunityToReprice,
      'ANZSIC' => getIndustries().containsKey(fa.anzsic)
        ? fa.anzsic + ' - ' + getIndustries().get(fa.anzsic)
        : fa.anzsic,
      'ManagersReviewDate' => fa.managersReviewDate,
      'AccountTitle' => fa.accountTitle,
      'AnnualReviewDate' => fa.annualReviewDate,
      'PurposeCode' => fa.purposeCode,
      'DomicileBranch' => fa.domicileBranch,
      'CostCentre' => fa.costCentre,
      'Instructions' => fa.instructions,
      'OwnershipCode' => fa.ownershipCode,
      'InterestBasis' => fa.interestBasis,
      'Balance' => fa.accountBalance,
      'InterestCycle' => fa.interestCycle,
      'PointsDifferenceMargin' => fa.pointDifferenceMargin,
      'SubProductCode' => fa.subProductCode,
      'ProductCode' => fa.productCode,
      'PenaltyInterest' => fa.penaltyInterest,
      'AccountToDebitForInterest' => fa.accountToDebitForInterest,
      'StatementCycle1' => fa.statementCycles?.statementCycle1,
      'StatementCycle2' => fa.statementCycles?.statementCycle2,
      'RefinanceAlterationAdditionIndicator' => fa.refinanceAlterationAdditionIndicator,
      'CreditInterestTo' => fa.creditInterestTo,
      'AccountNameLine1' => fa.accountNameLines?.accountNameLine1,
      'AccountNameLine2' => fa.accountNameLines?.accountNameLine2,
      'AccountNameLine3' => fa.accountNameLines?.accountNameLine3,
      'LimitType1' => fa.limitTypes?.type1,
      'LimitType2' => fa.limitTypes?.type2,
      'LimitType3' => fa.limitTypes?.type3,
      'Relationship' => FinancialAccountQueryHelper.getAccountRelationship(
        fa.accountNumber,
        this.roleTypes,
        this.accountRoleMap
      ),
      'ProductName' => FinancialAccountQueryHelper.getProductName(
        fa.accountNumber,
        this.accountRoleMap
      )
    };
    row.putAll(populateDates(fa.startDates, 'StartDate'));
    row.putAll(populateGrossLimits(fa.currentGrossLimits));
    row.putAll(
      populatePointsDifferences(fa.pointsDifferences, 'PointsDifference')
    );
    row.putAll(
      populatePointsDifferences(
        fa.tieredCreditInterest?.pointsDifferences,
        'TieredCreditInterestPointsDifference'
      )
    );
    row.putAll(populateFacilityTypes(fa.facilityTypes));
    row.putAll(populateDates(fa.expiryDates, 'ExpiryDate'));
    row.putAll(
      populatePercentageFactors(fa.percentageFactors, 'PercentageFactor')
    );
    row.putAll(
      populatePercentageFactors(
        fa.tieredCreditInterest?.percentageFactors,
        'TieredCreditInterestPercentageFactor'
      )
    );
    row.putAll(populateLimits(fa.limits, 'Limit'));
    row.putAll(
      populateLimits(
        fa.tieredCreditInterest?.limits,
        'TieredCreditInterestLimit'
      )
    );
    return row;
  }

  /**
   * @description This is used to populate the start/expiry dates
   * @param dates dates
   * @param externalAlias externalAlias
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populateDates(
    DemandAccountModel.Dates dates,
    String externalAlias
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (dates == null) {
      return row;
    }
    row.put(externalAlias + 1, dates.data1);
    row.put(externalAlias + 2, dates.data2);
    row.put(externalAlias + 3, dates.data3);
    return row;
  }

  /**
   * @description This is used to populate the start dates
   * @param grossLimits grossLimits
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populateGrossLimits(
    DemandAccountModel.currentGrossLimits grossLimits
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (grossLimits == null) {
      return row;
    }
    Map<String, Object> grossLimitsMap = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(grossLimits)
    );
    for (Integer i = 1; i <= grossLimitsMap.keySet().size(); i++) {
      Decimal limitValue = (Decimal) grossLimitsMap.get('limit' + i);
      if (limitValue == null) {
        continue;
      }
      row.put('CurrentGrossLimit' + i, limitValue);
    }
    return row;
  }

  /**
   * @description This is used to populate the start dates
   * @param percentageFactors percentageFactors
   * @param externalAlias String
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populatePercentageFactors(
    DemandAccountModel.percentageFactors percentageFactors,
    String externalAlias
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (percentageFactors == null) {
      return row;
    }
    Map<String, Object> pfMap = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(percentageFactors)
    );
    for (Integer i = 1; i <= pfMap.keySet().size(); i++) {
      Decimal pfValue = (Decimal) pfMap.get('percentageFactor' + i);
      if (pfValue == null) {
        continue;
      }
      row.put(externalAlias + i, pfValue);
    }
    return row;
  }

  /**
   * @description This is used to populate the limits
   * @param limits limits
   * @param externalAlias String
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populateLimits(
    DemandAccountModel.limits limits,
    String externalAlias
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (limits == null) {
      return row;
    }
    Map<String, Object> limitMap = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(limits)
    );
    for (Integer i = 1; i <= limitMap.keySet().size(); i++) {
      Decimal limitValue = (Decimal) limitMap.get('limit' + i);
      if (limitValue == null) {
        continue;
      }
      row.put(externalAlias + i, limitValue);
    }
    return row;
  }

  /**
   * @description This is used to populate the pointsDifferences
   * @param pointsDifferences pointsDifferences
   * @param externalAlias String
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populatePointsDifferences(
    DemandAccountModel.pointsDifference pointsDifferences,
    String externalAlias
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (pointsDifferences == null) {
      return row;
    }
    Map<String, Object> pointsDifferencesMap = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(pointsDifferences)
    );
    for (Integer i = 1; i <= pointsDifferencesMap.keySet().size(); i++) {
      Decimal pdValue = (Decimal) pointsDifferencesMap.get(
        'pointsDifference' + i
      );
      if (pdValue == null) {
        continue;
      }
      row.put(externalAlias + i, pdValue);
    }
    return row;
  }

  /**
   * @description This is used to populate the start dates
   * @param facilityTypes facilityTypes
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populateFacilityTypes(
    DemandAccountModel.facilityTypes facilityTypes
  ) {
    Map<String, Object> row = new Map<String, Object>();
    if (facilityTypes == null) {
      return row;
    }
    row.put('FacilityType1', facilityTypes.type1);
    row.put('FacilityType2', facilityTypes.type2);
    row.put('FacilityType3', facilityTypes.type3);
    return row;
  }
}
