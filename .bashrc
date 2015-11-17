						############################################################################################
						# 						           @author Allan Brito                                     #
						#  Se a váriável atualiza_bashrc estiver setada com true, qualquer alteração será perdida  #
						############################################################################################

#variaveis
now=$(date +"%Y%m%d_%H%M")
windows=false
linux=false
mac=false
path_root=/var/www
whoami=$(id -u -n)
path_config=~/.bashconfig
path_bash_files=~/bashrc
wiki_url="http://fabrica.moobitech.com.br/w/scripts_no_bash/"
default_params="atualiza_bashrc=true
mostrar_mensagem_ultimo_commit=true
baixa_por_ssh=false
local_host=192.168.25.200
local_user=root
local_pass=
remote_host=sindicalizi.com.br
remote_user=sindical
remote_pass="
use_database=

[ -f ~/.bashversion ] || touch ~/.bashversion
clear
set -o noglob
mkdir -p "$path_bash_files"
( [ -f "$path_config" ] || init_config)
eval "$default_params"
while read linha
do
    eval "$linha"
done < "$path_config"
case "$(uname -s)" in
	Darwin)
		mac=true
	;;
	Linux)
		linux=true
	;;
	CYGWIN*|MINGW32*|MSYS*)
		windows=true
		path_root=/c/xampp/htdocs
		alias mysql=$path_root/../mysql/bin/mysql.exe
		alias mysqldump=$path_root/../mysql/bin/mysqldump.exe
		alias php=$path_root/../php/php.exe
		alias subl="/C/Program\ Files/Sublime\ Text\ 3/subl.exe"
	;;
esac
migrations=$path_root/sindicalizi/migrations/

#atalhos
alias ls='ls -F --show-control-chars'
alias gts='git status '
alias e='exit'
alias home=path_home
alias bash=open_bash
alias moobidb=$path_root/sindicalizi/moobilib/scripts/moobidb.php
alias bash_update_version="( [ -f ~/.bashversion ] || touch ~/.bashversion) && echo $(date -d '-1 min' '+%Y-%m-%dT%H:%M') > ~/.bashversion"
alias commit=bash_commit
alias use=mysql_use
alias wiki=open_wiki
alias init=init_bash
alias reset=bash_reset
alias update=bash_update
alias subl_commit=sublime_commit
alias subl_update=sublime_update
alias changelog=bash_changelog
alias m=mysql_local
alias s=mysql_remote
alias mm=mysql_plus_local
alias ss="mysql_plus_local -r "
alias x=path_root
alias gtc="git_commit --"
alias gtu=git_update
alias migration=path_migration
alias migrate=migration_local_todas
alias migrates=migration_remote_todas
alias migratec=migration_create
alias bkp=mysql_backup
alias bkpl=mysql_backup_local
alias bkpr=mysql_backup_remote
alias upl=mysql_upload
alias upll=mysql_upload_local
alias uplr=mysql_upload_remote
alias dump=mysql_dump
alias dumpm=mysql_dump_migracao
alias restore=mysql_restore
alias restorem=mysql_restore_migracao
alias base_migracao=init_base_migracao
alias urlsispagl=mysql_update_urlws_local
alias urlsispagr=mysql_update_urlws_remote
alias h=help
alias a=atalhos
alias r=reset
alias b=bash
alias config=open_config
alias mysqli=/c/Python/Scripts/mycli.exe


#funcoes
function bash_changelog {
	local lines="$@"
	local message=$(git -C "$path_bash_files" log ${lines:--10} | cat)
	[[ ${#message} != 0 ]] && echo "Últimas mudanças:" && git -C "$path_bash_files" log "${lines:--10}" --pretty=format:"%C(white bold) %s %C(reset)%C(bold)%C(yellow ul)<%an, %ar>%C(reset)" | cat
	if [[ $lines != "" ]]; then
		bash_update_version
	fi
}

function bash_commit {
	# read -r -p "Deseja atualizar as funções? [S/n] " response
	clear
	read -r -p "Existem alterações, deseja [V]er ou [C]ommitar? [C/v/*] " response
	case $response in
		[cC])
			local path="${PWD##/}"
			read -r -p "Mensagem do commit: " msg
			msg=${msg:-bash_update}
			cd "$path_bash_files"
			cp ../.bashrc .bashrc
			# cp ~/AppData/Roaming/ConEmu.xml "$path_bash_files"/bash/
			git add .
			git commit -am "$msg"
			bash_update_version
			git pull origin master &&
			git push origin master
			cd "/$path"
		;;
		[vV])
			git diff --no-index -- "$path_bash_files"/.bashrc "$path_bash_files"/../.bashrc
			bash_commit
		;;
		"")
			bash_commit
		;;
	esac
}

