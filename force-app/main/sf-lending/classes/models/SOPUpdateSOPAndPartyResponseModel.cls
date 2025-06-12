/**
 * @author Raman Gupta
 * @since Dec 2024
 * @description response model for Update SOP And Party Callout
 * @group Models
 */
public with sharing class SOPUpdateSOPAndPartyResponseModel extends CalloutModel {
  /**
   * @description The partyData of the SOP Party.
   */
  public PartyData partyData;
  /**
   * @description The sopData of the SOP.
   */
  public SOPData sopData;

  /**
   * @description The PartyData wrapper.
   */
  public class PartyData {
    /**
     * @description The Party wrapper property.
     */
    public Party party;
  }
  /**
   * @description Party wrapper class.
   */
  public class Party {
    /**
     * @description List of parties involved in the SOP.
     */
    public List<Parties> parties;
    /**
     * @description Error code recieved for Update Party.
     */
    public String code;
    /**
     * @description Error message recieved for Update Party.
     */
    public String message;
  }

  /**
   * @description Parties wrapper class.
   */
  public class Parties {
    /**
     * @description The unique identifier for the party.
     */
    public String id;
    /**
     * @description The OCV ID associated with the party.
     */
    public String ocvId;
    /**
     * @description A flag indicating whether the spouse of the party earns income.
     */
    public Boolean spouseEarnsIncome;
    /**
     * @description relationshipState transform to retain actual status
     */
    public String relationshipState;
  }

  /**
   * @description SOPData wrapper
   */
  public class SOPData {
    /**
     * @description The name of the SOP.
     */
    public String name;
    /**
     * @description List of parties involved in the SOP.
     */
    public List<Parties> parties;
    /**
     * @description The count of dependents associated with the SOP.
     */
    public Integer dependantsCount;
    /**
     * @description The ETag for the SOP.
     */
    public String etag;
    /**
     * @description Error code recieved for Update Party.
     */
    public String code;
    /**
     * @description Error message recieved for Update Party.
     */
    public String message;
  }

  /**
   * @param json input string to deserialize
   * @return `SOPUpdateSOPAndPartyResponseModel`
   * @description deserializes the input string into the model
   */
  public static SOPUpdateSOPAndPartyResponseModel parse(String json) {
    return (SOPUpdateSOPAndPartyResponseModel) deserialize(
      json,
      SOPUpdateSOPAndPartyResponseModel.class
    );
  }
}
