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
        Case c = newCases[0];
        System.assertEquals(c.CaseNumber, c.CaseNumber__c, 'CaseNumber__c should be equal to CaseNumber.');
    }
    @isTest private static void testCaseNumberNoCopy() {
        // GIVEN cases which already have their case number copied
        Case[] casesWithNumber = new List<Case>();
        for(Integer i=0; i<Integer.valueOf(Label.Test_Bulk_Size); i++) {
            casesWithNumber.add(new Case(CaseNumber__c='123'));
        }
        // WHEN they are inserted
        insert casesWithNumber;
        // THEN CaseNumber is not copied into CaseNumber__c
        Case c = casesWithNumber[0];
        System.assertNotEquals(c.CaseNumber, c.CaseNumber__c, 'CaseNumber should not have been copied.');
        System.assertEquals('123', c.CaseNumber__c, 'CaseNumber__c should not have changed.');
    }
}