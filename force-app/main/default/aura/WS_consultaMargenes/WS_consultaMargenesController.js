/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : emeza@freewayconsulting.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-14-2023   emeza@freewayconsulting.com   Initial Version
**/
({
    handleClick: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        component.set("v.showSpinner", true);
        
        // Call the Apex class
        var action = component.get("c.consultarMargenes");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Display the text
                var toastEvent = $A.get("e.force:showToast");
                if(result != 'OK' && result.includes('Advertencia')){
                    toastEvent.setParams({
                        "title": "Warning",
                        "message": result,
                        "type": "warning"
                    });
                }else if(result != 'OK' && result.includes('Error')){
                    toastEvent.setParams({
                        "title": "Error",
                        "message": result,
                        "type": "error"
                    });
                }else{
                    toastEvent.setParams({
                        "title": "Success",
                        "message": result,
                        "type": "success"
                    });
                }
                toastEvent.fire();
                
                var closeQuickAction = $A.get("e.force:closeQuickAction");
                if (closeQuickAction) {
                    closeQuickAction.fire();
                }
                
                // Delay the page reload to allow time for the toast message to be displayed
                setTimeout(function(){
                    component.set("v.showSpinner", false);
                    $A.get('e.force:refreshView').fire();
                }, 5000);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var errorMessage = "Unknown error"; // Default error message
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})