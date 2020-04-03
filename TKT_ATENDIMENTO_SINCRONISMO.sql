CREATE OR REPLACE PROCEDURE APPS.TKT_ATENDIMENTO_SINCRONISMO (P_PRINCIPAL    IN VARCHAR2,
                                                              P_REQUEST_ID   IN NUMBER,                                                 
                                                              P_STATUS_DESEJ IN VARCHAR2)
AS
BEGIN
  
  DECLARE
   
   
    
    EXC_OPERACAO EXCEPTION;
    OPERACAO_ENT EXCEPTION;                                                            

    CURSOR CLI IS                                                                                                           
     SELECT BCA.CLIENTE_ID, BCA.STATUS_PROCESSAMENTO
      FROM APPS.TKT_BACEN_CLI_ALL BCA 
       WHERE BCA.CLIENTE_ID = P_REQUEST_ID;

       
    CURSOR EST IS                                                                                                           
     SELECT TBEA.ESTABELECIMENTO_ID, TBEA.STATUS_PROCESSAMENTO
      FROM APPS.TKT_BACEN_ESTAB_ALL TBEA 
       WHERE TBEA.ESTABELECIMENTO_ID = P_REQUEST_ID;      
     
                          
    VCLI CLI%ROWTYPE;  
    VEST EST%ROWTYPE;  
      
    BEGIN                     
       
       IF P_PRINCIPAL NOT IN ('CLI','EST')THEN
         RAISE OPERACAO_ENT;
       END IF;  
                   
       IF P_PRINCIPAL = 'CLI' THEN
         
              BEGIN
                    EXECUTE IMMEDIATE 'ALTER TRIGGER APPS.TKT_BACEN_CLI_B_AU_TRG DISABLE';      
              END;

              OPEN CLI;
                 LOOP
                   FETCH CLI INTO VCLI;
                   EXIT WHEN CLI%NOTFOUND;

                       IF P_STATUS_DESEJ NOT IN ('ERRO','SOLICITADA HIGIENIZACAO','HIGIENIZADO_PARCIAL','HIGIENIZADO')THEN                
                         RAISE EXC_OPERACAO;
                       ELSE              
                   
                          UPDATE APPS.TKT_BACEN_CLI_ALL SET ATTRIBUTE5 = NULL, STATUS_PROCESSAMENTO = P_STATUS_DESEJ WHERE CLIENTE_ID = P_REQUEST_ID AND STATUS_PROCESSAMENTO = VCLI.STATUS_PROCESSAMENTO;  
                         COMMIT;
                       END IF;
                         
                 END LOOP;
              CLOSE CLI;
              
              BEGIN
                    EXECUTE IMMEDIATE 'ALTER TRIGGER APPS.TKT_BACEN_CLI_B_AU_TRG ENABLE';
              END;
              
        ELSE
              BEGIN
                    EXECUTE IMMEDIATE 'ALTER TRIGGER APPS.TKT_BACEN_ESTAB_B_AU_TRG DISABLE';      
              END;
                                        
              OPEN EST;     
                       
                 LOOP
                   FETCH EST INTO VEST;
                   EXIT WHEN EST%NOTFOUND;
                        
                       IF P_STATUS_DESEJ NOT IN ('ERRO','SOLICITADA HIGIENIZACAO','HIGIENIZADO_PARCIAL','HIGIENIZADO')THEN                
                         RAISE EXC_OPERACAO;
                       ELSE  
                                                       
                          UPDATE APPS.TKT_BACEN_ESTAB_ALL SET ATTRIBUTE5 = NULL, STATUS_PROCESSAMENTO = P_STATUS_DESEJ WHERE ESTABELECIMENTO_ID = P_REQUEST_ID AND STATUS_PROCESSAMENTO = VEST.STATUS_PROCESSAMENTO;
                         COMMIT;
                       END IF;   
                                            
                 END LOOP;
              CLOSE EST;                   
              
              BEGIN
                    EXECUTE IMMEDIATE 'ALTER TRIGGER APPS.TKT_BACEN_ESTAB_B_AU_TRG ENABLE';
              END;  
                          
        END IF;
                                 
         EXCEPTION                      
                           
            WHEN EXC_OPERACAO THEN
               DBMS_OUTPUT.PUT_LINE('A OPERACAO NÃO PODE SER CONCLUÍDA PORQUE OS VALORES INFORMADOS NÃO SÃO VÁLIDOS, VOCÊ DEVE INFORMAR UM DOS VALORES ABAIXO:');
               DBMS_OUTPUT.NEW_LINE;
               DBMS_OUTPUT.PUT_LINE('ERRO');
               DBMS_OUTPUT.PUT_LINE('SOLICITADA HIGIENIZACAO');
               DBMS_OUTPUT.PUT_LINE('HIGIENIZADO_PARCIAL');
               DBMS_OUTPUT.PUT_LINE('HIGIENIZADO');
              ROLLBACK;
              
            WHEN OPERACAO_ENT THEN
              
               DBMS_OUTPUT.PUT_LINE('PARA CLIENTE, VOCÊ DE INFORMAR: CLI');
               DBMS_OUTPUT.NEW_LINE;
               DBMS_OUTPUT.PUT_LINE('PARA ESTABELECIEMTNO, VOCÊ DE INFORMAR: EST');
              ROLLBACK;               
                           
            WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE('CODIGO DO ERRO'||SQLCODE||' MSG '||SQLERRM);
               DBMS_OUTPUT.PUT_LINE('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    
    END;
    
END TKT_ATENDIMENTO_SINCRONISMO;

