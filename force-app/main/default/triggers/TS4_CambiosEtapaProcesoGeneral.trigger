trigger TS4_CambiosEtapaProcesoGeneral on Case (before insert,after update,before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate || Trigger.isBefore && Trigger.isInsert){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        for (Case c : Trigger.new) {
            contactIds.add(c.ContactId);
            acctIds.add(c.AccountId);
        }
        List <EntitlementContact> entlContacts =
            [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
             From EntitlementContact e
             Where e.ContactId in :contactIds
             And e.Entitlement.EndDate >= Today
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
        }
    }

    /*List<TS4_EtapasProcesoGeneral__c> metadataList = [SELECT TS4_EtapasEjecutivo__c FROM TS4_EtapasProcesoGeneral__c];

for (TS4_EtapasProcesoGeneral__c  metadata : metadataList) {
String value = metadata.TS4_EtapasEjecutivo__c;
System.debug('Value from Custom Metadata: ' + value);
}*/
    Integer countEtapas;
    public static Time calculateDateTimeDifference(Long hoursBussinesHour) {
        //Long milliseconds = endDate.getTime() - startDate.getTime();
        Long milliseconds = hoursBussinesHour;
        Long seconds = milliseconds / 1000;
        Long mins = milliseconds / 60000;
        Long hours = mins / 60;
        Long remainingMinutes = mins - (hours * 60);   
        System.debug('milliseconds'+milliseconds);
        System.debug('seconds'+seconds);
        System.debug('mins'+mins);
        System.debug('hours'+hours);
        System.debug('remainingMinutes'+remainingMinutes);

        //Time myTime = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 
        Time myTime = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(mins), Integer.valueOf(seconds), 0); 
        System.debug('myTime '+myTime);
        return myTime;
    }
    
    public static Time tiemposPorAutor(Time tiempoAnterior, Time tiempoNuevo) {
        Long time1Millis = tiempoAnterior.hour() * 3600000 + tiempoAnterior.minute() * 60000 + tiempoAnterior.second() * 1000;
        Long time2Millis = tiempoNuevo.hour() * 3600000 + tiempoNuevo.minute() * 60000 + tiempoNuevo.second() * 1000;
        Long totalTimeMillis = time1Millis + time2Millis;  
        Long seconds = totalTimeMillis / 1000;
        Long mins = totalTimeMillis / 60000;
        Long hours = mins / 60;
        Long remainingMinutes = mins - (hours * 60); 
        //Time myTime = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); // Represents 10:30 AM
        Time myTime = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(mins),Integer.valueOf(seconds), 0); // Represents 10:30 AM
        return myTime;
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        for(Case etapasCaso : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(etapasCaso.Id);
            BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic'];

            if(etapasCaso.ParentId ==null){
                if(etapasCaso.Status != oldCase.Status){
                    if(etapasCaso.Status=='En proceso'){
                        countEtapas= etapasCaso.TS4_FechaEtapaProceso__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesEnProceso__c+1);
                        etapasCaso.TS4_VecesEnProceso__c=countEtapas;
                        etapasCaso.TS4_FechaEtapaProceso__c=DateTime.now();
                        
                    }
                    else if(etapasCaso.Status=='Ayuda interna' && oldCase.Status=='En proceso'){
                        countEtapas= etapasCaso.TS4_FechaEtapaAreaInterna__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesAyudaAreaInterna__c+1);
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
                        countEtapas= etapasCaso.TS4_FechaEtapaEsperaCliente__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesPendienteCliente__c +1);
                        etapasCaso.TS4_VecesPendienteCliente__c=countEtapas;
                        etapasCaso.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                        
                        if (etapasCaso.TS4_FechaEtapaProceso__c != null) {
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaEsperaCliente__c); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);

                            if(etapasCaso.TS4_TiempoEjecutivo__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
                                
                                etapasCaso.TS4_TiempoEjecutivo__c = myTime;

                            }else{
                                etapasCaso.TS4_TiempoEjecutivo__c = tiempoEtapas;

                            }
                        }
                        
                    }
                    else if(etapasCaso.Status=='En validación' && oldCase.Status=='Ayuda interna'){
                        countEtapas= etapasCaso.TS4_FechaEtapaActualizado__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesActualizado__c+1);
                        etapasCaso.TS4_VecesActualizado__c=countEtapas;

                        etapasCaso.TS4_FechaEtapaActualizado__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                   
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaActualizado__c); 
                            Time tiempoEtapasCliente= calculateDateTimeDifference(hours);
                            //Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 

                            if(etapasCaso.TS4_TiempoAreaExterna__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaExterna__c);

                                etapasCaso.TS4_TiempoAreaExterna__c = myTime;
                            }else{
                                etapasCaso.TS4_TiempoAreaExterna__c=tiempoEtapasCliente;
                            }

                        }
                       
                    }
                    else if(etapasCaso.Status=='En validación' && oldCase.Status=='Pendiente por el cliente'){
                        countEtapas= etapasCaso.TS4_FechaEtapaActualizado__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesActualizado__c+1);
                        etapasCaso.TS4_VecesActualizado__c=countEtapas;

                        etapasCaso.TS4_FechaEtapaActualizado__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaEsperaCliente__c != null) { //tiempo le cuenta al cliente

                            Long milliseconds = etapasCaso.TS4_FechaEtapaActualizado__c.getTime() - etapasCaso.TS4_FechaEtapaEsperaCliente__c.getTime();
                            Long seconds = milliseconds / 1000;
                            Long mins = milliseconds / 60000;
                            Long hours = mins / 60;
                            Long remainingMinutes = mins - (hours * 60);                     
                            
                            Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(mins),Integer.valueOf(seconds), 0); // Represents 10:30 AM
                            System.debug('tiempoEtapasCliente'+tiempoEtapasCliente);

                            //Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(hours), Integer.valueOf(remainingMinutes), 0, 0); 
                            System.debug('tiempoEtapasCliente'+tiempoEtapasCliente);
                            if(etapasCaso.TS4_TiempoCliente__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoCliente__c);

                                etapasCaso.TS4_TiempoCliente__c = myTime;
                            }else{
                                etapasCaso.TS4_TiempoCliente__c=tiempoEtapasCliente;
                            }

                        }
                        /*List <Case> casoRelacionado=[SELECT Id FROM Case WHERE ParentId=: etapasCaso.Id];
                        if(casoRelacionado.size() >0){
                            casoRelacionado[0].Status='En proceso';
                            //le cuenta al ejecutivo
                            //update casoRelacionado;
                        }else{
                            Case casoRelacionadoNuevo = new Case(
                                ParentId =etapasCaso.Id,
                                Subject = etapasCaso.TS4_Categoria__c,
                                Status='En proceso'
                            );
                            insert casoRelacionadoNuevo;
                        }*/
                    }
          
                    else if(etapasCaso.Status=='Resuelto' && oldCase.Status=='En proceso'){
                        countEtapas= etapasCaso.TS4_FechaEtapaCerrado__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesCerrado__c+1);
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
                     /*else if(etapasCaso.Status=='En validación' && oldCase.Status=='Ayuda interna'){
                        etapasCaso.TS4_FechaEtapaActualizado__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaActualizado__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(etapasCaso.TS4_TiempoAreaExterna__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaExterna__c);

                                etapasCaso.TS4_TiempoAreaExterna__c  = myTime;
                            }else{
                                etapasCaso.TS4_TiempoAreaExterna__c =tiempoEtapasCliente;
                            }

                        }
                    }*/
                    else if(etapasCaso.Status=='Pendiente por el cliente' && oldCase.Status=='Ayuda interna'){
                        etapasCaso.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaEsperaCliente__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(etapasCaso.TS4_TiempoAreaExterna__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaExterna__c);

                                etapasCaso.TS4_TiempoAreaExterna__c  = myTime;
                            }else{
                                etapasCaso.TS4_TiempoAreaExterna__c =tiempoEtapasCliente;
                            }

                        }
                    }
                    
                    
                    
                }
            }/*else{
                if(etapasCaso.Status=='En proceso'){
                    etapasCaso.TS4_FechaEtapaProceso__c=DateTime.now();
                    //le cuenta al ejecutivo 

                }
                else if(etapasCaso.Status=='Ayuda interna' && oldCase.Status=='En proceso'){
                    countEtapas= etapasCaso.TS4_FechaEtapaAreaInterna__c==null?0:Integer.valueOf(etapasCaso.TS4_VecesAyudaAreaInterna__c +1);
                    etapasCaso.TS4_VecesAyudaAreaInterna__c =countEtapas;
                    etapasCaso.TS4_FechaEtapaAreaInterna__c=DateTime.now();
                    Case casoPrincipal =[SELECT Id,ParentId,Status FROM Case WHERE Id =:etapasCaso.ParentId];
                    casoPrincipal.Status='En proceso';
                    //le cuenta el tiempo al area externa
                     
                        if (etapasCaso.TS4_FechaEtapaProceso__c != null) {//tiempo le cuenta al ejecutivo
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaProceso__c,etapasCaso.TS4_FechaEtapaAreaInterna__c); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);

                            if(etapasCaso.TS4_TiempoEjecutivo__c !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapas,etapasCaso.TS4_TiempoEjecutivo__c);
                                etapasCaso.TS4_TiempoEjecutivo__c = myTime;

                            }else{
                                //etapasCaso.TS4_TiempoEjecutivo__c = calculateDateTimeDifference(etapasCaso.TS4_FechaEtapaProceso__c, etapasCaso.TS4_FechaEtapaEsperaCliente__c);
                                etapasCaso.TS4_TiempoEjecutivo__c = tiempoEtapas;

                            }
                        }
                }
                else if(etapasCaso.Status=='En validación' && oldCase.Status=='Ayuda interna'){
                        etapasCaso.TS4_FechaEtapaActualizado__c =DateTime.now();
                        if (etapasCaso.TS4_FechaEtapaAreaInterna__c != null) { //tiempo le cuenta al cliente
                            Long hours =horasTareas(bhIS,etapasCaso.TS4_FechaEtapaAreaInterna__c,etapasCaso.TS4_FechaEtapaActualizado__c); 
                            Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                            
                            if(etapasCaso.TS4_TiempoAreaExterna__c  !=null){

                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,etapasCaso.TS4_TiempoAreaExterna__c);

                                etapasCaso.TS4_TiempoAreaExterna__c  = myTime;
                            }else{
                                etapasCaso.TS4_TiempoAreaExterna__c =tiempoEtapasCliente;
                            }

                        }
                    }
                
            }*/
            
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
        /*System.debug('timeInMillis businnes'+timeInMillis);
        if (timeInMillis != null) {
            horasLaborales = (Decimal)timeInMillis / (1000 * 60 * 60);
        }*/
        return timeInMillis;
        
    }
    
}