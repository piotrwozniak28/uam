#!/bin/sh
TPCDS_DIR="tpc-ds"
TPCDS_TOOL_DIR="DSGen-software-code-3.2.0rc1"

mkdir -p ~/${TPCDS_DIR}
mv ~/${TPCDS_TOOL_DIR} ~/${TPCDS_DIR}

cat >> .bashrc << EOL
# Custom functions definitions
if [ -f ~/.bash_functions ]; then
. ~/.bash_functions
fi
EOL

. .bashrc

cd ~/${TPCDS_DIR}/${TPCDS_TOOL_DIR}/tools/