public without sharing class DSD_SettingsSupport {

    // data skew type constants
    @TestVisible public static final String SKEW_TYPE_ACCOUNT = 'Account';
    @TestVisible public static final String SKEW_TYPE_OWNER = 'Owner';
    @TestVisible public static final String SKEW_TYPE_LOOKUP = 'Lookup';

    // settings record name constants
    public static final String ACCOUNT_SETTINGS_NAME = 'Account_Settings';
    public static final String OWNER_SETTINGS_NAME = 'Owner_Settings';
    public static final String LOOKUP_SETTINGS_NAME = 'Lookup_Settings';

    public static DSD_Settings__c testAccountSettings;
    private static DSD_Settings__c accountSettings;

    @AuraEnabled(cacheable=true)
    public static DSD_Settings__c getAccountSettings() {
        
        if(accountSettings != null) return accountSettings;

        if(Test.isRunningTest() && testAccountSettings != null) {
            accountSettings = testAccountSettings;
            return accountSettings;
        }

        accountSettings = DSD_Settings__c.getInstance(ACCOUNT_SETTINGS_NAME);
        if(accountSettings != null) return accountSettings;

        accountSettings = initDefaultAccountSettings();
        insert accountSettings;
        return accountSettings;
    }

    public static DSD_Settings__c testOwnerSettings;
    private static DSD_Settings__c ownerSettings;

    public static DSD_Settings__c getOwnerSettings() {

        if(ownerSettings != null) return ownerSettings;

        if(Test.isRunningTest() && testOwnerSettings != null) {
            ownerSettings = testOwnerSettings;
            return ownerSettings;
        }

        ownerSettings = DSD_Settings__c.getInstance(OWNER_SETTINGS_NAME);
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

        lookupSettings = DSD_Settings__c.getInstance(LOOKUP_SETTINGS_NAME);
        if(lookupSettings != null) return lookupSettings;

        lookupSettings = initDefaultLookupSettings();
        insert lookupSettings;

        return lookupSettings;
    }

    private static DSD_Settings__c initDefaultAccountSettings(){
        DSD_Settings__c accountSettings = new DSD_Settings__c();
        accountSettings.Name = ACCOUNT_SETTINGS_NAME; 
        accountSettings.Skew_Type__c = SKEW_TYPE_ACCOUNT; 
        accountSettings.Skew_Threshold__c = 10000;
        accountSettings.Report_Other_Record_Counts__c = false;
        accountSettings.Parent_Object_API_Name__c = 'Account';
        accountSettings.Child_Object_API_Name__c = 'Contact';
        return accountSettings;
    }

    private static DSD_Settings__c initDefaultOwnerSettings(){
        DSD_Settings__c ownerSettings = new DSD_Settings__c();
        ownerSettings.Name = OWNER_SETTINGS_NAME;
        ownerSettings.Skew_Type__c = SKEW_TYPE_OWNER;
        ownerSettings.Skew_Threshold__c = 10000;
        ownerSettings.Report_Other_Record_Counts__c = false;
        ownerSettings.Parent_Object_API_Name__c = 'User';
        return ownerSettings;
    }

    private static DSD_Settings__c initDefaultLookupSettings(){
        DSD_Settings__c lookupSettings = new DSD_Settings__c();
        lookupSettings.Name = LOOKUP_SETTINGS_NAME;
        lookupSettings.Skew_Type__c = SKEW_TYPE_LOOKUP;
        lookupSettings.Skew_Threshold__c = 10000;
        lookupSettings.Report_Other_Record_Counts__c = false;
        lookupSettings.Lookup_Skew_Child_Limit__c = 10;
        return lookupSettings;
    }
}
