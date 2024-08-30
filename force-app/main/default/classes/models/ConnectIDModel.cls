/**
 * @author Batya Aisman Sufrin
 * @since Dec 2023
 * @description ConnectID Model to get response from Lighthouse thru mule
 * @design https://confluence.service.anz/display/ABT/Join+102+-+Connect+ID
 * @group Repository
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class ConnectIDModel extends CalloutModel {
  public static final String TIMEZONE = 'Australia/Sydney';

  static final Map<String, String> CLAIM_KEYS = new Map<String, String>{
    'CLAIM_KEY_NAME' => 'Full Name',
    'CLAIM_KEY_GIVEN_NAME' => 'First Name',
    'CLAIM_KEY_MIDDLE_NAME' => 'Middle Name',
    'CLAIM_KEY_FAMILY_NAME' => 'Last Name',
    'CLAIM_KEY_BIRTHDATE' => 'Birthdate',
    'CLAIM_KEY_EMAIL' => 'Email',
    'CLAIM_KEY_PHONE_NUMBER' => 'Phone Number',
    'CLAIM_KEY_ADDRESS' => 'Residential Address',
    'CLAIM_KEY_OVER_16' => '16+ Verification',
    'CLAIM_KEY_OVER_18' => '18+ Verification',
    'CLAIM_KEY_OVER_21' => '21+ Verification',
    'CLAIM_KEY_OVER_25' => '25+ Verification',
    'CLAIM_KEY_OVER_65' => '65+ Verification',
    'CLAIM_KEY_BENEFICIARY_ACCOUNT_AU' => 'Bank Account Details'
  };

  public Boolean hasError;
  public List<Consent> consents;
  public Integer count;
  public Integer total;

  /**
   * @description RelyingParty node from ListConsentHistory API
   */
  public class RelyingParty {
    public String displayName;
    public String logoUri;
  }

  /**
   * @description MappingClaim mapping the claims node from ListConsentHistory API to Display Labels
   */
  public class MappingClaim {
    String name;
    String value;

    /**
     * @param name name of Claim
     * @param value label of Claim
     * @description constructor
     */
    MappingClaim(String name, String value) {
      this.name = name;
      this.value = value;
    }
  }

  /**
   * @description a single concent record from the ListConsentHistory API
   */
  public class Consent {
    public String txn;
    public String purpose;
    public RelyingParty relyingParty;
    List<MappingClaim> mappingClaims {
      get {
        return this.getMappingClaims();
      }
      private set;
    }

    public List<String> claims;
    public String createdTime;

    private List<MappingClaim> getMappingClaims() {
      if (this.claims == null) {
        return new List<MappingClaim>();
      }

      List<MappingClaim> mappingClaims = new List<MappingClaim>();
      for (String claim : this.claims) {
        mappingClaims.add(new MappingClaim(claim, CLAIM_KEYS.get(claim)));
      }
      return mappingClaims;
    }
  }

  /**
   * @description Represents Response body for ConnectIDHistoryList API
   * @param json json response from ConnectIDHistoryList API
   * @return `ConnectIDModel` api response is serialised into ConnectIDModel
   */
  public static ConnectIDModel parse(String json) {
    return (ConnectIDModel) deserialize(json, ConnectIDModel.class);
  }
}
