public without sharing class DSD_LookupDataSkewBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // vars that maintain initial state 
    private final String parentObjectName;
    private final String childObjectName;
    private final String childFieldName;
    private final DSD_Settings__c lookupSettings;

    // vars that maintain state across batches
    private Map<Id, Integer> childCountMap;
    private List<DSD_LookupDataSkewBatch.DSD_LookupSkewChildObject> childrenToProcess;

    public DSD_LookupDataSkewBatch(String parentObjectName, List<Schema.ChildRelationship> crs) {
        // this will throw an exception if objectApiName is invalid, and will halt execution of the batch job
        Schema.DescribeSObjectResult[] result = Schema.describeSObjects(new List<String>{parentObjectName});
        DSD_ResultsSupport.hardDeleteResults(DSD_SettingsSupport.SKEW_TYPE_LOOKUP);
        this.lookupSettings = DSD_SettingsSupport.getLookupSettings();
        this.childCountMap = new Map<Id, Integer>();
        this.parentObjectName = parentObjectName;
        
        this.childrenToProcess = new List<DSD_LookupDataSkewBatch.DSD_LookupSkewChildObject>();

        for(Schema.ChildRelationship cr : crs) {
            this.childrenToProcess.add(new DSD_LookupDataSkewBatch.DSD_LookupSkewChildObject(cr));
        }

        this.childObjectName = this.childrenToProcess[0].ObjectName;
        this.childFieldName = this.childrenToProcess[0].FieldName;
        this.childrenToProcess.remove(0);
    }

    private DSD_LookupDataSkewBatch(String parentObjectName, List<DSD_LookupDataSkewBatch.DSD_LookupSkewChildObject> childrenToProcess, Boolean deleteOldResults) {
        if(deleteOldResults) DSD_ResultsSupport.hardDeleteResults(DSD_SettingsSupport.SKEW_TYPE_LOOKUP);

        this.lookupSettings = DSD_SettingsSupport.getLookupSettings();
        this.childCountMap = new Map<Id, Integer>();
        this.parentObjectName = parentObjectName;

        this.childrenToProcess = new List<DSD_LookupDataSkewBatch.DSD_LookupSkewChildObject>();

        this.childrenToProcess = childrenToProcess;
        this.childObjectName = this.childrenToProcess[0].ObjectName;
        this.childFieldName = this.childrenToProcess[0].FieldName;
        this.childrenToProcess.remove(0);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM ' + parentObjectName);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        Id parentId;
        Integer childCount;

        for (AggregateResult ar : Database.query('SELECT COUNT(Id) ChildCount,' + childFieldName + ' FROM ' + childObjectName + ' WHERE ' + childFieldName + ' IN :scope GROUP BY ' + childFieldName)) {
            
            parentId = (Id)ar.get(childFieldName);
            childCount = (Integer)ar.get('ChildCount');

            if(childCount >= lookupSettings.Skew_Threshold__c) {
                childCountMap.put(parentId, childCount);
            }
            else if(lookupSettings.Report_Other_Record_Counts__c) {
                if(childCount >= lookupSettings.Reporting_Threshold__c) {
                    childCountMap.put(parentId, childCount);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        DSD_ResultsSupport.saveResults(lookupSettings, childCountMap);
        
        if(childrenToProcess.size() > 0){
            Database.executeBatch(new DSD_LookupDataSkewBatch(parentObjectName, childrenToProcess, false));
        }
    }

    public class DSD_LookupSkewChildObject {
        public String ObjectName { get; private set; }
        public String FieldName { get; private set; }

        public DSD_LookupSkewChildObject(Schema.ChildRelationship cr) {
            this.ObjectName = cr.getChildSObject().getDescribe().getName();
            this.FieldName = cr.getField().getDescribe().getName();
        }
    }
}
