/**
 * @author Vidhya Raghavan
 * @date December 2022
 * @description Test class for {@link HomeLoanAPIRepository}
 * @group repository
 */

@isTest
public inherited sharing class HomeLoanAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
  }
  @isTest
  static void homeLoanAccountValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanAPIRepository hLoan = new HomeLoanAPIRepository();
      HomeLoanModel model = hLoan.getHomeLoanAccounts('2222');

      Test.stopTest();

      System.assertEquals(
        1,
        model.accounts.size(),
        'No home loan found with ocvId'
      );
      System.assertEquals(
        '390899946',
        model.accounts[0].account_number,
        'Account number is corresponding to OCVId'
      );
    }
  }
}
