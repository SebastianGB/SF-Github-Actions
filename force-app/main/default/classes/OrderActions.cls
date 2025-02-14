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

        // Loop through the AggregateResult records
        for (AggregateResult aggOrder : aggOrderTotalCosts) {
            // Get the Opportunity Id from the AggregateResult
            Id oppId = (Id) aggOrder.get('OpportunityId');
            
            // Check if the Opportunity Id exists in the opportunitiesMap
            if (opportunitiesMap.containsKey(oppId)) {
                // Retrieve the Opportunity from the map
                Opportunity opp = opportunitiesMap.get(oppId);
                
                // Get the total costs from the AggregateResult
                Decimal totalCosts = (Decimal) aggOrder.get('totalCosts');
        
                // Update the Contribution Margin field using the total costs
                opp.Contribution_Margin__c = OpportunityActions.calculateContributionMargin(opp, totalCosts);
            }
        }
        
        // Step Update the Opportunities in the map.
        if (opportunitiesMap.size() > 0) {
            // Implement company Log Solution to handle unsaved data
            List<Database.SaveResult> updatedOpportunities = Database.update(opportunitiesMap.values(), false);
        }
    }
}
