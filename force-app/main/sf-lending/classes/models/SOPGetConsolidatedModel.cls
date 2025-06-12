/**
 * @description model for Get Consolidated
 * @author @fangl6
 * @since 08/08/2024
 */
@SuppressWarnings('PMD.TooManyFields')
public with sharing class SOPGetConsolidatedModel extends CalloutModel {
  public Sop sop;
  public IncomesSummary incomesSummary;
  public LiabilitiesSummary liabilitiesSummary;
  public AssetsSummary assetsSummary;
  public MonthlyExpensesSummary monthlyExpensesSummary;
  public String etag;

  /**
   * @description Address model
   */
  public class Address {
    @AuraEnabled
    public String singleLineAddress;
    public String buildingNumber;
    public String street;
    public String streetName;
    public String streetType;
    public String locality;
    public String state;
    public String postalCode;
    public String country;
    public String countryCode;
    public String latitude;
    public String longitude;
    public String deliveryPointId;
    public String householdIdentificationNumber;
    public String deliveryPointBarcode;
    public String sortPlanNumber;
    public String council;
    public String councilCode;
    public String sa2Code;
  }

  /**
   * @description IncomesSummary model
   */
  public class IncomesSummary {
    public String sop;
    public List<Incomes> incomes;
    public Amount incomesTotalAmount;
    public String etag;
  }

  /**
   * @description Sop model
   */
  public class Sop {
    public String name;
    public String uid;
    public Datetime createTime;
    public Datetime updateTime;
    public String snapshotTime;
    public String status;
    public String type;
    public List<Components> components;
    public List<Parties> parties;
    public String expenseConfigVersion;
    public Integer dependantsCount;
    public String etag;
    // public List<IneligibleReasons> ineligibleReasons;
    // public List<IneligibleReasons> enquiries;
    // public List<IneligibleReasons> ineligibleReasonsWithInfo;
  }

  /**
   * @description Parties model
   */
  public class Parties implements GenericObject {
    public String id;
    public String ocvId;
    public Boolean spouseEarnsIncome;
    public String relationshipState;
    public Datetime confirmedAccountsTime;
    public Boolean multipleProfiles;
    public String personaId;
    public Property currentResidence;

    /**
     * @description Returns the value of the specified field.
     * @param fieldName The name of the field to retrieve the value for.
     * @return The value of the specified field.
     */
    public Object get(String fieldName) {
      switch on fieldName {
        when 'id' {
          return this.id;
        }
        when 'ocvId' {
          return this.ocvId;
        }
      }
      throw new IllegalArgumentException(
        'Field not yet supported: ' + fieldName
      );
    }
  }
  /**
   * @description Property model addedJaya
   */
  public class Property {
    public String propertyId;
    public Address address;
  }
  /**
   * @description Components model
   */
  public class Components {
    public String type;
    public Boolean confirmed;
    public List<PartyConfirmations> partyConfirmations;
  }
  /**
   * @description PartyConfirmations model
   */
  public class PartyConfirmations {
    public string partyId;
    public Datetime confirmedTime;
  }
  /**
   * @description LiabilitiesSummary model
   */
  public class LiabilitiesSummary {
    public String sop;
    public List<Liabilities> liabilities;
    public Amount liabilitiesTotalAmount;
    public String etag;
    public List<Sources> sources;
    public String liabilityConfirmationMarker;
  }
  /**
   * @description Liabilities model
   */
  public class Liabilities {
    public String name;
    public String uid;
    public String type;
    public InstitutionalLiability institutionalLiability;
    public Amount outstandingBalance;
    public SOPAccount account;
    //public List<IneligibleReasons> assets
    public List<String> sources;
    public List<Ownership> ownership;
    public Datetime createTime;
    public Datetime updateTime;
    public String updatedBy;
    public String etag;
    public Amount verifiedOutstandingBalance;
    // The liability term type (fixed/variable)
    public String termType;
    public Boolean validatedOutstandingBalance;
    public Boolean paidOffAndClosed;
    public Boolean evidenceProvided;
    public Boolean customerStatedClosed;
    public StudentLoan studentLoan;
    public Amount undrawnAmount;
    public Boolean fullyDrawn;
    public List<String> assets;
  }
  /**
   * @description InstitutionalLiability model
   */
  public class InstitutionalLiability {
    public Amount limitAmount; // in json: limit
    public Integer interestRate;
    public Integer interestOnlyRemainingTerm; //not in api?
    public Amount repaymentAmount;
    public String repaymentFrequency;
    public Integer principalInterestRemainingTerm;
    public Amount redrawAmount;
    //Payment method as to whether P&I, Interest-only etc (repayment type)
    public String paymentMethod;
    public String financialInstitution;
    public Boolean paidInFull;
    public Integer verifiedPrincipalInterestRemainingTerm;
    public Boolean validatedLimit;
    public Boolean validatedPrincipalInterestRemainingTerm;
    public Double taxDeductiblePercentage;
    public Boolean interestRateValidated;
    public Integer initialMargin;
    public Integer initialIndexRate;
    public String initialIndexCode;
    public Integer subsequentMargin;
    public Integer subsequentIndexRate;
    public String subsequentIndexCode;
    public Integer subsequentInterestRate;
    public String loanPurposeCode;
  }
  /**
   * @description Amount model
   */
  public class Amount {
    public String currencyCode;
    public String units;
    public Integer nanos;
  }
  /**
   * @description SOPAccount model
   */
  public class SOPAccount {
    public String id;
    public String bsb;
    public String accountNumber;
    public String accountName;
    public String status;
    public String financialInstitution;
    public String account;
    public ProductDetails productDetails;
  }
  /**
   * @description ProductDetails model
   */
  public class ProductDetails {
    public String marketingName;
  }
  /**
   * @description Ownership model
   */
  public class Ownership {
    @AuraEnabled
    public String partyId;
    @AuraEnabled
    public Proportion proportion;
  }
  /**
   * @description Proportion model
   */
  public class Proportion {
    @AuraEnabled
    public String value;
  }
  /**
   * @description StudentLoan model
   */
  public class StudentLoan {
    public Boolean hecsWithheldPayment;
  }
  /**
   * @description Sources model
   */
  public class Sources {
    public String type;
    public String subType;
    public Datetime retrievedTime; //Datetime
    public String loadBureauLiabilitiesState;
    public String partyId;
  }
  /**
   * @description Incomes model
   */
  public class Incomes {
    public String name;
    public String uid;
    public List<Details> details;
    public Employment employment;
    public Stream stream;
    public Verification verification;
    public Datetime createTime;
    public Datetime updateTime; //Datetime
    public String updatedBy;
    public String asset;
    public String etag;
  }
  /**
   * @description Details model
   */
  public class Details {
    public String id;
    public String type;
    public String frequency;
    public Amount amount;
    public String amountType;
    //public Object superAllocation;
    public Integer bonusPayments;
  }
  /**
   * @description Employment model
   */
  public class Employment {
    public String partyId;
    public String businessName;
    public String basis;
    //public BusinessLogo businessLogo {get;set;}
    public StartDate startDate;
    public String updatedBy;
    public String type;
    public Boolean hecsWithheldIncome;
    public Boolean taxFreeThresholdClaimed;
  }
  /**
   * @description StartDate model
   */
  public class StartDate {
    public String year;
    public String month;
    public String day;
    /**
     * @description returns formatted date
     * @return  `String` formatted date
     */
    public String getStartDateStr() {
      return year + '/' + month + '/' + day;
    }
  }
  /**
   * @description Stream model
   */
  public class Stream {
    public List<StreamDetails> details;
  }
  /**
   * @description StreamDetails model
   */
  public class StreamDetails {
    public Amount amount;
    public String incomeType;
    public String frequency;
  }
  /**
   * @description Verification model
   */
  public class Verification {
    public string id;
    public string incomeId;
    public Datetime createTime;
    public string method;
    public List<string> documentIds;
    public string createdBy;
  }
  /**
   * @description MonthlyExpensesSummary model
   */
  public class MonthlyExpensesSummary {
    public String sop;
    public List<MonthlyExpenses> monthlyExpenses;
    public Amount expensesTotalAmount;
    public String etag;
  }
  /**
   * @description MonthlyExpenses model
   */
  @SuppressWarnings('PMD.TooManyFields')
  public class MonthlyExpenses {
    public String name;
    public String uid;
    public String categoryId;
    public String expenseParent;
    public String categoryName;
    public Amount statedMonthlyAverageAmount;
    public Amount calculatedMonthlyAverageAmount;
    public Amount originalCalculatedMonthlyAverageAmount;
    public String control;
    public String review;
    public Boolean leafNode;
    public String justificationCode;
    public String otherJustificationText;
    public Amount warningCeilingAmount;
    public Amount justificationCeilingAmount;
    public String createTime;
    public Datetime updateTime; //Datetime
    public String updatedBy;
    public String etag;
    public String hemState;
    public String asset; // Only applicable for household expenses as they need to be linked to a property
    public String propertyId;
  }
  /**
   * @description AssetsSummary model
   */
  public class AssetsSummary {
    public String sop;
    public List<Assets> assets;
    public Amount assetsTotalAmount;
    public Amount savingsTotalAmount;
    public String etag;
    public String assetConfirmationMarker;
  }
  /**
   * @description Assets model
   */
  public class Assets {
    @AuraEnabled
    public String name;
    public String uid;
    @AuraEnabled
    public String type;
    public String subType;
    public String assetName;
    public Amount estimatedValue;
    //public List<IneligibleReasons> liabilities;
    public SOPAccount account;
    @AuraEnabled
    public List<Ownership> ownership;
    public List<String> source;
    public Datetime createTime; //updateTime
    public Datetime updateTime; //updateTime
    public String updatedBy;
    public String etag;
    public String propertyId;
    public String collateralAssessmentId;
    public Amount calculatedValue;
    public String propertyCategory;
    @AuraEnabled
    public Address address;
  }
  /**
   * @description SOPGetConsolidatedModel parse
   * @param json json string to parse
   * @return SOPGetConsolidatedModel model
   */
  public static SOPGetConsolidatedModel parse(String json) {
    SOPGetConsolidatedModel model = (SOPGetConsolidatedModel) deserialize(
      json,
      SOPGetConsolidatedModel.class
    );
    return model;
  }
}
