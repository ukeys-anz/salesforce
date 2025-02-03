/**
 * @author Prahlad Bhadani
 * @since  08/2024
 * @group CCRM, ML
 * @description OCRRelatedListRepository repository class.
 */
public with sharing class OCRRelatedListRepository {
  /**
   * @description get customer PersonContactId
   * @name getCustomer
   * @param recordId customer recordId
   * @return Account customer
   */
  public Account getCustomer(String recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }
    return [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :recordId AND IsPersonAccount = TRUE
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description get OCR Records.
   * @name getRecordsList
   * @param inputWrapper wrapper for inputs
   * @return List<OpportunityContactRole> records
   */
  public List<OpportunityContactRole> getRecordsList(
    OCRRelatedListController.OCRParamsWrapper inputWrapper
  ) {
    String recordId = inputWrapper.recordId;
    String personContactId = inputWrapper.personContactId;
    Integer pageSize = inputWrapper.pageSize;
    if (String.isBlank(recordId)) {
      return null;
    }
    String ocrQuery = 'SELECT OpportunityId, Opportunity.Name, Opportunity.StageName, Contact.Name,';
    ocrQuery += ' Opportunity.Amount, Opportunity.Customer_needs__c, Role, CreatedDate';
    ocrQuery += ' FROM OpportunityContactRole';
    ocrQuery +=
      ' WHERE ContactId =: personContactId AND Opportunity.AccountId != :recordId ORDER BY ' +
      String.escapeSingleQuotes(inputWrapper.sortByField) +
      ' ' +
      String.escapeSingleQuotes(inputWrapper.sortOrder) +
      ' NULLS LAST';
    ocrQuery += (pageSize != null) ? ' LIMIT :pageSize' : ' LIMIT 50000';
    return Database.query(ocrQuery, AccessLevel.USER_MODE);
  }

  /**
   * @description get count of OCR Records.
   * @name getRecordsList
   * @param personContactId customer personContactId
   * @param recordId customer recordId
   * @return Integer countOfRecords
   */
  public Integer countRecords(String personContactId, String recordId) {
    if (String.isBlank(recordId) || String.isBlank(personContactId)) {
      return 0;
    }
    String countQuery = 'SELECT COUNT() FROM OpportunityContactRole';
    countQuery += ' WHERE ContactId = :personContactId AND Opportunity.AccountId != :recordId';
    return Database.countQuery(countQuery, AccessLevel.USER_MODE);
  }
}
