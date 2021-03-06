#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.3
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
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
		local LOG_ID=0;
		local LOG_NAME;

		while true;
		do
			LOG_NAME=$(printf "valgrind.%03u\n" ${LOG_ID});

			if [ ! -e "${LOG_NAME}" ];
			then
				break;
			fi

			(( LOG_ID++ ));
		done

		STDOUT=$(valgrind --tool=memcheck --leak-check=yes --leak-check=full --show-reachable=yes --log-file="${LOG_NAME}" "${APP}" "${@}");
		RESULT="${?}";
	fi

	if [ "${STDOUT}" != "" ];
	then
		echo "${STDOUT}";
	fi

	return "${RESULT}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function test1()
{
	echo "1" >  "${1}";
	echo "2" >> "${1}";
	echo "3" >> "${1}";
	echo "4" >> "${1}";


	echo "5" >  "${2}";
	echo "2" >> "${2}";
	echo "3" >> "${2}";
	echo "8" >> "${2}";


	run_app '==' "${1}" "${2}" &> "${3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[test1()]: error in app";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi


	echo "2" >  "${4}";
	echo "3" >> "${4}";


	HASH1=$(shasum -a 1 "${3}" | { read a b; echo ${a}; });
	HASH2=$(shasum -a 1 "${4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR[test1()]: result different";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi

}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function test2()
{
	echo "1" >  "${1}";
	echo "2" >> "${1}";
	echo "3" >> "${1}";
	echo "4" >> "${1}";


	echo "5" >  "${2}";
	echo "2" >> "${2}";
	echo "3" >> "${2}";
	echo "8" >> "${2}";


	run_app '!=' "${1}" "${2}" &> "${3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[test2()]: error in app";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi


	echo "1" >  "${TMP4}";
	echo "4" >> "${TMP4}";


	HASH1=$(shasum -a 1 "${3}" | { read a b; echo ${a}; });
	HASH2=$(shasum -a 1 "${4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR[test2()]: result different";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function test3()
{
	echo "1" >  "${1}";
	echo "2" >> "${1}";
	echo "3" >> "${1}";
	echo -n "4" >> "${1}";


	echo "5" >  "${2}";
	echo "2" >> "${2}";
	echo "3" >> "${2}";
	echo -n "8" >> "${2}";


	run_app '!=' "${1}" "${2}" &> "${3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[test3()]: error in app";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi


	echo "1" >  "${TMP4}";
	echo "4" >> "${TMP4}";


	HASH1=$(shasum -a 1 "${3}" | { read a b; echo ${a}; });
	HASH2=$(shasum -a 1 "${4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR[test3()]: result different";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function test4()
{
	echo "1" >  "${1}";
	echo "2" >> "${1}";
	echo "2" >> "${1}";
	echo "3" >> "${1}";


	echo "5" >  "${2}";
	echo "6" >> "${2}";
	echo "2" >> "${2}";


	run_app 'diff' "${1}" "${2}" &> "${3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[test4()]: error in app";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi


	echo "-1" >  "${TMP4}";
	echo "-3" >> "${TMP4}";
	echo "+5" >> "${TMP4}";
	echo "+6" >> "${TMP4}";


	HASH1=$(shasum -a 1 "${3}" | { read a b; echo ${a}; });
	HASH2=$(shasum -a 1 "${4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR[test4()]: result different";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function test5()
{
	echo "1" >  "${1}";
	echo "2" >> "${1}";
	echo "2" >> "${1}";
	echo "3" >> "${1}";


	echo "5" >  "${2}";
	echo "6" >> "${2}";
	echo "2" >> "${2}";


	run_app 'diff' "${2}" "${1}" &> "${3}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[test5()]: error in app";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi


	echo "-5" >  "${TMP4}";
	echo "-6" >> "${TMP4}";
	echo "+1" >> "${TMP4}";
	echo "+3" >> "${TMP4}";


	HASH1=$(shasum -a 1 "${3}" | { read a b; echo ${a}; });
	HASH2=$(shasum -a 1 "${4}" | { read a b; echo ${a}; });


	if [ "${HASH1}" != "${HASH2}" ];
	then
		echo "ERROR[test5()]: result different";
		rm -rf "${TMP1}" &> /dev/null;
		rm -rf "${TMP2}" &> /dev/null;
		rm -rf "${TMP3}" &> /dev/null;
		rm -rf "${TMP4}" &> /dev/null;
		exit 1;
	fi
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


	test1 "${TMP1}" "${TMP2}" "${TMP3}" "${TMP4}"


	test2 "${TMP1}" "${TMP2}" "${TMP3}" "${TMP4}"


	test3 "${TMP1}" "${TMP2}" "${TMP3}" "${TMP4}"


	test4 "${TMP1}" "${TMP2}" "${TMP3}" "${TMP4}"


	test5 "${TMP1}" "${TMP2}" "${TMP3}" "${TMP4}"


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


	check_prog "cat echo rm shasum";
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
