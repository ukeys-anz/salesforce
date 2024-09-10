/**
 * @author Tan Phan
 * @since Aug 2024
 * @description Holds cached Case Record Types.
 */
@SuppressWarnings('PMD.TooManyFields')
public class RTCase {
  static QueryRT base = QueryRT.of(Case.SObjectType);

  public static Id accountClosure = base.getId('Account_Closure');
  public static Id anzxComplaint = base.getId('ANZx_Complaint');
  public static Id atmDispute = base.getId('ATM_Dispute');
  public static Id bpayDispute = base.getId('BPAY_Dispute');
  public static Id cardDispute = base.getId('Card_Dispute');
  public static Id cfmsMigratedCase = base.getId('CFMS_Migrated_Case');
  public static Id creditReferral = base.getId('Credit_Referral');
  public static Id customerComplaint = base.getId('Customer_Complaint');
  public static Id customerFeedback = base.getId('Customer_Feedback');
  public static Id directDebitDispute = base.getId('Direct_Debit_Dispute');
  public static Id directEntryDispute = base.getId('Direct_Entry_Dispute');
  public static Id falseCustomerProfile = base.getId('False_Customer_Profile');
  public static Id fraud = base.getId('Fraud');
  public static Id fraudCheck = base.getId('Fraud_Check');
  public static Id generalInquiry = base.getId('General_Inquiry');
  public static Id generalInquiryCmos = base.getId('General_Inquiry_CMOS');
  public static Id idOpsAssistance = base.getId('ID_Ops_Assistance');
  public static Id identity = base.getId('Identity');
  public static Id kycQa = base.getId('KYC_QA');
  public static Id nonCustomerComplaint = base.getId('Non_Customer_Complaint');
  public static Id nppDispute = base.getId('NPP_Dispute');
  public static Id pinRecovery = base.getId('PIN_Recovery');
  public static Id profileUpdate = base.getId('Profile_Update');
  public static Id recipientMule = base.getId('Recipient_Mule');
  public static Id scam = base.getId('Scam');
  public static Id selfieRecovery = base.getId('Selfie_Recovery');
  public static Id systemicIssue = base.getId('Systemic_Issue');
}
