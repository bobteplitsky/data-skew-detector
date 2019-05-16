public with sharing class DSD_Settings {

    public static DSD_Data_Skew_Detector_Settings__mdt testAccountSettings;
    private static DSD_Data_Skew_Detector_Settings__mdt accountSettings;

    public static DSD_Data_Skew_Detector_Settings__mdt getAccountSettings() {

        if(accountSettings != null) return accountSettings;

        if(Test.isRunningTest() && testAccountSettings != null) {
            accountSettings = testAccountSettings;
            return accountSettings;
        }

        accountSettings = getSingleRecord('DSD_Account_Settings');
        return accountSettings;
    }

    private static DSD_Data_Skew_Detector_Settings__mdt getSingleRecord(String apiName) {
        return [SELECT MasterLabel,
            QualifiedApiName,
            DSD_Skew_Type__c, 
            DSD_Skew_Threshold__c, 
            DSD_Report_Other_Record_Counts__c, 
            DSD_Reporting_Threshold__c 
            FROM DSD_Data_Skew_Detector_Settings__mdt 
            WHERE QualifiedApiName = :apiName];
    }
}
