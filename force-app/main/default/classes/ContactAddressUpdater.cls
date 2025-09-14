/**
 * @description Apex class to update Contact addresses from their related Account billing address
 * @author Generated
 * @date 2024
 */
public with sharing class ContactAddressUpdater {
    
    /**
     * @description Updates all contact addresses with their related account's billing address
     * @return Database.SaveResult[] - Results of the update operation
     */
    public static Database.SaveResult[] updateAllContactAddresses() {
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();
        
        try {
            // Query all contacts with their related account billing address
            List<Contact> contacts = [
                SELECT Id, AccountId, MailingStreet, MailingCity, MailingState, 
                       MailingPostalCode, MailingCountry,
                       Account.BillingStreet, Account.BillingCity, Account.BillingState,
                       Account.BillingPostalCode, Account.BillingCountry
                FROM Contact 
                WHERE AccountId != null
                AND Account.BillingStreet != null
                LIMIT 10000
            ];
            
            if (contacts.isEmpty()) {
                System.debug('No contacts found with valid account billing addresses');
                return new Database.SaveResult[0];
            }
            
            // Update contact addresses with account billing address
            for (Contact con : contacts) {
                Contact updatedContact = new Contact(Id = con.Id);
                boolean hasChanges = false;
                
                if (con.Account.BillingStreet != con.MailingStreet) {
                    updatedContact.MailingStreet = con.Account.BillingStreet;
                    hasChanges = true;
                }
                
                if (con.Account.BillingCity != con.MailingCity) {
                    updatedContact.MailingCity = con.Account.BillingCity;
                    hasChanges = true;
                }
                
                if (con.Account.BillingState != con.MailingState) {
                    updatedContact.MailingState = con.Account.BillingState;
                    hasChanges = true;
                }
                
                if (con.Account.BillingPostalCode != con.MailingPostalCode) {
                    updatedContact.MailingPostalCode = con.Account.BillingPostalCode;
                    hasChanges = true;
                }
                
                if (con.Account.BillingCountry != con.MailingCountry) {
                    updatedContact.MailingCountry = con.Account.BillingCountry;
                    hasChanges = true;
                }
                
                if (hasChanges) {
                    contactsToUpdate.add(updatedContact);
                }
            }
            
            System.debug('Found ' + contactsToUpdate.size() + ' contacts to update');
            
            // Update contacts in bulk
            if (!contactsToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(contactsToUpdate, false);
                logUpdateResults(results);
                return results;
            } else {
                System.debug('No contacts need address updates');
                return new Database.SaveResult[0];
            }
            
        } catch (Exception e) {
            System.debug('Error updating contact addresses: ' + e.getMessage());
            throw new ContactAddressUpdateException('Failed to update contact addresses: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates contact addresses for a specific account
     * @param accountId The ID of the account whose contacts should be updated
     * @return Database.SaveResult[] - Results of the update operation
     */
    public static Database.SaveResult[] updateContactAddressesByAccount(Id accountId) {
        if (accountId == null) {
            throw new ContactAddressUpdateException('Account ID cannot be null');
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        try {
            // Query contacts for the specific account
            List<Contact> contacts = [
                SELECT Id, AccountId, MailingStreet, MailingCity, MailingState, 
                       MailingPostalCode, MailingCountry,
                       Account.BillingStreet, Account.BillingCity, Account.BillingState,
                       Account.BillingPostalCode, Account.BillingCountry
                FROM Contact 
                WHERE AccountId = :accountId
                AND Account.BillingStreet != null
                LIMIT 1000
            ];
            
            if (contacts.isEmpty()) {
                System.debug('No contacts found for account: ' + accountId);
                return new Database.SaveResult[0];
            }
            
            // Update contact addresses with account billing address
            for (Contact con : contacts) {
                Contact updatedContact = new Contact(Id = con.Id);
                boolean hasChanges = false;
                
                if (con.Account.BillingStreet != con.MailingStreet) {
                    updatedContact.MailingStreet = con.Account.BillingStreet;
                    hasChanges = true;
                }
                
                if (con.Account.BillingCity != con.MailingCity) {
                    updatedContact.MailingCity = con.Account.BillingCity;
                    hasChanges = true;
                }
                
                if (con.Account.BillingState != con.MailingState) {
                    updatedContact.MailingState = con.Account.BillingState;
                    hasChanges = true;
                }
                
                if (con.Account.BillingPostalCode != con.MailingPostalCode) {
                    updatedContact.MailingPostalCode = con.Account.BillingPostalCode;
                    hasChanges = true;
                }
                
                if (con.Account.BillingCountry != con.MailingCountry) {
                    updatedContact.MailingCountry = con.Account.BillingCountry;
                    hasChanges = true;
                }
                
                if (hasChanges) {
                    contactsToUpdate.add(updatedContact);
                }
            }
            
            System.debug('Found ' + contactsToUpdate.size() + ' contacts to update for account: ' + accountId);
            
            // Update contacts in bulk
            if (!contactsToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(contactsToUpdate, false);
                logUpdateResults(results);
                return results;
            } else {
                System.debug('No contacts need address updates for account: ' + accountId);
                return new Database.SaveResult[0];
            }
            
        } catch (Exception e) {
            System.debug('Error updating contact addresses for account ' + accountId + ': ' + e.getMessage());
            throw new ContactAddressUpdateException('Failed to update contact addresses for account: ' + e.getMessage());
        }
    }
    
    /**
     * @description Logs the results of contact updates
     * @param results Database.SaveResult[] - Results to log
     */
    private static void logUpdateResults(Database.SaveResult[] results) {
        Integer successCount = 0;
        Integer failureCount = 0;
        
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                successCount++;
            } else {
                failureCount++;
                System.debug('Failed to update contact ' + result.getId() + ': ' + result.getErrors());
            }
        }
        
        System.debug('Contact address update completed. Success: ' + successCount + ', Failures: ' + failureCount);
    }
    
    /**
     * @description Custom exception for contact address update errors
     */
    public class ContactAddressUpdateException extends Exception {}
}
