@isTest
private class TestCaseProcess {
    @isTest private static void testCaseNumberCopy() {
        // GIVEN cases are created
        Case[] newCases = new List<Case>();
        for(Integer i=0; i<Integer.valueOf(Label.Test_Bulk_Size); i++) {
            newCases.add(new Case());
        }
        // WHEN they are inserted
        insert newCases;
        // THEN CaseNumber is copied into CaseNumber__c
        Case c = [SELECT CaseNumber, CaseNumber__c FROM Case WHERE id=:newCases[0].id];
        System.assertEquals(c.CaseNumber, c.CaseNumber__c, 'CaseNumber__c should be equal to CaseNumber.');
    }
    @isTest private static void testCaseNumberNoCopy() {
        // GIVEN cases which already have their case number copied
        Case[] casesWithCopiedCaseNumber = new List<Case>();
        for(Integer i=0; i<Integer.valueOf(Label.Test_Bulk_Size); i++) {
            casesWithCopiedCaseNumber.add(new Case(CaseNumber__c='123'));
        }
        // WHEN they are inserted
        insert casesWithCopiedCaseNumber;
        // THEN CaseNumber is not copied into CaseNumber__c
        Case c = [SELECT CaseNumber, CaseNumber__c FROM Case WHERE id=:casesWithCopiedCaseNumber[0].id];
        System.assertNotEquals(c.CaseNumber, c.CaseNumber__c, 'CaseNumber should not have been copied.');
        System.assertEquals('123', c.CaseNumber__c, 'CaseNumber__c should not have changed.');
    }
    @isTest private static void testCaseCardNumberMasking() {
        // GIVEN cases relate to a account/card/policy
        Case[] casesWithACPNumber = new List<Case>();
        for(Integer i=0; i<Integer.valueOf(Label.Test_Bulk_Size); i++) {
            casesWithACPNumber.add(new Case(IDR_Account_Card_Policy_Number__c='000001234'));
        }
        // WHEN they are inserted
        insert casesWithACPNumber;
        // THEN IDR_Account_Card_Policy_Number__c is masked, showing only the last four digits
        Case c =[SELECT IDR_Account_Card_Policy_Number__c FROM Case WHERE id=:casesWithACPNumber[0].id];
        System.assertEquals('*****1234', c.IDR_Account_Card_Policy_Number__c, 'IDR_Account_Card_Policy_Number__c should be masked.');
    }
}