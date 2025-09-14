/**
 * @description Test class for AccountOpportunityTotalCalculator
 * @author Salesforce Developer
 * @date 2024
 */
@isTest
public class AccountOpportunityTotalCalculatorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test Account 1'));
        testAccounts.add(new Account(Name = 'Test Account 2'));
        testAccounts.add(new Account(Name = 'Test Account 3'));
        insert testAccounts;
        
        // Create test opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        // Account 1 has 3 opportunities with amounts: 1000, 2000, 3000 = 6000 total
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 1-1',
            AccountId = testAccounts[0].Id,
            Amount = 1000,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 1-2',
            AccountId = testAccounts[0].Id,
            Amount = 2000,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 1-3',
            AccountId = testAccounts[0].Id,
            Amount = 3000,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        
        // Account 2 has 2 opportunities with amounts: 500, 1500 = 2000 total
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 2-1',
            AccountId = testAccounts[1].Id,
            Amount = 500,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 2-2',
            AccountId = testAccounts[1].Id,
            Amount = 1500,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        
        // Account 3 has 1 opportunity with amount: 7500
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 3-1',
            AccountId = testAccounts[2].Id,
            Amount = 7500,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        
        // Account 3 also has an opportunity with null amount (should be ignored)
        testOpportunities.add(new Opportunity(
            Name = 'Test Opp 3-2',
            AccountId = testAccounts[2].Id,
            Amount = null,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        ));
        
        insert testOpportunities;
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmount_SingleAccount() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Test.startTest();
        Decimal totalAmount = AccountOpportunityTotalCalculator.calculateTotalOpportunityAmount(testAccount.Id);
        Test.stopTest();
        
        // Account 1 should have total of 6000 (1000 + 2000 + 3000)
        System.assertEquals(6000, totalAmount, 'Total amount should be 6000');
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmount_NullAccountId() {
        Test.startTest();
        try {
            AccountOpportunityTotalCalculator.calculateTotalOpportunityAmount(null);
            System.assert(false, 'Should have thrown an exception for null account ID');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Account ID cannot be null', e.getMessage(), 'Should throw correct exception message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmounts_MultipleAccounts() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        Map<Id, Decimal> totalAmounts = AccountOpportunityTotalCalculator.calculateTotalOpportunityAmounts(accountIds);
        Test.stopTest();
        
        // Verify totals
        // Account 1: 6000, Account 2: 2000, Account 3: 7500
        System.assertEquals(3, totalAmounts.size(), 'Should have 3 accounts in the map');
        
        // Find account by name and verify totals
        for (Account acc : testAccounts) {
            if (acc.Name == 'Test Account 1') {
                System.assertEquals(6000, totalAmounts.get(acc.Id), 'Account 1 total should be 6000');
            } else if (acc.Name == 'Test Account 2') {
                System.assertEquals(2000, totalAmounts.get(acc.Id), 'Account 2 total should be 2000');
            } else if (acc.Name == 'Test Account 3') {
                System.assertEquals(7500, totalAmounts.get(acc.Id), 'Account 3 total should be 7500');
            }
        }
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmounts_NullList() {
        Test.startTest();
        try {
            AccountOpportunityTotalCalculator.calculateTotalOpportunityAmounts(null);
            System.assert(false, 'Should have thrown an exception for null list');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Account IDs list cannot be null or empty', e.getMessage(), 'Should throw correct exception message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateTotalOpportunityAmounts_EmptyList() {
        Test.startTest();
        try {
            AccountOpportunityTotalCalculator.calculateTotalOpportunityAmounts(new List<Id>());
            System.assert(false, 'Should have thrown an exception for empty list');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Account IDs list cannot be null or empty', e.getMessage(), 'Should throw correct exception message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountsWithOpportunityTotals() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        Map<Id, Decimal> accountsWithTotals = AccountOpportunityTotalCalculator.getAccountsWithOpportunityTotals(accountIds);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(3, accountsWithTotals.size(), 'Should return 3 accounts');
        
        // Verify totals are set correctly
        for (Account acc : testAccounts) {
            if (acc.Name == 'Test Account 1') {
                System.assertEquals(6000, accountsWithTotals.get(acc.Id), 'Account 1 total should be 6000');
            } else if (acc.Name == 'Test Account 2') {
                System.assertEquals(2000, accountsWithTotals.get(acc.Id), 'Account 2 total should be 2000');
            } else if (acc.Name == 'Test Account 3') {
                System.assertEquals(7500, accountsWithTotals.get(acc.Id), 'Account 3 total should be 7500');
            }
        }
    }
    
    @isTest
    static void testGetAccountsWithOpportunityTotals_NullList() {
        Test.startTest();
        try {
            AccountOpportunityTotalCalculator.getAccountsWithOpportunityTotals(null);
            System.assert(false, 'Should have thrown an exception for null list');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Account IDs list cannot be null or empty', e.getMessage(), 'Should throw correct exception message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllAccountsWithOpportunityTotals() {
        Test.startTest();
        Map<Id, Decimal> allAccountTotals = AccountOpportunityTotalCalculator.getAllAccountsWithOpportunityTotals();
        Test.stopTest();
        
        // Verify results
        System.assertEquals(3, allAccountTotals.size(), 'Should return 3 accounts with opportunities');
        
        // Get test accounts to verify totals
        List<Account> testAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        
        for (Account acc : testAccounts) {
            if (acc.Name == 'Test Account 1') {
                System.assertEquals(6000, allAccountTotals.get(acc.Id), 'Account 1 total should be 6000');
            } else if (acc.Name == 'Test Account 2') {
                System.assertEquals(2000, allAccountTotals.get(acc.Id), 'Account 2 total should be 2000');
            } else if (acc.Name == 'Test Account 3') {
                System.assertEquals(7500, allAccountTotals.get(acc.Id), 'Account 3 total should be 7500');
            }
        }
    }
    
    @isTest
    static void testAccountWithNoOpportunities() {
        // Create an account with no opportunities
        Account accountWithNoOpps = new Account(Name = 'Account With No Opportunities');
        insert accountWithNoOpps;
        
        Test.startTest();
        Decimal totalAmount = AccountOpportunityTotalCalculator.calculateTotalOpportunityAmount(accountWithNoOpps.Id);
        Test.stopTest();
        
        // Should return 0 for account with no opportunities
        System.assertEquals(0, totalAmount, 'Total amount should be 0 for account with no opportunities');
    }
}