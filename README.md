Configures a (mostly) free-tier AWS system using [terraform](https://www.terraform.io/) to host the [spring-experiments](https://github.com/jg210/spring-experiments) application [here](http://aws.jeremygreen.me.uk).

* The spring-experiments app is built using a [travis-ci job](https://travis-ci.com/jg210/spring-experiments) and the jar is pushed into an AWS S3 bucket.
* The terraform scripts in this repo create an EC2 instance,  configure it to run the jar (behind an nginx proxy) and update the site's DNS record.
* Staying within the free tier means there's no load balancer, just one EC2 instance behind an elastic IP address.

[![Build Status](https://travis-ci.com/jg210/aws-experiments.svg?branch=master)](https://travis-ci.com/jg210/aws-experiments)

## Non Free-Tier Resources

The Elastic IP address is not free if the EC2 instance is not running. Either keep the EC2 instance running, or destroy at least the Elastic IP address.

## Development Environment

These instructions are for Ubuntu and bash.

* Create AWS account.
* Configure an AWS IAM user with appropriate permissions.
* [Download](https://www.terraform.io/downloads.html) required version of terraform (see [main.tf](terraform/main.tf)), unpack and put executable on PATH.
* Create ~/.dns-api-password and ~/.dns-api-url with appropriate content and permissions etc.
* Run (from a bash shell):

```
sudo apt-get install python3.5-venv
python3.5 -m venv .venv
. environment
pip install --upgrade pip==19.0.3
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

To deploy:

```
cd terraform
terraform init
terraform plan
terraform deploy
```

An S3 bucket is used to store the terraform state. If this bucket doesn't exist yet, temporarily comment out the "backend" configuration in [main.tf](main.tf) while deploying, and it will be created for you.