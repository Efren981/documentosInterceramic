({
    convertArrayToCsv: function (downloadRecords, opportunity, tipo) {
        if (downloadRecords.length == 0) {
            return '';
        }
        let headersSet = new Set();
        downloadRecords.forEach(record => {
            let flatRecord = this.flattenObject(record, tipo);
            Object.keys(flatRecord).forEach(key => {
                headersSet.add(key);
            });
        });

        // Convert set to array and create CSV header
        let csvHeaders = Array.from(headersSet);
        let csvHeader = csvHeaders.join(',').replaceAll('_', ' ').replaceAll('a1', '').replaceAll('a2', '').replaceAll('a3', '').replaceAll('a4', '').replaceAll('a5', '').replaceAll('a6', '').replaceAll('a70', '').replaceAll('a71', '').replaceAll('a8', '').replaceAll('a90', '').replaceAll('a91', '').replaceAll('a92', '').replaceAll('a93', '').replaceAll('a94', '').replaceAll('m2', 'm²');

        // Get the CSV body
        let csvBody = downloadRecords.map((record) => {
            let flatRecord = this.flattenObject(record, tipo);
            return csvHeaders.map(header => {
                let value = flatRecord[header] !== undefined ? flatRecord[header] : '';
                return `"${value}"`;
            }).join(',');
        }).join('\n');
        let csvFile =
            'Oportunidad,' + (opportunity.Name ? opportunity.Name + ',' : '') +
            'Cuenta,' + (opportunity.Account.Name ? opportunity.Account.Name : '') + '\n' +
            'Contacto,' + (opportunity.Description ? opportunity.Description +',': '') + '\n' +
            'ID Convenio,' + (opportunity.INT_Id_Convenio__c ? opportunity.INT_Id_Convenio__c : '') + '\n' +
            'Fecha Inicio,' + (opportunity.INT_Fecha_inicio__c ? opportunity.INT_Fecha_inicio__c + ',' : '') +
            'Fecha Fin,' + (opportunity.CloseDate ? opportunity.CloseDate : '')
            + '\n' + '\n' +
            csvHeader + '\n' +
            csvBody;
        return csvFile;
    },

    flattenObject: function (ob, tipo) {
        let toReturn = {};

        for (let i in ob) {
            if (!ob.hasOwnProperty(i)){
                continue;
            } 
            if ((typeof ob[i]) === 'object' && ob[i] !== null) {
                
                let flatObject = this.flattenObject(ob[i], tipo);
                for (let x in flatObject) {
                    if (!flatObject.hasOwnProperty(x)) continue;
                    toReturn[i + '.' + x] = flatObject[x];
                }
            } else {
                let e =  tipo+ ' campo ' + i;

                if (e !== 'MB campo a71Precio_proyecto_por_m2') {
                    
                    toReturn[i] = ob[i];
                }
            }
        }
        return toReturn;
    },

    createLinkForDownload: function (csvFile) {
        var today = new Date();
        var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        var downLink = document.createElement("a");
        downLink.href = "data:text/csv;charset=utf-8," + escape(csvFile);
        downLink.target = '_blank';
        downLink.download = 'consolidado' + date + '.csv';
        downLink.click();
    }
})