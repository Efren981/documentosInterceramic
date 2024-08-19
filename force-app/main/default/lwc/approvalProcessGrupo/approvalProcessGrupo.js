import { LightningElement, api,track} from 'lwc';
import executeApprovalFlow from '@salesforce/apex/ApprovalGrupoController.executeApprovalFlow';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class ApprovalProcessGrupo extends LightningElement {
    @api recordId;
    @track isButtonDisabled = false;
    @track noEnviado = false;
    @track enviado = false;

    handleApproveClick() {
        this.isButtonDisabled = true;
        console.log('hola');
        console.log('recordId'+ this.recordId);
        
        //alert('Enviado a aprobación');
        //console.log('hola');
        //console.log('recordId'+ this.recordId);
        executeApprovalFlow({ recordId: this.recordId })
            .then(result => {
               console.log('result: ' + result);
               if(result[0] == 'Exito'){
                this.showNotification('EXITO', 'Cotización enviada a aprobar','success');
               }else{
                this.showNotification('ERROR', result[1],'error');
                this.isButtonDisabled = false;
               }
            })
            .catch(error => {
                // Manejar el error si ocurre
                console.log('OCURRIO UN ERROR: ' + error);
                console.log('OCURRIO UN ERROR:JSON: ' + JSON.stringify(error));
                this.showNotification('ERROR', JSON.stringify(error),'error');
                this.isButtonDisabled = false;
            });
    }


    showAlert(message) {
       // alert(message);
        if(message == true){
            this.enviado = true;
        }else{
            this.noEnviado = true;
        }
        
    }
    
    handleCancelClick() {
        this.showModal = false;
    }

    handleAcceptClick() {
        // Agrega aquí la lógica para enviar a aprobación
        this.showModal = false;
    }

    closeModal() {
        this.showModal = false;
    }

    showNotification(title, msj, variant) {
        const evt = new ShowToastEvent({
          title: title,
          message: msj,
          variant: variant,
        });
        this.dispatchEvent(evt);
      }
}