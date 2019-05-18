public inherited sharing class DSD_ResultsSupport {
    
    @TestVisible public static final String SKEW_TYPE_ACCOUNT = 'Account';
    @TestVisible public static final String SKEW_TYPE_OWNER = 'Owner';

    public static List<DSD_Data_Skew_Result__c> saveResults(DSD_Data_Skew_Detector_Settings__mdt settings, Map<Id, Integer> parentChildRecCountMap) {
        hardDeleteResults(settings.DSD_Skew_Type__c);
        DSD_Data_Skew_Result__c[] results = new DSD_Data_Skew_Result__c[]{};
        
        for(Id recId : parentChildRecCountMap.keySet()) {
            results.add(new DSD_Data_Skew_Result__c(
                DSD_Child_Object_API_Name__c = settings.DSD_Child_Object_API_Name__c,
                DSD_Parent_Object_API_Name__c = settings.DSD_Parent_Object_API_Name__c,
                DSD_Reporting_Threshold__c = settings.DSD_Reporting_Threshold__c,
                DSD_Skew_Record_Count__c = parentChildRecCountMap.get(recId),
                DSD_Skew_Threshold__c = settings.DSD_Skew_Threshold__c,
                DSD_Skew_Type__c = settings.DSD_Skew_Type__c,
                DSD_Skewed_Record_ID__c = recId
            ));
        }

        insert results;
        return results;
    }

    public static void hardDeleteResults(String skewType) {
        Database.DeleteResult[] results = Database.delete([SELECT Id FROM DSD_Data_Skew_Result__c WHERE DSD_Skew_Type__c = :skewType LIMIT 50000], false);

        DSD_UtilityFunctions.hardDeleteObjects(results);
    }

    @TestVisible 
    public static List<DSD_Data_Skew_Result__c> getAllResults() {
        return getResultsByType(null);
    }

    @TestVisible
    public static List<DSD_Data_Skew_Result__c> getResultsByType(String skewType) {
        String query = 'SELECT DSD_Child_Object_API_Name__c, DSD_Parent_Object_API_Name__c, DSD_Reporting_Threshold__c, DSD_Skew_Record_Count__c, DSD_Skew_Threshold__c, DSD_Skew_Type__c, DSD_Skewed_Record_ID__c FROM DSD_Data_Skew_Result__c';

        if(skewType != '' && skewType != null) query += ' WHERE DSD_Skew_Type__c = :skewType';

        return Database.query(query);
    }
}
