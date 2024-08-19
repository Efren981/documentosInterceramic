({
    doInit : function(component, event, helper) {
        console.log('init')
        var recordId = component.get("v.recordId");
        console.log("Record ID: " + recordId); 
        helper.loadAdjuntos(component);
    },
    
    handleFileUpload : function(component, event, helper) {
        var file = event.getSource().get("v.files")[0];
        var adjuntoId = event.getSource().get("v.name");
        helper.showToast(component, 'Cargando', 'El archivo está siendo cargado...', 'info');
        // Comprimir el archivo (si es necesario) y luego subirlo
        helper.previewFile(component, file, adjuntoId).then(function(compressedFileData) {
            // Realiza la subida del archivo al servicio
            
            helper.uploadFileToService(component, adjuntoId, compressedFileData);
            
        }).catch(function(error) {
            console.error("Error al comprimir o subir el archivo: ", error);
            helper.showToast(component, 'Error', 'Error al comprimir o subir el archivo.', 'error');
        });
    },
    
    handleViewFile : function(component, event, helper) {
        var adjuntoId = event.getSource().get("v.name");
        helper.viewFile(component, adjuntoId);
    },
    
    handleCloseModal : function(component, event, helper) {
        component.set("v.previewFile", null);
    },
    
    handleUploadToService : function(component, event, helper) {
        var adjuntoId = component.get('v.nameFile');
        console.log(adjuntoId);
        helper.uploadFileToService(component,adjuntoId);
    },
    handleDeleteFile : function(component, event, helper) {
    var adjuntoId = event.getSource().get("v.name");
    helper.showToast(component, 'Eliminando', 'El archivo está siendo eliminado...', 'info');
    helper.deleteFile(component, adjuntoId);
}
})