/**
 * @author cruzb
 * @since Oct 2024
 * @description View model for Credit Bureau Summary
 */
public with sharing class SOPCreditBureauSummaryViewModel {
  @AuraEnabled
  public Boolean consentReceived = false;
  @AuraEnabled
  public List<SOPCreditBureauViewModel> creditBureauChecks;

  /**
   * @description constructor to map from sop liability summary sources api model to credit bureau view model
   * @param sourceData sop liability summary sources array
   * @param partyIdToFirstNameMap party id to firstname map
   */
  public SOPCreditBureauSummaryViewModel(
    List<SOPGetConsolidatedModel.Sources> sourceData,
    Map<String, String> partyIdToFirstNameMap
  ) {
    this.creditBureauChecks = new List<SOPCreditBureauViewModel>();
    for (SOPGetConsolidatedModel.Sources creditBureau : sourceData) {
      this.creditBureauChecks.add(
        new SOPCreditBureauViewModel(creditBureau, partyIdToFirstNameMap)
      );
    }

    for (SOPCreditBureauViewModel check : this.creditBureauChecks) {
      if (check.liabilityState == 'LOAD_BUREAU_LIABILITIES_STATE_COMPLETE') {
        this.consentReceived = true;
        break;
      }
    }
  }

  /**
   * @author cruzb
   * @since Oct 2024
   * @description View model for Credit Bureau Item
   */
  public class SOPCreditBureauViewModel {
    @AuraEnabled
    public String ownerName;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String subType;
    @AuraEnabled
    public Datetime retrievedTime;
    @AuraEnabled
    public string liabilityState;

    /**
     * @description constructor to map from sop liability summary sources api model to credit bureau view model
     * @param sourceData sop liability summary sources array
     * @param partyIdToFirstNameMap party id to firstname map
     */
    public SOPCreditBureauViewModel(
      SOPGetConsolidatedModel.Sources sourceData,
      Map<String, String> partyIdToFirstNameMap
    ) {
      this.ownerName = partyIdToFirstNameMap.get(sourceData.partyId);
      this.type = sourceData.type;
      this.subType = sourceData.subType;
      this.retrievedTime = sourceData.retrievedTime;
      this.liabilityState = sourceData.loadBureauLiabilitiesState;
    }
  }
}
