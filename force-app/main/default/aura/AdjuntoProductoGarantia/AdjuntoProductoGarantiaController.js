({
    doInit : function(component, event, helper) {
        console.log('init')
        var recordId = component.get("v.recordId");
        console.log("Record ID: " + recordId); 
        helper.loadAdjuntos(component);
    },
    
    handleFileUpload : function(component, event, helper) {
        var file = event.getSource().get("v.files")[0];
        
        console.log('input');
        var adjuntoId = event.getSource().get("v.name");
        console.log(adjuntoId);
        helper.previewFile(component, file, adjuntoId);
    },
    
    handleViewFile : function(component, event, helper) {
        var adjuntoId = event.getSource().get("v.name");
        helper.viewFile(component, adjuntoId);
    },
    
    handleCloseModal : function(component, event, helper) {
        component.set("v.previewFile", null);
    },
    
    handleUploadToService : function(component, event, helper) {
        console.log('click al boton');
        helper.uploadFileToService(component);
    },
    handleDeleteFile : function(component, event, helper) {
    var adjuntoId = event.getSource().get("v.name");
    helper.deleteFile(component, adjuntoId);
}
})