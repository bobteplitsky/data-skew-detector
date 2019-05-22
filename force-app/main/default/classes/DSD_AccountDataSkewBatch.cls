public without sharing class DSD_AccountDataSkewBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // vars that maintain initial state 
    private final String query;
    private final DSD_Data_Skew_Detector_Settings__mdt accountSettings;

    // vars that maintain state across batches
    private Map<Id, Integer> accountContactCount;

    public DSD_AccountDataSkewBatch() {
        this.accountSettings = DSD_Settings.getAccountSkewSettings();
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

            if(contactCount >= accountSettings.DSD_Skew_Threshold__c) {
                accountContactCount.put(accountId, contactCount);
            }
            else if(accountSettings.DSD_Report_Other_Record_Counts__c) {
                if(contactCount >= accountSettings.DSD_Reporting_Threshold__c) {
                    accountContactCount.put(accountId, contactCount);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        DSD_ResultsSupport.hardDeleteResults(DSD_ResultsSupport.SKEW_TYPE_ACCOUNT);
        DSD_ResultsSupport.saveResults(accountSettings, accountContactCount);
    }
}