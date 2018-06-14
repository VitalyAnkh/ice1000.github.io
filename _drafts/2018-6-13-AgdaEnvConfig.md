---
layout: post
title: Agda Env
category: Agda
tags: Agda, Emacs
keywords: Agda, Emacs
description: Agda env and stdlib config
---

## Agda

https://github.com/ice1k/xjb-config/blob/master/ubuntu-setup.sh

```shell
## prerequisites
sudo apt install cabal-2.2 ghc-8.2.2 clone
export INSTALLATION_PATH=~/SDK # replace with your own

## installing agda
cabal update
cabal install alex happy cpphs
cabal install --allow-newer Agda
agda-mode setup
agda-mode compile
mkdir -p $INSTALLATION_PATH
git clone https://github.com/agda/agda-stdlib.git $INSTALLATION_PATH/agda-stdlib/
rm $INSTALLATION_PATH/agda-stdlib/src/index.agda
mkdir ~/.agda
echo "$INSTALLATION_PATH/agda-stdlib/standard-library.agda-lib" >> ~/.agda/libraries
echo "standard-library" >> ~/.agda/defaults
```