function bash_reset {
	. ~/.bashrc
	# if [[ "$windows" == true ]] ; then
		# $path_bash_files/bash/Bash.exe
		# "C:\Program Files (x86)\Git\bin\sh.exe" --login -i
	# fi
}

function bash_update {
	git -C "$path_bash_files" fetch
	if [[ $(git -C "$path_bash_files" rev-parse HEAD) != $(git -C "$path_bash_files" rev-parse origin/master) ]]; then
		# read -r -p "Deseja atualizar as funções? [S/n] " response
		# case $response in
		# 	[sS][iI][mM]|[sS])
				cd "$path_bash_files"
				git checkout -f
				git pull origin master
				cp .bashrc ../.bashrc
				bash_reset
		# 	;;
		# esac
	fi
}

function git_clone {
	[[ "$1" != '' ]] && x && git clone git@46.101.133.178:sistema/"$1".git && cd "$1"
}
alias clone=git_clone
function git_commit {
	local update=true
	local mensagem=
	while [ "$1" != "" ]; do
		case $1 in
			-e)
				update=false
			;;
			* )
				mensagem="$mensagem $1"
			;;
		esac
		shift
	done
	if [[ $mensagem != "" ]]; then
		git add .
		git commit -am "$mensagem" || true
		git pull
		git push
		if [[ $update == true ]]; then
			git_update
		fi
	fi
}

function git_update {
	local path="${PWD##/}"
	if [[ -d "sisfinanc" ]]; then
		echo "  sisfinanc, env e var:"
		cd sisfinanc
		git pull || true
	else
		echo "  env e var:"
	fi
	x env
	git pull || true
	x var
	git pull || true
	cd "/$path"
}

function init_bash {
	if [ ! -d "$path_bash_files"/.git ]; then
		git -C "$path_bash_files" init
		git -C "$path_bash_files" remote add origin https://github.com/allanbrito/my_bash.git
		git -C "$path_bash_files" fetch --all
		git -C "$path_bash_files" pull origin master
		bash_update_version
		cp "$path_bash_files"/.bashrc "$path_bash_files"/../.bashrc
		# cp "$path_bash_files"/bash/ConEmu.xml ~/AppData/Roaming/
		if [[ $windows == true ]]; then
			cp $path_bash_files/bash/Bash.lnk ~/Desktop/
			$path_bash_files/bash/Bash.exe
			exit
		fi
	fi
	if [[ ! -f ~/Desktop/Bash.lnk ]]; then
		cp $path_bash_files/bash/Bash.lnk ~/Desktop/
	fi
}

function init_base_migracao {
	if [[ "$1" != "" ]]; then
		banco=${2:-sinpoldf}
		mysql_local "$1" create database if not exists sindical_"$1"_migracao
		mysql_backup_local $@ -d -f -b "$banco"
		mysql_upload_local $@ -b "$1"_migracao # -path "$fullpath"
		mysql_backup_local $@ -f -b "$banco"
		mysql_upload_local $@ -b "$1"_migracao # -path "$fullpath"
	fi
}

function init_config {
	(touch "$path_config" && echo "$default_params" > "$path_config" && config)
}

function init_ssh {
	read -r -p "Email: " email
	ssh-keygen -t rsa -b 4096 -C "$email"
	clip < ~/.ssh/id_rsa.pub
	echo "A chave está no seu ctrl+c"
}
alias ssh_gen=init_ssh

function migration_create {
	if [[ "$1" != "" ]] ; then
		local hora=$(date +"%Y%m%d%H%M")
		echo migration "$hora"_"$1".sql criada
		touch $migrations/"$hora"_"$1".sql
		subl $migrations/"$hora"_"$1".sql
		if [[ "$2" != "" ]] ; then
			local nome="$hora"_"$1".sql
			read -r -p "Deseja marcar a migration \"$nome\" no banco \"$2\" local? [S/n] " response
			case $response in
				[sS][iI][mM]|[sS])
					migration -s "$2" --mark "$hora"_"$1".sql
				;;
			esac
		fi
	fi
}

