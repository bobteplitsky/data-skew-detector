public without sharing class DSD_SettingsSupport {

    // data skew type constants
    @TestVisible public static final String SKEW_TYPE_ACCOUNT = 'Account';
    @TestVisible public static final String SKEW_TYPE_OWNER = 'Owner';
    @TestVisible public static final String SKEW_TYPE_LOOKUP = 'Lookup';

    public static DSD_Settings__c testAccountSettings;
    private static DSD_Settings__c accountSettings;
    private static DSD_SettingsSupport.SettingsWrapper accountSettingsWrapped;

    public static DSD_Settings__c getAccountSettings() {
        
        if(accountSettings != null) return accountSettings;

        if(Test.isRunningTest() && testAccountSettings != null) {
            accountSettings = testAccountSettings;
            return accountSettings;
        }

        accountSettings = DSD_Settings__c.getInstance(SKEW_TYPE_ACCOUNT);
        if(accountSettings != null) return accountSettings;

        accountSettings = initDefaultAccountSettings();
        insert accountSettings;
        return accountSettings;
    }

    public static DSD_Settings__c getAccountSettings(Boolean bypassCache) {
        if(bypassCache) accountSettings = null;
        return getAccountSettings();
    }

    @AuraEnabled
    public static Boolean saveAccountSettings(String accountSettings){
        try {
            //return false;
            DSD_SettingsSupport.SettingsWrapper w = (DSD_SettingsSupport.SettingsWrapper)JSON.deserialize(accountSettings, DSD_SettingsSupport.SettingsWrapper.class);

            DSD_Settings__c s = getAccountSettings();
            s.Skew_Threshold__c = w.skewThreshold;
            if(w.reportingThreshold != null || w.reportingThreshold > 0){
                s.Report_Other_Record_Counts__c = true;
                s.Reporting_Threshold__c = w.reportingThreshold;
            }
            else{
                s.Report_Other_Record_Counts__c = false;
                s.Reporting_Threshold__c = null;
            }

            update s;
            return true;
        }
        catch(Exception ex){
            return false;
        }
    }

    @AuraEnabled
    public static DSD_SettingsSupport.SettingsWrapper getAccountSettingsWrapped() {
        if(accountSettingsWrapped != null) return accountSettingsWrapped;
        accountSettingsWrapped = wrapSettings(getAccountSettings());
        accountSettingsWrapped.parentObjectCount = DSD_AccountDataSkewBatch.getAccountCount();
        return accountSettingsWrapped;
    }

    public static DSD_Settings__c testOwnerSettings;
    private static DSD_Settings__c ownerSettings;

    public static DSD_Settings__c getOwnerSettings() {

        if(ownerSettings != null) return ownerSettings;

        if(Test.isRunningTest() && testOwnerSettings != null) {
            ownerSettings = testOwnerSettings;
            return ownerSettings;
        }

        ownerSettings = DSD_Settings__c.getInstance(SKEW_TYPE_OWNER);
        if(ownerSettings != null) return ownerSettings;

        ownerSettings = initDefaultOwnerSettings();
        insert ownerSettings;

        return ownerSettings;
    }

    public static DSD_Settings__c testLookupSettings;
    private static DSD_Settings__c lookupSettings;

    public static DSD_Settings__c getLookupSettings() {

        if(lookupSettings != null) return lookupSettings;

        if(Test.isRunningTest() && testLookupSettings != null) {
            lookupSettings = testLookupSettings;
            return lookupSettings;
        }

        lookupSettings = DSD_Settings__c.getInstance(SKEW_TYPE_LOOKUP);
        if(lookupSettings != null) return lookupSettings;

        lookupSettings = initDefaultLookupSettings();
        insert lookupSettings;

        return lookupSettings;
    }

    private static DSD_Settings__c initDefaultAccountSettings(){
        DSD_Settings__c accountSettings = new DSD_Settings__c();
        accountSettings.Name = SKEW_TYPE_ACCOUNT; 
        accountSettings.Skew_Type__c = SKEW_TYPE_ACCOUNT; 
        accountSettings.Skew_Threshold__c = 10000;
        accountSettings.Report_Other_Record_Counts__c = false;
        accountSettings.Parent_Object_API_Name__c = 'Account';
        accountSettings.Child_Object_API_Name__c = 'Contact';
        return accountSettings;
    }

    private static DSD_Settings__c initDefaultOwnerSettings(){
        DSD_Settings__c ownerSettings = new DSD_Settings__c();
        ownerSettings.Name = SKEW_TYPE_OWNER;
        ownerSettings.Skew_Type__c = SKEW_TYPE_OWNER;
        ownerSettings.Skew_Threshold__c = 10000;
        ownerSettings.Report_Other_Record_Counts__c = false;
        ownerSettings.Parent_Object_API_Name__c = 'User';
        return ownerSettings;
    }

    private static DSD_Settings__c initDefaultLookupSettings(){
        DSD_Settings__c lookupSettings = new DSD_Settings__c();
        lookupSettings.Name = SKEW_TYPE_LOOKUP;
        lookupSettings.Skew_Type__c = SKEW_TYPE_LOOKUP;
        lookupSettings.Skew_Threshold__c = 10000;
        lookupSettings.Report_Other_Record_Counts__c = false;
        lookupSettings.Lookup_Skew_Child_Limit__c = 10;
        return lookupSettings;
    }

    private static SettingsWrapper wrapSettings(DSD_Settings__c s) {
        DSD_SettingsSupport.SettingsWrapper w = new DSD_SettingsSupport.SettingsWrapper();
        w.id = s.Id;
        w.name = s.Name;
        w.childObjectApiName = s.Child_Object_API_Name__c;
        w.lastRunEndTime = s.Last_Run_End_Time__c;
        w.lastRunJobId = s.Last_Run_Job_Id__c;
        w.lastRunProcessedRecs = (Integer)s.Last_Run_Processed_Records__c;
        w.lastRunSkewedRecCount = (Integer)s.Last_Run_Skewed_Record_Count__c;
        w.lastRunStartTime = s.Last_Run_Start_Time__c;
        w.lastRunTotalRecs = (Integer)s.Last_Run_Total_Records__c;
        w.lookupSkewChildLimit = (Integer)s.Lookup_Skew_Child_Limit__c;
        w.parentObjectApiName = s.Parent_Object_API_Name__c;
        w.reportOtherRecCounts = s.Report_Other_Record_Counts__c;
        w.reportingThreshold = (Integer)s.Reporting_Threshold__c;
        w.skewThreshold = (Integer)s.Skew_Threshold__c;
        w.skewType = s.Skew_Type__c;
        w.parentObjectCount = 0;
        w.orgName = UserInfo.getOrganizationName();
        return w;
    }

    private static DSD_Settings__c unwrapSettings(DSD_SettingsSupport.SettingsWrapper w) {
        DSD_Settings__c s = new DSD_Settings__c();
        s.Id = w.id;
        s.Name = w.name;
        s.Child_Object_API_Name__c = w.childObjectApiName;
        s.Last_Run_End_Time__c = w.lastRunEndTime;
        s.Last_Run_Job_Id__c = w.lastRunJobId;
        s.Last_Run_Processed_Records__c = w.lastRunProcessedRecs;
        s.Last_Run_Skewed_Record_Count__c = w.lastRunSkewedRecCount;
        s.Last_Run_Start_Time__c = w.lastRunStartTime;
        s.Last_Run_Total_Records__c = w.lastRunTotalRecs;
        s.Lookup_Skew_Child_Limit__c = w.lookupSkewChildLimit;
        s.Parent_Object_API_Name__c = w.parentObjectApiName;
        s.Report_Other_Record_Counts__c = w.reportOtherRecCounts;
        s.Reporting_Threshold__c = w.reportingThreshold;
        s.Skew_Threshold__c = w.skewThreshold;
        s.Skew_Type__c = w.skewType;
        return s;
    }

    public static void unwrapAndSaveSettings(DSD_SettingsSupport.SettingsWrapper w){
        DSD_Settings__c s = unwrapSettings(w);
        if(s.Name == null) s.Name = s.Name = s.Skew_Type__c;
        upsert s;
    }

    public class SettingsWrapper {
        @AuraEnabled public String id { get;set; }
        @AuraEnabled public String name { get;set; }
        @AuraEnabled public String childObjectApiName { get;set; }
        @AuraEnabled public DateTime lastRunEndTime { get;set; }
        @AuraEnabled public String lastRunJobId { get;set; }
        @AuraEnabled public Integer lastRunProcessedRecs { get;set; }
        @AuraEnabled public Integer lastRunSkewedRecCount { get;set; }
        @AuraEnabled public DateTime lastRunStartTime { get;set; }
        @AuraEnabled public Integer lastRunTotalRecs { get;set; }
        @AuraEnabled public Integer lookupSkewChildLimit { get;set; }
        @AuraEnabled public String parentObjectApiName { get;set; }
        @AuraEnabled public Integer parentObjectCount { get;set; }
        @AuraEnabled public Boolean reportOtherRecCounts { get;set; }
        @AuraEnabled public Integer reportingThreshold { get;set; }
        @AuraEnabled public Integer skewThreshold { get;set; }
        @AuraEnabled public String skewType { get;set; }
        @AuraEnabled public String orgName { get;set; }
    }
}
