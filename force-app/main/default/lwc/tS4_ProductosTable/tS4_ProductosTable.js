import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProductsForCase from '@salesforce/apex/TS4_ProductTableController.getProductsForCase';
import updateProducts from '@salesforce/apex/TS4_ProductTableController.updateProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TS4_ProductosTable extends LightningElement {
    @api recordId; // Id del Case
    @api editableFields = 'Name,TS4_Numero_de_piezas_a_reclamar__c'; // Campos editables como string
    @track data = [];
    @track columns = [];
    @track draftValues = [];

    editableFieldsArray = [];

    wiredProductsResult;

    connectedCallback() {
        // Convertir el string de campos editables a un array
        this.editableFieldsArray = this.editableFields.split(',').map(field => field.trim());
        this.generateColumns();
    }

    @wire(getProductsForCase, { caseId: '$recordId' })
    wiredProducts(result) {
        this.wiredProductsResult = result;
        if (result.data) {
            this.data = this.processData(result.data);
        } else if (result.error) {
            this.showToast('Error', 'Error al cargar los productos', 'error');
        }
    }

    processData(rawData) {
        return rawData.map(record => {
            let processedRecord = {};
            this.editableFieldsArray.forEach(field => {
                processedRecord[field] = record[field];
            });
            return processedRecord;
        });
    }

    generateColumns() {
        this.columns = this.editableFieldsArray.map(field => ({
            label: this.getFieldLabel(field),
            fieldName: field,
            type: this.getFieldType(field),
            editable: true
        }));
    }

    getFieldLabel(field) {
        switch(field) {
            case 'Name':
                return 'Nombre del Producto';
            case 'TS4_Numero_de_piezas_a_reclamar__c':
                return 'Número de Piezas a Reclamar';
            default:
                return field.replace('__c', '').replace('_', ' ');
        }
    }

    getFieldType(field) {
        if (field === 'TS4_Numero_de_piezas_a_reclamar__c') {
            return 'number';
        }
        return 'text';
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('Campos actualizados:', JSON.stringify(updatedFields));
        
        updateProducts({ productsToUpdate: updatedFields })
            .then(() => {
                this.showToast('Éxito', 'Productos actualizados correctamente', 'success');
                this.draftValues = [];
                return refreshApex(this.wiredProductsResult);
            })
            .catch(error => {
                console.error('Error al actualizar productos:', error);
                let errorMessage = 'Error al actualizar los productos';
                if (error.body && error.body.message) {
                    errorMessage += ': ' + error.body.message;
                }
                if (error.body && error.body.output && error.body.output.errors) {
                    errorMessage += ' Detalles: ' + JSON.stringify(error.body.output.errors);
                }
                this.showToast('Error', errorMessage, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}