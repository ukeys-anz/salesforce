/**
 * @author Vidhya Raghavan
 * @since Dec 2023
 * @description Test class for SOPDebt model
 */

@isTest
public with sharing class SOPDebtTest {
  @isTest
  static void testJointNameWhenFirstOwnerNameExist() {
    SOPDebt sopDebt = new SOPDebt();
    List<SOPOwnership> ownerships = new List<SOPOwnership>();
    sopDebt.ownership = ownerships;

    //create ownerships
    SOPOwnership ownership1 = new SOPOwnership();
    ownership1.partyId = 'partyId1';
    ownerships.add(ownership1);

    SOPOwnership ownership2 = new SOPOwnership();
    ownership2.partyId = 'partyId2';
    ownerships.add(ownership2);

    //Set mock party to account map to avoid query
    ResidentialLoanApplicationModel.partyIdToAccountMap = new Map<String, Account>();
    Account account1 = new Account(FirstName = 'FirstName1');
    ResidentialLoanApplicationModel.partyIdToAccountMap.put(
      'partyId1',
      account1
    );

    Account account2 = new Account(FirstName = 'FirstName2');
    ResidentialLoanApplicationModel.partyIdToAccountMap.put(
      'partyId2',
      account2
    );

    System.assertEquals('FirstName1', sopDebt.jointOwnerName, 'Expected Value');
  }

  @isTest
  static void testJointNameWhenFirstOwnerNameDoesNotExist() {
    SOPDebt sopDebt = new SOPDebt();
    List<SOPOwnership> ownerships = new List<SOPOwnership>();
    sopDebt.ownership = ownerships;

    //create ownerships
    SOPOwnership ownership1 = new SOPOwnership();
    ownership1.partyId = 'partyId1';
    ownerships.add(ownership1);

    SOPOwnership ownership2 = new SOPOwnership();
    ownership2.partyId = 'partyId2';
    ownerships.add(ownership2);

    //Set mock party to account map so that this test will not query
    ResidentialLoanApplicationModel.partyIdToAccountMap = new Map<String, Account>();
    Account account1 = new Account();
    account1.Name = null;
    ResidentialLoanApplicationModel.partyIdToAccountMap.put(
      'partyId1',
      account1
    );

    Account account2 = new Account(FirstName = 'FirstName2');
    account2.Name = 'FirstName2';
    ResidentialLoanApplicationModel.partyIdToAccountMap.put(
      'partyId2',
      account2
    );

    System.assertEquals('FirstName2', sopDebt.jointOwnerName, 'Expected Value');
  }

  @isTest
  static void testJointNameWhenForSingleOwner() {
    SOPDebt sopDebt = new SOPDebt();
    List<SOPOwnership> ownerships = new List<SOPOwnership>();
    sopDebt.ownership = ownerships;

    //create ownerships
    SOPOwnership ownership1 = new SOPOwnership();
    ownership1.partyId = 'partyId1';
    ownerships.add(ownership1);

    //Set mock party to account map so that this test will not query
    ResidentialLoanApplicationModel.partyIdToAccountMap = new Map<String, Account>();
    Account account1 = new Account(FirstName = 'FirstName1');
    ResidentialLoanApplicationModel.partyIdToAccountMap.put(
      'partyId1',
      account1
    );

    System.assertEquals('FirstName1', sopDebt.jointOwnerName, 'Expected Value');
  }
}
