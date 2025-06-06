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
  @AuraEnabled
  public PartyData partyData;
  /**
   * @description The sopData of the SOP.
   */
  @AuraEnabled
  public SOPData sopData;

  /**
   * @description The PartyData wrapper.
   */
  public class PartyData {
    /**
     * @description The Party wrapper property.
     */
    @AuraEnabled
    public Party party;
  }
  /**
   * @description Party wrapper class.
   */
  public class Party {
    /**
     * @description List of parties involved in the SOP.
     */
    @AuraEnabled
    public List<Parties> parties;
    /**
     * @description Error code recieved for Update Party.
     */
    @AuraEnabled
    public String code;
    /**
     * @description Error message recieved for Update Party.
     */
    @AuraEnabled
    public String message;
  }

  /**
   * @description Parties wrapper class.
   */
  public class Parties {
    /**
     * @description The unique identifier for the party.
     */
    @AuraEnabled
    public String id;
    /**
     * @description The OCV ID associated with the party.
     */
    @AuraEnabled
    public String ocvId;
    /**
     * @description A flag indicating whether the spouse of the party earns income.
     */
    @AuraEnabled
    public Boolean spouseEarnsIncome;
    /**
     * @description relationshipState transform to retain actual status
     */
    @AuraEnabled
    public String relationshipState;
  }

  /**
   * @description SOPData wrapper
   */
  public class SOPData {
    /**
     * @description The name of the SOP.
     */
    @AuraEnabled
    public String name;
    /**
     * @description List of parties involved in the SOP.
     */
    @AuraEnabled
    public List<Parties> parties;
    /**
     * @description The count of dependents associated with the SOP.
     */
    @AuraEnabled
    public Integer dependantsCount;
    /**
     * @description The ETag for the SOP.
     */
    @AuraEnabled
    public String etag;
    /**
     * @description Error code recieved for Update Party.
     */
    @AuraEnabled
    public String code;
    /**
     * @description Error message recieved for Update Party.
     */
    @AuraEnabled
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
