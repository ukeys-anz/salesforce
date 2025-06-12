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
     * @description home address of applicant.
     */
    @AuraEnabled
    public Property currentResidence { get; set; }
    /**
     * @description applicant address to display.
     */
    @AuraEnabled
    public String applicantAddress {
      get {
        return currentResidence?.address?.singleLineAddress;
      }
      set;
    }

    /**
     * @description current housing status of applicant.
     */
    @AuraEnabled
    public String currentHousingStatus { get; set; }

    /**
     * @description livingStatusOther of applicant.
     */
    @AuraEnabled
    public String livingStatusOther { get; set; }

    /**
     * @description applicant name to display on UI.
     */
    @AuraEnabled
    public String applicantName { get; set; }

    /**
     * @description applicant record Id to navigate.
     */
    @AuraEnabled
    public String applicantId { get; set; }

    /**
     * @description soleIncomeEarner value for to display on UI
     */
    @AuraEnabled
    public String soleIncomeEarner {
      get {
        // If spouseEarnsIncome is true, return 'No', otherwise return 'Yes'
        return spouseEarnsIncome == true ? 'No' : 'Yes';
      }
      set;
    }

    /**
     * @description shareFinanceWithPartner value to display on UI
     */
    @AuraEnabled
    public String shareFinanceWithPartner {
      get {
        return relationshipState == 'RELATIONSHIP_STATE_IN_RELATIONSHIP'
          ? 'Yes'
          : 'No';
      }
    }

    /**
     * @description relationshipState transform to retain actual status
     */
    @AuraEnabled
    public String relationshipState { get; set; }

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
   * @description Property wrapper
   */
  public class Property {
    /**
     * @description to capture the current address of applicant.
     */
    @AuraEnabled
    public LexTypeAddress.Address address { get; set; }
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
