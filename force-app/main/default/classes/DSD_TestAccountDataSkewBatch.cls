@isTest
public with sharing class DSD_TestAccountDataSkewBatch {
    
    @isTest
    static void TestAccountsWithAndWithoutSkew(){
        
        Integer skewThresholdForTest = 10;

        List<Account> acctsWithSkew = DSD_TestSupport.initTestAccounts('skewedacct', 10);
        insert acctsWithSkew;
        Map<Id, Account> acctsWithSkewMap = new Map<Id, Account>(acctsWithSkew);

        List<Contact> contacts = DSD_TestSupport.addContactsToAccounts(acctsWithSkew, 10);
        insert contacts;

        List<Account> acctsWithoutSkew = DSD_TestSupport.initTestAccounts('noskewacct', 1);
        insert acctsWithoutSkew;
        Map<Id, Account> acctsWithoutSkewMap = new Map<Id, Account>(acctsWithoutSkew);

        List<Contact> contacts2 = DSD_TestSupport.addContactsToAccounts(acctsWithoutSkew, 9);
        insert contacts2;

        Test.startTest();
        DSD_Settings__c settings = DSD_SettingsSupport.getAccountSettings();
        settings.Skew_Threshold__c = skewThresholdForTest;
        DSD_SettingsSupport.testAccountSettings = settings;
        Database.executeBatch(new DSD_AccountDataSkewBatch());
        Test.stopTest();

        DSD_Data_Skew_Result__c[] results = DSD_ResultsSupport.getResultsByType(DSD_SettingsSupport.SKEW_TYPE_ACCOUNT);
        System.assertEquals(10, results.size());
        
        for(DSD_Data_Skew_Result__c r : results) {
            System.assert(acctsWithSkewMap.containsKey(r.DSD_Skewed_Record_ID__c));
            System.assertEquals(10, r.DSD_Skew_Record_Count__c, 'Skew record count should be 10 but is not');
            System.assertEquals('Account', r.DSD_Parent_Object_API_Name__c, 'Parent object should be Account but is not');
            System.assertEquals('Contact', r.DSD_Child_Object_API_Name__c, 'Child object should be Contact but is not');
            System.assertEquals(false, acctsWithoutSkewMap.containsKey(r.DSD_Skewed_Record_ID__c), 'An account without skew was flagged as having skew');
        }
    }
}