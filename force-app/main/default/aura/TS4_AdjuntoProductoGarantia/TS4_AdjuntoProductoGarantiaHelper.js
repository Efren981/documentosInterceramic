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
    showToast : function(component, title, message, variant) {
        var toastLibrary = component.find("toastLibrary");
        if (toastLibrary) {
            toastLibrary.showToast({
                title: title,
                message: message,
                variant: variant
            });
        } else {
            console.error('No se encontró la biblioteca de notificaciones');
        }
    },
    
    previewFile : function(component, file, adjuntoId) {
        return new Promise(function(resolve, reject) {
            var reader = new FileReader();
            reader.onload = function() {
                var fileContents = reader.result;
                var img = new Image();
                img.src = fileContents;
                img.onload = function() {
                    var canvas = document.createElement('canvas');
                    var ctx = canvas.getContext('2d');
        
                    canvas.width = img.width;
                    canvas.height = img.height;
        
                    ctx.drawImage(img, 0, 0, img.width, img.height);
        
                    var quality = 0.9;
                    var compressedDataUrl;
                    var compressedSize;
        
                    // Comprimiendo la imagen
                    do {
                        compressedDataUrl = canvas.toDataURL(file.type, quality);
                        compressedSize = Math.round((compressedDataUrl.length * (3 / 4))); // Tamaño en bytes
                        quality -= 0.10; // Reduce la calidad en cada iteración
                    } while (compressedSize > 1500 * 1024 && quality > 0); // 200 KB máximo
        
                    // Resuelve la promesa con los datos del archivo comprimido
                    resolve({
                        'filename': file.name,
                        'base64': compressedDataUrl.split(',')[1],
                        'adjuntoId': adjuntoId,
                        'fileType': file.type
                    });
                };
            };
            reader.readAsDataURL(file);
        });
    },
    
    
    viewFile : function(component, adjuntoId) {
        var adjuntos = component.get("v.adjuntos");
        var adjunto = adjuntos.find(a => a.Id === adjuntoId);
        if (adjunto && adjunto.URL_del_archivo__c) {
            window.open(adjunto.URL_del_archivo__c, '_blank');
        }
    },
    
    uploadFileToService : function(component, adjuntoId, fileData) {
        component.set("v.isLoading", true);
        
        var action = component.get("c.uploadFile");
        action.setParams({
            fileData: fileData.base64,
            fileType: fileData.fileType,
            idAdjunto: adjuntoId
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result === 'OK'){
                    this.loadAdjuntos(component);
                    this.showToast(component, 'Éxito', 'Archivo subido exitosamente.', 'success');
                }
            } else {
                this.showToast(component, 'Error', 'Error en la llamada al servidor.', 'error');
            }
            component.set("v.isLoading", false);
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
            this.showToast(component, 'Éxito', 'Archivo eliminado exitosamente.', 'success');
        } else {
            this.showToast(component, 'Error', 'Error al eliminar el adjunto.', 'error');
        }
    });
    $A.enqueueAction(action);
}
})