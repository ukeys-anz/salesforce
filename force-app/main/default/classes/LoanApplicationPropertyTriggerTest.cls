@isTest
private class LoanApplicationPropertyTriggerTest {
  @isTest
  static void coverTrigger() {
    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Name = 'Test Loan Application';
    rla.AccountId = acc.Id;
    rla.SOP_ID__c = '1234';
    insert rla;
    LoanApplicationProperty prop = new LoanApplicationProperty();
    prop.Name = 'Test Property';
    prop.LoanApplicationId = rla.Id;
    insert prop;

    Test.startTest();
    prop.PropertyValue = 500;
    update prop;
    Test.stopTest();

    System.assertEquals(
      500,
      [
        SELECT PropertyValue
        FROM LoanApplicationProperty
        WHERE LoanApplicationId = :rla.Id
        LIMIT 1
      ]
      .PropertyValue,
      'property value should be updated'
    );
  }
}
