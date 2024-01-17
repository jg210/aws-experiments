[![build status](https://github.com/jg210/aws-experiments/actions/workflows/checks.yml/badge.svg)](https://github.com/jg210/aws-experiments/actions/workflows/checks.yml)

This repo uses [terraform](https://www.terraform.io/) and AWS to host the [spring-experiments](https://github.com/jg210/spring-experiments) application using both:

* A [lambda function](https://aws.amazon.com/pm/lambda/) and [API gateway](https://aws.amazon.com/api-gateway/): https://aws.jeremygreen.me.uk.
* [EC2](https://aws.amazon.com/ec2/): http://spring-experiments.jeremygreen.me.uk.

## Notes

* The spring-experiments app is built using a [CI job](https://github.com/jg210/spring-experiments/actions/workflows/checks.yml) and the jar is pushed into an AWS S3 bucket.
* [Packer](https://packer.io/) creates an AMI that runs the jar behind an nginx proxy.
* [Terraform](terraform) creates an EC2 instance from the AMI and updates the [site](http://spring-experiments.jeremygreen.me.uk)'s DNS record.
* Keeping costs down means there's no load balancer, just one EC2 instance behind an Elastic IP address.
* Until Feb 2024, the Elastic IP address is not free if the EC2 instance is not running. Either keep the EC2 instance running, or destroy at least the Elastic IP address.
* After Feb 2024, there will be a cost all the time.
* API gateway requests are configured with heavy rate limiting (to cap lambda costs and to simulate an overloaded API), so it gives 429 HTTP responses if make too many requests. E.g. if scroll through list of local authorities too fast. Adding retries in the frontend app would mask this...
* Monitoring is done with [UptimeRobot](https://stats.uptimerobot.com/kD80YhnAzD) (the free plan, so there's no scheduled downtime facility).
* Lambda functions are not a good way to host a production JVM-based server since the startup time of a JVM is long. They are cheaper than a suitably sized EC2 instance (whether used directly or via e.g. ECS), and the aim here is to learn about things, not host a real server.
* Direct EC2 use is not a good way to host an app either :-)
* The EC2 instance is border-line too small - close to the OOM killer stopping the java process. The next largest instance is twice the price though.

## Development Environment

These instructions are for Ubuntu and bash.

* Create an AWS account.
* Configure an AWS IAM user with appropriate permissions.
* [Download](https://www.terraform.io/downloads.html) required [version](terraform/main.tf) of terraform.
* [Download](https://www.packer.io/downloads.html) required [version](bin/packer) of packer.
* Unzip terraform and packer.
* Rename terraform and packer executables to add version suffix - e.g. terraform-1.2.3.
* Put renamed terraform and packer executables in directory that is on PATH.
* Create ~/.dns-api-password and ~/.dns-api-url with appropriate content and permissions etc.
* Run (from a bash shell):

```
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
eval "$(~/.pyenv/bin/pyenv init -)"
~/.pyenv/bin/pyenv install
pyenv exec python -m venv --clear .venv
. environment
pip install --upgrade pip==23.3.1
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
packer init .
packer build --force packer.pkr.hcl
```

To deploy:

```
cd terraform
terraform init
terraform plan
terraform apply
```

An S3 bucket is used to store the terraform state. If this bucket doesn't exist yet, temporarily comment out the "backend" configuration in [main.tf](main.tf) while deploying, and it will be created for you (and then your temporary local state will get migrated to S3). This trick will only work if are deploying for the first time.
