/**
 * @author Hinduja Upadhyay
 * @since Feb 2024
 * @description TFMConsentAccountWrapper wrapper to send payload to listConsent api
 * @group TFM
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class TFMConsentAccountWrapper {
  public String consent_id;
  public list<ConsentAccountsWrapper> consent_accounts;
  /**
   * @param consentId string
   * @param consentAccountsWrapperList list
   * @description constructor for getConsentAccount payload
   */
  public TFMConsentAccountWrapper(
    String consentId,
    list<ConsentAccountsWrapper> consentAccountsWrapperList
  ) {
    this.consent_id = consentId;
    this.consent_accounts = consentAccountsWrapperList;
  }
  /**
   * @description assiging values to ConsentAccountsWrapper
   */
  public class ConsentAccountsWrapper {
    public String bsb;
    public String accountNumber;
    /**
     * @param bsb string
     * @param accountNumber string
     * @description constructor for getConsentAccountList payload
     */
    public ConsentAccountsWrapper(String bsb, String accountNumber) {
      this.bsb = bsb;
      this.accountNumber = accountNumber;
    }
  }
}