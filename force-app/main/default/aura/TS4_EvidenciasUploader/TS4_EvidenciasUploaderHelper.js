({
    uploadFile: function(component, file, productoId) {
        var reader = new FileReader();
        reader.onloadend = function() {
            var base64 = reader.result.split(',')[1];
            var action = component.get("c.saveFile");
            
            action.setParams({
                fileName: file.name,
                base64Data: base64,
                productoId: productoId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Archivo subido exitosamente.");
                } else {
                    console.error("Error al subir el archivo.");
                }
            });
            
            $A.enqueueAction(action);
        };
        reader.readAsDataURL(file);
    }
})