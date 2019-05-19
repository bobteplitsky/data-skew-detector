public with sharing class DSD_Settings {

    public static DSD_Data_Skew_Detector_Settings__mdt testAccountSettings;
    private static DSD_Data_Skew_Detector_Settings__mdt accountSettings;

    public static DSD_Data_Skew_Detector_Settings__mdt getAccountSkewSettings() {

        if(accountSettings != null) return accountSettings;

        if(Test.isRunningTest() && testAccountSettings != null) {
            accountSettings = testAccountSettings;
            return accountSettings;
        }

        accountSettings = getSingleRecord('DSD_Account_Settings');
        return accountSettings;
    }

    public static DSD_Data_Skew_Detector_Settings__mdt testOwnerSettings;
    private static DSD_Data_Skew_Detector_Settings__mdt ownerSettings;

    public static DSD_Data_Skew_Detector_Settings__mdt getOwnerSkewSettings() {

        if(ownerSettings != null) return ownerSettings;

        if(Test.isRunningTest() && testOwnerSettings != null) {
            ownerSettings = testOwnerSettings;
            return ownerSettings;
        }

        ownerSettings = getSingleRecord('DSD_Owner_Settings');
        return ownerSettings;
    }

    public static DSD_Data_Skew_Detector_Settings__mdt testLookupSettings;
    private static DSD_Data_Skew_Detector_Settings__mdt lookupSettings;

    public static DSD_Data_Skew_Detector_Settings__mdt getLookupSkewSettings() {

        if(lookupSettings != null) return lookupSettings;

        if(Test.isRunningTest() && testLookupSettings != null) {
            lookupSettings = testLookupSettings;
            return lookupSettings;
        }

        lookupSettings = getSingleRecord('DSD_Lookup_Settings');
        return lookupSettings;
    }

    private static DSD_Data_Skew_Detector_Settings__mdt getSingleRecord(String apiName) {
        return [SELECT MasterLabel,
            QualifiedApiName,
            DSD_Skew_Type__c, 
            DSD_Skew_Threshold__c, 
            DSD_Report_Other_Record_Counts__c, 
            DSD_Reporting_Threshold__c,
            DSD_Child_Object_API_Name__c,
            DSD_Parent_Object_API_Name__c
            FROM DSD_Data_Skew_Detector_Settings__mdt 
            WHERE QualifiedApiName = :apiName];
    }
}
