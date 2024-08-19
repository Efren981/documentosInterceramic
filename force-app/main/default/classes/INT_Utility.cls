/**FREEWAY
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Clase de utilidades para los desarrollos del proyecto INTERCERAMIC
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abraham Gudiño   <agudino@freewayconsulting.com>
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        08-09-2023
* @modified       
* @systemLayer    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            xxxxxxxxx@xxxxx.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class INT_Utility {
    

    /*
    * @name         sendApprovalNotification
    * @description	Metodo que envia la bell notification(Custom Notification) al usuario correspondiente para aprobación de partidas
    * @param		recipientsIds: Lista de usuarios, targetId: registro al que redirige la CN, title: titulo de la notificación
    *               body: cuerpo de la notificación
    * @return		N/A
    */
    public static void sendApprovalNotification(Set<String> recipientsIds, String targetId, String title, String body){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Aprobacion_Cotizaciones'];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    /*
    * @name         sendApprovalEmail
    * @description	Metodo que envia la bell notification(Custom Notification) al usuario correspondiente para aprobación de partidas
    * @param		templateId: id de la plantilla de correo electronico, recordId: Id del registro asociado a la plantilla,
    *               idTargetUser: Id de usuario objetivo para enviar el correo electronico
    * @return		N/A
    */
    public static void sendApprovalEmail(String templateId, String recordId, String idTargetUser){
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, idTargetUser, recordId);

        String emailSubject = email.getSubject();
        String emailTextBody = email.getPlainTextBody();

        email.setTargetObjectId(idTargetUser);
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailTextBody);
        email.saveAsActivity = false;

        try {
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        catch (Exception e) {
            System.debug('Problem sending email: ' + e.getMessage());
        }
    }
}