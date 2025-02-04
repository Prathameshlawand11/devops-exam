# devops-candidate-exam

Dear Candidate, 

In this hands-on exam we are going to test your knowledge and capabilities in the following topics,

- Jenkins
  - Declarative Pipeline
  - General Configuration
- Git
- Terraform
- AWS
- Coding (Preferred Python)

**Note to mention** that you may use the internet to complete your exercise.

## Exercise Details

You will create a small infrastructure on AWS using Terraform. \
The ultimate objective of this exercise is to invoke your Lambda function against a remote API, which will receive a specific payload. \
Once the remote API is triggered, an email containing the relevant information from your exercise will be sent to both you and us. \
Please inform the local instructor about this so that we can verify if the email is received correctly.

---

## Exercise Steps

### **Step 1 - GitHub**

Please follow the steps below, but make sure **not to fork** this repository. If you fork the repository, other candidates will be able to view your results.

* **Clone** this repository to your local machine
* Setup your own GitHub account if you don't already have one
* Create a public repo on your GitHub account (empty repo)
* Update the git origin to point your own GitHub account repository. \
  Example,
    ```
    git remote set-url origin https://github.com/<GitHub Account>/devops-exam.git
    ```
* Once you have updated the git origin try pushing the content from your local workspace to your remote git origin
  * In case you are having trouble to modify the code locally and push it to GitHub via SSH, try using the HTTPS origin or upload your modified files via the GitHub Web UI.

### **Step 2 - Jenkins**

In this step you will:

- Verify the access to your own personal Jenkins server.
- Configure a declarative pipeline.
- Validate that you are able to run the pipeline.

Steps:

* Contact your local instructor to get your personal Jenkins URL.
  * The Jenkins URL is accessible via **HTTP** only
* Create a new declarative pipeline and configure it to point your *Jenkinsfile* located on your publicly available GitHub repo.
* Run your pipeline to verify you are able to access your repo and to reach to your remote *Jenkinsfile*

Notes:

In the provided Jenkins server we have already taken care of the following prerequisites,

- **Terraform**
- **AWS CLI**
- **JQ**
- **AWS IAM Role** that allows you to generate the resources and to invoke your Lambda. No need to specify a profile or creds in the pipeline.

### **Step 3 - Terraform**

In this step you will create the following resources in AWS using Terraform,

* Private Subnet
* Routing Table
* Lambda Function (Inside a VPC)
  * Security Group

We will provide the *VPC ID*, *NAT Gateway ID*, *Lambda IAM Role & Policy*. \
Check the [data.tf](https://github.com/jerasioren/devops-exam/blob/main/data.tf) for reference to those resources.

> **Important Note**: When using the provided IAM role for your Terraform, **you won’t be able to recreate (delete and create) your Lambda.** To do that, you’ll need to create a new Lambda, leaving the previous one untouched.

#### Configuring your Terraform backend:
Use the following details to configure the AWS provider configuration. Pay attention that we are using S3 backend. 

```
S3 Bucket: "467.devops.candidate.exam"
Region: "ap-south-1"
Key: "<Your First Name>.<You Last Name>"
```

Once you have created your S3 backend config you may try to perform Terraform init. \
> ***NOTE**: Terraform init or any AWS CLI command can be executed only from the Jenkins pipeline.*

For the **Private Subnet** CIDR block please use 10.0.X.0/24 block, for example:
```
10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
10.0.4.0/24
...
...
10.0.254.0/24
```
The VPC CIDR block is `10.0.0.0/16`. \
We do not have any preference regarding the availability zone for the subnet. \
If the CIDR block is in use, select another one.

Continue with writing the other resources and refer to **Step 4** for further instructions about the Lambda code.

### **Step 4 - Lambda Code**

Your Lambda code should invoke a remote API endpoint. \
You may use any language you wish, although we preferred it to be python.

Your Lambda function should:
- Configure to run under a **VPC** using your private subnet you have created.
- POST a request to the following HTTPS endpoint:
`https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data`
  - You should use the following security header for the request to pass: \
  `{'X-Siemens-Auth': 'test'}` 
  - The data payload must be as followed:
    ```json
    payload = {
      "subnet_id": "<Your Private Subnet ID>",
      "name": "<Your Full Name>",
      "email": "<Your Email Address>"
    }
    ```
    You should use real values in the payload.
> `Note:` your Private Subnet ID value should come from the Terraform code instead of hard coded it.

> `Tip:` When you'r invoking your Lambda from the CLI, remember to add the following argument to the command **"--log-type Tail"**. This will return your **"LogResult"** which contain your actual post response in a base 64 format. You will need to convert it in order to view the actual endpoint response. When there is no execution error in the result, that means you have successfully invoked our API endpoint. \
Return code example:
```json
{
    "StatusCode": 200,
    "LogResult": "U1RBUlQgUmVxdWVzdElkOiAyMjVjNTNmZC1hYTg0LTQwMzgtODA0OS1iYTYwN2M5ZmZjMWQgVmVyc2lvbjogJExBVEVTVAp7Im1lc3NhZ2UiOiAiTWVzc2FnZSBwcm9jZXNzZWQgc3VjY2Vzc2Z1bGx5LiJ9CjIwMApFTkQgUmVxdWVzdElkOiAyMjVjNTNmZC1hYTg0LTQwMzgtODA0OS1iYTYwN2M5ZmZjMWQKUkVQT1JUIFJlcXVlc3RJZDogMjI1YzUzZmQtYWE4NC00MDM4LTgwNDktYmE2MDdjOWZmYzFkCUR1cmF0aW9uOiAyODY1LjA2IG1zCUJpbGxlZCBEdXJhdGlvbjogMjg2NiBtcwlNZW1vcnkgU2l6ZTogMTI4IE1CCU1heCBNZW1vcnkgVXNlZDogNDkgTUIJSW5pdCBEdXJhdGlvbjogMzQzLjUxIG1zCQo=",
    "ExecutedVersion": "$LATEST"
}
```

> `Bonus Point`: Automatically convert the Lambda base64 response and write them to the console output in Jenkins.

### **Step 5 - Jenkins - Running your pipeline**

Use the `Jenkinsfile` provided in this repository to init, plan, apply and invoke your Lambda function. \
The end goal is that you will have a fully working pipeline that creates/synchronizes the infrastructure and that invoke your Lambda.

### **Step 6 - Verify you are done**

Check out your email inbox. when successfully invoking our API endpoint you should be receiving an email with the following structure:

**Candidate's response:**
| Field      | Value |
| --- | --- |
| subnet_id | xxx |
| name | xxx |
| email | xxx | 

### **Step 7 - Link to your GitHub repo**

Share with us the link to your public GitHub repo, \
so we can review your coding work.

## Good Luck!
