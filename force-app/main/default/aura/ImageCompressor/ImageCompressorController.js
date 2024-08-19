({
    handleFileUpload: function(component, event) {
        const file = event.target.files[0];
        if (!file) {
            return;
        }

        const MAX_SIZE = 200 * 1024; // Tamaño máximo en bytes (200 KB)
        const img = new Image();
        const reader = new FileReader();
        reader.onload = function(e) {
            img.src = e.target.result;
            img.onload = function() {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                // Establece las dimensiones del canvas
                canvas.width = img.width;
                canvas.height = img.height;

                // Dibuja la imagen en el canvas
                ctx.drawImage(img, 0, 0, img.width, img.height);

                // Ajusta la calidad de compresión iterativamente
                let quality = 0.9;
                let compressedDataUrl;
                let compressedSize;

                do {
                    compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
                    compressedSize = Math.round((compressedDataUrl.length * (3/4))); // Tamaño en bytes
                    quality -= 0.05; // Reduce la calidad en cada iteración
                } while (compressedSize > MAX_SIZE && quality > 0);

                // Actualiza las variables de atributo en el componente
                component.set("v.originalImageUrl", img.src);
                component.set("v.compressedImageUrl", compressedDataUrl);
                component.set("v.originalSize", Math.round(file.size / 1024) + ' KB');
                component.set("v.compressedSize", Math.round(compressedSize / 1024) + ' KB');
                console.log(compressedDataUrl);
            };
        };
        reader.readAsDataURL(file);
    }
})