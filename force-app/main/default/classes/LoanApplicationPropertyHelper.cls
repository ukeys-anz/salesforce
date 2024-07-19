/**
 * @description helper class for Loan Application Property Object
 * @author @fangl6
 * @since 12/06/2024
 */
public with sharing class LoanApplicationPropertyHelper {
  private static final LoanApplicationPropertyRepository LOAN_PROPERTY_REPOSITORY = (LoanApplicationPropertyRepository) Lib_InstanceProvider.forType(
    LoanApplicationPropertyRepository.class
  );
  /**
   * @description filter out the  properties that have assessment id updated
   * @param records records from trigger new
   * @param oldMap old map from trigger
   * @return  `Map<Id,LoanApplicationProperty>>` filtered properties in map of applicaition Id
   */
  public static Map<Id, LoanApplicationProperty> updatedAssessmentIdProperties(
    List<LoanApplicationProperty> records,
    Map<Id, LoanApplicationProperty> oldMap
  ) {
    Map<Id, LoanApplicationProperty> updatedAssessmentIdProperties = new Map<Id, LoanApplicationProperty>();

    for (LoanApplicationProperty property : records) {
      if (
        property.Collateral_Assessment_ID__c !=
        oldMap.get(property.Id).get('Collateral_Assessment_ID__c')
      ) {
        updatedAssessmentIdProperties.put(property.LoanApplicationId, property);
      }
    }
    return updatedAssessmentIdProperties;
  }

  /**
   * @description update case with value from related property record
   * @param cases list of case
   * @param propertyMap map of application id and property record
   * @return  `List<Case>` cases with updated values
   */
  public static List<Case> updateCaseValues(
    List<Case> cases,
    Map<Id, LoanApplicationProperty> propertyMap
  ) {
    List<Case> casewithNewValues = new List<Case>();

    for (Case c : cases) {
      c.Property_Valuation_Id__c = propertyMap.get(c.Loan_Application__c)
        .Collateral_Assessment_ID__c;
      casewithNewValues.add(c);
    }
    return casewithNewValues;
  }
}
