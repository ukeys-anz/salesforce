/**
 * @author Raman Gupta
 * @since  November 2024
 * @group Models
 * @description Update SOP View Model
 */
public with sharing class SOPViewModel extends CalloutModel {
  /**
   * @description The name of the SOP.
   */
  @AuraEnabled
  public String name { get; set; }

  /**
   * @description List of parties involved in the SOP.
   */
  @AuraEnabled
  public List<Parties> parties { get; set; }

  /**
   * @description The count of dependents associated with the SOP.
   */
  @AuraEnabled
  public Integer dependantsCount { get; set; }

  /**
   * @description The ETag for the SOP.
   */
  @AuraEnabled
  public String etag { get; set; }

  /**
   * @description A flag indicating whether there was an error during processing of UpdateSOP callout. Default is false, indicating no error.
   */
  @AuraEnabled
  public Boolean isUpdateSOPFailed = false;

  /**
   * @description A flag indicating whether there was an error during processing of UpdateParty callout. Default is false, indicating no error.
   */
  @AuraEnabled
  public Boolean isUpdatePartyFailed = false;

  /**
   * @description A flag coming from lwc indicating if the SOP data has been updated.
   */
  @AuraEnabled
  public Boolean isSOPDataUpdated { get; set; }

  /**
   * @description A flag coming from lwc indicating if the party data has been updated.
   */
  @AuraEnabled
  public Boolean isPartyDataUpdated { get; set; }

  /**
   * @description Parties wrapper
   */
  public class Parties {
    /**
     * @description The unique identifier for the party.
     */
    @AuraEnabled
    public String id { get; set; }

    /**
     * @description The OCV ID associated with the party.
     */
    @AuraEnabled
    public String ocvId { get; set; }
    /**
     * @description A flag indicating whether the spouse of the party earns income.
     */
    @AuraEnabled
    public Boolean spouseEarnsIncome { get; set; }

    /**
     * @description soleIncomeEarner value for flex card reference
     */
    @AuraEnabled
    public String soleIncomeEarner {
      get {
        return spouseEarnsIncome == true ? 'No' : 'Yes';
      }
      set;
    }

    /**
     * @description relationshipState transform to retain actual status
     */
    @AuraEnabled
    public String relationshipState {
      get {
        if (String.isEmpty(relationshipState)) {
          return relationshipState;
        }
        List<String> arrRelationship = relationshipState.split('_');
        String relationship = arrRelationship[arrRelationship.size() - 1]
          .toLowerCase()
          .capitalize();
        if (relationship == 'Relationship') {
          return 'In a relationship';
        }
        return relationship;
      }
      set;
    }

    /**
     * @description partyDependantsCount value equals sop.dependantsCount for flex card reference
     */
    @AuraEnabled
    public Integer partyDependantsCount { get; set; }

    /**
     * @description Blank constructor
     */
    public Parties() {
    }

    /**
     * @description parameterized constrcutor
     * @param partiesDetail
     */
    public Parties(SOPUpdateSOPAndPartyResponseModel.Parties partiesDetail) {
      this.relationshipState = partiesDetail?.relationshipState;
      this.spouseEarnsIncome = partiesDetail?.spouseEarnsIncome;
      this.ocvId = partiesDetail?.ocvId;
    }
  }

  /**
   * @description Blank constructor
   */
  public SOPViewModel() {
  }

  /**
   * @description parameterized constrcutor
   * @param sopAndPartyResponse
   */
  public SOPViewModel(SOPUpdateSOPAndPartyResponseModel sopAndPartyResponse) {
    this.dependantsCount = sopAndPartyResponse?.sopData?.dependantsCount;
    this.etag = sopAndPartyResponse?.sopData?.etag;
    this.parties = new List<SOPViewModel.Parties>();
    if (sopAndPartyResponse?.partyData?.party?.parties != null) {
      for (
        SOPUpdateSOPAndPartyResponseModel.Parties partiesData : sopAndPartyResponse.partyData.party.parties
      ) {
        SOPViewModel.Parties partyData = new SOPViewModel.Parties(partiesData);
        this.parties.add(partyData);
      }
    }
    this.isUpdateSOPFailed =
      String.isNotBlank(sopAndPartyResponse?.sopData?.code) &&
      sopAndPartyResponse?.sopData?.code.equalsIgnoreCase('ERROR');
    this.isUpdatePartyFailed =
      String.isNotBlank(sopAndPartyResponse?.partyData?.party?.code) &&
      sopAndPartyResponse?.partyData?.party?.code.equalsIgnoreCase('ERROR');
  }

  /**
   * @param json input string to deserialize
   * @return `SOPViewModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPViewModel parse(String json) {
    return (SOPViewModel) deserialize(json, SOPViewModel.class);
  }
}
