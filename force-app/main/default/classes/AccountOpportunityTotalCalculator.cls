/**
 * @description Apex class to calculate the total opportunity amount for accounts
 * @author Salesforce Developer
 * @date 2024
 */
public with sharing class AccountOpportunityTotalCalculator {
    
    /**
     * @description Calculate total opportunity amount for a single account
     * @param accountId The ID of the account to calculate opportunity total for
     * @return Decimal The total amount of all opportunities related to the account
     */
    public static Decimal calculateTotalOpportunityAmount(Id accountId) {
        if (accountId == null) {
            throw new IllegalArgumentException('Account ID cannot be null');
        }
        
        // Query all opportunities related to the account
        List<Opportunity> opportunities = [
            SELECT Id, Amount 
            FROM Opportunity 
            WHERE AccountId = :accountId 
            AND Amount != null
        ];
        
        Decimal totalAmount = 0;
        for (Opportunity opp : opportunities) {
            totalAmount += opp.Amount;
        }
        
        return totalAmount;
    }
    
    /**
     * @description Calculate total opportunity amounts for multiple accounts
     * @param accountIds List of account IDs to calculate opportunity totals for
     * @return Map<Id, Decimal> Map of account ID to total opportunity amount
     */
    public static Map<Id, Decimal> calculateTotalOpportunityAmounts(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            throw new IllegalArgumentException('Account IDs list cannot be null or empty');
        }
        
        // Query all opportunities related to the accounts
        List<Opportunity> opportunities = [
            SELECT Id, AccountId, Amount 
            FROM Opportunity 
            WHERE AccountId IN :accountIds 
            AND Amount != null
        ];
        
        Map<Id, Decimal> accountTotalMap = new Map<Id, Decimal>();
        
        // Initialize all accounts with 0
        for (Id accountId : accountIds) {
            accountTotalMap.put(accountId, 0);
        }
        
        // Sum up amounts by account
        for (Opportunity opp : opportunities) {
            Decimal currentTotal = accountTotalMap.get(opp.AccountId);
            accountTotalMap.put(opp.AccountId, currentTotal + opp.Amount);
        }
        
        return accountTotalMap;
    }
    
    /**
     * @description Get account records with their total opportunity amounts
     * @param accountIds List of account IDs to retrieve with totals
     * @return Map<Id, Decimal> Map of account ID to total opportunity amount
     */
    public static Map<Id, Decimal> getAccountsWithOpportunityTotals(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            throw new IllegalArgumentException('Account IDs list cannot be null or empty');
        }
        
        // Get the total amounts
        Map<Id, Decimal> totalAmounts = calculateTotalOpportunityAmounts(accountIds);
        
        return totalAmounts;
    }
    
    /**
     * @description Get all accounts with their total opportunity amounts
     * This method returns a map of account IDs to their total opportunity amounts
     */
    public static Map<Id, Decimal> getAllAccountsWithOpportunityTotals() {
        // Get all accounts that have opportunities
        List<Account> accountsWithOpportunities = [
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Amount != null)
        ];
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : accountsWithOpportunities) {
            accountIds.add(acc.Id);
        }
        
        // Calculate totals
        Map<Id, Decimal> totalAmounts = calculateTotalOpportunityAmounts(accountIds);
        
        return totalAmounts;
    }
}