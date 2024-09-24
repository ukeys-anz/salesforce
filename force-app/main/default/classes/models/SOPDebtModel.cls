/**
 * @author cruzb
 * @since December 2023
 * @description model for SOPDebtModel, used by both add debt and edit debt in boh
 * @group Models
 * ExcessivePublicCount Surpressed : SOPDebtModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.VariableNamingConventions, PMD.FieldNamingConventions'
)
public with sharing class SOPDebtModel extends CalloutModel {
  public SOPLiability institutionalLiability;
  public SOPDebtMoney outstandingBalance;
  public SOPDebtMoney verifiedOutstandingBalance;
  public SOPAccount account;
  public SOPStudentLoan studentLoan;
  public List<String> sources;
  public String type;
  public String strOwnership;
  public String name;
  public String uid;
  public String etag;
  public String termType;
  public Boolean validatedOutstandingBalance;
  public Boolean paidOffAndClosed;
  public Boolean evidenceProvided;
  public Boolean customerStatedClosed;

  /**
   * @description convert the ownership string to set of ownerships
   */
  public Set<SOPOwnership> ownership {
    get {
      Set<SOPOwnership> ownerShipSet = new Set<SOPOwnership>();
      if (strOwnership == null) {
        return ownerShipSet;
      }
      SOPOwnership.FlatOwnerShip fos = (SOPOwnership.FlatOwnerShip) JSON.deserialize(
        this.strOwnership,
        SOPOwnership.FlatOwnerShip.class
      );
      if (!String.isBlank(fos.partyIdOne)) {
        ownerShipSet.add(
          new SOPOwnership(fos.partyIdOne, fos.proportionValueOne)
        );
      }
      if (String.isBlank(fos.partyIdTwo)) {
        return ownerShipSet;
      }
      ownerShipSet.add(
        new SOPOwnership(fos.partyIdTwo, fos.proportionValueTwo)
      );
      return ownerShipSet;
    }
  }
  /**
   * @description liability wrapper
   */
  public class SOPLiability {
    SOPDebtMoney limitAmount;
    SOPDebtMoney redrawAmount;
    String financialInstitution;
    String repaymentFrequency;
    Boolean paidInFull;
    Boolean validatedLimit;
    Boolean validatedPrincipalInterestRemainingTerm;
    Integer principalInterestRemainingTerm;
    Integer verifiedPrincipalInterestRemainingTerm;
    Integer interestRate;

    /**
     * @description passes null when met to remove key when serialised
     */
    public SOPDebtMoney repaymentAmount {
      get {
        return paidInFull == true ? null : repaymentAmount;
      }
    }
  }

  /**
   * @description account wrapper
   */
  public class SOPAccount {
    String financialInstitution;
    String bsb;
    String accountNumber;
    String status;
    String id;
  }

  /**
   * @description SOPDebtMoney wrapper
   */
  public class SOPDebtMoney {
    public String currencyCode;
    public String units;

    /**
     * @description multiply nanos
     */
    public Integer nanos {
      get {
        return nanos * 10000000;
      }
      set;
    }
  }

  /**
   * @description SOPStudentLoan wrapper
   */
  public class SOPStudentLoan {
    public Boolean hecsWithheldPayment;
  }

  /**
   * @param json input string to deserialize
   * @return `SOPDebtModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPDebtModel parse(String json) {
    return (SOPDebtModel) deserialize(json, SOPDebtModel.class);
  }
}
