# Interop-Probing Infrastructure


## Requirements

The following tools are required to setup the project locally. 

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
2. [tfenv](https://github.com/tfutils/tfenv) to manage terraform versions.

## Start building

Create:

* The s3 bucket to store terraform state
* The Dynamodb table to manage terraform locks
* The Github OpenId connection

```bash
# init uat environment
cd src/init

./terraform.sh init uat

./terraform.sh apply uat

# create uat environment

cd ../../
cd src/main

./terraform.sh init uat

./terraform.sh apply uat
```

## Manage cognito users

### Create user
In order to create a cognito user with already verified password must be used the following 

IMPORTANT Username MUST NOT be in email format.

```bash
aws cognito-idp admin-create-user --user-pool-id <value> --username <value> --user-attributes Name=email,Value=<email> Name=email_verified,Value=True --force-alias-creation

aws cognito-idp admin-set-user-password --user-pool-id <value> --username <value> --password <value> --permanent
```
Password can be arbitrary beacause the user is forced to change password at the first access.
### Add users to a group
In order to add a user in a specific user group use the following

```bash
aws cognito-idp admin-add-user-to-group --user-pool-id <value> --username <value> --group-name <value>
```
PN The possible groups are: `users` , `admins`

## Referencees

* [Confluence page](https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/467894592/AWS+Setup+new+project)
* [Terraform](https://terraform.io/)
* [Github action](https://docs.github.com/en/actions)
* [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)