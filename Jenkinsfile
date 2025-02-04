pipeline{
    agent any
    environment {
        SUBNET_ID = sh(returnStdout: true, script: 'terraform output -raw subnet_id').trim()
    }
    stages{
        stage("TF Init"){
            steps{
                echo "Executing Terraform Init"
                 sh 'rm -rf .terraform .terraform.lock.hcl'
                sh 'terraform init -reconfigure'
            }
        }
        stage("TF Validate"){
            steps{
                echo "Validating Terraform Code"
                sh 'terraform validate'
            }
        }
        stage("TF Plan"){
            steps{
                echo "Executing Terraform Plan"
                sh 'terraform plan -target=aws_route_table_association.PrivateToPrivate'

            }
        }
        stage("TF Apply"){
            steps{
                echo "Executing Terraform Apply"
                sh 'terraform apply -auto-approve'
            }
        }

        

        stage("Invoke Lambda"){
            steps{
                echo "Invoking your AWS Lambda"

                 script {
          sh """
            aws lambda invoke --function-name lambda_func4 --region ap-south-1 --cli-binary-format raw-in-base64-out  --payload  '{ "subnet_id":"${SUBNET_ID}" }' response.json  --log-type Tail
          """
          output = readFile('response.json')
          
        }
            }
        }
    }
}
