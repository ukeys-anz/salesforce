/**
 * @author Pooja Kirtishahi
 * @date Oct 2024
 * @description Test class for {@link OffsetAccountHelper}
 */

@isTest
public class OffsetAccountHelperTest {
  private static OffsetAccountModel getOffsetData() {
    StaticResource mockResponse = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_linkedOffsetAccount'
      WITH SECURITY_ENFORCED
    ];

    String offsetStr = (mockResponse.Body.toString()).replace('accounts/', '');
    OffsetAccountModel offsetDetails = OffsetAccountModel.parse(offsetStr);
    return offsetDetails;
  }

  @isTest
  static void testGetFinAccNumberList() {
    Test.startTest();
    OffsetAccountModel mockOffsetDetails = getOffsetData();
    List<String> finAccNumberList = OffsetAccountHelper.getFinAccNumberList(
      mockOffsetDetails.loan_offsets
    );
    Test.stopTest();

    Assert.areEqual(
      finAccNumberList[0],
      mockOffsetDetails.loan_offsets[0].offset_accounts[0],
      'Offset account is available in response'
    );
  }

  @isTest
  static void testTransformDataForUI() {
    String offsetId = '111111111';

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      FinServ__FinancialAccountNumber__c = offsetId
    );
    OffsetAccountModel mockOffsetDetails = getOffsetData();
    Map<String, FinServ__FinancialAccount__c> offsetFinAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    offsetFinAccountMap.put(offsetId, finAccount);
    Test.startTest();
    List<OffsetAccountModel.LoanOffsets> linkedOffsetResponse = OffsetAccountHelper.transformDataForUI(
      mockOffsetDetails.loan_offsets,
      offsetFinAccountMap
    );

    Test.stopTest();
    Assert.areEqual(
      mockOffsetDetails.loan_offsets[0].offset_accounts[0],
      linkedOffsetResponse[0].offsetDetails[0].financialAccountNumber,
      'Offset account is available in response'
    );
  }

  @isTest
  static void testTransformDataForUINullException() {
    Exception resultException;
    Test.startTest();
    try {
      OffsetAccountHelper.transformDataForUI(null, null);
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();
    Assert.areEqual(
      'Attempt to de-reference a null object',
      resultException.getMessage(),
      'Should throw null pointer exception'
    );
  }

  @isTest
  static void testGetFinAccNumberListNullException() {
    Exception resultException;
    Test.startTest();
    try {
      OffsetAccountHelper.getFinAccNumberList(null);
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();
    Assert.areEqual(
      'Attempt to de-reference a null object',
      resultException.getMessage(),
      'Should throw null pointer exception'
    );
  }
}
