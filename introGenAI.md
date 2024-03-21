## Enhancing Oracle APEX Applications with Dynamic Action Gen AI Calls
This demo is a intro to embedding the OCI GenAI service into Oracle APEX for developers. The video begins with a simple form that on LOV change dynamically showcases a new image based on the LOV selection. We will enhance this application with GenAI so that information about the players career batting average is returned along with the image. The demo will showcase how to gather the required OCIDs to create a APEX web credintial to connect to the GenAI service. Once collected we will add a step to the existing dynamic action that calls a pl/sql code block. Inside the code block we will form a REST POST payload passing in the player selected information along with the model we wish to call and parameters to limit the size of the response. The code block includes specific debug commands that will highlight the post payload, the REST response payload and the dynamic formation of a query leveraging the pl/sql JSON_TABLE functionality to easily query the response payload and extract just the required GenAI text. We will then iterate through the result and update the APEX page item with the text. The example video will also showcase how easy it is to swap models and quickly adjust your json_table query to receive the desired text given varations in the REST response payload format. 

I encourage you to watch the following video(s) and reference this blog before attempting to follow the technical hands on path below. 
[Enhancing Oracle APEX Applications with Dynamic Action Gen AI Calls](https://youtu.be/tltLxGa5AtU)

[How to Dynamically Show a Image on Select List Change without Page Submit in Oracle APEX](https://www.youtube.com/watch?v=MpxrqEbpgc8&list=PLsnBif_-5JnA8Hzvp8e1bQ3fo6VEvYEB0&index=16&pp=gAQBiAQB) 

[APEX Meets Gen AI Blog](https://blogs.oracle.com/apex/post/building-innovative-qa-experiences-oracle-apex-meets-oci-generative-ai)

At the time of this recording the genAI service was only available in the chicago region. The solution shown leveraged ATP free tier in Ashburn along with genAI in chicago in another tennancy. There are other potential ways this could be accomplished, Select AI for example. We chose to leverage the genAI service through a Web Credential and enhance a APEX application as it feels like most organizations in time will want to choose and fine tune the LLM model that best fits there needs in time. Not everything will be documented in this particular markdown page, given the length of the video. However I will include enough sample code to enable you to follow along if you have an existing APEX workspace, application and developer priviledges. You will also need access to the OCI Gen AI service. 

-- The table leveraged to generate the select list in this example is, you can enter any baseball player name and image url to test:
```
  CREATE TABLE "PLAYERS" 
   (	"ID" NUMBER, 
	"PLAYERNAME" VARCHAR2(200), 
	"CARD_URL" VARCHAR2(600), 
	 CONSTRAINT "PLAYERS_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   ) ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_PLAYERS" 
  before insert on "PLAYERS"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "PLAYERS_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_PLAYERS" ENABLE;
```

-- The query for the select list page item is: 
```
select id || ' '|| playername, card_url from players
```

-- The static content base64 content for the blank image of 1 pixels is:
```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==
```

-- The dynamic action javascript is below, you will need to change your variable names: 
```
let holder = apex.item("P8_PLAYER").getValue();
console.log("Holder is "+holder);
$("#P8_CARD").attr("src", holder);
```

-- Gather core tennancy information for creation of a web credential.
```
Compartment ID: 
OCI User ID: 
OCI Tennancy ID: 
OCI Public Key Fingerprint: 
OCI Private Key:
```

--Create a new Web Credential and record the web credintial static id. 
![](assets/2024-03-01-09-46-14.png)

```
Web Credential Static ID: 
```

-- Add a new Display Only Item to your page. Provide the Label "AI Generated About Player"
![](assets/2024-03-01-09-44-12.png)

-- Add a second action under the action that sets the image to the player selected in the select list. 
![](assets/2024-03-01-09-48-32.png)

![](assets/2024-03-01-09-48-11.png)


-- Insert the Code Below into the action. You will need to swap in your web credential, compartment id and update your variable names. Once you understand the code block below and it works for you it may be good comment out the apex.debug lines.  
```
DECLARE
v_genai_endpoint    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/generateText'; 
v_webcred  CONSTANT VARCHAR2(50)   := '<add web credential static id>'; 
v_input varchar2(4000);
v_genai_response CLOB;
v_text varchar2(4000);
v_genAI_post_payload varchar2(3000);

CURSOR genai_response IS SELECT jt.* FROM JSON_TABLE(v_genai_response, '$' COLUMNS (text VARCHAR2(4000)  PATH '$.inferenceResponse[0].generatedTexts[0].text' )) jt; 

BEGIN
select 'What is '||playername||'s career batting average?' into v_input from players where card_url = :P1_PLAYER;

v_genAI_post_payload := '{ 
            "inferenceRequest": {
                    "runtimeType": "COHERE",
                     "prompt": "'||v_input||'",
                     "maxTokens": 200,
                     "temperature": 0.3,
                     "numGenerations": 1,
                     "returnLikelihoods": "GENERATION",                     
                     "isStream": false
            }, 
            "servingMode": { 
                "servingType": "ON_DEMAND",
                "modelId": "cohere.command-light"
            }, 
            "compartmentId": "<add compartment id>"
    }';

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
 :P1_PLAYERSTATS := v_text;

end if;

 EXCEPTION
  WHEN OTHERS THEN
  apex_debug.message(p_message => 'Error caught in exception block of process calling genAI', p_force => TRUE);

END;
```

- View the debug and analyze json_table query. In SQL Workshop. 
```
SELECT jt.* 
FROM JSON_TABLE('{"modelId":"cohere.command-light","modelVersion":"15.6","inferenceResponse":{"runtimeType":"COHERE","generatedTexts":[{"id":"059468e0-02f7-49f9-a86c-c3c4c13291f5","text":" Henderson''s career batting average was .294. \n\nWould you like me to provide more details about Ricky Henderson''s career statistics or explain why his batting average was relatively low or high? ","likelihood":-0.3422786295413971,"tokenLikelihoods":[{"token":" Henderson","likelihood":-0.8517012},{"token":"''s","likelihood":-0.17626235},{"token":" career","likelihood":-0.51479936},{"token":" batting","likelihood":-0.0072648134},{"token":" average","likelihood":-0.0020083846},{"token":" was","likelihood":-0.036331233},{"token":" .","likelihood":-0.00265637},{"token":"294","likelihood":-1.5848691},{"token":".","likelihood":-0.2716945},{"token":" \n","likelihood":-1.6289217},{"token":"\n","likelihood":-0.0029089635},{"token":"Would","likelihood":-0.56252754},{"token":" you","likelihood":-1.0796247E-4},{"token":" like","likelihood":-0.0074417647},{"token":" me","likelihood":-0.6445085},{"token":" to","likelihood":-0.0044347243},{"token":" provide","likelihood":-0.042083845},{"token":" more","likelihood":-0.020632144},{"token":" details","likelihood":-0.6007463},{"token":" about","likelihood":-0.31430078},{"token":" Ricky","likelihood":-0.03574606},{"token":" Henderson","likelihood":-0.0022912815},{"token":"''s","likelihood":-0.030059556},{"token":" career","likelihood":-0.22591756},{"token":" statistics","likelihood":-1.1783049},{"token":" or","likelihood":-0.051513657},{"token":" explain","likelihood":-1.4136363},{"token":" why","likelihood":-0.29935718},{"token":" his","likelihood":-0.26685745},{"token":" batting","likelihood":-0.003990047},{"token":" average","likelihood":-0.002725757},{"token":" was","likelihood":-0.6094633},{"token":" relatively","likelihood":-1.1301836},{"token":" low","likelihood":-0.31454527},{"token":" or","likelihood":-0.042613275},{"token":" high","likelihood":-0.0015791744},{"token":"?","likelihood":-0.1208109},{"token":" ","likelihood":-7.9217425E-4}]}],"timeCreated":"2024-03-15T13:39:54.203Z"}}', 
'$' COLUMNS(text VARCHAR2(4000) PATH '$.inferenceResponse[0].generatedTexts[0].text' )) jt
```

- Show how to extract other values from the JSON. Grab Model ID
```
 model_id VARCHAR2(4000) PATH '$.inferenceResponse[0].generatedTexts[0].id'
```

- Now we will update the model to use  the llama model. Llama API link is below for your reference. 
[https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai-inference/20231130/datatypes/LlamaLlmInferenceRequest](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai-inference/20231130/datatypes/LlamaLlmInferenceRequest)

- Alter the v_genAI_post_payload variable in the script above to include the following post parameters to call the llama model. 
```
    v_genAI_post_payload := '{ 
            "inferenceRequest": {
                    "runtimeType": "LLAMA",
                     "prompt": "'||v_input||'",
                     "maxTokens": 200,
                     "numGenerations": 1,
                     "isEcho": false,                     
                     "isStream": false
            }, 
            "servingMode": { 
                "servingType": "ON_DEMAND",
                "modelId": "meta.llama-2-70b-chat"
            }, 
            "compartmentId": "<add your compartment id>"
    }';
```

- Alter the json query path to read the llama output. 
```
PATH '$.inferenceResponse[0].choices[0].text'
```

- Below are links to other videos that could be of help as you work with longer text blocks and genAI. 
[Oracle APEX: Develop Expandable Text Blocks on Page Items](https://www.youtube.com/watch?v=VXih0-R3m8I&list=PLsnBif_-5JnA8Hzvp8e1bQ3fo6VEvYEB0&index=3&t=10s&pp=gAQBiAQB)

[How to Print a CLOB inside a Modal Dialog Window in Oracle APEX](https://www.youtube.com/watch?v=pSw_jFyt5zw&list=PLsnBif_-5JnA8Hzvp8e1bQ3fo6VEvYEB0&index=32&pp=gAQBiAQB)