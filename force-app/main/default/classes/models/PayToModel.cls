/**
 * @author Arpit
 * @since July 2023
 * @description PayTo Model to get response from Fabric thru mule
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 * @group Repository
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class PayToModel extends CalloutModel {
  public Integer count;
  public Integer total;
  public List<Mandate> mandates;

  /**
   * @description a single mandate record from the View Mandate API
   */
  public class Mandate {
    public String name;
    public String identification;
    public String status;
    public String statusDescription;
    public String statusPartyRole;
    public String statusReasonCode;
    public String statusReasonDescription;
    public String mandateType;
    public String establishmentScheme;
    public String purposeCode;
    public String purposeDescription;
    public String description;
    public String shortDescription;
    public GoogleType.GoogleDate validityStartDate;
    public GoogleType.GoogleDate validityEndDate;
    public String transferArrangement;
    public Boolean automaticExtensionIndicator;
    public String initiatingPartyName;
    public String initiatingPartyType;
    public String additionalInformation;
    public Boolean pendingActionIndicator;
    public Boolean mandateProcessingIndicator;
    public DebtorInformation debtorInformation;
    public CreditorInformation creditorInformation;
    public PaymentInformation paymentInformation;
    public Boolean isMigratedDdr;
    public Boolean isMgcrPendingAuth;
  }

  /**
   * @description debtor information node from the View Mandate API
   */
  public class DebtorInformation {
    public String partyName;
    public String ultimatePartyName;
    public String accountIdentificationTypeCode;
    public AccountInformation destinationAccount;
    public PayIdInformation payid;
    public String partyReference;
  }

  /**
   * @description creditor information node from the View Mandate API
   */
  public class CreditorInformation {
    public String partyName;
    public String ultimatePartyName;
  }

  /**
   * @description payment information node from the View Mandate API
   */
  public class PaymentInformation {
    public String paymentFrequency;
    public String paymentFrequencyDescription;
    public GoogleType.TimeOfDay paymentExecuteNotBeforeTime;
    public String frequencyDetails;
    public String paymentAmountType;
    public String paymentAmountTypeDescription;
    public FabricType.FabricMoney firstPaymentAmount;
    public FabricType.FabricMoney lastPaymentAmount;
    public FabricType.FabricMoney amount;
    public FabricType.FabricMoney maximumAmount;
    public GoogleType.GoogleDate firstPaymentDate;
    public GoogleType.GoogleDate lastPaymentDate;
  }

  /**
   * @description destination account node in View Mandates API
   */
  public class AccountInformation {
    public String bsb;
    public String transactionAccountNumber;
  }

  /**
   * @description payid node in View Mandates API
   */
  public class PayIdInformation {
    public String accountAliasTypeCode;
    public String accountAliasIdentification;
  }

  /**
   * @description Represents Response body for View Mndate API
   * @param json json response from View Mandate API
   * @return `PayToModel` api response is serialised into PayToModel
   */
  public static PayToModel parse(String json) {
    return (PayToModel) deserialize(json, PayToModel.class);
  }
}
