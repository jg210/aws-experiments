This repo uses [terraform](https://www.terraform.io/) and AWS to...

Configure a lambda function and API gateway to host a hello-world API: https://aws.jeremygreen.me.uk.

Host the [spring-experiments](https://github.com/jg210/spring-experiments) application at http://spring-experiments.jeremygreen.me.uk.

* The spring-experiments app is built using a [travis-ci job](https://travis-ci.com/jg210/spring-experiments) and the jar is pushed into an AWS S3 bucket.
* [Packer](https://packer.io/) creates an AMI that runs the jar behind an nginx proxy.
* [Terraform](terraform) creates an EC2 instance from the AMI and updates the [site](http://spring-experiments.jeremygreen.me.uk)'s DNS record.
* Staying within the free tier means there's no load balancer, just one EC2 instance behind an elastic IP address.

[![Build Status](https://travis-ci.com/jg210/aws-experiments.svg?branch=master)](https://travis-ci.com/jg210/aws-experiments)

## Non Free-Tier Resources

The Elastic IP address is not free if the EC2 instance is not running. Either keep the EC2 instance running, or destroy at least the Elastic IP address.

## Development Environment

These instructions are for Ubuntu and bash.

* Create an AWS account.
* Configure an AWS IAM user with appropriate permissions.
* [Download](https://www.terraform.io/downloads.html) required version of terraform (see [main.tf](terraform/main.tf)).
* [Download](https://www.packer.io/downloads.html) required [version](bin/packer) of packer.
* Unzip terraform and packer.
* Rename terraform and packer executables to e.g. terraform-1.2.3.
* Put terraform and packer executable in directory that is on PATH.
* Create ~/.dns-api-password and ~/.dns-api-url with appropriate content and permissions etc.
* Run (from a bash shell):

```
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
eval "$(~/.pyenv/bin/pyenv init -)"
~/.pyenv/bin/pyenv install
pyenv exec python -m venv --clear .venv
. environment
pip install --upgrade pip==20.0.2
pip install -r requirements.txt
aws configure # eu-west-1, json.
```

Close and reopen terminal, then just need to run:

```
. environment
```

To configure emacs:

* Add [melpa](https://www.emacswiki.org/emacs/MELPA) package-source configuration to ~/.emacs
* From emacs, `M-x list-packages` and install terraform-mode.

To build AMI:

```
packer build --force packer.json
```

To deploy:

```
cd terraform
terraform init
terraform plan
terraform apply
```

An S3 bucket is used to store the terraform state. If this bucket doesn't exist yet, temporarily comment out the "backend" configuration in [main.tf](main.tf) while deploying, and it will be created for you (and then your temporary local state will get migrated to S3). This trick will only work if are deploying for the first time.