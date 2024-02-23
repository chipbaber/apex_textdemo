## Example Flow to call Gen AI from APEX 

- WIP for new video

- Link to jsonl validator
https://jsonlines.org/validator/

```
DECLARE
  v_genai_endpoint    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/generateText'; 
  v_webcred  CONSTANT VARCHAR2(50)   := 'genai_webcredential';   
  v_input varchar2(4000) := :P7_AI_INPUT; 
  v_genai_response CLOB;
  v_text varchar2(4000);
   
   
    v_genAI_post_payload varchar2(3000) := '{ 
            "inferenceRequest": {
                    "runtimeType": "COHERE",
                     "prompt": "'||v_input||'",
                     "maxTokens": 2000,
                     "numGenerations": 1,
                     "returnLikelihoods": "GENERATION",
                     "isStream": false
            }, 
            "servingMode": { 
                "servingType": "ON_DEMAND",
                "modelId": "cohere.command-light"
            }, 
            "compartmentId": "ocid1.compartment.oc1..aaaaaaaaagdhriektod7f2k57eudaiu6en5tqdzc4frrt5dh4drlhagbpaja"
    }';
 
  CURSOR genai_response IS SELECT jt.* FROM JSON_TABLE(v_genai_response, '$' COLUMNS (text VARCHAR2(4000)  PATH '$.inferenceResponse[0].generatedTexts[0].text' )) jt; 

BEGIN
-- Comment out debug later. For learning lets take a look at what is happening. 
apex_debug.message(p_message => 'Example GenAI call. Lets Check our input variables:',p_force => TRUE);
apex_debug.message(p_message => 'REST Post Payload set in variable v_genAI_post_payload: '||CHR(13) || v_genAI_post_payload, p_force => TRUE);


  if v_input is not null then
        --set headers to return payload as json
        apex_web_service.g_request_headers.DELETE; 
        apex_web_service.g_request_headers(1).name  := 'Content-Type'; 
        apex_web_service.g_request_headers(1).value := 'application/json';  

         v_genai_response := apex_web_service.make_rest_request 
           (p_url                  => v_genai_endpoint, 
            p_http_method          => 'POST', 
            p_body                 => v_genAI_post_payload, 
            p_credential_static_id => v_webcred); 

--View full response payload
apex_debug.message(p_message => 'REST Response Payload set in variable v_genai_response: ' ||CHR(13)|| v_genai_response, p_force => TRUE);

--Output and Test your cursor query. Please note to run the query addition ''  are required around the response payload.
apex_debug.message(p_message => 'SQL Query generated for :'||CHR(13)||'SELECT jt.* FROM JSON_TABLE('''||v_genai_response||''', ''$'' COLUMNS(text VARCHAR2(4000) PATH ''$.inferenceResponse[0].generatedTexts[0].text'' )) jt', p_force => TRUE);

 for line in genai_response Loop
           v_text := v_text || line.text;           
 end loop;
 :P7_AI_OUTPUT := v_text;

 end if;
 EXCEPTION
  WHEN OTHERS THEN
  apex_debug.message(p_message => 'Error caught in exception block of process calling genAI', p_force => TRUE);

END;
```
- When we ask the question "What was Babe Ruths leftime batting average?" the following query is returned. 
```
SELECT jt.* FROM JSON_TABLE('{"modelId":"cohere.command-light","modelVersion":"15.6","inferenceResponse":{"runtimeType":"COHERE","generatedTexts":[{"id":"95d0e1b8-3480-4313-98c4-99653fc85b72","text":" Babe Ruth had a career batting average of .269 with 2,113 hits and 714 home runs. \n\nDid you mean his lifetime batting average, or his average during a specific season? ","likelihood":-0.5517994165420532,"tokenLikelihoods":[{"token":" Babe","likelihood":-0.19363071},{"token":" Ruth","likelihood":-3.3123003E-4},{"token":" had","likelihood":-0.2679999},{"token":" a","likelihood":-0.39327347},{"token":" career","likelihood":-1.1319788},{"token":" batting","likelihood":-0.1372917},{"token":" average","likelihood":-3.6706397E-4},{"token":" of","likelihood":-6.265847E-5},{"token":" .","likelihood":-0.073035836},{"token":"269","likelihood":-3.0858097},{"token":" with","likelihood":-0.055492565},{"token":" 2","likelihood":-0.0039565945},{"token":",","likelihood":-0.020179788},{"token":"113","likelihood":-4.780512},{"token":" hits","likelihood":-0.14724964},{"token":" and","likelihood":-0.49410135},{"token":" 7","likelihood":-0.7612309},{"token":"14","likelihood":-0.09212719},{"token":" home","likelihood":-0.29098254},{"token":" runs","likelihood":-2.2087281E-4},{"token":".","likelihood":-0.112734854},{"token":" \n","likelihood":-0.9955226},{"token":"\n","likelihood":-0.0054945033},{"token":"Did","likelihood":-2.4564254},{"token":" you","likelihood":-1.3586106E-4},{"token":" mean","likelihood":-0.021475717},{"token":" his","likelihood":-1.0877302},{"token":" lifetime","likelihood":-2.0622993},{"token":" batting","likelihood":-0.12400646},{"token":" average","likelihood":-7.51311E-4},{"token":",","likelihood":-1.1863374},{"token":" or","likelihood":-0.013323185},{"token":" his","likelihood":-0.0395805},{"token":" average","likelihood":-0.3930866},{"token":" during","likelihood":-0.028461808},{"token":" a","likelihood":-0.62464523},{"token":" specific","likelihood":-0.072968766},{"token":" season","likelihood":-0.8572424},{"token":"?","likelihood":-0.054366603},{"token":" ","likelihood":-0.0055533014}]}],"timeCreated":"2024-02-22T19:18:12.673Z"}}', '$' COLUMNS(text VARCHAR2(4000) PATH '$.inferenceResponse[0].generatedTexts[0].text' )) jt
```

- Show how to extract other values from the JSON. Grab Model ID
```
 model_id VARCHAR2(4000) PATH '$.inferenceResponse[0].generatedTexts[0].id'
```
