({
    doInit : function(component, event, helper) {
        console.log('boton');
        var action = component.get("c.createSigntaureRequest");
        action.setParams({
            "idCaso": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Aquí puedes manejar la respuesta del controlador
                console.log(result);
                if(result.flag===true){
                    helper.showToast('Exito',result.message,'success','dismissible');
                }else{
                    helper.showToast('Error',result.message,'error','dismissible');
                }
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire(); 

                //
                //helper.showToast('Exito','Se crearon exitosamente '+ result.success.length+' registros de partidas y dieron error '+ result.errors.length+ ' registros','success','sticky');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast('Error',errors[0].message,'error','sticky');
                    }
                } else {
                    helper.showToast('Error','Unknown error','error','sticky');
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})