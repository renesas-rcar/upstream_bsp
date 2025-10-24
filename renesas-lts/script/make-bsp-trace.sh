#! /bin/bash
#===============================
#
# make-bsp-trace
#
# 2025/10/24 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
HTML=${TOP}/bsp-trace.html
BSP_URL=https://github.com/renesas-rcar/linux-bsp/commit/
UP_URL=https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=

echo "<html>"			> ${HTML}

FULL=`grep -v \"^#\" ${TOP}/full | wc -l`

#
# Handled
#
num=`grep -v "^#" ${TOP}/handled | grep -v "^$" | wc -l`

echo "<h1>Handled (${num}/${FULL})</h1>"	>> ${HTML}
echo "<table border=\"1\">"			>> ${HTML}
echo "<tr><th>BSP</th><th>upstream</th></tr>"	>> ${HTML}

T=0
UPSTRAM=
grep -v "^$" ${TOP}/handled | while IFS= read -r line; do

	if [[ ${line} == \#* ]]; then
		# print remains
		if [ ${T} = 1 ]; then
			echo "</td>"	>> ${HTML}
			echo "<td>"	>> ${HTML}

			br=
			for commit in ${COMMITS}
			do
				log=`git log -1 --format=%s $commit`
				echo -e "${br}<a href=\"${UP_URL}${commit}\">${log}</a>"	>> ${HTML}
				br="<BR>\n"
			done

			echo "</td></tr>"	>> ${HTML}

			T=0
			COMMITS=
		fi

		# line = "# upstream: nnnn ("xxx")"
		if [[ ${line} == \#\ upstream:\ * ]]; then
			tmp=${line#*: }		# = nnnn ("xxx")"
			commit=${tmp%% *}	# = nnnn
			COMMITS="${COMMITS} ${commit}"
		fi
	else
		if [ ${T} = 0 ]; then
			echo "<tr><td>"		>> ${HTML}
		fi
		commit=${line%% *}	# = nnnn
		log=`git log -1 --format=%s $commit`
		echo "<a href=\"${BSP_URL}${commit}\">${log}</a>"	>> ${HTML}
		T=1
	fi
done
echo "</table>"			>> ${HTML}

#
# Active
#
num=`grep -v \"^#\" ${TOP}/active | wc -l`

echo "<h1>Active (${num}/${FULL})</h1>"	>> ${HTML}
echo "<table border=\"1\">"		>> ${HTML}
echo "<tr><th>BSP</th></tr>"		>> ${HTML}

grep -v "^#" ${TOP}/active | cut -d " " -f 1 | while IFS= read -r commit; do
	log=`git log -1 --format=%s $commit`
	echo -e "<tr><td><a href=\"${BSP_URL}${commit}\">${log}</a></td></tr>"	>> ${HTML}

done
echo "</table>"			>> ${HTML}

#
# ramins
#
num=`grep -v \"^#\" ${TOP}/remains* | wc -l`

echo "<h1>Remains (${num}/${FULL})</h1>"	>> ${HTML}
echo "<table border=\"1\">"			>> ${HTML}
echo "<tr><th>BSP</th></tr>"			>> ${HTML}

grep -vh "^#" ${TOP}/remains* | cut -d " " -f 1 | while IFS= read -r commit; do
	log=`git log -1 --format=%s $commit`
	echo -e "<tr><td><a href=\"${BSP_URL}${commit}\">${log}</a></td></tr>"	>> ${HTML}

done
echo "</table>"			>> ${HTML}


echo "</html>"	>> ${HTML}
