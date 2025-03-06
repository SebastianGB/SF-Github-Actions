public with sharing class OrderActions {
    public static void updateOpportunityCM(Map<Id, Order> newOrdersMap) { 

        if(newOrdersMap.isEmpty() || newOrdersMap == null) {
            return;
        }

        // Create Lists to Store Opps
        Set<Id> opportunityIds = new Set<Id>();
        // Create a list to store the AggregateResult records
        List<AggregateResult> aggOrderTotalCosts = new List<AggregateResult>();

        // Initialize a set to store the Opportunity IDs related to the Orders.
        for (Order order : newOrdersMap.values()) {
            // If Opportunity is linked store Id in List
            if (order.OpportunityId != null) {
                opportunityIds.add(order.OpportunityId);
            }
        }
        
        // Step Query the Opportunities with the Contribution_Margin__c, GMV__c, and Purchase_Price__c fields.
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity> ([SELECT Id, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id IN :opportunityIds]);

        // Query the opportunities and related orders
        aggOrderTotalCosts = [
            SELECT OpportunityId, SUM(Total_Costs__c) totalCosts
            FROM Order
            WHERE OpportunityId IN :opportunityIds
            GROUP BY OpportunityId
        ];

        // Loop through the Opportunities to find their Orders and remove them
        for (Opportunity opp: opportunitiesMap.values()) {
            
            Decimal totalCosts = 0;
            // Loop through the AggregateResult records
            for (AggregateResult aggOrder: aggOrderTotalCosts) {
                Id oppId = (Id) aggOrder.get('OpportunityId');
                if (opp.Id == oppId) {
                    totalCosts = totalCosts + (Decimal) aggOrder.get('totalCosts');
                }
            }
            
            opp.Contribution_Margin__c = opp.GMV__c - opp.Purchase_Price__c - totalCosts;        
        }
        // Step Update the Opportunities in the map.
        if (opportunitiesMap.size() > 0) {
            // Implement company Log Solution to handle unsaved data
            List<Database.SaveResult> updatedOpportunities = Database.update(opportunitiesMap.values(), false);
        }
    }
}
