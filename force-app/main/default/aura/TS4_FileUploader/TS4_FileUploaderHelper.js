({
     loadAdjuntosDeProducto : function(component) {
        var action = component.get("c.getAdjuntosDeProducto");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.adjuntosDeProducto", response.getReturnValue());
            } else {
                console.error("Error al cargar adjuntos de producto");
            }
        });
        $A.enqueueAction(action);
    },
    
    uploadFileToS3 : function(component) {
        var file = component.get("v.selectedFile");
        var reader = new FileReader();
        
        reader.onload = function(e) {
            var blob = new Blob([e.target.result], {type: file.type});
            
            // Aquí iría la lógica para subir el blob a S3
            // Por ahora, simularemos una respuesta exitosa
            var fakeS3Url = "https://fake-s3-bucket.amazonaws.com/" + file.name;
            
            this.updateAdjuntoRecord(component, fakeS3Url);
        }.bind(this);
        
        reader.readAsArrayBuffer(file);
    },
    
    updateAdjuntoRecord : function(component, s3Url) {
        var action = component.get("c.updateAdjuntoUrl");
        action.setParams({
            "adjuntoId": component.get("v.selectedAdjuntoId"),
            "fileUrl": s3Url
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("URL actualizada con éxito");
                component.set("v.showModal", false);
                this.loadAdjuntosDeProducto(component);  // Recargar los adjuntos
            } else {
                console.error("Error al actualizar URL");
            }
        });
        $A.enqueueAction(action);
    }
})