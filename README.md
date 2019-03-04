Setting up a free-tier AWS system using [CloudFormation](https://aws.amazon.com/cloudformation/).

[![Build Status](https://travis-ci.com/jg210/aws-experiments.svg?branch=master)](https://travis-ci.com/jg210/aws-experiments)

## Development Environment

These instructions are for Ubuntu, but should be adaptable to other platforms.

* Install [rbenv](https://github.com/rbenv/rbenv#installation).
* Install [ruby-build](https://github.com/rbenv/ruby-build) as an rbenv plugin.
* Run (from a bash shell):

```
sudo apt-get install python3.5-venv yaml-mode
rbenv install "$(cat .ruby-version)"
rbenv exec bundle install
python3.5 -m venv .venv
. environment # Repeat this every time open new terminal.
pip install --upgrade pip==19.0.3
pip install -r requirements.txt
```

If add the set of gem executables is changed, re-run this:

```
. environment
bundler binstubs --all --path .bundle/bin
```

To run [cfn_nag](https://github.com/stelligent/cfn_nag) CloudFormation static analysis:

```
cfn_nag_scan --input-path cloudformation.yaml
```
