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
     */
    public PartyData(List<SOPViewModel.Parties> partiesList) {
      this.party = new List<Party>();
      for (SOPViewModel.Parties sopViewPartyDetails : partiesList) {
        this.party.add(new Party(sopViewPartyDetails));
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
     */
    public Party(SOPViewModel.Parties sopViewPartyDetails) {
      this.id = sopViewPartyDetails.id;
      this.currentHousingStatus = sopViewPartyDetails.currentHousingStatus;
      this.livingStatusOther = sopViewPartyDetails.livingStatusOther;
      this.spouseEarnsIncome = sopViewPartyDetails.soleIncomeEarner.equalsIgnoreCase(
        'No'
      );
      this.relationshipState = sopViewPartyDetails.relationshipState;
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
   */
  public SOPUpdateSOPAndPartyRequestModel(SOPViewModel sopDetails) {
    this.partyData = sopDetails.isPartyDataUpdated
      ? new PartyData(sopDetails.parties)
      : null;
    this.sopData = sopDetails.isSOPDataUpdated ? new SopData(sopDetails) : null;
  }
}
