/**
 * @description helper class for SOP
 * @author @fangl6
 * @since 10/2024
 */
public with sharing class SOPHelper {
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description create the party id to account firstname from the partyId to OCV id map
   * @param parties model parties in SOPGetConsolidatedModel
   * @return  `Map<String, String>` party id to account first name map
   */
  public static Map<String, String> initPartyIdToFirstNameMap(
    List<SOPGetConsolidatedModel.Parties> parties
  ) {
    Map<String, String> partyIdToFirstNameMap = new Map<String, String>();
    List<String> ocvIds = (List<String>) ListUtil.getValues(
      parties,
      'ocvId',
      String.class
    );
    List<Account> accList = RLA_SOQL_REPOSITORY.getAccountsFromOcvIds(ocvIds);
    Map<String, Account> accOcvMap = (Map<String, Account>) ListUtil.mapBy(
      accList,
      Account.ocv_id__c
    );
    for (SOPGetConsolidatedModel.Parties party : parties) {
      if (partyIdToFirstNameMap.containsKey(party.id) == true) {
        continue;
      }
      partyIdToFirstNameMap.put(party.id, accOcvMap.get(party.ocvId).FirstName);
    }
    return partyIdToFirstNameMap;
  }
  /**
   * @description convert amout class from SOPGetConsolidatedModel to Decimal
   * @param amount SOPGetConsolidatedModel.Amount
   * @return  `Decimal` amount in decimal
   */
  public static Decimal convertAmountToDecimal(
    SOPGetConsolidatedModel.Amount amount
  ) {
    if (amount == null) {
      return 0.00;
    }
    Decimal unitValue = String.isNotBlank(amount.units)
      ? decimal.valueOf(amount.units)
      : 0;
    Decimal nanoValue = amount.nanos != null ? amount.nanos : 0;
    return unitValue + (nanoValue / 1000000000);
  }

  /**
   * @description put the property asset into map with property id as key
   * @param assets list of assets in SOP data
   * @return  `Map<Id, SOPAsset>` property id map
   */
  public static Set<String> getPropertyIdSet(
    List<SOPGetConsolidatedModel.Assets> assets
  ) {
    Set<String> propertyIdMap = new Set<String>();
    for (SOPGetConsolidatedModel.Assets asset : assets) {
      if (asset.type != 'ASSET_TYPE_PROPERTY') {
        continue;
      }
      propertyIdMap.add(asset.propertyId);
    }
    return propertyIdMap;
  }

  /**
   * @description publishes RLA event for reassessment toast
   * @param loan ResidentialLoanApplication
   */
  public static void publishRLARecordMonitoringToast(
    ResidentialLoanApplication loan
  ) {
    if (loan.Credit_Reassess_Required__c) {
      ToastAlertService.publishRecordMonitoringEvent(
        ToastAlertService.RLA_MESSAGE,
        new Set<ID>{ loan.Id }
      );
      return;
    }
    setToReassessmentIsRequired(loan.Id);
  }

  /**
   * @description sets the Credit_Reassess_Required__c = true to fire the toast
   * @param loanId the loan id to update
   */
  public static void setToReassessmentIsRequired(String loanId) {
    DML_REPOSITORY.updateRecords(
      new List<ResidentialLoanApplication>{
        new ResidentialLoanApplication(
          Id = loanId,
          Credit_Reassess_Required__c = true
        )
      },
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description builds a map containing ownership strings from ownership data
   * @param ownershipData list of ownership data from SOPGetConsolidatedModel
   * @param partyIdToFirstNameMap map of party id to account first name
   * @return  `Map<String, String>` map with keys 'belongs-to' and 'ownership-split' containing the respective ownership strings
   */
  public static Map<String, String> buildOwnershipStrings(
    List<SOPGetConsolidatedModel.Ownership> ownershipData,
    Map<String, String> partyIdToFirstNameMap
  ) {
    List<String> ownershipList = new List<String>();
    List<String> ownershipSplitList = new List<String>();
    for (SOPGetConsolidatedModel.Ownership owner : ownershipData) {
      ownershipList.add(partyIdToFirstNameMap.get(owner.partyId));
      ownershipSplitList.add(owner.proportion.value);
    }
    String ownershipString = String.join(ownershipList, ' / ');
    String ownershipSplitString = ownershipSplitList.size() == 1
      ? ownershipSplitList[0] + '%'
      : String.join(ownershipSplitList, ' / ');

    return new Map<String, String>{
      'belongs-to' => ownershipString,
      'ownership-split' => ownershipSplitString
    };
  }

  /**
   * @description Retrieves a list of asset names from the address lookup based on the provided source assets.
   * @param sourceAssets A list of asset identifiers to look up.
   * @param assetPropertyLookup A map of asset identifiers to asset details.
   * @return A list of asset names corresponding to the provided asset identifiers.
   */
  public static List<String> getAssetsFromassetPropertyLookup(
    List<String> sourceAssets,
    Map<String, SOPGetConsolidatedModel.Assets> assetPropertyLookup
  ) {
    List<String> assets = new List<String>();
    if (sourceAssets == null) {
      return assets;
    }

    for (String asset : sourceAssets) {
      SOPGetConsolidatedModel.Assets assetDetail = assetPropertyLookup.get(
        asset
      );
      if (assetDetail != null) {
        assets.add(assetDetail.address?.singleLineAddress);
      }
    }
    return assets;
  }

  /**
   * @description Creates a flat ownership map from ownership data
   * @param ownershipData list of ownership data from SOPGetConsolidatedModel
   * @return List<Map<String, Integer>> flattened list of ownership data
   */
  public static List<Map<String, String>> setOwnership(
    List<SOPGetConsolidatedModel.Ownership> ownershipData
  ) {
    List<Map<String, String>> ownershipList = new List<Map<String, String>>();

    for (SOPGetConsolidatedModel.Ownership owner : ownershipData) {
      ownershipList.add(
        new Map<String, String>{
          'partyId' => owner.partyId,
          'proportion' => owner.proportion.value
        }
      );
    }
    return ownershipList;
  }
}
