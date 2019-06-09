global without sharing class DSD_ContactTestDataGeneratorBatch implements Database.Batchable<Contact> {
    
    private Set<id> accountIds;
    
    global DSD_ContactTestDataGeneratorBatch(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    global List<Contact> start(Database.BatchableContext bc) {
        List<Account> acts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        List<Contact> cts = new List<Contact>();
        cts.addAll(DSD_TestSupport.addContactsToAccounts(acts, 10000));
        return cts;
    }

    global void execute(Database.BatchableContext bc, List<Contact> cts) {
        insert cts;
    }

    global void finish(Database.BatchableContext bc) {
    }
}
