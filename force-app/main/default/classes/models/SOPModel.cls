/**
 * Suppressing PMD naming convention warnings
 */
@SuppressWarnings(
  'PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.ExcessivePublicCount'
)
/**
 * @author cruzb
 * @since August 2023
 * @description Model for SOP
 */
public with sharing class SOPModel extends CalloutModel {
  public static final String EQUIFAX = 'EQUIFAX';
  public static final String EQUIFAX_LC = 'Equifax';
  public static final String EXPERIAN = 'EXPERIAN';
  public static final String EXPERIAN_LC = 'Experian';
  public static final String ILLION = 'ILLION';
  public static final String ILLION_LC = 'Illion';
  public static final String CONFIRMED = 'Confirmed on ';
  public static final String NOT_CONFIRMED = 'Confirmation not yet provided';
  public static final String CREDIT_CHECK_COMPLETED = ' Credit Check completed on ';
  public static final String CREDIT_CHECK_ATTEMPTED = 'Credit check attempted';

  public String name;
  public Components[] components;
  public Parties[] parties;
  public Integer dependantsCount;
  public LiabilitySource[] liabilitySources;
  public List<PartyLiability> partyLiabilities;
  /**
   * @description flag to hide Credit Bureau section if no confirmation received from all parties
   */
  public boolean confirmationFlag {
    get {
      for (Parties party : parties) {
        if (party.confirmedAccounts == null) {
          return false;
        }
      }
      return true;
    }
  }

  /**
   * @description Components wrapper
   */
  public class Components {
    public String type;
    public boolean confirmed;
    public PartyConfirmations[] partyConfirmations;
  }

  /**
   * @description Parties wrapper
   */
  public class Parties {
    public String id;
    public String ocvId;
    public String ownerName;
    public boolean spouseEarnsIncome;

    /**
     * @description soleIncomeEarner value for flex card reference
     */
    public String soleIncomeEarner {
      get {
        return this.spouseEarnsIncome == false ? 'Yes' : 'No';
      }
    }

    /**
     * @description relationshipState transform to retain actual status
     */
    public String relationshipState {
      get {
        if (String.isEmpty(relationshipState)) {
          return relationshipState;
        }
        String[] arrRelationship = relationshipState.split('_');
        String relationship = arrRelationship[arrRelationship.size() - 1]
          .toLowerCase()
          .capitalize();
        if (relationship == 'Relationship') {
          return 'In a relationship';
        }
        return relationship;
      }
    }
    public Datetime confirmedAccounts;
    /**
     * @param confirmedAccounts input in dateTime format
     * @return returns the formatted value for date and time
     * @description formats the value for date and time
     */
    public String confirmedAccountsTimeStr {
      get {
        if (confirmedAccounts == null) {
          return NOT_CONFIRMED;
        } else {
          return CONFIRMED + BOHService.getFormatedDate(confirmedAccounts);
        }
      }
    }
    public boolean multipleProfiles;
    public String personaId;

    /**
     * @description partyDependantsCount value equals sop.dependantsCount for flex card reference
     */
    public Integer partyDependantsCount;
  }

  /**
   * @description ConfirmedAccountsTime wrapper
   */
  public class ConfirmedAccountsTime {
  }

  /**
   * @description PartyConfirmations wrapper
   */
  public class PartyConfirmations {
  }

  /**
   * @description Owner Name wrapper
   */

  public class OwnerDetails {
    public string ocvId;
    public string firstName;
  }

  /**
   * @description Liability Sources wrapper
   */
  public class LiabilitySource {
    public String partyId;
    public String type;
    public String subType;
    public Datetime retrievedTime;
    /**
     * @description return update time in the expected format
     */
    public String updateRetrievedTimeStr {
      get {
        if (success == false) {
          return CREDIT_CHECK_ATTEMPTED;
        } else {
          return CREDIT_CHECK_COMPLETED +
            BOHService.getFormatedDate(retrievedTime);
        }
      }
    }
    public boolean success;
  }

  /**
   * @description group
   */
  /**
   * @description Liability Sources wrapper
   */
  public class PartyLiability {
    public String partyId;
    public String ownerName;
    public LiabilitySource liabilitySourceEquifax;
    public LiabilitySource liabilitySourceExperian;
    public LiabilitySource liabilitySourceIllion;
  }

  /**
   * @param json input string to deserialize
   * @return `SOPModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPModel parse(String json) {
    SOPMOdel model = (SOPModel) System.JSON.deserialize(json, SOPModel.class);
    return model;
  }
}
