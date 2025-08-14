/**
 * @author Peter Charalambous
 * @since June 2025
 * @description Lex API repository
 * @group Repository
 */

@SuppressWarnings('PMD.ApexDoc, PMD.PropertyNamingConventions')
public with sharing class LexAPIRepository extends RepositoryBase {
  private static final LexService SERVICE = (LexService) Lib_InstanceProvider.forType(
    LexService.class
  );
  /**
   * @param poiDetails proof of insurance details
   * @return `VerifyInsuranceModel`
   * @description Verifies a customers proof of insurance
   */
  public VerifyInsuranceModel verifyInsurance(
    ProofOfInsuranceController.VerifyInsuranceWrapper poiDetails
  ) {
    // Populate request body
    ProofOfInsuranceVerification poiVerification = new ProofOfInsuranceVerification();
    poiVerification.documentId = poiDetails.documentId;
    poiVerification.documentFileVersion = poiDetails.documentFileVersion;

    VerifyInsuranceRequestBody requestBody = new VerifyInsuranceRequestBody();
    requestBody.settlementId = poiDetails.settlementId;
    requestBody.mortgageContractId = poiDetails.mortgageContractId;
    requestBody.propertyId = poiDetails.propertyId;
    requestBody.proofOfInsuranceVerification = poiVerification;

    HttpCalloutResponse response = SERVICE.verifyInsurance(
      json.serialize(requestBody),
      poiDetails.ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    VerifyInsuranceModel verifyInsurance;
    try {
      verifyInsurance = VerifyInsuranceModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return verifyInsurance;
  }

  /**
   * @description VerifyInsuranceRequestBody returns request body of verifyInsurance call
   */
  public class VerifyInsuranceRequestBody {
    public String settlementId;
    public String mortgageContractId;
    public String propertyId;
    public ProofOfInsuranceVerification proofOfInsuranceVerification;
  }

  /**
   * @description ProofOfInsuranceVerification returns request body of verifyInsurance call
   */
  public class ProofOfInsuranceVerification {
    public String documentId;
    public String documentFileVersion;
  }

  /**
   * @description Returns settlement record
   * @param settlementId settlementId to fetch
   * @param ocvId OCV ID of the account associated with the settlement
   * @return `LexSettlementV1b1SettlementTypes.Settlement` settlement record
   */
  public LexSettlementV1b1SettlementTypes.Settlement getSettlement(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getSettlement(settlementId, ocvId);
    if (response.successful == false) {
      throw response.error;
    }

    LexSettlementV1b1SettlementTypes.Settlement settlement;
    try {
      settlement = (LexSettlementV1b1SettlementTypes.Settlement) CalloutModel.deserialize(
        response.body,
        (LexSettlementV1b1SettlementTypes.Settlement.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return settlement;
  }

  //Suppress name since it comes from API
  @SuppressWarnings('PMD.PropertyNamingConventions')
  public with sharing class ListLoanFacilityConfigsResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.LoanFacilityConfig> loanFacilityConfigs {
      get;
      set;
    }
  }
  /**
   * @description Returns LoanFacilityConfig records
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `Object` a list of LoanFacilityConfig records
   */
  public ListLoanFacilityConfigsResponse listLoanFacilityConfigs(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.listLoanFacilityConfigs(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    ListLoanFacilityConfigsResponse lfcr;
    try {
      lfcr = (ListLoanFacilityConfigsResponse) CalloutModel.deserialize(
        response.body,
        (ListLoanFacilityConfigsResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return lfcr;
  }

  //Suppress name since it comes from API
  @SuppressWarnings('PMD.PropertyNamingConventions')
  public with sharing class ListAutomaticRepaymentPreferencesResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences> automaticRepaymentPreferences {
      get;
      set;
    }
  }

  /**
   * @description Returns AutomaticRepaymentPreferences records
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `Object` a list of AutomaticRepaymentPreferences records
   */
  public ListAutomaticRepaymentPreferencesResponse listAutomaticRepaymentPreferences(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.listAutomaticRepaymentPreferences(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    ListAutomaticRepaymentPreferencesResponse larr;
    try {
      larr = (ListAutomaticRepaymentPreferencesResponse) CalloutModel.deserialize(
        response.body,
        (ListAutomaticRepaymentPreferencesResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return larr;
  }
  public with sharing class ListProofOfInsuranceResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument> proofOfInsurances {
      get;
      set;
    }
  }
  /**
   * @description Returns Proof of Insurance record
   * @param settlementId settlementId to fetch
   * @param ocvId OCV ID
   * @return `LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument` settlement record
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument> getProofOfInsurance(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getProofOfInsurance(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    ListProofOfInsuranceResponse lpir;
    try {
      lpir = (ListProofOfInsuranceResponse) CalloutModel.deserialize(
        response.body,
        (ListProofOfInsuranceResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }
    return lpir.proofOfInsurances;
  }

  //Suppress name since it comes from API
  @SuppressWarnings('PMD.PropertyNamingConventions')
  public with sharing class MortgageContractResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.MortgageContract> mortgageContracts {
      get;
      set;
    }
  }
  /**
   * @description Returns Mortgage record
   * @param settlementId settlementId to fetch
   * @param ocvId OCV ID of the account
   * @return `Object` mortgage contract record
   */
  public MortgageContractResponse getListMortgageContracts(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getListMortgageContracts(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    MortgageContractResponse mortgageContractResponse;
    try {
      mortgageContractResponse = (MortgageContractResponse) CalloutModel.deserialize(
        response.body,
        (MortgageContractResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return mortgageContractResponse;
  }

  //Suppress name since it comes from API
  @SuppressWarnings('PMD.PropertyNamingConventions')
  public with sharing class SettlementAccountResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.SettlementAccount> settlementAccounts {
      get;
      set;
    }
  }

  /**
   * @description Returns Settlement Account record
   * @param settlementId settlementId to pass
   * @param ocvId OCV ID of account
   * @return `Object` settlement Account record
   */
  public SettlementAccountResponse getSettlementAccount(
    String settlementId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getSettlementAccount(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    SettlementAccountResponse settlementAccount;
    try {
      settlementAccount = (SettlementAccountResponse) CalloutModel.deserialize(
        response.body,
        (SettlementAccountResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }

    return settlementAccount;
  }

  //Suppress name since it comes from API
  public with sharing class DrawdownResponse extends CalloutModel {
    @AuraEnabled
    public List<LexSettlementV1b1SettlementTypes.Drawdown> drawdowns {
      get;
      set;
    }
  }

  /**
   * @description Returns List Drawdowns
   * @param settlementId settlementId to fetch
   * @param ocvId OCV ID of the account
   * @return `Object` drawdown record
   */
  public DrawdownResponse getListDrawdowns(String settlementId, String ocvId) {
    HttpCalloutResponse response = SERVICE.getListDrawdowns(
      settlementId,
      ocvId
    );
    if (response.successful == false) {
      throw response.error;
    }

    DrawdownResponse drawdown;
    try {
      drawdown = (DrawdownResponse) CalloutModel.deserialize(
        response.body,
        (DrawdownResponse.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }
    return drawdown;
  }

  /**
   * @description Returns Drawdown record
   * @param drawdownId drawdown to fetch
   * @param ocvId OCV ID of the account
   * @return `LexSLMV1alpha2LoanManagementTypes.Drawdown`  record
   */
  public LexSLMV1alpha2LoanManagementTypes.Drawdown getDrawdown(
    String drawdownId,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getDrawdown(drawdownId, ocvId);
    if (response.successful == false) {
      throw response.error;
    }

    LexSLMV1alpha2LoanManagementTypes.Drawdown drawdownResponse;
    try {
      drawdownResponse = (LexSLMV1alpha2LoanManagementTypes.Drawdown) CalloutModel.deserialize(
        response.body,
        (LexSLMV1alpha2LoanManagementTypes.Drawdown.class)
      );
    } catch (Exception e) {
      handleErrors(response, e, LexAPIRepository.class);
    }
    return drawdownResponse;
  }
}
