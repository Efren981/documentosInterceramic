({
    loadAdjuntos : function(component) {
        var action = component.get("c.getAdjuntos");
        console.log(component.get('v.recordId'));
        action.setParams({
            recordId:component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.adjuntos", response.getReturnValue());
            } else {
                console.error('Error al cargar adjuntos');
            }
        });
        $A.enqueueAction(action);
    },
    
    previewFile : function(component, file, adjuntoId) {
        var reader = new FileReader();
        reader.onload = function() {
            var fileContents = reader.result;
            var fileData = {
                'filename': file.name,
                'base64': fileContents.split(',')[1],
                'adjuntoId': adjuntoId
            };
            component.set("v.previewFile", { src: fileContents, data: fileData });
            component.set("v.base64", fileContents);
            component.set("v.fileType", file.type);
            
        };
        reader.readAsDataURL(file);
    },
    
    viewFile : function(component, adjuntoId) {
        var adjuntos = component.get("v.adjuntos");
        var adjunto = adjuntos.find(a => a.Id === adjuntoId);
        if (adjunto && adjunto.URL_del_archivo__c) {
            window.open(adjunto.URL_del_archivo__c, '_blank');
        }
    },
    
    uploadFileToService : function(component) {
        
        var fileData = component.get("v.base64");
        var fileContents = fileData.replace('data:','').replace(/^.+,/,'');
        var filetype = component.get("v.fileType");
        console.log(fileContents);
        console.log(component.get('v.adjuntos'));
        component.set("v.isLoading", true);
        
        var action = component.get("c.uploadFile");
        action.setParams({
            fileData:fileContents,
            fileType:filetype,
            listaProductos:component.get('v.adjuntos')
         });
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.success) {
                    this.updateAdjunto(component, fileData.adjuntoId, result.url);
                    component.set("v.previewFile", null);
                } else {
                    //console.error('Error al subir el archivo:', result.message);
                }
            } else {
                console.error('Error en la llamada al servidor');
            }
        });
        $A.enqueueAction(action);
    },
    
    updateAdjunto : function(component, adjuntoId, url) {
        var action = component.get("c.updateAdjunto");
        action.setParams({ adjuntoId: adjuntoId, url: url });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.loadAdjuntos(component);
            } else {
                console.error('Error al actualizar el adjunto');
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteFile : function(component, adjuntoId) {
    var action = component.get("c.deleteAdjunto");
    action.setParams({ adjuntoId: adjuntoId });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            this.loadAdjuntos(component);
        } else {
            console.error('Error al eliminar el adjunto');
        }
    });
    $A.enqueueAction(action);
}
})