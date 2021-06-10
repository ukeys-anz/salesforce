/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  IDRConstants consists of all the IDR constants
 */
public with sharing class IDRConstants {
  //Milestone Sla
  public static final string COMPLAINTS_ENTITLMENT_ACCT = 'Complaint Entitlement Account';
  public static final string COMPLAINTS_ENTITLMENT_PROCESS = 'complaints';
  public static final string COMPLAINTS_ENTITLEMENT_NAME = 'Complaints Entitlement';

  //Channel Recieved
  public static final string CHANNEL_RECEIVED_AFCA_REFERRED = '11';

  /**
   * @description Static variable to list CMOS workbaskets' API names
   * @return List CMOS workbaskets' API names
   */
  @TestVisible
  public static final List<String> workBasketNames {
    get {
      if (workBasketNames == null) {
        workBasketNames = new List<String>{
          'Specialised_Early_Resolution_Hardship',
          'Specialised_EarlyRes_Responsible_Lending',
          'EDR_Early_Resolution',
          'IDR_Hardship',
          'IDR_Responsible_Lending',
          'IDR_CEO',
          'IDR_Business_Owners',
          'IDR_Everyday_Banking',
          'IDR_Home_Owners',
          'IDR_Wealth',
          'IDR_Early_Resolution'
        };
      }
      return workBasketNames;
    }
    set;
  }

  /**
   * @description mapping from product to queue for workbasket allocation
   * @return Map of Product to Workbasket
   */
  public static final Map<String, String> caseAssignmentProductMap {
    get {
      if (caseAssignmentProductMap == null) {
        caseAssignmentProductMap = new Map<String, String>{
          'ANZ Business Black Credit Card' => 'IDR_Business_Owners',
          'ANZ Business 55 Days Interest Free Credit Card' => 'IDR_Business_Owners',
          'ANZ Business Rewards Options Credit Card' => 'IDR_Business_Owners',
          'ANZ Business Low Rate Credit Card' => 'IDR_Business_Owners',
          'ANZ Visa Purchasing Card' => 'IDR_Business_Owners',
          'ANZ Virtual Card' => 'IDR_Business_Owners',
          'ANZ Travel Account' => 'IDR_Business_Owners',
          'ANZ Corporate Card' => 'IDR_Business_Owners',
          'AGRI Finance Loan' => 'IDR_Business_Owners',
          'ANZ Business Loan (ABL) for Personal Investment' => 'IDR_Business_Owners',
          'ANZ Business Loan (ABL)' => 'IDR_Business_Owners',
          'ANZ Business Mortgage Loan (BML)' => 'IDR_Business_Owners',
          'ANZ Business Saver Loan' => 'IDR_Business_Owners',
          'Investment Property Loan (GF)' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - VARIABLE INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - RANGE INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - FIXED INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - FIX INT IN ADV' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - CAPPED INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF)' => 'IDR_Business_Owners',
          'ANZ Tailored Business Facility' => 'IDR_Business_Owners',
          'Chattel Mortgage' => 'IDR_Business_Owners',
          'Finance Lease' => 'IDR_Business_Owners',
          'Novated Lease' => 'IDR_Business_Owners',
          'Luxury Asset Lease' => 'IDR_Business_Owners',
          'Offer to Hire' => 'IDR_Business_Owners',
          'Asset Finance' => 'IDR_Business_Owners',
          'ANZ Revolving AGRI Line overdraft' => 'IDR_Business_Owners',
          'Business Credit Facility' => 'IDR_Business_Owners',
          'Business Advantage Overdraft' => 'IDR_Business_Owners',
          'Cash Covered Facility Account' => 'IDR_Business_Owners',
          'Cash Cover Indemnity Guarantee' => 'IDR_Business_Owners',
          'Indemnity Guarantee Facility' => 'IDR_Business_Owners',
          'Business Classic Account' => 'IDR_Business_Owners',
          'GST Payment Account' => 'IDR_Business_Owners',
          'Business Extra 50 Account' => 'IDR_Business_Owners',
          'Business Extra Account' => 'IDR_Business_Owners',
          'Negotiator Account' => 'IDR_Business_Owners',
          'ANZ Business Essentials (Previously ANZ Business Premium Saver)' => 'IDR_Business_Owners',
          'Negotiator Investor Account' => 'IDR_Business_Owners',
          'Statutory Trust Account' => 'IDR_Business_Owners',
          'Business Advantage Account' => 'IDR_Business_Owners',
          'Security Deposit Account' => 'IDR_Business_Owners',
          'Farm Management Deposit Account' => 'IDR_Business_Owners',
          'Agri Finance Offset Account' => 'IDR_Business_Owners',
          'ANZ Business Offset' => 'IDR_Business_Owners',
          'BML Offset Account - with Cheque Book' => 'IDR_Business_Owners',
          'Missing Funds' => 'IDR_Business_Owners',
          'ANZ Business Visa Debit card (ABVD)' => 'IDR_Business_Owners',
          'Business Online Saver Account' => 'IDR_Business_Owners',
          'ANZ Farm Management Deposit' => 'IDR_Business_Owners',
          'ANZ Business Notice Term Deposit' => 'IDR_Business_Owners',
          'Merchant services' => 'IDR_Business_Owners',
          'ANZ IB4B - Internet Banking for Business' => 'IDR_Business_Owners',
          'ANZ Transactive' => 'IDR_Business_Owners',
          'ANZ First Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ First (for Students) Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Low Rate Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Low Rate Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Black Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Travel Adventures Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Black Credit Card' => 'IDR_Everyday_Banking',
          'Foreign Currency Accountx' => 'IDR_Everyday_Banking',
          'ANZ Passbook Pensioner Advantage' => 'IDR_Everyday_Banking',
          'ANZ Passbook Savings' => 'IDR_Everyday_Banking',
          'ANZ Access Select' => 'IDR_Everyday_Banking',
          'ANZ Everyday Visa Debit' => 'IDR_Everyday_Banking',
          'ANZ V2Plus (Retail)' => 'IDR_Everyday_Banking',
          'ANZ First Home Saver' => 'IDR_Everyday_Banking',
          'ANZ Cash Management Account' => 'IDR_Everyday_Banking',
          'ANZ Access Advantage' => 'IDR_Everyday_Banking',
          'ANZ Pensioner Advantage' => 'IDR_Everyday_Banking',
          'ANZ Access Basic' => 'IDR_Everyday_Banking',
          'Staff Cheque Account' => 'IDR_Everyday_Banking',
          'Retired Officers Cheque Account' => 'IDR_Everyday_Banking',
          'Security Deposit' => 'IDR_Everyday_Banking',
          'ANZ Access Limited' => 'IDR_Everyday_Banking',
          'V2 Plus' => 'IDR_Everyday_Banking',
          'V2 Plus Broking' => 'IDR_Everyday_Banking',
          'V2 Plus including Margin Lending' => 'IDR_Everyday_Banking',
          'V2 Plus Intermediary' => 'IDR_Everyday_Banking',
          'ANZ Access Visa Debit card (AAVD)' => 'IDR_Everyday_Banking',
          'Custodial Services' => 'IDR_Everyday_Banking',
          'Safe Deposit Box' => 'IDR_Everyday_Banking',
          'ANZ Premium Cash Management Account' => 'IDR_Everyday_Banking',
          'ANZ Cash Investment Account' => 'IDR_Everyday_Banking',
          'Investor Cash Hub' => 'IDR_Everyday_Banking',
          'ANZ Cash Advantage' => 'IDR_Everyday_Banking',
          'Prime Cash Management Account' => 'IDR_Everyday_Banking',
          'Prime Cash Management Account - Pension' => 'IDR_Everyday_Banking',
          'ANZ Online Saver' => 'IDR_Everyday_Banking',
          'ANZ Progress Saver' => 'IDR_Everyday_Banking',
          'ANZ Term Deposit' => 'IDR_Everyday_Banking',
          'ANZ Advance Notice Term Deposit' => 'IDR_Everyday_Banking',
          'Seniors Term Deposit' => 'IDR_Everyday_Banking',
          'Travel Money' => 'IDR_Everyday_Banking',
          'ANZ ATM' => 'IDR_Everyday_Banking',
          'Bank Drafts' => 'IDR_Everyday_Banking',
          'Cheque' => 'IDR_Everyday_Banking',
          'Branch Transaction' => 'IDR_Everyday_Banking',
          'Direct Debit' => 'IDR_Everyday_Banking',
          'EFTPOS Transaction' => 'IDR_Everyday_Banking',
          'Foreign Currency Transaction' => 'IDR_Everyday_Banking',
          'FOREX' => 'IDR_Everyday_Banking',
          'International payments' => 'IDR_Everyday_Banking',
          'Cash Pack' => 'IDR_Everyday_Banking',
          'Telegraphic Transfer' => 'IDR_Everyday_Banking',
          'ANZ Reward Points' => 'IDR_Everyday_Banking',
          'Qantas Frequent Flyer Points' => 'IDR_Everyday_Banking',
          'ANZ Internet Banking' => 'IDR_Everyday_Banking',
          'ANZ App' => 'IDR_Everyday_Banking',
          'ANZ FX Online' => 'IDR_Everyday_Banking',
          'ANZ Private FX Online' => 'IDR_Everyday_Banking',
          'ANZ Cashactive Virtual' => 'IDR_Everyday_Banking',
          'Currency by ANZ (app)' => 'IDR_Everyday_Banking',
          'ANZ Shield' => 'IDR_Everyday_Banking',
          'Phone Banking' => 'IDR_Everyday_Banking',
          'ANZ Travel Card (Multi Currency)' => 'IDR_Everyday_Banking',
          'Power of Attorney' => 'IDR_Everyday_Banking',
          'Wills' => 'IDR_Everyday_Banking',
          'Deceased Estates' => 'IDR_Everyday_Banking',
          'Open Banking/Data Sharing' => 'IDR_Everyday_Banking',
          'IVR' => 'IDR_Everyday_Banking',
          'N/A' => 'IDR_Everyday_Banking',
          'ANZ Breakfree Package' => 'IDR_Home_Owners',
          'ANZ Standard Variable Home Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Home Loan' => 'IDR_Home_Owners',
          'ANZ Simplicity Plus Home Loan' => 'IDR_Home_Owners',
          'ANZ Standard Variable Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Simplicity Plus Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Assured' => 'IDR_Home_Owners',
          'ANZ Personal Overdraft' => 'IDR_Home_Owners',
          'ANZ Equity Manager' => 'IDR_Home_Owners',
          'ANZ Variable Rate Personal Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Rate Personal Loan' => 'IDR_Home_Owners',
          'ANZ One Offset Account' => 'IDR_Home_Owners',
          'Margin Lending' => 'IDR_Wealth',
          'ANZ SMSF Cash Hub' => 'IDR_Wealth',
          'OnePath Life Term Deposit' => 'IDR_Wealth',
          'ANZ Term Deposit via External Platforms & Oasis Wrap' => 'IDR_Wealth',
          'ANZ Credit Card Insurance' => 'IDR_Wealth',
          'ANZ Loan Protection Insurance' => 'IDR_Wealth',
          'ANZ Mortgage Protection Insurance' => 'IDR_Wealth',
          'ANZ Lenders Mortgage Insurance' => 'IDR_Wealth',
          'ANZ Home and Contents Insurance' => 'IDR_Wealth',
          'ANZ Landlord Insurance' => 'IDR_Wealth',
          'ANZ Contents Insurance' => 'IDR_Wealth',
          'ANZ Car Insurance (Comprehensive)' => 'IDR_Wealth',
          'ANZ Car Insurance (Third Party Property Damage, Fire and Theft)' => 'IDR_Wealth',
          'ANZ Car Insurance (Third Party Property Damage)' => 'IDR_Wealth',
          'ANZ Travel Insurance' => 'IDR_Wealth',
          'ANZ Share Investment Loan' => 'IDR_Wealth',
          'White-Label ANZ Share Investing Service' => 'IDR_Wealth',
          'ANZ Accident Cover Plus' => 'IDR_Wealth',
          'ANZ Critical Illness Cover' => 'IDR_Wealth',
          'ANZ Income Cover' => 'IDR_Wealth',
          'ANZ Income Protection' => 'IDR_Wealth',
          'ANZ 50+ Life Cover' => 'IDR_Wealth',
          'ANZ Life Insurance' => 'IDR_Wealth',
          'ANZ Recover Well' => 'IDR_Wealth',
          'ANZ Credit Cover Plus' => 'IDR_Wealth',
          'ANZ Credit Cover' => 'IDR_Wealth',
          'ANZ Smart Choice Super for Employers and their Employees' => 'IDR_Wealth',
          'ANZ Smart Choice Pension' => 'IDR_Wealth',
          'ANZ Smart Choice Super' => 'IDR_Wealth',
          'IPO & Capital Raising Campaigns' => 'IDR_Wealth',
          'Direct Investments' => 'IDR_Wealth',
          'ANZ OneAnswer' => 'IDR_Wealth',
          'OneAnswer Frontier' => 'IDR_Wealth',
          'BT Wrap' => 'IDR_Wealth',
          'Netwealth' => 'IDR_Wealth',
          'Self Managed Super Fund (SMSF)' => 'IDR_Wealth'
        };
      }
      return caseAssignmentProductMap;
    }
    set;
  }
}
