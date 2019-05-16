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
}
