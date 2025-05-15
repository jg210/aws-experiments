[![build status](https://github.com/jg210/aws-experiments/actions/workflows/checks.yml/badge.svg)](https://github.com/jg210/aws-experiments/actions/workflows/checks.yml)

This repo uses [terraform](https://www.terraform.io/) and AWS to host the [spring-experiments](https://github.com/jg210/spring-experiments) application using a [lambda function](https://aws.amazon.com/pm/lambda/) and [API gateway](https://aws.amazon.com/api-gateway/): https://aws.jeremygreen.me.uk.

## Notes

* The spring-experiments app is built using a [CI job](https://github.com/jg210/spring-experiments/actions/workflows/checks.yml) and the jar is pushed into an AWS S3 bucket.
* API gateway requests are configured with heavy rate limiting (to cap lambda costs and to simulate an overloaded API), so it gives 429 HTTP responses if make too many requests. E.g. if scroll through list of local authorities too fast. Retries in the frontend app hides this from the user.
* Monitoring is done with [UptimeRobot](https://stats.uptimerobot.com/kD80YhnAzD) (the free plan, so there's no scheduled downtime facility).
* Lambda functions are not a good way to host a production JVM-based server since the startup time of a JVM is long. Spring auto-configuration etc. takes time too.
* Latency could be partially mitigated with [Lambda SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html) or an external system polling the API to keep lambda instance alive (though this wouldn't help if/when need more than one instance).
* For this site's very low usage levels, lambda functions are cheaper than a permanently running EC2 instance. The aim here is to learn about things: e.g. how to handle a slow server.

## Development Environment

These instructions are for Ubuntu and bash.

* Create an AWS account.
* Configure an AWS IAM user with appropriate permissions.
* [Download](https://www.terraform.io/downloads.html) required [version](terraform/main.tf) of terraform.
* Unzip terraform.
* Rename terraform executable to add version suffix - e.g. terraform-1.2.3.
* Put renamed terraform executable in directory that is on PATH.
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

To deploy:

```
cd terraform
terraform init
terraform plan
terraform apply
```

An S3 bucket is used to store the terraform state. If this bucket doesn't exist yet, temporarily comment out the "backend" configuration in [main.tf](main.tf) while deploying, and it will be created for you (and then your temporary local state will get migrated to S3). This trick will only work if are deploying for the first time.
