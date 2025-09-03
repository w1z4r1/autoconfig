#!/bin/bash

pkgs_to_install="make git zsh xclip"
sudo apt install -y $pkgs_to_install

echo "Copiando .vimrc"
cp ./res $HOME/.vimrc

# Una funcion para modificar algun valor de los ficheros de configuracion por un nuevo valor.
# Si no esta el valor, se anade.
ensure_line() {
	local pattern=$1
	local newline=$2
	local file=$3

	if [[ ! -f "$file" ]]; then
		touch "$file"
	else
		cp "$file" "${file}.bak"
	fi

	if LC_ALL=C grep -q "$pattern" "$file"; then
		sed -i "/$pattern/ c $newline" "$file"
	else
		printf "%s\n" "$newline" >> $file
	fi

}

# Oh-my-zsh
if [[ ! -d $HOME/.oh-my-zsh  ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "Oh-my-zsh installed already!"
fi

ensure_line "ZSH_THEME=\"robbyrussell\"" "ZSH_THEME=\"josh\"" "$HOME/.zshrc"

# Oh-my-tmux
if [[ ! -f $HOME/.tmux.conf.local ]]; then
	echo "Installing Oh-my-tmux..."
	pwd=$PWD
	cd $HOME
	git clone --single-branch https://github.com/gpakosz/.tmux.git
	ln -s -f .tmux/.tmux.conf
	cp .tmux/.tmux.conf.local .
	cd $pwd
	echo "Installed Oh-my-tmux!"
else
	echo "Oh-my-tmux installed already!"
fi

ensure_line "tmux_conf_copy_to_os_clipboard=false " "tmux_conf_copy_to_os_clipboard=true " "$HOME/.tmux.conf.local"
