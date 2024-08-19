({
    convertArrayToCsv: function (downloadRecords, groupRecords) {
        console.log('csvFile: ' + downloadRecords);
        if (downloadRecords.length == 0) {
            return '';
        }
        let headersSet = new Set();
        downloadRecords.forEach(record => {
            let flatRecord = this.flattenObject(record);
            Object.keys(flatRecord).forEach(key => {
                headersSet.add(key);
            });
        });

        // Convert set to array and create CSV header
        let csvHeaders = Array.from(headersSet);
        let csvHeader = csvHeaders.join(',').replaceAll('_', ' ').replaceAll('a1', '').replaceAll('a2', '').replaceAll('a30', '').replaceAll('a31', '').replaceAll('a4', '').replaceAll('a5', '').replaceAll('a6', '').replaceAll('a7', '').replaceAll('a8', '').replaceAll('a900', '').replaceAll('a901', '').replaceAll('a902', '').replaceAll('a903', '').replaceAll('a904', '').replaceAll('a905', '').replaceAll('a906', '').replaceAll('a907', '').replaceAll('a908', '').replaceAll('a909', '').replaceAll('a910', '').replaceAll('a911', '').replaceAll('a912', '').replaceAll('Clasificacion', 'Clasificación').replaceAll('codigo', 'código');
        
        // Get the CSV body
        let csvBody = downloadRecords.map((record) => {
            let flatRecord = this.flattenObject(record);
            return csvHeaders.map(header => {
                let value = flatRecord[header] !== undefined ? flatRecord[header] : '';
                return `"${value}"`;
            }).join(',');
        }).join('\n');
        let sPrincipal = (groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__c == null) ? '' : 'Oportunidad Principal,' + groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__r.Name + '\n';
        let csvFile = 'Nombre de Grupo de productos a aprobar,' + (groupRecords.Name ? groupRecords.Name : '') + '\n' +
        
            'Oportunidad,' + (groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Name ? groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Name : '') + '\n' +
            sPrincipal +
            'Cuenta,' + (groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Account.Name ? groupRecords.Cotizacion__r.SBQQ__Opportunity2__r.Account.Name : '') + '\n' +
            'Cotización,' + (groupRecords.Cotizacion__r.Name ? groupRecords.Cotizacion__r.Name : '') + '\n' +
            
            'Descripción,' + (groupRecords.Descripcion__c ? groupRecords.Descripcion__c : '') + '\n' +
            'Lista de precios,' + (groupRecords.Cotizacion__r.SBQQ__PriceBook__r.Name ? groupRecords.Cotizacion__r.SBQQ__PriceBook__r.Name : '') + '\n' + '\n' +
            csvHeader + '\n' +
            csvBody;
        return csvFile;
    },

    flattenObject: function (ob) {
        let toReturn = {};

        for (let i in ob) {
            if (!ob.hasOwnProperty(i)) continue;

            if ((typeof ob[i]) === 'object' && ob[i] !== null) {
                let flatObject = this.flattenObject(ob[i]);
                for (let x in flatObject) {
                    if (!flatObject.hasOwnProperty(x)) continue;
                    toReturn[i + '.' + x] = flatObject[x];
                }
            } else {
                toReturn[i] = ob[i];
            }
        }
        return toReturn;
    },

    createLinkForDownload: function (csvFile) {
        var downLink = document.createElement("a");
        downLink.href = "data:text/csv;charset=utf-8," + escape(csvFile);
        downLink.target = '_blank';
        downLink.download = "grupoAprobar.csv";
        downLink.click();
    }
})