function migration_local_todas {
	migration --migrate --all "$@"
}

function migration_remote_todas {
	migration --migrate --prod --all "$@"
}

function mysql_backup {
	local host="$local_host"
	local user="$local_user"
	local pass="$local_pass"
	local ssh="200"
	local banco=
	local tabelas=
	local exit=false
	local remote=false
	local bIgnoraTabelas=true
	local aTabelasIgnoradas=(log_log uso_usuario usi_usuario_grupo_usuario pro_perfil_usuario usuario_acao sms_sms eml_email)
	local extracommands=''
	now=$(date +"%Y%m%d_%H%M")

	mkdir -p ~/backups

	while [ "$1" != "" ]; do
		case $1 in
			-h | --host )
				shift
				host=$1
				ssh=
			;;
			-u | --user )
				shift
				user=$1
				ssh=
			;;
			-p | --pass )
				shift
				pass=$1
				ssh=
			;;
			-b | --banco )
				shift
				banco=$1
			;;
			-d | --no-data )
				extracommands+=" -d"
			;;
			-t | --tabelas )
				shift
				tabelas=$1
			;;
			-f | --full)
				bIgnoraTabelas=false
				;;
			-r | --remote )
				remote=true
				ssh="sindicalizi"
				;;
			--h | -help )
				echo "    Usage: banco [tabela1 tabela2 ...] [-h host] [-u usuario] [-p senha] [-r]"
				echo "       Options:"
				echo "         -h: define o host. 	Padrão: acesso à 200"
				echo "         -u: define o usuario.	Padrão: acesso à 200"
				echo "         -p: define a senha.	Padrão: acesso à 200"
				echo "         -r: troca o padrão de acesso para a produção"
				echo "       Parameters:"
				echo "         -banco: banco que será baixado"
				echo "         -tabelas: tabelas que serão baixadas (opcional)"
				exit=true
			;;
			* )
				if [[ $banco == "" ]] ; then
					banco=$1
				else
					if [[ $tabelas == "" ]] ; then
						tabelas="$1"
					else
						tabelas="$tabelas $1"
					fi
				fi
			;;
		esac
		shift
	done

	if [[ $exit == false ]] &&  [[ $banco != "" ]]; then
		if [[ $remote == true ]] ; then
			host="$remote_host"
			user="$remote_user"
			pass="$remote_pass"
			path=remote_"$banco"_$now
		else
			path=local_"$banco"_$now
		fi
		if [[ $tabelas != "" ]] ; then
			path="$path"_"($tabelas)"
		fi
		mkdir -p ~/backups/"$banco"
		path="$path".sql
		fullpath=~/backups/"$banco"/"${path// /_}"
		if [[ $banco != *_* ]]; then
			banco=sindical_$banco
		fi
		if [[ $bIgnoraTabelas == true ]] ; then
			for tabela in "${aTabelasIgnoradas[@]}"
			do :
			   extracommands+=" --ignore-table=$banco.${tabela}"
			done
		fi

		if [[ $baixa_por_ssh == true && $remote == true && $ssh != "" ]] ; then
			ssh.exe "$ssh" "mysqldump -u $user -p$pass $banco $tabelas $extracommands > /tmp/$banco.sql && gzip -f /tmp/$banco.sql"
			scp sindicalizi:/tmp/"$banco".sql.gz ~/backups/temp.gz
			gunzip -c ~/backups/temp.gz > "$fullpath"
			rm ~/backups/temp.gz
		else
			$path_root/../mysql/bin/mysqldump.exe -u "$user" -p"$pass" -h "$host" "$banco" $tabelas $extracommands > "$fullpath"
		fi
		sed -i 's/DEFAULT CURRENT_TIMESTAMP//g' "$fullpath"
		sed -i 's/.+DEFINER=.+\n//g' "$fullpath"
		sed -i 's/.+CREATE ALGORITHM=.+\n//g' "$fullpath"
		echo -e "SET AUTOCOMMIT=0;\nSET UNIQUE_CHECKS=0;\nSET FOREIGN_KEY_CHECKS=0;" | cat - "$fullpath" > "$fullpath"_temp.sql
		(cat "$fullpath"_temp.sql ; echo -e "SET FOREIGN_KEY_CHECKS=1;\nSET UNIQUE_CHECKS=1;\nSET AUTOCOMMIT=1;\nCOMMIT;") > "$fullpath"
		rm "$fullpath"_temp.sql
	fi
}

