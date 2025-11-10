/**
 * @author Prahlad Bhadani
 * @since  Oct 2025
 * @group Platform
 * @description OCVDuplicateTableController is controller class for ocvDuplicateTable LWC.
 */
public with sharing class OCVDuplicateTableController {
  private static final OCVDuplicateTableControllerRepository CTRL_REPOSITORY = (OCVDuplicateTableControllerRepository) Lib_InstanceProvider.forType(
    OCVDuplicateTableControllerRepository.class
  );
  /**
   * @description called from ocvDuplicateTable component
   * @name getAllCustomersByOCVId
   * @param recordId String account record id.
   * @return List<Account>
   */
  @AuraEnabled
  public static List<Account> getAllCustomersByOCVId(String recordId) {
    try {
      if (string.isBlank(recordId)) {
        return new List<Account>();
      }
      Account acc = CTRL_REPOSITORY.getCustomer(recordId);
      if (String.isBlank(acc?.OCV_Id__c)) {
        return new List<Account>();
      }
      String sourceSystemName = (acc.Source_System_Name__c == 'CAP-CIS')
        ? 'CACHE'
        : 'CAP-CIS';
      return CTRL_REPOSITORY.getAllCustomers(acc.OCV_ID__c, sourceSystemName);
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }
}
