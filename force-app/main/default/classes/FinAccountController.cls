/**
 * @author Pragya Awasthi
 * @since 02/2025
 * @description FinAccountController retrieves External account Id for the viewAccountDetails LWC
 * @runTests FinAccountControllerTest
 */
public with sharing class FinAccountController {
  private static final FinAccountRepository FIN_ACCOUNT_REPOSITORY = (FinAccountRepository) Lib_InstanceProvider.forType(
    FinAccountRepository.class
  );
  private static final Map<String, String> MAP_PRODUCT_CODE_TO_OBJECT = new Map<String, String>{
    'DDA' => 'Deposit_Account__x',
    'FM' => 'Deposit_Account__x',
    'SSI' => 'Deposit_Account__x',
    'RSV' => 'Deposit_Account__x',
    'ILS' => 'Loan_Account__x',
    'CDA' => 'Term_Deposit__x',
    'OLL' => 'Other_Limits_and_Liabilities__x',
    'PTF' => 'Portfolio_Of_Loan__x',
    'PCA' => 'Credit_Card__x'
  };
  @AuraEnabled(cacheable=true)
  /**
   * @description get External Account Record Id
   * @name getExternalRecordId
   * @param recordId Financial Account record Id
   * @return recordId External Account record Id
   */
  public static String getExternalRecordId(String recordId) {
    try {
      FinServ__FinancialAccount__c finAccount = FIN_ACCOUNT_REPOSITORY.getFinAccountDetails(
        recordId
      );

      if (finAccount == null) {
        throw new AuraHandledException(
          'No Financial account found for the given record Id'
        );
      }

      String externalId =
        finAccount.Account_Key__c +
        '|' +
        finAccount.Product_Code_Display__c +
        '-' +
        finAccount.FinServ__FinancialAccountNumber__c;

      String objName = MAP_PRODUCT_CODE_TO_OBJECT.get(
        finAccount.Product_Code_Display__c
      );

      SObject record = FIN_ACCOUNT_REPOSITORY.getExternalAccountDetails(
        externalId,
        objName
      );
      return record != null ? (String) record.get('Id') : null;
    } catch (QueryException e) {
      throw new AuraHandledException('No external record found');
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }
}
