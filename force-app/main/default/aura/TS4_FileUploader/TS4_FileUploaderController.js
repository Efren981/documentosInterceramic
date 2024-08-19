({
    doInit : function(component, event, helper) {
        helper.loadAdjuntosDeProducto(component);
    },
    
    handleFileSelect : function(component, event, helper) {
        var file = event.getSource().get("v.files")[0];
        var adjuntoId = event.getSource().getLocalId().split('_')[1];
        var reader = new FileReader();
        
        reader.onload = function(e) {
            component.set("v.selectedFile", file);
            component.set("v.previewUrl", e.target.result);
            component.set("v.showModal", true);
            component.set("v.selectedAdjuntoId", adjuntoId);
        };
        
        reader.readAsDataURL(file);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.showModal", false);
    },
    
    uploadFile : function(component, event, helper) {
        helper.uploadFileToS3(component);
    }
})