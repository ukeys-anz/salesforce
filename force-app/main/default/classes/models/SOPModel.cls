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
  public Sop sop;

  /**
   * @description main sop wrapper
   */
  public class Sop {
    public String name;
    public Components[] components;
    public Parties[] parties;
    public Integer dependantsCount;
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
    public boolean spouseEarnsIncome;

    /**
     * @description soleIncomeEarner value for flex card reference
     */
    public String soleIncomeEarner;

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
    public confirmedAccountsTime confirmedAccountsTime;
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
   * @param json input string to deserialize
   * @return `SOPModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPModel parse(String json) {
    return (SOPModel) System.JSON.deserialize(json, SOPModel.class);
  }
}
