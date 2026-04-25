# sudo -E setup.sh
echo "setting up ssh file"
mkdir -p ~/.ssh
cp -r ./ssh/. ~/.ssh
chmod 600 ~/.ssh/* 2>/dev/null
chmod 644 ~/.ssh/*pub 2>/dev/null

echo "Setting up git config"
cat > ~/.gitconfig << EOF
[user]
		email = fakeemail
		name = vvvv
EOF

mkdir -p ~/dotfiles

git clone git@github.com:teamrocket77/dotfiles.git ~/dotfiles
chown -R "$HOST:users" ~/dotfiles
