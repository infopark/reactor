pyenv local 3.7.1
pip3 install awscli --upgrade --user
export PATH=$PATH:$HOME/.local/bin
aws ecr get-login --no-include-email | bash