function mysql_backup_local {
	echo "Fazendo dump local"
	bkp $@
}

function mysql_backup_remote {
	if [[ $baixa_por_ssh == true ]]; then
		echo "Fazendo dump de produção por ssh"
	else
		echo "Fazendo dump de produção"
	fi

	bkp -r $@
}

function mysql_dump {
	mysql_backup_remote $@
	mysql_upload_local $@ # -path "$fullpath"
}

function mysql_dump_migracao {
	m "$1" create database if not exists sindical_"$1"_migracao
	mysql_backup_remote $@ -d -f
	mysql_upload_local $@ -b "$1"_migracao # -path "$fullpath"
	mysql_backup_remote $@ -f
	mysql_upload_local $@ -b "$1"_migracao # -path "$fullpath"
}

function mysql_local {
	local host="$local_host"
	local user="$local_user"
	local pass="$local_pass"
	local banco=
	local mysql_commands=("select" "update" "delete" "alter" "show" "desc" "create" "drop" "describe" "flush")

	if [[ "$1" == "-r" ]] ; then
		host="$remote_host"
		user="$remote_user"
		pass="$remote_pass"
		shift
	fi

	# connection="-u $user -h $host -p$pass"
	connection="$pass mysql -u $user -h $host"
	if [[ "$2" == "" ]] ; then
		[[ "$1" != "" ]] && use "$1"
		# if [[ $use_database != *_* ]]; then
			banco=$use_database
		# else
		# 	banco=$1
		# fi
		if [[ $banco != *_ ]]; then
			# if [[ $banco != *_* ]]; then
			# 	banco=sindical_$banco
			# fi
			eval MYSQL_PWD=$connection "$banco"
		else
			eval MYSQL_PWD=$connection
		fi
		# mysql $connection sindical_${use_database:-$1} || mysql $connection
	else
		if [[ $(echo "${mysql_commands[@]}" | grep "$1" | wc -w) -eq 0 ]]; then
			use "$1"
			shift
		fi
			banco="$use_database"
		local sql=$@
		if [[ -f $@ ]]; then
			sql="source ${sql/~/\~}"
		fi
		# if [[ $banco != *_* ]]; then
		# 	banco=sindical_$banco
		# fi

		if [[ "$sql" != "" ]]; then
			eval MYSQL_PWD=$connection "$banco" -e \'"$sql"\'
		else
			eval MYSQL_PWD=$connection
		fi
		# mysql $connection sindical_$banco -e "$sql" || mysql $connection
	fi
}


function mysql_plus_local {
	local host="$local_host"
	local user="$local_user"
	local pass="$local_pass"
	local banco=

	if [[ "$1" == "-r" ]] ; then
		host="$remote_host"
		user="$remote_user"
		pass="$remote_pass"
		shift
	fi

	# connection="-u $user -h $host -p$pass"
	connection="-u $user -h $host -p$pass"
	[[ "$1" != "" ]] && use "$1"
	# if [[ $use_database != *_* ]]; then
		banco=$use_database
	# else
	# 	banco=$1
	# fi
	if [[ $banco != *_ ]]; then
		# if [[ $banco != *_* ]]; then
		# 	banco=sindical_$banco
		# fi
		mysqli $connection "$banco"
	else
		mysqli $connection
	fi
}

function mysql_remote {
	mysql_local -r "$@"
}

function mysql_update_urlws_local {
	local banco=${1:-sispag}
	local sql="update ema_empresa set ema_url_ws = replace(replace(ema_url_ws, '.sindicalizi.com.br',''), 'http://', 'http://localhost/')  where ema_url_ws like '%.sindicalizi.com.br/sispagintegracao/';"
	echo "Alterando ema_url_ws de $banco para local" && mysql -u"$local_user" -p"$local_pass"  -h"$local_host" sindical_"$banco" -e "$sql"
}

