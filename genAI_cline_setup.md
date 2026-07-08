# How to Set Up Cline to Access Oracle Generative AI LLMs

This guide shows how to connect Cline to Oracle Generative AI by using an Oracle Generative AI API key and an OpenAI-compatible endpoint.

> **Note:** Please watch the accompanying video [https://youtu.be/ZhFmOjUU3AE](https://youtu.be/ZhFmOjUU3AE) before proceeding. The instructions below are intended as a high-level supplement to the video.

## Prerequisites

Before you begin, make sure you have:

- Access to an Oracle Cloud Infrastructure tenancy with Oracle Generative AI enabled.
- Permission to create Generative AI API keys.
- Permission to create or update IAM policies.
- Visual Studio Code installed.
- The Cline extension installed in Visual Studio Code.

> **Security reminder:** API keys are sensitive credentials. Store them securely, and do not commit them to source control.

## 1. Create an Oracle Generative AI API Key

Navigate to Oracle Generative AI services and select **API Key** from the menu.

![Oracle Generative AI API Key menu](assets/2026-07-07-10-27-32.png)

Set the compartment that you want to use for this work, then copy the compartment name for later use.

![Oracle compartment selection](assets/2026-07-07-10-30-36.png)

Click **Create API Key** and complete the form.

![Create API Key form](assets/2026-07-07-10-33-13.png)

Copy your API key. It is shown only once.

![Generated API key](assets/2026-07-07-10-34-06.png)

Copy the OCID for your newly created API key and save it for future reference.

![API key OCID](assets/2026-07-07-10-46-58.png)

## 2. Create an IAM Policy

Create a policy statement that allows your selected group or principal to access Oracle Generative AI in the target compartment by using the newly created API key.

To get started, confirm that you have selected the correct compartment on the policy screen. In this example, the policy is created in the root compartment and scoped to the Generative AI API key created earlier.

![Oracle IAM policy compartment selection](assets/2026-07-07-10-53-18.png)

Click **Create Policy**, then enter the following name:

```text
AI-Cline-Access
```

Use the following description:

```text
Policy to enable access to GenAI keys
```

Enter manual mode, then paste and edit the policy below.

```text
allow any-user to use generative-ai-chat in compartment <compartment-name> where ALL {request.principal.type='generativeaiapikey', request.principal.id='<generative-ai-api-key-ocid>'}
```

Replace the placeholders with your actual values:

- `<compartment-name>`: The compartment name you copied earlier.
- `<generative-ai-api-key-ocid>`: The OCID for the API key you created.

![Manual IAM policy statement](assets/2026-07-07-11-37-20.png)

## 3. Configure Cline in Visual Studio Code

This step assumes that Visual Studio Code and the Cline extension are already installed.

Look at the OCID you copied earlier. It includes a region, such as `us-chicago-1` or `us-ashburn-1`. Copy that region value.

![Region value in OCID](assets/2026-07-07-11-41-47.png)

Paste the region into the endpoint URL format below:

```text
https://inference.generativeai.<region>.oci.oraclecloud.com/20231130/actions/v1
```

For example, if your region is `us-chicago-1`, your endpoint would be:

```text
https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/v1
```

Open Cline and click the gear icon.

![Cline settings gear icon](assets/2026-07-07-11-47-57.png)

Select **OpenAI Compatible API**.

![OpenAI Compatible API option in Cline](assets/2026-07-07-11-48-37.png)

Paste in the endpoint URL you created earlier. Then enter the model you want to use and the API key you generated earlier.

![Cline API configuration](assets/2026-07-07-11-57-26.png)

Click **Done**, then test Cline.

![Cline test prompt](assets/2026-07-07-11-57-53.png)

## 4. Find Available Models

The models available to you are listed in the Oracle Generative AI playground for your selected region.

![Oracle Generative AI playground model list](assets/2026-07-07-11-52-30.png)

## Troubleshooting Tips

- Make sure the endpoint region matches the region where your Oracle Generative AI resources and API key are available.
- Confirm that the IAM policy uses the correct compartment name and API key OCID.
- Verify that the selected model is available in your region.
- If Cline cannot connect, regenerate or re-enter the API key and confirm there are no extra spaces.
