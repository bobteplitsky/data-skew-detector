@isTest
public with sharing class DSD_TestOwnerDataSkewBatch {
    
    @isTest
    static void TestLeadOwnershipWithSkew() {

        Integer skewThresholdForTest = 10;
        String childObject = 'Lead';
        Integer childObjectCount = 150;
        Integer childObjectCountWithoutSkew = 2;

        User u = DSD_TestSupport.getTestUser();
        System.assert(u != null);

        Lead[] leadsWithSkew = DSD_TestSupport.initTestLeads('dsd_testlead', childObjectCount);
        for(Lead l : leadsWithSkew) l.OwnerId = u.Id;
        insert leadsWithSkew;

        // add some leads not owned by this user to make sure they don't get counted in the skew count
        User u2 = DSD_TestSupport.initTestUser('mytestuser', 'testu');
        insert u2;
        Lead[] leadsWithoutSkew = DSD_TestSupport.initTestLeads('dsd_leadswithoutskew', childObjectCountWithoutSkew);
        for(Lead l : leadsWithoutSkew) l.OwnerId = u2.Id;
        insert leadsWithoutSkew;

        Test.startTest();
        DSD_Settings__c settings = DSD_SettingsSupport.getOwnerSettings();
        settings.Skew_Threshold__c = skewThresholdForTest;
        settings.Child_Object_API_Name__c = childObject;
        DSD_SettingsSupport.testOwnerSettings = settings;
        Database.executeBatch(new DSD_OwnerDataSkewBatch(childObject));
        Test.stopTest();

        DSD_Data_Skew_Result__c[] results = DSD_ResultsSupport.getResultsByType(DSD_SettingsSupport.SKEW_TYPE_OWNER);
        
        System.assertEquals(1, results.size());
        System.assertEquals(u.Id, results[0].DSD_Skewed_Record_ID__c);
        System.assertEquals(childObjectCount, results[0].DSD_Skew_Record_Count__c, 'Skew record count is incorrect');
        System.assertEquals('User', results[0].DSD_Parent_Object_API_Name__c, 'Parent object should be User but is not');
        System.assertEquals(childObject, results[0].DSD_Child_Object_API_Name__c, 'Child object should be Lead but is not');
    }

    @isTest
    static void TestLeadOwnershipWithoutSkew() {

        Integer skewThresholdForTest = 10000;
        String childObject = 'Lead';
        Integer childObjectCount = 150;
        
        User u = DSD_TestSupport.getTestUser();
        System.assert(u != null);

        Lead[] leadsWithSkew = DSD_TestSupport.initTestLeads('dsd_testlead', childObjectCount);
        for(Lead l : leadsWithSkew) l.OwnerId = u.Id;
        insert leadsWithSkew;

        Test.startTest();
        DSD_Settings__c settings = DSD_SettingsSupport.getOwnerSettings();
        settings.Skew_Threshold__c = skewThresholdForTest;
        settings.Child_Object_API_Name__c = childObject;
        DSD_SettingsSupport.testOwnerSettings = settings;
        Database.executeBatch(new DSD_OwnerDataSkewBatch(childObject));
        Test.stopTest();

        DSD_Data_Skew_Result__c[] results = DSD_ResultsSupport.getResultsByType(DSD_SettingsSupport.SKEW_TYPE_OWNER);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void TestLeadOwnershipReportOtherCounts() {

        Integer skewThresholdForTest = 10000;
        Integer reportOtherThreshold = 10;
        String childObject = 'Lead';
        Integer childObjectCount = 150;
        
        User u = DSD_TestSupport.getTestUser();
        System.assert(u != null);

        Lead[] leadsWithSkew = DSD_TestSupport.initTestLeads('dsd_testlead', childObjectCount);
        for(Lead l : leadsWithSkew) l.OwnerId = u.Id;
        insert leadsWithSkew;

        Test.startTest();
        DSD_Settings__c settings = DSD_SettingsSupport.getOwnerSettings();
        settings.Skew_Threshold__c = skewThresholdForTest;
        settings.Child_Object_API_Name__c = childObject;
        settings.Report_Other_Record_Counts__c = true;
        settings.Reporting_Threshold__c = reportOtherThreshold;
        DSD_SettingsSupport.testOwnerSettings = settings;
        Database.executeBatch(new DSD_OwnerDataSkewBatch(childObject));
        Test.stopTest();

        DSD_Data_Skew_Result__c[] results = DSD_ResultsSupport.getResultsByType(DSD_SettingsSupport.SKEW_TYPE_OWNER);
        System.assertEquals(1, results.size());
        System.assertEquals(u.Id, results[0].DSD_Skewed_Record_ID__c);
        System.assertEquals(childObjectCount, results[0].DSD_Skew_Record_Count__c, 'Reported record count is incorrect');
        System.assertEquals('User', results[0].DSD_Parent_Object_API_Name__c, 'Parent object should be User but is not');
        System.assertEquals(childObject, results[0].DSD_Child_Object_API_Name__c, 'Child object should be Lead but is not');
    }
}
