global without sharing class DSD_AccountTestDataGeneratorBatch implements Database.Batchable<Account> {
    
    // adding comment to master branch 
    
    private final Integer contactCount;
    private final String accountPrefix;
    private final Integer accountCount;
    
    global DSD_AccountTestDataGeneratorBatch(Integer accountCount, String accountPrefix, Integer contactCount) {
        this.contactCount = contactCount;
        this.accountPrefix = accountPrefix;
        this.accountCount = accountCount;
    }

    global List<Account> start(Database.BatchableContext bc) {
        return DSD_TestSupport.initTestAccounts(accountPrefix, accountCount);
    }

    global void execute(Database.BatchableContext bc, List<Account> accts) {
        insert accts;
        List<Contact> cts = DSD_TestSupport.addContactsToAccounts(accts, this.contactCount);
        insert cts;
    }

    global void finish(Database.BatchableContext bc) {
    }
}
