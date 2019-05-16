public with sharing class DSD_TestDataFactory {
    
    public static List<Account> GetTestAccounts(String prefix, Integer count) {
        List<Account> accts = new List<Account>();
        for(Integer i = 1; i <= count; i++){
            accts.add(new Account(Name=prefix + String.valueOf(i)));
        }
        return accts;
    }

    public static List<Contact> AddContactsToAccounts(List<Account> accts, Integer count) {
        List<Contact> contacts = new List<Contact>();
        for(Account a : accts) {
            for(Integer i = 1; i <= count; i++) {
                contacts.add(new Contact(FirstName='Test', LastName='LastName' + String.valueOf(i), AccountId=a.Id));
            }
        }
        return contacts;
    }
}