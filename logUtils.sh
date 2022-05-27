logSuccess() {
	echo -e "\e[32m$*\e[0m"
}

logError() {
	echo -e "\e[31m$*\e[0m" >&2
}

logWarn() {
	echo -e "\e[33m$*\e[0m" >&2
}
