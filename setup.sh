cp dws-attach /usr/local/bin/
chmod +x /usr/local/bin/dws-attach
alias dws='source /usr/local/bin/dws-attach'
echo "alias dws='source dws-attach'" >> ~/.bashrc