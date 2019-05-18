@isTest
public with sharing class DSD_TestOwnerDataSkewBatch {
    
    @isTest
    static void TestLeadOwnershipWithSkew() {

        Integer skewThresholdForTest = 10;
        String childObject = 'Lead';
        Integer childObjectCount = 150;

        User u = DSD_TestSupport.getTestUser();
        System.assert(u != null);

        Lead[] leads = DSD_TestSupport.initTestLeads('dsd_testlead', childObjectCount);
        for(Lead l : leads) l.OwnerId = u.Id;
        insert leads;

        Test.startTest();

        DSD_Data_Skew_Detector_Settings__mdt settings = DSD_Settings.getOwnerSkewSettings();
        settings.DSD_Skew_Threshold__c = skewThresholdForTest;
        settings.DSD_Child_Object_API_Name__c = childObject;
        DSD_Settings.testOwnerSettings = settings;
        Database.executeBatch(new DSD_OwnerDataSkewBatch(childObject));
        
        Test.stopTest();

        DSD_Data_Skew_Result__c[] results = DSD_ResultsSupport.getResultsByType(DSD_ResultsSupport.SKEW_TYPE_OWNER);
        System.assertEquals(1, results.size());
        
        System.assertEquals(u.Id, results[0].DSD_Skewed_Record_ID__c);
        System.assertEquals(childObjectCount, results[0].DSD_Skew_Record_Count__c, 'Skew record count should be 10 but is not');
        System.assertEquals('User', results[0].DSD_Parent_Object_API_Name__c, 'Parent object should be User but is not');
        System.assertEquals(childObject, results[0].DSD_Child_Object_API_Name__c, 'Child object should be Lead but is not');
    }
}
