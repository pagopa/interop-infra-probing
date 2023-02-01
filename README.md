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
## Referencees

* [Confluence page](https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/467894592/AWS+Setup+new+project)
* [Terraform](https://terraform.io/)
* [Github action](https://docs.github.com/en/actions)
* [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)