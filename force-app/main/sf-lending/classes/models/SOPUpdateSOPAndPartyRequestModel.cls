/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description model for SOP party and Update SOP
 * @group Models
 */
public with sharing class SOPUpdateSOPAndPartyRequestModel extends CalloutModel {
  // Wrapper for the 'partyData' object
  public PartyData partyData;

  // Wrapper for the 'sopData' object
  public SopData sopData;

  /**
   * @description PartyData class
   */
  public class PartyData {
    public List<Party> party;

    /**
     * @description blank construcuor
     */
    public PartyData() {
    }

    /**
     * @description parameterized constrcutor
     * @param partiesList
     * @param ocvId
     */
    public PartyData(List<SOPViewModel.Parties> partiesList, String ocvId) {
      this.party = new List<Party>();
      for (SOPViewModel.Parties sopViewPartyDetails : partiesList) {
        this.party.add(new Party(sopViewPartyDetails, ocvId));
      }
    }
  }
  /**
   * @description Party nested class
   */
  public class Party {
    public String id;
    public String relationshipState;
    public Boolean spouseEarnsIncome;
    public String currentHousingStatus;
    public String livingStatusOther;

    /**
     * @description blank construcuor
     */
    public Party() {
    }
    /**
     * @description parameterized constrcutor
     * @param sopViewPartyDetails
     * @param ocvId
     */
    public Party(SOPViewModel.Parties sopViewPartyDetails, String ocvId) {
      this.id = sopViewPartyDetails.id;
      this.currentHousingStatus = sopViewPartyDetails.currentHousingStatus;

      this.livingStatusOther = this.currentHousingStatus ==
        'LIVING_STATUS_OTHER'
        ? sopViewPartyDetails.livingStatusOther
        : null;
      if (sopViewPartyDetails.ocvId == ocvId) {
        this.spouseEarnsIncome = SOPUpdateSOPandPartyHelper.transformSpouceEarnIncome(
          sopViewPartyDetails.soleIncomeEarner
        );
        this.relationshipState = SOPUpdateSOPandPartyHelper.transformToRelationshipState(
          sopViewPartyDetails.relationshipState
        );
      }
    }
  }

  /**
   * @description Class for SopData Node
   */
  public class SopData {
    public Integer dependantsCount;
    public String etag;
    /**
     * @description blank constrcutor
     */
    public SopData() {
    }
    /**
     * @description parameterized constrcutor
     * @param sopViewDetails
     */
    public SopData(SOPViewModel sopViewDetails) {
      this.dependantsCount = sopViewDetails.dependantsCount;
      this.etag = sopViewDetails.etag;
    }
  }

  /**
   * @description blank constrcutor
   */
  public SOPUpdateSOPAndPartyRequestModel() {
  }
  /**
   * @description parameterized constrcutor
   * @param sopDetails
   * @param ocvId
   */
  public SOPUpdateSOPAndPartyRequestModel(
    SOPViewModel sopDetails,
    String ocvId
  ) {
    this.partyData = new PartyData(sopDetails.parties, ocvId);
    this.sopData = new SopData(sopDetails);
  }
}
