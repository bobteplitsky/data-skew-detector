public with sharing class DSD_UtilityFunctions {
    
    public static void hardDeleteObjects(List<Database.DeleteResult> drs){
		List<ID> drids = new List<ID>();
		for(Database.DeleteResult dr: drs)
		{
			if(dr.isSuccess()) drids.add(dr.id);
			if(drids.size()==199)
			{
				Database.emptyRecycleBin(drids); drids.clear();
			}				
		}
		if(drids.size()>0) Database.emptyRecycleBin(drids);
	}

	@AuraEnabled(cacheable=true)
	public static String getAccountReportId(){
		List<Report> reports = [SELECT Id FROM Report WHERE DeveloperName = 'DSD_Account_Data_Skew_Results'];
		if(reports.size() == 0) return null;
		return reports[0].Id;
	}
}
