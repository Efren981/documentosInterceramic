public class TS4_IS_CaseHandler {

    public List<Case> triggerNew;
    public List<Case> triggerOld; 
    Id rtGarantias = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_Garantia').getRecordTypeId();
    Integer countEtapas;

    public TS4_IS_CaseHandler(List<Case> triggerNew, List<Case> triggerOld) {
        this.triggerNew = triggerNew;
        this.triggerOld = triggerOld;
    }
    
    public void entitlementCase(){
        for(Integer i=0; i<triggerNew.size(); i++) {  
            Case caseNew = triggerNew[i];
            Set<Id> contactIds = new Set<Id>();
            Set<Id> acctIds = new Set<Id>();
            //for (Case c : Trigger.new) {
                contactIds.add(caseNew.ContactId);
                acctIds.add(caseNew.AccountId);
            //}
            List <EntitlementContact> entlContacts =
                [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
                 From EntitlementContact e
                 Where e.ContactId in :contactIds
                 //And e.Entitlement.EndDate >= Today
                 And e.Entitlement.StartDate <= Today];
            if(entlContacts.isEmpty()==false){
                //for(Case c : Trigger.new){
                    if(caseNew.EntitlementId == null && caseNew.ContactId != null){
                        for(EntitlementContact ec:entlContacts){
                            if(ec.ContactId==caseNew.ContactId){
                                caseNew.EntitlementId = ec.EntitlementId;
                                if(caseNew.AssetId==null && ec.Entitlement.AssetId!=null)
                                    caseNew.AssetId=ec.Entitlement.AssetId;
                                break;
                            }
                        }
                    }
                //}
            } else{
                List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate,
                                            e.AccountId, e.AssetId
                                            From Entitlement e
                                            Where e.AccountId in :acctIds /*And e.EndDate >= Today*/
                                            And e.StartDate <= Today];
                if(entls.isEmpty()==false){
                    //for(Case c : Trigger.new){
                        if(caseNew.EntitlementId == null && caseNew.AccountId != null){
                            for(Entitlement e:entls){
                                if(e.AccountId==caseNew.AccountId){
                                    caseNew.EntitlementId = e.Id;
                                    if(caseNew.AssetId==null && e.AssetId!=null)
                                        caseNew.AssetId=e.AssetId;
                                    break;
                                }
                            }
                        }
                    //}
                }
            }
            
        } 
        
        
    }
    
    public void cambioEtapasProcesoGarantiasVentas(){
        //Asignado
        //en proceso
        //pendiente por cliente
        //en validacion
        //cancelado
        //resuelto
        //asignado AT
        //enviado EBS
        //
        //tiempo ejecutivo
        //tiempo pendiente por cliente
        //tiempo asesor tecnico
        //timepo EBS
        for(Integer i=0; i<triggerNew.size(); i++) {   
            Case caseNew = triggerNew[i];
            Case caseOld = triggerOld[i];
            BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic'];
            
            if(caseNew.ParentId ==null){
                if(caseNew.Status != caseOld.Status){
                    if(caseNew.Status=='En proceso'){
                        countEtapas= caseNew.TS4_FechaEtapaProceso__c==null?0:Integer.valueOf(caseNew.TS4_VecesEnProceso__c+1);
                        caseNew.TS4_VecesEnProceso__c=countEtapas;
                        caseNew.TS4_FechaEtapaProceso__c=DateTime.now();
                    }
                    
                    else if(caseNew.Status=='Ayuda interna' && caseOld.Status=='En proceso'){
                        //validar el propietario del caso
                        countEtapas= caseNew.TS4_FechaEtapaAreaInterna__c==null?0:Integer.valueOf(caseNew.TS4_VecesAyudaAreaInterna__c+1);
                        caseNew.TS4_VecesAyudaAreaInterna__c=countEtapas;
                        caseNew.TS4_FechaEtapaAreaInterna__c =DateTime.now();

                        if (caseNew.TS4_FechaEtapaProceso__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaAreaInterna__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(caseNew.TS4_TiempoEjecutivo__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoEjecutivo__c);

                                caseNew.TS4_TiempoEjecutivo__c  = myTime;
                            }else{
                                caseNew.TS4_TiempoEjecutivo__c =tiempoEtapasCliente;
                            }

                        }
                    }
                    else if(caseNew.Status=='Pendiente por el cliente' && caseOld.Status=='En proceso'){
                        countEtapas= caseNew.TS4_FechaEtapaEsperaCliente__c==null?0:Integer.valueOf(caseNew.TS4_VecesPendienteCliente__c +1);
                        caseNew.TS4_VecesPendienteCliente__c=countEtapas;
                        caseNew.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                        
                        if (caseNew.TS4_FechaEtapaProceso__c != null) {
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaEsperaCliente__c); 
                            System.debug('hours'+hours);
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            System.debug('tiempoEtapas'+tiempoEtapas);

                            if(caseNew.TS4_TiempoEjecutivo__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoEjecutivo__c);
                                System.debug('myTime'+myTime);
                                caseNew.TS4_TiempoEjecutivo__c = myTime;

                            }else{
                                caseNew.TS4_TiempoEjecutivo__c = tiempoEtapas;

                            }
                        }
                        
                    }
                    else if(caseNew.Status=='En validación' && caseOld.Status=='Ayuda interna'){
                        countEtapas= caseNew.TS4_FechaEtapaValidacion__c==null?0:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                        caseNew.TS4_VecesValidacion__c=countEtapas;

                        caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                   
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaAreaInterna__c,caseNew.TS4_FechaEtapaValidacion__c); 
                            Time tiempoEtapasCliente= calculateDateTimeDifference(hours);
                            //Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 

                            if(caseNew.TS4_TiempoAreaInterna__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoAreaInterna__c);

                                caseNew.TS4_TiempoAreaInterna__c = myTime;
                            }else{
                                caseNew.TS4_TiempoAreaInterna__c=tiempoEtapasCliente;
                            }

                        }
                       
                    }
                    else if(caseNew.Status=='En validación' && caseOld.Status=='Pendiente por el cliente'){
                        countEtapas= caseNew.TS4_FechaEtapaValidacion__c==null?0:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                        caseNew.TS4_VecesValidacion__c=countEtapas;

                        caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaEsperaCliente__c != null) { //tiempo le cuenta al cliente

                            Long milliseconds = caseNew.TS4_FechaEtapaValidacion__c.getTime() - caseNew.TS4_FechaEtapaEsperaCliente__c.getTime();
                            /*Long seconds = milliseconds / 1000;
                            Long mins = milliseconds / 60000;
                            Long hours = mins / 60;
                            Long remainingMinutes = mins - (hours * 60);  */
                            Integer horas = (Integer)(milliseconds / 3600000);
                            Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                            Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000);
                            
                            System.debug('Horas: ' + horas);
                            System.debug('Minutos: ' + minutos);
                            System.debug('Segundos: ' + segundos);
                            
                            Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
                            System.debug('tiempoEtapasCliente'+tiempoEtapasCliente);

                            //Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 
                            System.debug('tiempoEtapasCliente'+tiempoEtapasCliente);
                            if(caseNew.TS4_TiempoCliente__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoCliente__c);

                                caseNew.TS4_TiempoCliente__c = myTime;
                            }else{
                                caseNew.TS4_TiempoCliente__c=tiempoEtapasCliente;
                            }

                        }
                        
                    }
                    else if(caseNew.Status=='Resuelto' && caseOld.Status=='En proceso'){
                        countEtapas= caseNew.TS4_FechaEtapaCerrado__c==null?0:Integer.valueOf(caseNew.TS4_VecesCerrado__c+1);
                        caseNew.TS4_VecesCerrado__c=countEtapas;
                        caseNew.TS4_FechaEtapaCerrado__c=DateTime.now();
                        if (caseNew.TS4_FechaEtapaProceso__c != null) {
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaCerrado__c); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            
                            if(caseNew.TS4_TiempoEjecutivo__c !=null){
                                
                                Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoEjecutivo__c);
                                caseNew.TS4_TiempoEjecutivo__c = myTime;
                                
                            }
                        }

                      
                    }
                    else if(caseNew.Status=='Pendiente por el cliente' && caseOld.Status=='Ayuda interna'){
                        caseNew.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaAreaInterna__c,caseNew.TS4_FechaEtapaEsperaCliente__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(caseNew.TS4_TiempoAreaInterna__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoAreaInterna__c);

                                caseNew.TS4_TiempoAreaInterna__c  = myTime;
                            }else{
                                caseNew.TS4_TiempoAreaInterna__c =tiempoEtapasCliente;
                            }

                        }
                    }

                    
                }   
            }
            else{
                if(caseNew.Status=='En proceso'){
                    caseNew.TS4_FechaEtapaProceso__c=DateTime.now();
                    countEtapas= caseNew.TS4_FechaEtapaProceso__c==null?0:Integer.valueOf(caseNew.TS4_VecesEnProceso__c+1);
                    caseNew.TS4_VecesEnProceso__c=countEtapas;
                    caseNew.TS4_FechaEtapaProceso__c=DateTime.now();
                    //le cuenta al ejecutivo 

                }
                else if(caseNew.Status=='Ayuda interna' && caseOld.Status=='En proceso'){
                        countEtapas= caseNew.TS4_FechaEtapaAreaInterna__c==null?0:Integer.valueOf(caseNew.TS4_VecesAyudaAreaInterna__c+1);
                        caseNew.TS4_VecesAyudaAreaInterna__c=countEtapas;
                        caseNew.TS4_FechaEtapaAreaInterna__c =DateTime.now();

                        if (caseNew.TS4_FechaEtapaProceso__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaAreaInterna__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(caseNew.Parent.TS4_TiempoEjecutivo__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.Parent.TS4_TiempoEjecutivo__c);

                                caseNew.Parent.TS4_TiempoEjecutivo__c  = myTime;
                            }else{
                                caseNew.Parent.TS4_TiempoEjecutivo__c =tiempoEtapasCliente;
                            }

                        }
                    }
                else if(caseNew.Status=='Pendiente por el cliente' && caseOld.Status=='En proceso'){
                    countEtapas= caseNew.TS4_FechaEtapaEsperaCliente__c==null?0:Integer.valueOf(caseNew.TS4_VecesPendienteCliente__c +1);
                    caseNew.TS4_VecesPendienteCliente__c=countEtapas;
                    caseNew.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                    
                    if (caseNew.TS4_FechaEtapaProceso__c != null) {
                        Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaEsperaCliente__c); 
                        System.debug('hours'+hours);
                        Time tiempoEtapas= calculateDateTimeDifference(hours);
                        System.debug('tiempoEtapas'+tiempoEtapas);
                        
                        if(caseNew.Parent.TS4_TiempoEjecutivo__c !=null){
                            Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.Parent.TS4_TiempoEjecutivo__c);
                            System.debug('myTime'+myTime);
                            caseNew.Parent.TS4_TiempoEjecutivo__c = myTime;
                            
                        }else{
                            caseNew.Parent.TS4_TiempoEjecutivo__c = tiempoEtapas;
                            
                        }
                    }
                    
                }
                else if(caseNew.Status=='En validación' && caseOld.Status=='Ayuda interna'){
                        countEtapas= caseNew.TS4_FechaEtapaValidacion__c==null?0:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                        caseNew.TS4_VecesValidacion__c=countEtapas;

                        caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                   
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaAreaInterna__c,caseNew.TS4_FechaEtapaValidacion__c); 
                            Time tiempoEtapasCliente= calculateDateTimeDifference(hours);
                            //Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 

                            if(caseNew.Parent.TS4_TiempoAreaInterna__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.Parent.TS4_TiempoAreaInterna__c);

                                caseNew.Parent.TS4_TiempoAreaInterna__c = myTime;
                            }else{
                                caseNew.Parent.TS4_TiempoAreaInterna__c=tiempoEtapasCliente;
                            }

                        }
                       
                    }
                 else if(caseNew.Status=='En validación' && caseOld.Status=='Pendiente por el cliente'){
                        countEtapas= caseNew.TS4_FechaEtapaValidacion__c==null?0:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                        caseNew.TS4_VecesValidacion__c=countEtapas;

                        caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaEsperaCliente__c != null) { //tiempo le cuenta al cliente

                            Long milliseconds = caseNew.TS4_FechaEtapaValidacion__c.getTime() - caseNew.TS4_FechaEtapaEsperaCliente__c.getTime();
       
                            Integer horas = (Integer)(milliseconds / 3600000);
                            Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                            Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000);

                            Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM

                            if(caseNew.Parent.TS4_TiempoCliente__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.Parent.TS4_TiempoCliente__c);

                                caseNew.Parent.TS4_TiempoCliente__c = myTime;
                            }else{
                                caseNew.Parent.TS4_TiempoCliente__c=tiempoEtapasCliente;
                            }

                        }
                        
                    }
                else if(caseNew.Status=='Resuelto' && caseOld.Status=='En proceso'){
                    countEtapas= caseNew.TS4_FechaEtapaCerrado__c==null?0:Integer.valueOf(caseNew.TS4_VecesCerrado__c+1);
                    caseNew.TS4_VecesCerrado__c=countEtapas;
                    caseNew.TS4_FechaEtapaCerrado__c=DateTime.now();
                    if (caseNew.TS4_FechaEtapaProceso__c != null) {
                        Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaCerrado__c); 
                        Time tiempoEtapas= calculateDateTimeDifference(hours);
                        
                        if(caseNew.Parent.TS4_TiempoEjecutivo__c !=null){
                            
                            Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.Parent.TS4_TiempoEjecutivo__c);
                            caseNew.Parent.TS4_TiempoEjecutivo__c = myTime;
                            
                        }
                    }
                    
                    
                }

                
            }

        }        

        
    }
    
    /******************************************************************* 
Propósito: Método utilizado para calcular las horas acumuladas de una tarea.
Parametros: BusinessHours bh,Datetime startDate, Datetime endDate.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/    
    public static Long horasTareas(BusinessHours bh,Datetime startDate, Datetime endDate){
        String horasAcumuladas;                
        Decimal horasLaborales =0;
        Long timeInMillis= BusinessHours.diff(bh.id,startDate,endDate);
        System.debug('timeInMillis'+timeInMillis);
       
        return timeInMillis;
        
    }
    
    public static Time calculateDateTimeDifference(Long hoursBussinesHour) {
        Long milliseconds = hoursBussinesHour;
        Integer horas = (Integer)(milliseconds / 3600000);
        Integer minutos = (Integer)((Math.mod(milliseconds, 3600000 )) / 60000);        
        Integer segundos = (Integer)((Math.mod( (Math.mod(milliseconds, 3600000 )), 60000 )) / 1000);
        
        Time myTime = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos), Integer.valueOf(segundos), 0); 
        return myTime;
    }
    
    public static Time tiemposPorAutor(Time tiempoAnterior, Time tiempoNuevo) {

        Long time1Millis = tiempoAnterior.hour() * 3600000 + tiempoAnterior.minute() * 60000 + tiempoAnterior.second() * 1000;
        Long time2Millis = tiempoNuevo.hour() * 3600000 + tiempoNuevo.minute() * 60000 + tiempoNuevo.second() * 1000;
        Long totalTimeMillis = time1Millis + time2Millis;  
        Integer horas = (Integer)(totalTimeMillis / 3600000);
        Integer minutos = (Integer)((Math.mod( totalTimeMillis, 3600000 )) / 60000);        
        Integer segundos = (Integer)((Math.mod( (Math.mod( totalTimeMillis, 3600000 )), 60000 )) / 1000);
        
        Time myTime = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
        return myTime;
    }
    
}