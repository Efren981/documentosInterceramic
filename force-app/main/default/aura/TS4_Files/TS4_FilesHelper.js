({
    /*resizeImage: function(component, fileContents, fileType) {
        console.log('entro al resize');
        var img = new Image();
        img.onload = function() {
            var maxWidth = 1250; // Define your max width
            var maxHeight = 1250; // Define your max height
            var width = img.width;
            var height = img.height;
            console.log(width);
            console.log(height);
            if (width > maxWidth || height > maxHeight) {
                console.log('entro al if');
                if (width > height) {
                    if (width > maxWidth) {
                        height *= maxWidth / width;
                        width = maxWidth;
                    }
                } else {
                    if (height > maxHeight) {
                        width *= maxHeight / height;
                        height = maxHeight;
                    }
                }

                var canvas = document.createElement('canvas');
                canvas.width = width;
                canvas.height = height;
                var ctx = canvas.getContext("2d");
                ctx.imageSmoothingEnabled = true;
                ctx.imageSmoothingQuality = 'high';
                ctx.drawImage(img, 0, 0, width, height);

                var resizedDataUrl = canvas.toDataURL(fileType, 0.9); // Set quality to 90%
                var base64Mark = 'base64,';
                var dataStart = resizedDataUrl.indexOf(base64Mark) + base64Mark.length;
                var resizedBase64 = resizedDataUrl.substring(dataStart);
                console.log(resizedBase64);
                component.set("v.fileName", file.name);
                component.set("v.fileContent", resizedBase64);
                component.set("v.fileSize", resizedBase64.length * (3/4)); // Approximate size
                

            } else {
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                var base64Data = fileContents.substring(dataStart);

                component.set("v.fileName", file.name);
                component.set("v.fileContent", base64Data);
                component.set("v.fileSize", base64Data.length * (3/4)); // Approximate size
               
            }
        };
        img.src = fileContents;
    }*/
})