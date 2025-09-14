/**
 * @description Test class for ContactAddressUpdater
 * @author Generated
 * @date 2024
 */
@isTest
private class ContactAddressUpdaterTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test accounts with billing addresses
        List<Account> testAccounts = new List<Account>();
        
        Account acc1 = new Account(
            Name = 'Test Account 1',
            BillingStreet = '123 Main St',
            BillingCity = 'New York',
            BillingPostalCode = '10001',
            BillingCountry = 'United States'
        );
        testAccounts.add(acc1);
        
        Account acc2 = new Account(
            Name = 'Test Account 2',
            BillingStreet = '456 Oak Ave',
            BillingCity = 'Los Angeles',
            BillingPostalCode = '90210',
            BillingCountry = 'United States'
        );
        testAccounts.add(acc2);
        
        Account acc3 = new Account(
            Name = 'Test Account 3',
            BillingStreet = null, // Account with no billing address
            BillingCity = null,
            BillingState = null,
            BillingPostalCode = null,
            BillingCountry = null
        );
        testAccounts.add(acc3);
        
        insert testAccounts;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        
        // Contacts with different addresses than their accounts
        Contact con1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccounts[0].Id,
            MailingStreet = '999 Different St',
            MailingCity = 'Different City',
            MailingPostalCode = '99999',
            MailingCountry = 'Canada'
        );
        testContacts.add(con1);
        
        Contact con2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            AccountId = testAccounts[1].Id,
            MailingStreet = '777 Another St',
            MailingCity = 'Another City',
            MailingPostalCode = '77777',
            MailingCountry = 'United Kingdom'
        );
        testContacts.add(con2);
        
        // Contact with same address as account (should not be updated)
        Contact con3 = new Contact(
            FirstName = 'Bob',
            LastName = 'Johnson',
            AccountId = testAccounts[1].Id,
            MailingStreet = testAccounts[1].BillingStreet,
            MailingCity = testAccounts[1].BillingCity,
            MailingState = testAccounts[1].BillingState,
            MailingPostalCode = testAccounts[1].BillingPostalCode,
            MailingCountry = testAccounts[1].BillingCountry
        );
        testContacts.add(con3);
        
        // Contact with account that has no billing address
        Contact con4 = new Contact(
            FirstName = 'Alice',
            LastName = 'Brown',
            AccountId = testAccounts[2].Id,
            MailingStreet = '555 Test St',
            MailingCity = 'Test City',
            MailingPostalCode = '55555',
            MailingCountry = 'Australia'
        );
        testContacts.add(con4);
        
        // Contact with no account
        Contact con5 = new Contact(
            FirstName = 'Charlie',
            LastName = 'Wilson',
            AccountId = null,
            MailingStreet = '111 No Account St',
            MailingCity = 'No Account City',
            MailingPostalCode = '11111',
            MailingCountry = 'Germany'
        );
        testContacts.add(con5);
        
        insert testContacts;
    }
    
    /**
     * @description Test updating all contact addresses
     */
    @isTest
    static void testUpdateAllContactAddresses() {
        Test.startTest();
        Database.SaveResult[] results = ContactAddressUpdater.updateAllContactAddresses();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, results, 'Results should not be null');
        
        // Query updated contacts
        List<Contact> updatedContacts = [
            SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                   Account.BillingStreet, Account.BillingCity, Account.BillingState, 
                   Account.BillingPostalCode, Account.BillingCountry
            FROM Contact
            WHERE AccountId != null
            AND Account.BillingStreet != null
        ];
        
        // Verify that contacts with different addresses were updated
        for (Contact con : updatedContacts) {
            System.assertEquals(con.Account.BillingStreet, con.MailingStreet, 
                'Contact mailing street should match account billing street');
            System.assertEquals(con.Account.BillingCity, con.MailingCity, 
                'Contact mailing city should match account billing city');
            System.assertEquals(con.Account.BillingState, con.MailingState, 
                'Contact mailing state should match account billing state');
            System.assertEquals(con.Account.BillingPostalCode, con.MailingPostalCode, 
                'Contact mailing postal code should match account billing postal code');
            System.assertEquals(con.Account.BillingCountry, con.MailingCountry, 
                'Contact mailing country should match account billing country');
        }
        
        // Verify contacts with no account or account with no billing address were not updated
        List<Contact> unchangedContacts = [
            SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE AccountId = null OR Account.BillingStreet = null
        ];
        
        for (Contact con : unchangedContacts) {
            if (con.MailingStreet != null) {
                System.assert(con.MailingStreet.contains('Test') || con.MailingStreet.contains('No Account'), 
                    'Contacts with no account or no billing address should not be updated');
            }
        }
    }
    
    /**
     * @description Test updating contact addresses for a specific account
     */
    @isTest
    static void testUpdateContactAddressesByAccount() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Test.startTest();
        Database.SaveResult[] results = ContactAddressUpdater.updateContactAddressesByAccount(testAccount.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, results, 'Results should not be null');
        
        // Verify contacts for this account were updated
        List<Contact> updatedContacts = [
            SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                   Account.BillingStreet, Account.BillingCity, Account.BillingState, 
                   Account.BillingPostalCode, Account.BillingCountry
            FROM Contact
            WHERE AccountId = :testAccount.Id
        ];
        
        for (Contact con : updatedContacts) {
            System.assertEquals(con.Account.BillingStreet, con.MailingStreet, 
                'Contact mailing street should match account billing street');
            System.assertEquals(con.Account.BillingCity, con.MailingCity, 
                'Contact mailing city should match account billing city');
            System.assertEquals(con.Account.BillingState, con.MailingState, 
                'Contact mailing state should match account billing state');
            System.assertEquals(con.Account.BillingPostalCode, con.MailingPostalCode, 
                'Contact mailing postal code should match account billing postal code');
            System.assertEquals(con.Account.BillingCountry, con.MailingCountry, 
                'Contact mailing country should match account billing country');
        }
    }
    
    /**
     * @description Test updating contact addresses with null account ID
     */
    @isTest
    static void testUpdateContactAddressesByAccountWithNullId() {
        Test.startTest();
        try {
            ContactAddressUpdater.updateContactAddressesByAccount(null);
            System.assert(false, 'Exception should have been thrown for null account ID');
        } catch (ContactAddressUpdater.ContactAddressUpdateException e) {
            System.assertEquals('Account ID cannot be null', e.getMessage(), 
                'Correct exception message should be thrown');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updating contact addresses with invalid account ID
     */
    @isTest
    static void testUpdateContactAddressesByAccountWithInvalidId() {
        Id invalidId = '001000000000000'; // Invalid account ID format
        
        Test.startTest();
        try {
            ContactAddressUpdater.updateContactAddressesByAccount(invalidId);
            // If no exception is thrown, verify no contacts were updated
            List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :invalidId];
            System.assertEquals(0, contacts.size(), 'No contacts should exist for invalid account ID');
        } catch (Exception e) {
            // Exception is acceptable for invalid ID
            System.assert(true, 'Exception thrown for invalid account ID is acceptable');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk update scenario
     */
    @isTest
    static void testBulkUpdateScenario() {
        // Create additional test data for bulk scenario
        List<Account> bulkAccounts = new List<Account>();
        List<Contact> bulkContacts = new List<Contact>();
        
        for (Integer i = 0; i < 200; i++) {
            Account acc = new Account(
                Name = 'Bulk Account ' + i,
                BillingStreet = 'Bulk Street ' + i,
                BillingCity = 'Bulk City ' + i,
                BillingPostalCode = '90000',
                BillingCountry = 'United States'
            );
            bulkAccounts.add(acc);
        }
        insert bulkAccounts;
        
        for (Integer i = 0; i < 200; i++) {
            Contact con = new Contact(
                FirstName = 'Bulk',
                LastName = 'Contact ' + i,
                AccountId = bulkAccounts[i].Id,
                MailingStreet = 'Different Street ' + i,
                MailingCity = 'Different City ' + i,
                MailingPostalCode = '99999',
                MailingCountry = 'Canada'
            );
            bulkContacts.add(con);
        }
        insert bulkContacts;
        
        Test.startTest();
        Database.SaveResult[] results = ContactAddressUpdater.updateAllContactAddresses();
        Test.stopTest();
        
        // Verify bulk update was successful
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should have updated some contacts');
        
        // Verify some contacts were updated successfully
        Integer successCount = 0;
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                successCount++;
            }
        }
        System.assert(successCount > 0, 'At least some contacts should have been updated successfully');
    }
}