function mysql_update_urlws_remote {
	local banco=${1:-sispag}
	local sql="update ema_empresa set ema_url_ws = replace(replace(ema_url_ws, 'localhost/', ''), '/sispagintegracao/', '.sindicalizi.com.br/sispagintegracao/') where ema_url_ws like 'http://localhost/%' and ema_url_ws not like 'http://localhost/sispagintegracao/';"
	if [[ "$2" == "-l" ]]; then
		mysql -u"$local_user" -p"$local_pass"  -h"$local_host" sindical_"$banco" -e "$sql"
	else
		echo "Alterando ema_url_ws de $banco para remote" && mysql -u"$remote_user" -p"$remote_pass"  -h"$remote_host" sindical_"$banco" -e "$sql"
	fi
}

function mysql_upload {
	local host="$local_host"
	local user="$local_user"
	local pass="$local_pass"
	local banco=
	local exit=false
	local remote=false

	while [ "$1" != "" ]; do
		case $1 in
			-h | --host )
				shift
				host=$1
			;;
			-u | --user )
				shift
				user=$1
			;;
			-p | --pass )
				shift
				pass=$1
			;;
			-b | --banco )
				shift
				banco=$1
			;;
			--h | -help )
				echo "Que doideira!!"
				exit=true
			;;
			-r | --remote )
				remote=true
				ssh="sindicalizi"
			;;
			* )
				if [[ $banco == "" ]] ; then
					banco=$1
				else
					fullpath=$1
					path=$(echo $fullpath | tr "/" " ")
					path=${path[@]:(-1)}
				fi
			;;
		esac
		shift
	done

	if [[ $exit == false ]] && [[ $banco != "" ]] && [[ "$path" != "" ]]; then
		if [[ $remote == true ]]; then
			host="$remote_host"
			user="$remote_user"
			pass="$remote_pass"
			[[ $banco == sispag* ]] && mysql_update_urlws_remote $banco -l
		fi
		if [[ $banco != *_* ]]; then
			banco=sindical_$banco
		fi

		connection="$pass mysql -u $user -h $host"
		if [[ $baixa_por_ssh == true && $remote == true && $ssh != "" ]] ; then
			if [[ $fullpath != *.gz ]]; then
				gzip "$fullpath"
				fullpath="$fullpath".gz
			fi
			scp "$fullpath" sindicalizi:.
			ssh.exe "$ssh" "gunzip $path.gz && mysql -u $user -p$pass $banco < $path"
			# rm "$fullpath".gz
		else
			mysql -u "$user" -p"$pass" -h "$host" "$banco" < "$fullpath"
		fi



		[[ $banco == sispag* && $remote == false ]] && mysql_update_urlws_local $banco
		[[ $banco == sispag* && $remote == true ]] && mysql_update_urlws_remote $banco && mysql_update_urlws_local $banco
	fi
}

function mysql_upload_local {
	echo "Fazendo restore local"
	mysql_upload $@
}

function mysql_upload_remote {

	read -r -p "Tem certeza que deseja subir dados para o servidor? [S/N] " response
	case $response in
		[sS][iI][mM]|[sS])
			echo "Fazendo restore em produção"
			mysql_upload -r $@
			;;
		*)
			;;
	esac
}

