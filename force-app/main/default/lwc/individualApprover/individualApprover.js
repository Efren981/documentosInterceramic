/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 2023-10-24
 * @last modified by  : Catalina Orozco - corozco@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-31-2023   emeza@freewayconsulting.com   Initial Version
**/
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import fetchQuoteLineItems from '@salesforce/apex/individualApproverController.fetchQuoteLineItems';
import updateQLI from '@salesforce/apex/individualApproverController.updateQLI';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { NavigationMixin } from 'lightning/navigation';
import QUOTE_FIELD from "@salesforce/schema/Grupo_de_productos_a_aprobar__c.Cotizacion__c";
import LEVEL_FIELD from "@salesforce/schema/Grupo_de_productos_a_aprobar__c.Nivel__c";

const FIELDS = [QUOTE_FIELD,LEVEL_FIELD];
const COLUMNS_NO = [
    { label: 'Producto', fieldName: 'SBQQ__ProductCode__c', initialWidth : 205 },
    { label: 'Cantidad', fieldName: 'SBQQ__Quantity__c', type : 'number',initialWidth : 100, typeAttributes: { step: '0.01' }},
    { label: 'Metros', fieldName: 'METROS__c', type : 'number', typeAttributes: { step: '0.01' }, initialWidth : 110},
    { label: 'Precio', fieldName: 'SBQQ__OriginalPrice__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { label: 'Descuento', fieldName: 'SBQQ__Discount__c', type: 'percent',typeAttributes: {step: '0.01'}, initialWidth : 110},
    { label: 'Precio con descuento', fieldName: 'PRECIO_DESCUENTO__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 115},
    { label: 'Importe Bruto', fieldName: 'IMPORTE_BRUTO__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 115},
    { label: 'Margen Porcentaje', fieldName: 'MARGEN_CONSOLIDADO_PORC__c', type: 'percent',typeAttributes: {step: '0.01'}, initialWidth : 114},
    { label: 'Margen Operación', fieldName: 'MARGEN_CONSOLIDADO__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 115},
    { label: 'Utilidad Consolidada', fieldName: 'UTILIDAD_CONSOLIDADA__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { fieldName: '', label: '',initialWidth : 34, cellAttributes: { iconName: { fieldName: 'dynamicIcon'}}, initialWidth : 110}
];
const COLUMNS_MB = [
    { label: 'Código de producto', fieldName: 'SBQQ__ProductCode__c', initialWidth : 119 },
    { label: 'Nombre de producto', fieldName: 'INT_Nombre_de_producto__c',initialWidth : 205, wrapText:true},
    //{ label: 'Cantidad', fieldName: 'SBQQ__Quantity__c', type : 'number',initialWidth : 100, typeAttributes: { step: '0.01' }},
    { label: 'Precio base', fieldName: 'PRECIO_BASE__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { label: 'Precio especial', fieldName: 'SBQQ__ListPrice__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' },initialWidth : 110},
    { label: 'Descuento', fieldName: 'DESCTO_PROY_PORC__c', type: 'percent',typeAttributes: {step: '0.00001',
	minimumFractionDigits: '2',
	maximumFractionDigits: '3',}, initialWidth : 110},
    { label: 'Precio proyecto', fieldName: 'PRECIO_PROY_SIN_IVA__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { label: 'Importe bruto', fieldName: 'TOTAL_PROYECTO__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { label: 'Margen porcentaje', fieldName: 'MARGEN_PORC__c', type: 'percent',typeAttributes: {step: '0.01'}, initialWidth : 110},
    { label: 'Margen operación', fieldName: 'MARGEN__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { label: 'Utilidad consolidada', fieldName: 'UTILIDAD_CONSOLIDADA__c',type: 'currency', typeAttributes: { currencyCode: 'MXN', step: '0.01' }, initialWidth : 110},
    { fieldName: '', label: '',initialWidth : 34, cellAttributes: { iconName: { fieldName: 'dynamicIcon'}}, initialWidth : 110}
];

export default class individualApprover extends NavigationMixin(LightningElement) {
    @api recordId;
    @api quote;
    @api quoteId;
    @api level;
    @track isLoading = false;
    comments = '';
    emptyPendingApproval = false;
    isEmptyQLINO = false;
    isEmptyQLIMB = false;
    selectedQLINO = [];
    selectedQLIMB = [];
    quoteLineItemsMB = [];
    quoteLineItemsNO = [];
    error;
    approvalLevel;
    columnsNO = COLUMNS_NO;
    columnsMB = COLUMNS_MB;
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
      if (error) {
        let message = "Unknown error";
        console.log('ERROR: ' + JSON.stringify(error));
        if (Array.isArray(error.body)) {
          message = error.body.map((e) => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
          message = error.body.message;
        }
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error loading Attachments",
            message: message,
            variant: "error",
          }),
        );
      } else if (data) {
        console.log('SUCCESS:ENTRAMOS AQUI OTRA VEZ...');
          console.log(data)
        this.quote = data;
        this.quoteId = this.quote.fields.Cotizacion__c.value;
        this.level = this.quote.fields.Nivel__c.value;
        console.log(this.quoteId);
      }
    }

    @wire(fetchQuoteLineItems, {quoteId: "$quoteId",groupId : "$recordId"})
    wiredResult({data, error}){
        if(data){
            let dataSize = [];
            dataSize = data;
            console.log('DATASize: ' + dataSize);
            console.log('DATASize:LENGTH: ' + dataSize.length);
            if(dataSize.length > 0){
                console.log('ENTRAMOS AQUI');
                if(!data[0].Estado_Aprobacion_Nivel_1__c){
                    this.approvalLevel = '1';
                }else if(!data[0].Estado_Aprobacion_Nivel_2__c && data[0].Aprobador_Nivel_2__c){
                    this.approvalLevel = '2';
                }else if(!data[0].Estado_Aprobacion_Nivel_3__c && data[0].Aprobador_Nivel_3__c){
                    this.approvalLevel = '3';
                }else if(!data[0].Estado_Aprobacion_Nivel_4__c && data[0].Aprobador_Nivel_4__c){
                    this.approvalLevel = '4';
                }else if(!data[0].Estado_Aprobacion_Nivel_5__c && data[0].Aprobador_Nivel_5__c){
                    this.approvalLevel = '5';
                }else if(!data[0].Estado_Aprobacion_Nivel_6__c && data[0].Aprobador_Nivel_6__c){
                    this.approvalLevel = '6';
                }else{
                    this.emptyPendingApproval = true;
                }
                console.log('emptyPendingApproval',this.quoteLineItemsMB);
                console.log('approvalLevel',this.quoteLineItemsNO);
                if(this.quoteLineItemsMB.length === 0 && this.quoteLineItemsNO.length === 0){
                    data.forEach(element => {
                        console.log('TIPO DE PRICEBOOK: ' + element.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c);
                        //Distincion por lista de precio
                        if(element.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c){
                            this.quoteLineItemsMB = [...this.quoteLineItemsMB, element];
                        }else{
                            this.quoteLineItemsNO = [...this.quoteLineItemsNO, element];
                        }
                        //DIstincion por tipo CPQ
                        /*if(element.INT_Tipo_CPQ__c == "MB"){
                            this.quoteLineItemsMB = [...this.quoteLineItemsMB, element];
                        }else{
                            this.quoteLineItemsNO = [...this.quoteLineItemsNO, element];
                        }*/
                    });
                }
                
                this.isEmptyQLIMB = Object.keys(this.quoteLineItemsMB).length !== 0;
                this.isEmptyQLINO = Object.keys(this.quoteLineItemsNO).length !== 0;
                console.log(this.quoteLineItemsMB);
                console.log(this.quoteLineItemsNO);
            }
        }
        if(error){
            console.log(error)
            this.quoteLineItemsMB = undefined;
            this.quoteLineItemsNO = undefined;
        }
    }

    handleKeyChange( event ) {
        /*const searchKey = event.target.value;
        if ( searchKey ) {
            fetchQuoteLineItems( { searchKey } )
            .then(result => {
                this.quoteLineItems = result;
            })
            .catch(error => {
                this.error = error;
            });
        } else
        this.quoteLineItems = undefined;*/
    }
    handleClickApprove( event ) {
        console.log(this.selectedQLIMB);
        console.log(this.quoteLineItemsMB);
        console.log(typeof this.selectedQLIMB);
        console.log(this.selectedQLINO);
        console.log(typeof this.selectedQLINO);
        let arrayMB = this.quoteLineItemsMB.map(a => {return {...a}})
        for (let i = 0; i < this.selectedQLIMB.length; i++) {
            let qli = arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id);
            if(this.approvalLevel == '1'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_1__c = "Approved";
            }else if(this.approvalLevel == '2'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_2__c = "Approved";
            }else if(this.approvalLevel == '3'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_3__c = "Approved";
            }else if(this.approvalLevel == '4'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_4__c = "Approved";
            }else if(this.approvalLevel == '5'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_5__c = "Approved";
            }else if(this.approvalLevel == '6'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_6__c = "Approved";
            }
            
            arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).dynamicIcon = "action:approval";
            
        }
        this.quoteLineItemsMB = arrayMB;
        console.log(this.quoteLineItemsMB);
        let arrayNO = this.quoteLineItemsNO.map(a => {return {...a}})
        for (let i = 0; i < this.selectedQLINO.length; i++) {
            let qli = arrayNO.find(a => a.Id == this.selectedQLINO[i].Id);
            if(this.approvalLevel == '1'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_1__c = "Approved";
            }else if(this.approvalLevel == '2'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_2__c = "Approved";
            }else if(this.approvalLevel == '3'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_3__c = "Approved";
            }else if(this.approvalLevel == '4'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_4__c = "Approved";
            }else if(this.approvalLevel == '5'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_5__c = "Approved";
            }else if(this.approvalLevel == '6'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_6__c = "Approved";
            }
            arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).dynamicIcon = "action:approval";
        }
        this.quoteLineItemsNO = arrayNO;
    }
    handleClickReject( event ) {
        console.log(this.selectedQLIMB);
        console.log(this.quoteLineItemsMB);
        console.log(typeof this.selectedQLIMB);
        console.log(this.selectedQLINO);
        console.log(typeof this.selectedQLINO);
        let arrayMB = this.quoteLineItemsMB.map(a => {return {...a}})
        for (let i = 0; i < this.selectedQLIMB.length; i++) {
            let qli = arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id);
            if(this.approvalLevel == '1'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_1__c = "Rejected";
            }else if(this.approvalLevel == '2'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_2__c = "Rejected";
            }else if(this.approvalLevel == '3'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_3__c = "Rejected";
            }else if(this.approvalLevel == '4'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_4__c = "Rejected";
            }else if(this.approvalLevel == '5'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_5__c = "Rejected";
            }else if(this.approvalLevel == '6'){
                arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).Estado_Aprobacion_Nivel_6__c = "Rejected";
            }
            arrayMB.find(a => a.Id == this.selectedQLIMB[i].Id).dynamicIcon = "action:close";
            
        }
        this.quoteLineItemsMB = arrayMB;
        console.log(this.quoteLineItemsMB);
        let arrayNO = this.quoteLineItemsNO.map(a => {return {...a}})
        for (let i = 0; i < this.selectedQLINO.length; i++) {
            let qli = arrayNO.find(a => a.Id == this.selectedQLINO[i].Id);
            if(this.approvalLevel == '1'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_1__c = "Rejected";
            }else if(this.approvalLevel == '2'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_2__c = "Rejected";
            }else if(this.approvalLevel == '3'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_3__c = "Rejected";
            }else if(this.approvalLevel == '4'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_4__c = "Rejected";
            }else if(this.approvalLevel == '5'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_5__c = "Rejected";
            }else if(this.approvalLevel == '6'){
                arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).Estado_Aprobacion_Nivel_6__c = "Rejected";
            }
            arrayNO.find(a => a.Id == this.selectedQLINO[i].Id).dynamicIcon = "action:close";
        }
        this.quoteLineItemsNO = arrayNO;
    }
    getSelectedNameMB(event) {
        console.log("getSelectedNameMB");
        const selectedRows = event.detail.selectedRows;
        const selected = [];
        // Display that fieldName of the selected rows
        selectedRows.forEach(element => {
            //selected = [...selected, element];
            selected.push(element);
        });
        this.selectedQLIMB = selected;
        /*for (let i = 0; i < selectedRows.length; i++) {
            console.log('You selected: ' + selectedRows[i].Name);
        }*/
    }
    getSelectedNameNO(event) {
        console.log("getSelectedNameNO");
        const selectedRows = event.detail.selectedRows;
        const selected = [];
        console.log(selectedRows);
        // Display that fieldName of the selected rows
        selectedRows.forEach(element => {
            //selected = [...selected, element];
            selected.push(element);
        });
        this.selectedQLINO = selected;
        console.log(selected);

        /*for (let i = 0; i < selectedRows.length; i++) {
            console.log('You selected: ' + selectedRows[i].Name);
        }*/
    }
    callRowAction( event ) {
        const recId =  event.detail.row.Id;
        const actionName = event.detail.action.name;
        if ( actionName === 'Edit' ) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Account',
                    actionName: 'edit'
                }
            })
        } else if ( actionName === 'View') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Account',
                    actionName: 'view'
                }
            })
        }
    }
    handleRowAction(event) {
        
        if (event.detail.action.name === 'viewApprovals') {
            console.log(' Aprobadores');
        }
    }
    handleClickSave( event ) {
        this.isLoading = true;
        let isPending = false;
        let allQLI = [];
        if(this.quoteLineItemsMB.length > 0){
			for (var i = 0; i < this.quoteLineItemsMB.length; i++) {
				allQLI = [...allQLI, this.quoteLineItemsMB[i]];
				if(!this.quoteLineItemsMB[i].dynamicIcon){
					isPending = true;
				}
			}
		}
		if(this.quoteLineItemsNO.length > 0){
			for (let i = 0; i < this.quoteLineItemsNO.length; i++) {
				allQLI = [...allQLI, this.quoteLineItemsNO[i]];
				if(!this.quoteLineItemsNO[i].dynamicIcon){
					isPending = true;
				}
			}
		}
		if(allQLI.length > 0 && !isPending)  {
			for (let i = 0; i < allQLI.length; i++) {
				if(allQLI[i].SBQQ__Discount__c) delete allQLI[i].SBQQ__Discount__c;
				if(allQLI[i].DESCTO_PROY_PORC__c) delete allQLI[i].DESCTO_PROY_PORC__c;
				if(allQLI[i].MARGEN_PORC__c) delete allQLI[i].MARGEN_PORC__c;
				if(allQLI[i].MARGEN_CONSOLIDADO_PORC__c) delete allQLI[i].MARGEN_CONSOLIDADO_PORC__c;
			}
		}
        console.log("allQLI ",allQLI);
		console.log("isPending ",isPending);
        if(isPending){
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Selección Incompleta",
                  message : "Debes aprobar o rechazar la totalidad de los registros en este grupo",
                  variant: "error"
                }),
              );
        }else{
            updateQLI({ lstQLIUpdate: allQLI, comments: this.comments })
            .then((result) => {
                this.isLoading = false;
                this.emptyPendingApproval = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "¡Éxito!",
                      message : "Se han aprobado/rechazado correctamente las partidas",
                      variant: "success"
                    }),
                  );
                  this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                console.log('ERROR: ' + JSON.stringify(error));
                if(Object.keys(error).length !== 0){
                    console.log('ERROR:BODY ' + JSON.stringify(error.body));
                    console.log('ERROR:MSJ ' + JSON.stringify(error.body.message));
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error aprobando/rechanzando las partidas',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }else{
                    console.log('NO TENEMOS ERROR');
                }
            });
        }

    }
    changeComments(event){
        this.comments = event.target.value;
     }
}