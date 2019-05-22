public with sharing class DSD_TestSupport {
    
    public static List<Account> initTestAccounts(String prefix, Integer count) {
        List<Account> accts = new List<Account>();
        for(Integer i = 1; i <= count; i++){
            accts.add(new Account(Name=prefix + String.valueOf(i)));
        }
        return accts;
    }

    public static List<Contact> addContactsToAccounts(List<Account> accts, Integer count) {
        List<Contact> contacts = new List<Contact>();
        for(Account a : accts) {
            for(Integer i = 1; i <= count; i++) {
                contacts.add(new Contact(FirstName='Test', LastName='LastName' + String.valueOf(i), AccountId=a.Id));
            }
        }
        return contacts;
    }

    public static List<Lead> initTestLeads(String prefix, Integer count) {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 1; i <= count; i++){
            leads.add(new Lead(LastName=prefix + String.valueOf(i), Company=prefix + String.valueOf(i)));
        }
        return leads;
    }

    public static User getTestUser() {
	 	User[] users = [SELECT Id FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name='System Administrator') and IsActive=true LIMIT 1];
        return users.size() > 0 ? users[0] : null;
	}

    public static User initTestUser(String username, String thealias) {
        User u = new User(Alias = thealias, Email = username + '@milenine.com', FirstName='Joe', LastName= username, TimeZoneSidKey = 'America/Los_Angeles', UserName = username + '@milenine.com', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey = 'en_US');
        u.ProfileId = UserInfo.getProfileId();
        return u;
    }
}