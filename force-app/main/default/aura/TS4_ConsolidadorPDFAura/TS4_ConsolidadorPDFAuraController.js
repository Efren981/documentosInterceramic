({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchRecords");
        component.set('v.loaded', !component.get('v.loaded'));
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accountData", response.getReturnValue());
            } else if (state === "ERROR") {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

        var recordId = component.get("v.recordId");
        
        var action = component.get("c.getOpportunity");
        action.setParams({
            "recordId": recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opportunity", response.getReturnValue());
            } else {
                console.error("Error fetching Grupo de productos a aprobar: " + response.getError());
            }
        });
        $A.enqueueAction(action);

        var action = component.get("c.getTipo");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.tipo", response.getReturnValue());
            } else {
                console.error("Error fetching Grupo de productos a aprobar: " + response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    handleIframeLoad: function(component, event, helper) {
        // Set isLoading to false when iframe is loaded
        component.set("v.loaded", false);
    },

    download: function (component, event) {
        var today = new Date();
        var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();


        // Call the Apex method to insert PDF as attachment
        var action = component.get("c.getPdfFileAsBase64String");
        action.setParams({
            "recordId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            console.log('response', response);
            var state = response.getState();
            console.log('state', state);
            if (state === "SUCCESS") {
                var pdfData = /*JSON.parse(*/response.getReturnValue()/*)*/;
                console.log('pdfData', pdfData);
                if (pdfData) {
                    var dlnk = document.createElement('a');
                    dlnk.href = "data:application/pdf;base64," + pdfData;
                    dlnk.download = 'consolidado'+date+'.pdf'; // Nombre del archivo
                    // Simular un clic en el enlace para iniciar la descarga
                    dlnk.click();
                } else {
                    console.log("Error: No se pudo descargar el PDF");
                }
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

    clickHandler : function(component, event, helper) {
        var opportunity = component.get("v.opportunity");
        var tipo = component.get("v.tipo");
        var accountData = component.get("v.accountData");
        var csvFile = helper.convertArrayToCsv(accountData, opportunity, tipo);
        helper.createLinkForDownload(csvFile);
    }

})