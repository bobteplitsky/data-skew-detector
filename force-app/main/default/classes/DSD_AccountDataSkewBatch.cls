public without sharing class DSD_AccountDataSkewBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // vars that maintain initial state 
    private final String query;

    // vars that maintain state across batches
    private Map<Id, Integer> accountContactCount;
    private Integer processedRecs = 0;
    private DSD_Settings__c accountSettings;

    private static Integer accountCount;

    public DSD_AccountDataSkewBatch() {
        this.accountSettings = DSD_SettingsSupport.getAccountSettings();
        this.accountContactCount = new Map<Id, Integer>();
        this.query = 'SELECT Id FROM Account';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {

        // declare vars for use within the loop
        Id accountId;
        Integer contactCount;

        for (AggregateResult ar : [SELECT COUNT(Id) ContactCount, AccountId FROM Contact WHERE AccountId in :scope GROUP BY AccountId]) {
            
            accountId = (Id)ar.get('AccountId');
            contactCount = (Integer)ar.get('ContactCount');

            if(contactCount >= accountSettings.Skew_Threshold__c) {
                accountContactCount.put(accountId, contactCount);
            }
            else if(accountSettings.Report_Other_Record_Counts__c) {
                if(contactCount >= accountSettings.Reporting_Threshold__c) {
                    accountContactCount.put(accountId, contactCount);
                }
            }

            this.processedRecs = this.processedRecs + 1;
        }

        System.debug('processedRecs: ' + processedRecs);
    }

    public void finish(Database.BatchableContext bc) {
        DSD_ResultsSupport.hardDeleteResults(DSD_SettingsSupport.SKEW_TYPE_ACCOUNT);
        DSD_ResultsSupport.saveResults(accountSettings, accountContactCount);

        DSD_Settings__c settings = DSD_Settings__c.getInstance(DSD_SettingsSupport.SKEW_TYPE_ACCOUNT);
        settings.Last_Run_Processed_Records__c = this.processedRecs;
        settings.Last_Run_Skewed_Record_Count__c = this.accountContactCount.size();
        settings.Last_Run_End_Time__c = System.now();
        update settings;
    }

    @AuraEnabled
    public static Integer startBatchJob(String accountSettings){
        System.debug('accountSettings: ' + accountSettings);

        Integer recCount = Database.countQuery('SELECT COUNT() FROM Account');
        DSD_SettingsSupport.SettingsWrapper w = (DSD_SettingsSupport.SettingsWrapper)JSON.deserialize(accountSettings, DSD_SettingsSupport.SettingsWrapper.class);

        w.lastRunTotalRecs = recCount;
        w.lastRunProcessedRecs = 0;
        DSD_SettingsSupport.unwrapAndSaveSettings(w); 

        if(recCount > 0){
            w.lastRunJobId = Database.executeBatch(new DSD_AccountDataSkewBatch(), 20);
            w.lastRunStartTime = System.now();
            DSD_SettingsSupport.unwrapAndSaveSettings(w);
        }

        return recCount;
    }

    @AuraEnabled
    public static Boolean abortBatchJob(){
        try{
            DSD_Settings__c settings = DSD_SettingsSupport.getAccountSettings();
            if(settings.Last_Run_Job_ID__c != null) System.abortJob(settings.Last_Run_Job_ID__c);
            return true;
        }
        catch(Exception ex){
            System.debug('Exception aborting job: ' + ex.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static AsyncApexJob checkBatchStatus(){
        DSD_Settings__c settings = DSD_SettingsSupport.getAccountSettings(true);
        
        List<AsyncApexJob> jobs = [SELECT Status,
            TotalJobItems, 
            JobItemsProcessed,
            LastProcessed,
            LastProcessedOffset,
            NumberOfErrors,
            ExtendedStatus,
            CompletedDate
            FROM AsyncApexJob 
            WHERE Id = :settings.Last_Run_Job_Id__c];

        if(jobs.size() == 0) return null;
        return jobs[0];
    }

    public static Integer getAccountCount(){
        if(accountCount != null) return accountCount;
        accountCount = [SELECT COUNT() FROM Account];
        return accountCount;
    }
}