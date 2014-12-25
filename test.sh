#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
APP='./bin/hashjoin';
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# run app
function run_app()
{
	local RESULT=0;
	local STDOUT;

	if [ "${FLAG_VALGRIND}" != "1" ];
	then
		STDOUT=$("${APP}" "${@}");
		RESULT="${?}";
	else
		local VAL="valgrind --tool=memcheck --leak-check=yes --leak-check=full --show-reachable=yes --log-file=valgrind.log";

		STDOUT=$("${VAL}" "${APP}" "${@}");
		RESULT="${?}";

		echo '--------------------------' >> valgrind.all.log;
		cat valgrind.log >> valgrind.all.log;
		rm -rf valgrind.log;
	fi


	if [ "${STDOUT}" != "" ];
	then
		echo "${STDOUT}";
	fi

	return "${RESULT}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# test
function test_it()
{
	local TMP1;
	local TMP2;
	local TMP3;
	local HASH1;
	local HASH2;


	TMP1=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "ERROR: don't make tmp file...";
		exit 1;
	fi


	TMP2=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "ERROR: don't make tmp file...";
		rm -rf "${TMP1}" &> /dev/null;
		exit 1;
	fi


	TMP3=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "ERROR: don't make tmp file...";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		exit 1;
	fi


	TMP4=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "ERROR: don't make tmp file...";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		exit 1;
	fi


	echo "1" >  "${TMP1}";
	echo "2" >> "${TMP1}";
	echo "3" >> "${TMP1}";
	echo "4" >> "${TMP1}";


	echo "5" >  "${TMP2}";
	echo "2" >> "${TMP2}";
	echo "3" >> "${TMP2}";
	echo "8" >> "${TMP2}";


	run_app '==' "${TMP1}" "${TMP2}" &> "${TMP3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR in app";
		exit 1;
	fi


	echo "2" >  "${TMP4}";
	echo "3" >> "${TMP4}";


	HASH1=$(sha1sum "${TMP3}" | { read a b; echo ${a}; });
	HASH2=$(sha1sum "${TMP4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR: result different";
		exit 1;
	fi


	run_app '=!' "${TMP1}" "${TMP2}" &> "${TMP3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR in app";
		exit 1;
	fi


	echo "1" >  "${TMP4}";
	echo "4" >> "${TMP4}";


	HASH1=$(sha1sum "${TMP3}" | { read a b; echo ${a}; });
	HASH2=$(sha1sum "${TMP4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR: result different";
		exit 1;
	fi


	rm -rf "${TMP1}" &> /dev/null;
	rm -rf "${TMP2}" &> /dev/null;
	rm -rf "${TMP3}" &> /dev/null;
	rm -rf "${TMP4}" &> /dev/null;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	if [ ! -e "${APP}" ];
	then
		echo "ERROR: make it";
		return 1;
	fi


	check_prog "cat echo rm sha1sum";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	test_it;


	echo "ok, test passed";
	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
