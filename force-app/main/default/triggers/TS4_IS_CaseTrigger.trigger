trigger TS4_IS_CaseTrigger on Case (before insert,after update,before update) {
    
    if(Trigger.isBefore) {
        if(Trigger.isUpdate){
            
        }
    }

    
    
    Integer countEtapas;
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Case etapasCaso : Trigger.new) {
            
            Case oldCase = Trigger.oldMap.get(etapasCaso.Id);
            BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='Horario Prueba'];            
            List<Group> ownerQueue=[Select id FROM group WHERE Type='Queue' AND Id=:etapasCaso.OwnerId];
            
            if(ownerQueue.size()==0){
                User usuarioCaso = [SELECT Id,Name,ProfileId FROM User WHERE Id=:etapasCaso.OwnerId];
                
                //Id idAgenteVentas=[SELECT Id from Profile where Name='Agentes de Ventas'].Id;
                //Id idAsesorTecnico=[SELECT Id from Profile where Name='Asesores Técnicos'].Id;
                //Id isEjecutivo=[SELECT Id from Profile where Name='Administrador del sistema'].Id;
                
                if(etapasCaso.ParentId ==null){
                    if(etapasCaso.Status != oldCase.Status){
                        if(etapasCaso.Status=='En proceso'){
                            countEtapas= etapasCaso.TS4_VecesEnProceso__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesEnProceso__c+1);
                            etapasCaso.TS4_VecesEnProceso__c=countEtapas;
                            etapasCaso.TS4_FechaEtapaProceso__c=DateTime.now();
                            etapasCaso.TS4_FechaEtapaEsperaCliente__c =null;
                            etapasCaso.TS4_FechaEtapaValidacion__c =null;
                            
                        }
                        else if(etapasCaso.Status=='Ayuda interna' && oldCase.Status=='En proceso'){
                            
                            //validar el propietario del caso
                            countEtapas= etapasCaso.TS4_VecesAyudaAreaInterna__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesAyudaAreaInterna__c+1);
                            etapasCaso.TS4_VecesAyudaAreaInterna__c=countEtapas;
                            etapasCaso.TS4_FechaEtapaAreaInterna__c =DateTime.now();
                            
                            if (etapasCaso.TS4_FechaEtapaProceso__c != null) { //tiempo le cuenta al cliente
                                Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaAreaInterna__c); 
                                Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                                
                                if(etapasCaso.TS4_TiempoEjecutivo__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoEjecutivo__c);
                                    
                                    etapasCaso.TS4_TiempoEjecutivo__c  = myTime;
                                }else{
                                    etapasCaso.TS4_TiempoEjecutivo__c =tiempoEtapasCliente;
                                }
                                
                            }
                        }
                        else if(etapasCaso.Status=='Pendiente por el cliente' && oldCase.Status=='En proceso'){
                            System.debug('entra if');
                            countEtapas= etapasCaso.TS4_VecesPendienteCliente__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesPendienteCliente__c+1);
                            etapasCaso.TS4_VecesPendienteCliente__c=countEtapas;
                            etapasCaso.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                            
                            if (etapasCaso.TS4_FechaEtapaProceso__c != null) {
                                Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaEsperaCliente__c); 
                                System.debug('hours'+hours);
                                Time tiempoEtapas= calculateDateTimeDifference(hours);
                                System.debug('tiempoEtapas'+tiempoEtapas);
                                
                                //diferencia por proceso de atención general y garantías
                                //if(etapasCaso.Owner.ProfileId ==idAgenteVentas){
                                System.debug('etapasCaso.Owner.ProfileId'+usuarioCaso.ProfileId);
                                //System.debug('isEjecutivo'+isEjecutivo);
                                
                                //if(usuarioCaso.ProfileId ==isEjecutivo){
                                    
                                    if(etapasCaso.TS4_TiempoEjecutivo__c !=null){
                                        Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
                                        System.debug('myTime'+myTime);
                                        etapasCaso.TS4_TiempoEjecutivo__c = myTime;
                                        
                                    }else{
                                        etapasCaso.TS4_TiempoEjecutivo__c = tiempoEtapas;
                                        
                                    }
                                    
                                    //}else if(etapasCaso.Owner.ProfileId ==idAsesorTecnico){
                                /*}else{
                                    if(etapasCaso.TS4_TiempoAT__c !=null){
                                        Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoAT__c);
                                        etapasCaso.TS4_TiempoAT__c = myTime;
                                        
                                    }else{
                                        etapasCaso.TS4_TiempoAT__c = tiempoEtapas;
                                        
                                    }
                                }*/
                                
                                /*if(etapasCaso.TS4_TiempoEjecutivo__c !=null){
Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
System.debug('myTime'+myTime);
etapasCaso.TS4_TiempoEjecutivo__c = myTime;

}else{
etapasCaso.TS4_TiempoEjecutivo__c = tiempoEtapas;

}*/
                            }
                            
                        }
                        else if(etapasCaso.Status=='En validación' && oldCase.Status=='Ayuda interna'){
                            countEtapas= etapasCaso.TS4_VecesValidacion__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesValidacion__c+1);
                            etapasCaso.TS4_VecesValidacion__c=countEtapas;
                            
                            etapasCaso.TS4_FechaEtapaValidacion__c =DateTime.now();
                            /*if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente

Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaValidacion__c); 
Time tiempoEtapasCliente= calculateDateTimeDifference(hours);

if(etapasCaso.TS4_TiempoAreaInterna__c !=null){
Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaInterna__c);

etapasCaso.TS4_TiempoAreaInterna__c = myTime;
}else{
etapasCaso.TS4_TiempoAreaInterna__c=tiempoEtapasCliente;
}

}*/
                            
                        }
                        else if(etapasCaso.Status=='En validación' && oldCase.Status=='Pendiente por el cliente'){
                            countEtapas= etapasCaso.TS4_VecesValidacion__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesValidacion__c+1);
                            etapasCaso.TS4_VecesValidacion__c=countEtapas;
                            
                            etapasCaso.TS4_FechaEtapaValidacion__c =DateTime.now();
                            if (etapasCaso.TS4_FechaEtapaEsperaCliente__c != null) { //tiempo le cuenta al cliente
                                
                                Long milliseconds = etapasCaso.TS4_FechaEtapaValidacion__c.getTime() - etapasCaso.TS4_FechaEtapaEsperaCliente__c.getTime();
                                
                                Integer horas = (Integer)(milliseconds / 3600000);
                                Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                                Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000); 
                                Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
                                
                                if(etapasCaso.TS4_TiempoCliente__c !=null){
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoCliente__c);
                                    
                                    etapasCaso.TS4_TiempoCliente__c = myTime;
                                }else{
                                    etapasCaso.TS4_TiempoCliente__c=tiempoEtapasCliente;
                                }
                                
                            }
                            
                        }
                        
                        else if(etapasCaso.Status=='Resuelto' && oldCase.Status=='En proceso'){
                            countEtapas= etapasCaso.TS4_VecesCerrado__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesCerrado__c+1);
                            etapasCaso.TS4_VecesCerrado__c=countEtapas;
                            etapasCaso.TS4_FechaEtapaCerrado__c=DateTime.now();
                            if (etapasCaso.TS4_FechaEtapaProceso__c != null) {
                                Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaCerrado__c); 
                                Time tiempoEtapas= calculateDateTimeDifference(hours);
                                
                                if(etapasCaso.TS4_TiempoEjecutivo__c !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
                                    etapasCaso.TS4_TiempoEjecutivo__c = myTime;
                                    
                                }
                            }
                            
                            
                        }
                        
                        else if(etapasCaso.Status=='Pendiente por el cliente' && oldCase.Status=='Ayuda interna'){
                            countEtapas= etapasCaso.TS4_VecesPendienteCliente__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesPendienteCliente__c +1);
                            etapasCaso.TS4_VecesPendienteCliente__c=countEtapas;
                            etapasCaso.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                            if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                                Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaEsperaCliente__c); 
                                Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                                
                                if(etapasCaso.TS4_TiempoAreaInterna__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaInterna__c);
                                    
                                    etapasCaso.TS4_TiempoAreaInterna__c  = myTime;
                                }else{
                                    etapasCaso.TS4_TiempoAreaInterna__c =tiempoEtapasCliente;
                                }
                                
                            }
                        }
                        
                        else if(etapasCaso.Status=='Asignado AT' && oldCase.Status=='En proceso'){
                            Datetime etapaAsesorTecnico=DateTime.now();
                            etapasCaso.TS4_FechaEtapaAreaInterna__c =DateTime.now();
                            
                            if (etapasCaso.TS4_FechaEtapaProceso__c != null) { //tiempo le cuenta al cliente
                                Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapaAsesorTecnico); 
                                Time tiempoEtapasEjecutivo=calculateDateTimeDifference(hours);
                                
                                if(etapasCaso.TS4_TiempoEjecutivo__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasEjecutivo,etapasCaso.TS4_TiempoEjecutivo__c);
                                    
                                    etapasCaso.TS4_TiempoEjecutivo__c  = myTime;
                                }else{
                                    etapasCaso.TS4_TiempoEjecutivo__c =tiempoEtapasEjecutivo;
                                }
                                
                            }
                            
                        }
                        
                    }
                }else{
                    Time myTimeCasoPrincipal;
                    
                    Case casoPadre =[SELECT Id,TS4_TiempoEjecutivo__c,TS4_TiempoCliente__c,TS4_FechaEtapaAreaInterna__c,TS4_TiempoAreaInterna__c,TS4_VecesEnProceso__c,TS4_VecesPendienteCliente__c,TS4_VecesValidacion__c FROM Case Where Id =:etapasCaso.ParentId];
                    
                    if(etapasCaso.Status=='En proceso'){
                        countEtapas= casoPadre.TS4_VecesEnProceso__c==null?1:Integer.valueOf(casoPadre.TS4_VecesEnProceso__c+1);
                        casoPadre.TS4_VecesEnProceso__c=countEtapas;
                        etapasCaso.TS4_FechaEtapaProceso__c=DateTime.now();
                        //le cuenta al ejecutivo 
                        
                        
                    }
                    
                    else if(etapasCaso.Status=='Pendiente por el cliente' && oldCase.Status=='En proceso'){
                        countEtapas= casoPadre.TS4_VecesPendienteCliente__c==null?1:Integer.valueOf(casoPadre.TS4_VecesPendienteCliente__c +1);
                        casoPadre.TS4_VecesPendienteCliente__c=countEtapas;
                        etapasCaso.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                        
                        if (etapasCaso.TS4_FechaEtapaProceso__c != null) {
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaEsperaCliente__c); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            
                            if(etapasCaso.TS4_TiempoEjecutivo__c !=null){
                                
                                Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
                                etapasCaso.TS4_TiempoEjecutivo__c = myTime;
                                
                                if(casoPadre.TS4_TiempoEjecutivo__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoEjecutivo__c,tiempoEtapas);
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                }else{
                                    myTimeCasoPrincipal =myTime;
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                    
                                }
                                
                            }else{
                                etapasCaso.TS4_TiempoEjecutivo__c = tiempoEtapas;
                                if(casoPadre.TS4_TiempoEjecutivo__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoEjecutivo__c,tiempoEtapas);
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                    
                                    
                                }else{
                                    casoPadre.TS4_TiempoEjecutivo__c=tiempoEtapas;
                                    
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                    else if(etapasCaso.Status=='En validación' && oldCase.Status=='Pendiente por el cliente'){
                        countEtapas= casoPadre.TS4_VecesValidacion__c==null?1:Integer.valueOf(casoPadre.TS4_VecesValidacion__c+1);
                        casoPadre.TS4_VecesValidacion__c=countEtapas;
                        
                        etapasCaso.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaEsperaCliente__c != null) { //tiempo le cuenta al cliente
                            
                            Long milliseconds = etapasCaso.TS4_FechaEtapaValidacion__c.getTime() - etapasCaso.TS4_FechaEtapaEsperaCliente__c.getTime();
                            
                            Integer horas = (Integer)(milliseconds / 3600000);
                            Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                            Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000);
                            
                            Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
                            
                            if(etapasCaso.TS4_TiempoCliente__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoCliente__c);
                                
                                //casoPadre.TS4_TiempoCliente__c = myTime;
                                etapasCaso.TS4_TiempoCliente__c = myTime;
                                
                                if(casoPadre.TS4_TiempoCliente__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoCliente__c,tiempoEtapasCliente);
                                    casoPadre.TS4_TiempoCliente__c=myTimeCasoPrincipal;
                                }else{
                                    myTimeCasoPrincipal =myTime;
                                    casoPadre.TS4_TiempoCliente__c=myTimeCasoPrincipal;
                                    
                                }
                                
                            }else{
                                //casoPadre.TS4_TiempoCliente__c=tiempoEtapasCliente;
                                etapasCaso.TS4_TiempoCliente__c = tiempoEtapasCliente;
                                if(casoPadre.TS4_TiempoCliente__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoCliente__c,tiempoEtapasCliente);
                                    casoPadre.TS4_TiempoCliente__c=myTimeCasoPrincipal;
                                    
                                    
                                }else{
                                    casoPadre.TS4_TiempoCliente__c=tiempoEtapasCliente;
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                    //else if(etapasCaso.Status=='En resolución'){
                    else if(etapasCaso.Status=='Resuelto'){
                        //countEtapas= etapasCaso.TS4_VecesCerrado__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesCerrado__c+1);
                        //etapasCaso.TS4_VecesCerrado__c=countEtapas;
                        Datetime fechaResolucion=DateTime.now();
                        if (casoPadre.TS4_FechaEtapaAreaInterna__c != null) {
                            Long hours =horasTareas(bhIS,casoPadre.TS4_FechaEtapaAreaInterna__c,fechaResolucion); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            
                            if(casoPadre.TS4_TiempoAreaInterna__c !=null){
                                
                                Time myTime =tiemposPorAutor(tiempoEtapas,casoPadre.TS4_TiempoAreaInterna__c);
                                casoPadre.TS4_TiempoAreaInterna__c = myTime;
                                
                            }else{
                                casoPadre.TS4_TiempoAreaInterna__c = tiempoEtapas;
                                
                            }
                        }
                        
                        
                    }
                    /*else if(etapasCaso.Status=='Resuelto' && oldCase.Status=='En proceso'){
countEtapas= etapasCaso.TS4_VecesCerrado__c==null?1:Integer.valueOf(etapasCaso.TS4_VecesCerrado__c+1);
etapasCaso.TS4_VecesCerrado__c=countEtapas;
etapasCaso.TS4_FechaEtapaCerrado__c=DateTime.now();
if (etapasCaso.TS4_FechaEtapaProceso__c != null) {
Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaCerrado__c); 
Time tiempoEtapas= calculateDateTimeDifference(hours);

if(etapasCaso.TS4_TiempoEjecutivo__c !=null){

Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
etapasCaso.Parent.TS4_TiempoEjecutivo__c = myTime;

}
}


}*/
 
                    update casoPadre;
                }
                
            }
            
            
        }
        
    }
    
        
    if(Trigger.isBefore && Trigger.isUpdate || Trigger.isBefore && Trigger.isInsert){
        TS4_IS_CaseHandler caseHandler = new TS4_IS_CaseHandler(Trigger.New,Trigger.Old);
        caseHandler.entitlementCase();
        /*Set<Id> contactIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        for (Case c : Trigger.new) {
            contactIds.add(c.ContactId);
            acctIds.add(c.AccountId);
        }
        List <EntitlementContact> entlContacts =
            [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
             From EntitlementContact e
             Where e.ContactId in :contactIds
             //And e.Entitlement.EndDate >= Today
             And e.Entitlement.StartDate <= Today];
        if(entlContacts.isEmpty()==false){
            for(Case c : Trigger.new){
                if(c.EntitlementId == null && c.ContactId != null){
                    for(EntitlementContact ec:entlContacts){
                        if(ec.ContactId==c.ContactId){
                            c.EntitlementId = ec.EntitlementId;
                            if(c.AssetId==null && ec.Entitlement.AssetId!=null)
                                c.AssetId=ec.Entitlement.AssetId;
                            break;
                        }
                    }
                }
            }
        } else{
            List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate,
                                        e.AccountId, e.AssetId
                                        From Entitlement e
                                        Where e.AccountId in :acctIds And e.EndDate >= Today
                                        And e.StartDate <= Today];
            if(entls.isEmpty()==false){
                for(Case c : Trigger.new){
                    if(c.EntitlementId == null && c.AccountId != null){
                        for(Entitlement e:entls){
                            if(e.AccountId==c.AccountId){
                                c.EntitlementId = e.Id;
                                if(c.AssetId==null && e.AssetId!=null)
                                    c.AssetId=e.AssetId;
                                break;
                            }
                        }
                    }
                }
            }
        }*/
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