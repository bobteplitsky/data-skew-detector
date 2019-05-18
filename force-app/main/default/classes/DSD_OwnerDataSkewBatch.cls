public without sharing class DSD_OwnerDataSkewBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // vars that maintain initial state 
    private final String objectApiName;
    private final DSD_Data_Skew_Detector_Settings__mdt ownerSettings;

    // vars that maintain state across batches
    private Map<Id, Integer> ownerCountMap;

    public DSD_OwnerDataSkewBatch(String objectApiName) {
        // this will throw an exception if objectApiName is invalid, and will halt execution of the batch job
        Schema.DescribeSObjectResult[] result = Schema.describeSObjects(new List<String>{objectApiName});
        this.ownerSettings = DSD_Settings.getOwnerSkewSettings();
        this.objectApiName = objectApiName;
        this.ownerCountMap = new Map<Id, Integer>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM User WHERE IsActive = true');
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        // declare vars for use within the loop
        Id ownerId;
        Integer childCount;
        
        for (AggregateResult ar : Database.query('SELECT COUNT(Id) ChildCount, OwnerId FROM ' + this.objectApiName + ' WHERE OwnerId IN :scope GROUP BY OwnerId')) {
            
            ownerId = (Id)ar.get('OwnerId');
            childCount = (Integer)ar.get('ChildCount');

            System.debug('ownerId: ' + ownerId);
            System.debug('childCount: ' + childCount);
            System.debug('skew threshold: ' + ownerSettings.DSD_Skew_Threshold__c);

            if(childCount >= ownerSettings.DSD_Skew_Threshold__c) {
                ownerCountMap.put(ownerId, childCount);
            }
            else if(ownerSettings.DSD_Report_Other_Record_Counts__c) {
                if(childCount >= ownerSettings.DSD_Reporting_Threshold__c) {
                    ownerCountMap.put(ownerId, childCount);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        DSD_ResultsSupport.saveResults(ownerSettings, ownerCountMap);
    }
}
