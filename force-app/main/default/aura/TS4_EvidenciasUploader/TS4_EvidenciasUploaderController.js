({
    handleFileChange: function(component, event, helper) {
        var fileInput = event.target;
        var file = fileInput.files[0];
        var productoId = fileInput.getAttribute('data-id');

        if (file) {
            helper.uploadFile(component, file, productoId);
        }
    }
})