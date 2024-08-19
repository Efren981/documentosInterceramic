@isTest
public class TS4_MessagingSessionTrigger_Test {
    
    @testSetup
    public static void init(){

        Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
        
        User usuario = new User();
        usuario.Username ='usuarioprueba1@gmail.com';
        usuario.LastName ='Usuario1';
        usuario.FirstName ='Prueba1';
        usuario.MiddleName='Test'; 
        usuario.CompanyName ='Interceramic';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='IS1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='is1';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es'; 
        insert usuario;
        
        Account testAccount = new Account(
            Name = 'Test Cuenta',
            INT_RFC__c='MAPD097812'
        );
        insert testAccount;
        
        Contact contacto = new Contact(
            AccountId =testAccount.Id,
            FirstName ='Prueba',
            Lastname ='Prueba',
            Title='Sr'
        );
        insert contacto;
        
        Case caso = new Case();
        caso.Subject='Chatbot';
        caso.TS4_Correo__c='prueba@gmail.com';
        caso.AccountId=testAccount.Id;
        caso.ContactId=contacto.Id;
        insert caso;

        MessagingSession ms =new MessagingSession();
        ms.StartTime=System.today();
        ms.CaseId  =caso.id;
        ms.MessagingChannelId='0MjcY000000UuKvSAK';
        ms.MessagingEndUserId='0PAcY000000dlLeWAI';
        ms.Status='Waiting';
        ms.ConversationId='0dwcY000001J6sMQAS';
        insert ms;
    }
    
    @isTest
    static void createMessagingSession(){
        MessagingSession sessions = [SELECT Id, MessagingEndUserId FROM MessagingSession WHERE MessagingEndUserId ='0PAcY000000dlLeWAI'];
        //sessions.Status='Active';
        //update sessions;

    }

}