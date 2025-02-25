/**
 * @author cruzb
 * @since Oct 2024
 * @description View model for SOP Summary
 */
public with sharing class SOPSummaryViewModel {
  @AuraEnabled
  public List<SOPComponentViewModel> components;

  @AuraEnabled
  public List<SOPPartyViewModel> parties;

  /**
   * @description gets all check for all parties consented
   */
  @AuraEnabled
  public Boolean allPartiesConsented {
    get {
      for (SOPPartyViewModel party : this.parties) {
        if (party.confirmedAccountsTime == null) {
          return false;
        }
      }
      return true;
    }
  }

  /**
   * @description constructor to map from sop summary api model to sop summary view model
   * @param sourceData sop api object
   * @param partyIdToFirstNameMap map to get firstname from account
   * @param typeToTotalMap get total per summary
   */
  public SOPSummaryViewModel(
    SOPGetConsolidatedModel.sop sourceData,
    Map<String, String> partyIdToFirstNameMap,
    Map<String, Decimal> typeToTotalMap
  ) {
    Set<String> componentTypes = new Set<String>{
      'COMPONENT_TYPE_INCOMES',
      'COMPONENT_TYPE_ASSETS',
      'COMPONENT_TYPE_LIABILITIES',
      'COMPONENT_TYPE_EXPENSES',
      'COMPONENT_TYPE_SAVINGS'
    };
    this.components = new List<SOPComponentViewModel>();
    for (SOPGetConsolidatedModel.Components component : sourceData.components) {
      if (!componentTypes.contains(component.type)) {
        continue;
      }
      this.components.add(
        new SOPComponentViewModel(
          component,
          partyIdToFirstNameMap,
          typeToTotalMap
        )
      );
    }

    this.parties = new List<SOPPartyViewModel>();
    for (SOPGetConsolidatedModel.Parties party : sourceData.parties) {
      this.parties.add(new SOPPartyViewModel(party));
    }
  }

  /**
   * @description View model for SOP Component
   */
  public class SOPComponentViewModel {
    @AuraEnabled
    public String type;

    @AuraEnabled
    public List<SOPPartyConfirmationViewModel> partyConfirmations;

    @AuraEnabled
    public Decimal totalAmount;

    /**
     * @description constructor to map from sop component api model to sop component view model
     * @param sourceData sop component api object
     * @param partyIdToFirstNameMap map to get firstname from account
     * @param typeToTotalMap get total per summary
     */
    public SOPComponentViewModel(
      SOPGetConsolidatedModel.Components sourceData,
      Map<String, String> partyIdToFirstNameMap,
      Map<String, Decimal> typeToTotalMap
    ) {
      this.type = sourceData.type;
      this.totalAmount = typeToTotalMap.get(sourceData.type);
      this.partyConfirmations = new List<SOPPartyConfirmationViewModel>();
      for (
        SOPGetConsolidatedModel.PartyConfirmations partyConfirmation : sourceData.partyConfirmations
      ) {
        this.partyConfirmations.add(
          new SOPPartyConfirmationViewModel(
            partyConfirmation,
            partyIdToFirstNameMap
          )
        );
      }
    }
  }

  /**
   * @description View model for SOP Party Confirmations
   */
  public class SOPPartyConfirmationViewModel {
    @AuraEnabled
    public String ownerName;

    @AuraEnabled
    public Datetime confirmedTime;

    /**
     * @description constructor to map from sop party confirmation api model to sop party confirmation view model
     * @param sourceData sop party confirmation api object
     * @param partyIdToFirstNameMap map to get firstname from account
     */
    public SOPPartyConfirmationViewModel(
      SOPGetConsolidatedModel.PartyConfirmations sourceData,
      Map<String, String> partyIdToFirstNameMap
    ) {
      this.ownerName = partyIdToFirstNameMap.get(sourceData.partyId);
      this.confirmedTime = sourceData.confirmedTime;
    }
  }

  /**
   * @description View model for Credit Bureau Item
   */
  public class SOPPartyViewModel {
    @AuraEnabled
    public Datetime confirmedAccountsTime;
    @AuraEnabled
    public String partyId;
    @AuraEnabled
    public String ocvId;

    /**
     * @description constructor to map from sop party api model to sop party view model
     * @param sourceData sop party api object
     */
    public SOPPartyViewModel(SOPGetConsolidatedModel.Parties sourceData) {
      this.confirmedAccountsTime = sourceData.confirmedAccountsTime;
      this.partyId = sourceData.id;
      this.ocvId = sourceData.ocvId;
    }
  }
}
