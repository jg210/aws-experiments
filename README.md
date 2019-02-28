Setting up a free-tier AWS system using [CloudFormation](https://aws.amazon.com/cloudformation/).

[![Build Status](https://travis-ci.com/jg210/aws-experiments.svg?branch=master)](https://travis-ci.com/jg210/aws-experiments)

## Development Environment

```
pip install awscli
sudo apt-get install yaml-mode # If use emacs.
```

To run [cfn_nag](https://github.com/stelligent/cfn_nag) CloudFormation static analysis:

* Install [rbenv](https://github.com/rbenv/rbenv#installation).
* Install [ruby-build](https://github.com/rbenv/ruby-build) as an rbenv plugin.
* Run:

```
rbenv install "$(cat .ruby-version)"
bundle install
bundle exec cfn_nag_scan cloudformation.yaml
```