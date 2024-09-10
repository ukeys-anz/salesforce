/**
 * @author shawg2
 * @since Jan 2024
 * @description Test class for GetHelpCaseActions
 */
@IsTest
private class GetHelpCaseActionsTest {
  @IsTest
  static void setOwnerToIDOpsQueue() {
    Account oAccount = TestDataFactory.createAccount(true);

    List<Case> lstCases = new List<Case>{
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = RTCase.profileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.OPEN_STATUS
      ),
      new Case(AccountId = oAccount.Id, RecordTypeId = RTCase.generalInquiry)
    };

    Test.startTest();

    GetHelpCaseActions.setOwnerToIDOpsQueue(lstCases);

    Test.stopTest();

    for (Case oCase : lstCases) {
      if (oCase.RecordTypeId == RTCase.profileUpdate) {
        Assert.areEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Profile Update cases should be assigned to the ID Ops Queue on insert'
        );
      } else {
        Assert.areNotEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Non-Profile Update cases should not be assigned to ID Ops Queue on insert'
        );
      }
    }
  }
}
