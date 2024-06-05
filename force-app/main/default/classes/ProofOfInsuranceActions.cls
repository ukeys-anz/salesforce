/**
 * @author Peter Charalambous
 * @since Mon Mar 25 2024
 * @description class for proof of insurance actions
 */
public with sharing class ProofOfInsuranceActions {
  /**
   * @description Find and populate the fields with customer name via ocv id
   * @param records records to populate with customer name
   */
  public static void populateCustomerName(List<Proof_of_Insurance__c> records) {
    List<String> verifiedByOCVIds = filterVerifiedByRecords(records);
    updateVerifiedBy(records, verifiedByOCVIds);
  }

  /**
   * @description Filter records to retrieve only those with a Verified_By__c value
   * @param records records to filter
   * @return List<String>
   */
  private static List<String> filterVerifiedByRecords(
    List<Proof_of_Insurance__c> records
  ) {
    List<String> verifiedByOCVIds = new List<String>();
    //Populate list with OCV Ids provided
    for (Proof_of_Insurance__c record : records) {
      if (record.Verified_By__c != null) {
        verifiedByOCVIds.add(record.Verified_By__c);
      }
    }
    return verifiedByOCVIds;
  }

  /**
   * @description Update the verified by with customer account name
   * @param records records to populate with customer name
   * @param verifiedByOCVIds OCV ids to retrieve the accounts from
   */
  private static void updateVerifiedBy(
    List<Proof_of_Insurance__c> records,
    List<String> verifiedByOCVIds
  ) {
    Map<String, String> ocvIdNames = new Map<String, String>();
    //Query for OCV Ids from lists
    for (Account acc : [
      SELECT Id, OCV_ID__c, Name
      FROM Account
      WHERE ANZx_Customer__c = TRUE AND OCV_ID__c IN :verifiedByOCVIds
    ]) {
      ocvIdNames.put(acc.OCV_ID__c, acc.Name);
    }

    //Loop through records and update the values to be the name provided from the account
    for (Proof_of_Insurance__c record : records) {
      record.Verified_By__c = ocvIdNames.get(record.Verified_By__c);
    }
  }
}
