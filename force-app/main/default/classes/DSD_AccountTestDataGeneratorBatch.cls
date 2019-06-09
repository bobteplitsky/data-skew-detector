global without sharing class DSD_AccountTestDataGeneratorBatch implements Database.Batchable<Account> {
    
    private final Integer contactCount;
    private final String accountPrefix;
    private final Integer accountCount;
    
    global DSD_AccountTestDataGeneratorBatch(Integer accountCount, String accountPrefix, Integer contactCount) {
        this.contactCount = contactCount;
        this.accountPrefix = accountPrefix;
        this.accountCount = accountCount;
    }

    global List<Account> start(Database.BatchableContext bc) {
        List<Account> accts = DSD_TestSupport.initTestAccounts(accountPrefix, accountCount);
        return accts;
    }

    global void execute(Database.BatchableContext bc, List<Account> accts) {
        insert accts;
        List<Contact> cts = DSD_TestSupport.addContactsToAccounts(accts, this.contactCount);
        insert cts;
    }

    global void finish(Database.BatchableContext bc) {
    }
}
