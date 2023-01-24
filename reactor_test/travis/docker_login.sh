pyenv versions
pyenv local 3.7
pyenv exec pip3 install awscli --upgrade --user
export PATH=$PATH:$HOME/.local/bin
pyenv exec aws ecr get-login --no-include-email | bash
pyenv local 2.7
