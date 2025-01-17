/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description  Model Class for the Fabric Seal Response
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * ExcessivePublicCount Surpressed : FabricSealResponseModel to have all the public methods and attributes together.
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.FieldNamingConventions')
public with sharing class FabricSealResponseModel extends CalloutModel {
  @AuraEnabled
  public String acceptance;
  @AuraEnabled
  public String salesforceCaseNumber;
  @AuraEnabled
  public String businessProcessId;
  @AuraEnabled
  public UnsatisfiedPreconditions unsatisfiedPreconditions;
  @AuraEnabled
  public String code;
  @AuraEnabled
  public String message;

  /**
   * @description unsatisfied pre conditions values
   */
  public class UnsatisfiedPreconditions {
    @AuraEnabled
    public Restraints restraints;
    @AuraEnabled
    public Bankruptcy bankruptcy;
    @AuraEnabled
    public DeceasedEstates deceasedEstates;
    @AuraEnabled
    public UnclearedFunds unclearedFunds;
    @AuraEnabled
    public NonzeroAvailableBalance nonzeroAvailableBalance;
    @AuraEnabled
    public NonzeroClosureBalance nonzeroClosureBalance;
    @AuraEnabled
    public PendingAuths pendingAuths;
    @AuraEnabled
    public LoanOffset loanOffset;
  }

  /**
   * @description restraint values
   */
  public class Restraints {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description Bankruptcy values
   */
  public class Bankruptcy {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description the DeceasedEstates value
   */
  public class DeceasedEstates {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description UnclearedFunds value
   */
  public class UnclearedFunds {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description NonzeroAvailableBalance value
   */
  public class NonzeroAvailableBalance {
    @AuraEnabled
    public String eligibility;
    @AuraEnabled
    public AvailableBalance availableBalance;
  }

  /**
   * @description AvailableBalance value
   */
  public class AvailableBalance {
    @AuraEnabled
    public String currencyCode;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
  }

  /**
   * @description NonzeroClosureBalance value
   */
  public class NonzeroClosureBalance {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description PendingAuths value
   */
  public class PendingAuths {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @description LoanOffset value
   */
  public class LoanOffset {
    @AuraEnabled
    public String eligibility;
  }

  /**
   * @param json input string to deserialize
   * @return `List<FabricSealResponseModel>`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static List<FabricSealResponseModel> parse(String json) {
    List<FabricSealResponseModel> model = (List<FabricSealResponseModel>) deserialize(
      json,
      List<FabricSealResponseModel>.class
    );
    return model;
  }
}
