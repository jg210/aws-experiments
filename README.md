Setting up a (mostly) free-tier AWS system using [terraform](https://www.terraform.io/).

Earlier versions of this repo used a [CloudFormation](https://aws.amazon.com/cloudformation/) template instead of terraform.

[![Build Status](https://travis-ci.com/jg210/aws-experiments.svg?branch=master)](https://travis-ci.com/jg210/aws-experiments)

## Non Free-Tier Resources

The Elastic IP address is not free if the EC2 instance is not running. Either keep the EC2 instance running, or destroy at least the Elastic IP address.

## Development Environment

These instructions are for Ubuntu, but should be adaptable to other platforms.

* Create AWS account.
* Configure an AWS IAM user with appropriate permissions.
* [Download](https://www.terraform.io/downloads.html) terraform, unpack and put executable on PATH.
* Configure terraform shell completion: https://www.terraform.io/docs/commands/index.html#shell-tab-completion
* Install [rbenv](https://github.com/rbenv/rbenv#installation).
* Install [ruby-build](https://github.com/rbenv/ruby-build) as an rbenv plugin.
* Run (from a bash shell):

```
sudo apt-get install python3.5-venv
rbenv install "$(cat .ruby-version)"
rbenv exec bundle install
python3.5 -m venv .venv
. environment # Repeat this every time open new terminal.
pip install --upgrade pip==19.0.3
pip install -r requirements.txt
aws configure # eu-west-1, json.
```

To configure emacs:

* Add [melpa](https://www.emacswiki.org/emacs/MELPA) package-source configuration to ~/.emacs
* From emacs, `M-x list-packages` and install terraform-mode.

If the set of gem executables is changed, re-run this and check in the result:

```
. environment
bundler binstubs --all --path .bundle/bin
```

To deploy:

```
terraform init
terraform plan
terraform deploy
```