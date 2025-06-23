/**
 * @author CMOS
 * @since 05/2025
 * @description UpdateCustomerInformation used for updating customer information.
 */
public with sharing class UpdateCustomerInformation {
  private static final ComplaintsRepository COMPLAINTS_REPOSITORY = (ComplaintsRepository) Lib_InstanceProvider.forType(
    ComplaintsRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final String NO_ACCESS = 'No Access';

  /**
   * @description  to handle update Customer Information.
   * @param records from trigger handler
   */
  public static void updateCustomer(List<Case> records) {
    if (USER_INFO.checkProfile(NO_ACCESS)) {
      return;
    }
    Set<Id> accountIds = ListUtil.getIds(records, case.AccountId);
    Map<Id, Account> accountMap = new Map<Id, Account>(
      COMPLAINTS_REPOSITORY.findAccountsByAccountIds(accountIds)
    );

    for (Case c : records) {
      if (!accountMap.containsKey(c.AccountId)) {
        continue;
      }
      Account acc = accountMap.get(c.AccountId);
      c.OCV_Id__c = acc.OCV_ID__c;
      c.IDR_CC_Country__c = getCountry(acc);
      c.IDR_CC_Age__c = DateTimeUtils.getAge(acc.PersonBirthDate);
      c.IDR_CC_Postcode__c = getPostalCode(acc);
      c.IDR_Customer_Number__c = acc.Source_System_ID__c;
      c.CPID__c = acc.CPID__c;
      c.IDR_CC_Gender__c = acc.Gender__pc;
      c.IDR_Customer_Identifier__c = IDRConstants.CUSTOMER_IDENTIFIER_CAP_ID;
    }
  }

  private static String getCountry(Account acc) {
    if (acc.RecordTypeId != RTAccount.businessAccount) {
      return acc.PersonOtherCountry;
    }
    if (String.isBlank(acc.ShippingCountry)) {
      return acc.BillingCountry;
    }

    return acc.ShippingCountry;
  }

  private static String getPostalCode(Account acc) {
    if (acc.RecordTypeId != RTAccount.businessAccount) {
      return acc.PersonOtherPostalCode;
    }
    if (String.isBlank(acc.ShippingPostalCode)) {
      return acc.BillingPostalCode;
    }

    return acc.ShippingPostalCode;
  }
}
