#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_MANAGER_HOME='@{definitions:environment:MANAGER_HOME}'
		_MANAGER_ENDPOINT_IP='@{definitions:environment:MANAGER_ENDPOINT_IP}'
		_MANAGER_ENDPOINT_PORT='@{definitions:environment:MANAGER_ENDPOINT_PORT}'
		
		_DDA_ENDPOINT_IP='@{definitions:environment:DDA_ENDPOINT_IP}'
		_DDA_ENDPOINT_PORT='@{definitions:environment:DDA_ENDPOINT_PORT}'
		
		_SDA_MATLAB_ENDPOINT_IP='@{definitions:environment:SDA_MATLAB_ENDPOINT_IP}'
		_SDA_MATLAB_ENDPOINT_PORT='@{definitions:environment:SDA_MATLAB_ENDPOINT_PORT}'
		
		_SDA_WEKA_ENDPOINT_IP='@{definitions:environment:SDA_WEKA_ENDPOINT_IP}'
		_SDA_WEKA_ENDPOINT_PORT='@{definitions:environment:SDA_WEKA_ENDPOINT_PORT}'
		
		_KNOWLEDGEBASE_ENDPOINT_IP='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_IP}'
		_KNOWLEDGEBASE_ENDPOINT_PORT='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_PORT}'
		_KNOWLEDGEBASE_DATASET_PATH='@{definitions:environment:KNOWLEDGEBASE_DATASET_PATH}'
		
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_MANAGER_ENDPOINT_IP="${MODACLOUDS_MONITORING_MANAGER_ENDPOINT_IP:-${_MANAGER_ENDPOINT_IP}}"
		_MANAGER_ENDPOINT_PORT="${MODACLOUDS_MONITORING_MANAGER_ENDPOINT_PORT:-${_MANAGER_ENDPOINT_PORT}}"
		
		_DDA_ENDPOINT_IP="${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP:-${_DDA_ENDPOINT_IP}}"
		_DDA_ENDPOINT_PORT="${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT:-${_DDA_ENDPOINT_PORT}}"
		
		_SDA_MATLAB_ENDPOINT_IP="${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_IP:-${_SDA_MATLAB_ENDPOINT_IP}}"
		_SDA_MATLAB_ENDPOINT_PORT="${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_PORT:-${_SDA_MATLAB_ENDPOINT_PORT}}"
		
		_SDA_WEKA_ENDPOINT_IP="${MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_IP:-${_SDA_WEKA_ENDPOINT_IP}}"
		_SDA_WEKA_ENDPOINT_PORT="${MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_PORT:-${_SDA_WEKA_ENDPOINT_PORT}}"
		
		_KNOWLEDGEBASE_ENDPOINT_IP="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP:-${_KNOWLEDGEBASE_ENDPOINT_IP}}"
		_KNOWLEDGEBASE_ENDPOINT_PORT="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT:-${_KNOWLEDGEBASE_ENDPOINT_PORT}}"
		_KNOWLEDGEBASE_DATASET_PATH="${MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH:-${_KNOWLEDGEBASE_DATASET_PATH}}"
		
		_TMPDIR="${MODACLOUDS_MONITORING_MANAGER_TMPDIR:-${_TMPDIR}}"
)
declare "${_variable_overrides[@]}"

_environment=(
		PATH="${_PATH}"
		TMPDIR="${_TMPDIR}/tmp"
		HOME="${_TMPDIR}/home"
		USER='modaclouds-services'
)

if test ! -e "${_TMPDIR}" ; then
	mkdir -- "${_TMPDIR}"
	mkdir -- "${_TMPDIR}/tmp"
	mkdir -- "${_TMPDIR}/home"
fi

_environment+=(
		
		MODACLOUDS_MONITORING_MANAGER_PORT="${_MANAGER_ENDPOINT_PORT}"
		
		MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP="${_KNOWLEDGEBASE_ENDPOINT_IP}"
		MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT="${_KNOWLEDGEBASE_ENDPOINT_PORT}"
		MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH="${_KNOWLEDGEBASE_DATASET_PATH}"
		
		MODACLOUDS_MONITORING_DDA_ENDPOINT_IP="${_DDA_ENDPOINT_IP}"
		MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT="${_DDA_ENDPOINT_PORT}"
		
		MODACLOUDS_MATLAB_SDA_IP="${_SDA_MATLAB_ENDPOINT_IP}"
		MODACLOUDS_MATLAB_SDA_PORT="${_SDA_MATLAB_ENDPOINT_PORT}"
		
		MODACLOUDS_WEKA_SDA_IP="${_SDA_WEKA_ENDPOINT_IP}"
		MODACLOUDS_WEKA_SDA_PORT="${_SDA_WEKA_ENDPOINT_PORT}"
)

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * monitoring manager endpoint: `http://%s:%s/`;\n' "${_MANAGER_ENDPOINT_IP}" "${_MANAGER_ENDPOINT_PORT}" >&2
printf '[ii]   * monitoring SDA Matlab endpoint: `http://%s:%s/`;\n' "${_SDA_MATLAB_ENDPOINT_IP}" "${_SDA_MATLAB_ENDPOINT_PORT}" >&2
printf '[ii]   * monitoring SDA Weka endpoint: `http://%s:%s/`;\n' "${_SDA_WEKA_ENDPOINT_IP}" "${_SDA_WEKA_ENDPOINT_PORT}" >&2
printf '[ii]   * monitoring DDA endpoint: `http://%s:%s/`;\n' "${_DDA_ENDPOINT_IP}" "${_DDA_ENDPOINT_PORT}" >&2
printf '[ii]   * knowledgebase endpoint: `http://%s:%s/`;\n' "${_KNOWLEDGEBASE_ENDPOINT_IP}" "${_KNOWLEDGEBASE_ENDPOINT_PORT}" >&2
printf '[ii]   * knowledgebase dataset: `%s`;\n' "${_KNOWLEDGEBASE_DATASET_PATH}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting monitoring manager...' >&2
printf '[--]\n' >&2

exec \
	env \
			-i "${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_MANAGER_HOME}/service.jar"

exit 1
