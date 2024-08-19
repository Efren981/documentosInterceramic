({
    doneRendering: function(component, event, helper) {
        if(!component.get("v.isDoneRendering")){
            component.set("v.isDoneRendering", true);
            var container = component.find('modalContainer');
            $A.util.addClass(container, 'slds-modal--large');
            
            var opportunityId = component.get("v.recordId");
            if (opportunityId) {
                // Check if Opportunity has an attachment
                var action = component.get("c.checkOpportunityAttachment");
                action.setParams({
                    "opportunityId": opportunityId
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var hasAttachment = response.getReturnValue();
                        component.set("v.hasAttachment", hasAttachment);
                    }
                });
                
                $A.enqueueAction(action);
            }
        }
    },
    
    doAttachQuoteDocument: function(component, event, helper) {
        console.log('doAttachQuoteDocument');
        
        var opportunityId = component.get("v.recordId");
        console.log('opportunityId', opportunityId);
        
        // Call the Apex method to insert PDF as attachment
        var action = component.get("c.insertPDFAsAttachment");
        action.setParams({
            "opportunityId": opportunityId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            if (state === "SUCCESS") {
                // Handle the success scenario
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'PDF attached to Opportunity successfully.',
                    type: 'success'
                });
                toastEvent.fire();
                
                // Close the component
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "ERROR") {
                // Handle the error scenario
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    doCancel: function(component, event, helper){
        // Close the component
        $A.get("e.force:closeQuickAction").fire();
    }
})