function mysql_use {
	local bases=("manager" "sindical")
	local array_handler
	array_handler=(${1//_/ })
	if [[ $1 == "" ]]; then
		use_database=sindical_
	else if [[ "${bases[@]}" == *"${array_handler[0]}"* ]]; then
			use_database="$1"
			if [[ $use_database != *_* ]]; then
				use_database="$use_database"_
			fi
		else if [[ $use_database == *_* ]]; then
			array_handler=(${use_database//_/ })
			use_database="${array_handler[0]}"_"$1"
			fi
		fi
	fi
	# echo "usando $use_database"
}

function mysql_restore {
	mysql_backup_local $@ -b "$1"
	mysql_upload_remote $@ # -path "$fullpath"
}

function mysql_restore_migracao {
	mysql_backup_local $@ -b "$1"_migracao
	mysql_upload_remote $@ # -path "$fullpath"
}

function open_config {
	vim "$path_config"
}

function open_bash {
	if [[ "$windows" == true ]] ; then
		/C/Program\ Files/Sublime\ Text\ 3/subl.exe ~/.bashrc
	fi
}

function open_wiki {
	if [[ "$windows" == true ]] ; then
		start "$wiki_url"
	else
		if [[ "$mac" == true ]] ; then
			open "$wiki_url"
		else
			xdg-open "$wiki_url"
		fi
	fi
}

function path_home {
	cd ~
}

function path_migration {
	moobidb --no-ansi "$@"
}

function path_root {
	cd $path_root/"$1"
}

function sublime_commit {
	local path="${PWD##/}"
	tar -zcvf "$path_bash_files"/Sublime_"$whoami".tar.gz -C ~/AppData/Roaming/Sublime\ Text\ 3/ Packages Installed\ Packages
	read -r -p "Deseja commitar? [S/n] " response
	case $response in
		[sS][iI][mM]|[sS])
			git -C "$path_bash_files" add .
			git -C "$path_bash_files" commit -am "Sublime preferences"
			git -C "$path_bash_files" pull origin master
			git -C "$path_bash_files" push
		;;
	esac
}

function sublime_update {
	local user="$1"
	if [[ "$user" == "" ]] ; then
		user='allan' # "$whoami"
	fi
	if [[ ! -f "$path_bash_files"/Sublime_"$user".tar.gz ]]; then
		echo "O sublime de $user não está disponível"
	else
		tar -zxvf  "$path_bash_files"/Sublime_"$user".tar.gz -C ~/AppData/Roaming/Sublime\ Text\ 3/
		clear
		echo "Sublime atualizado para o de ${user}!"
	fi
}

function help {
	if [[ "$1" != "" && -f "$path_bash_files"/help/"$1" ]] ; then
		if [[ -f "$path_bash_files"/help/"$1" ]]; then
			echo -e $(cat "$path_bash_files"/help/"$1")
		# else
		# 	echo "$1: Ainda não documentada"
		fi
	else
		local funcao=''
		[[ "$1" != "-a" ]] && funcao="$1"
		local funcoes=($(grep "function\ .*$funcao" ~/.bashrc | sed 's/function//' | sed 's/ {//'))
		local falta_documentar=
		for i in "${funcoes[@]}"
		do :
			if [[ -f "$path_bash_files"/help/"$i" ]]; then
				echo -e $(head -1 "$path_bash_files"/help/"$i")
			else
				falta_documentar="$falta_documentar\n$i: Ainda não documentada"
			fi
		done
		if [[ "$1" == "-a" ]]; then
			echo -e "$falta_documentar"
		fi
	fi
}

function atalhos {
	echo "Em breve!"
	# aAtalho="${aaAtalhos	[0]}"
	# aaAtalhos=$(grep "alias\ .*=[^$].*_" ~/.bashrc | sed 's/alias //')
	x=0
	atalhos=()
	grep "alias\ .*=[^$].*_" ~/.bashrc | sed 's/alias //' | while read -r line ; do
		line=(${line//=/ })
		# eval ${line[1]}=${!line[1]}, ${line[0]}
		# echo ${!line[1]}
		# atalhos+=("${line[1]}:${line[0]}")
		# for i in "${atalhos[@]}"
		# do :
		# 	if [[ $i == "$line[1]"* ]]; then
		# 		echo "$i""${line[1]}"
		# 	fi
		# done
	done
	# echo "${atalhos[0,0]} ${atalhos[0,1]}" # will print 0 1
}

#exec


if [[ "$atualiza_bashrc" == true ]] ; then
	init_bash
	if [[ $(diff "$path_bash_files"/.bashrc "$path_bash_files"/../.bashrc) ]]; then
		bash_commit
	else
		bash_update
	fi
	clear
fi

if [[ "$mostrar_mensagem_ultimo_commit" == true ]] ; then
	# echo $(git -C $path_bash_files/ log  @{1}.. --reverse --no-merges)
	# echo $(git -C "$path_bash_files" log -1 --pretty=format:"%C(bold)%s %C(bold)%C(Yellow ul)%an, %ar")
	bash_changelog $(echo "--after='"$(cat ~/.bashversion)"'" || echo "-1")
fi

[[ ! -d /c/Python ]] && tar -zxvf "$path_bash_files"/Python.tar.gz -C /c && clear

use sindical