#!/bin/sh

FNAME=logfile.log
SUM=0
FLG_JOIN=0
FLG_JOIN_QT=0
FLG_JOIN_BR=0
SPLIT_ARRAY=()
SPACE=" "
SLOW10=()
FAST10=()

# フラグクリア
clear_join_flg() {
    JOINING_STR=
    FLG_JOIN_QT=0
    FLG_JOIN_BR=0
    FLG_JOIN=0
}

# 初期化処理
init() {
    # SLOW10の初期化
    i=0
    while [ $i -lt 10 ]
    do
        i=`expr $i + 1`
        SLOW10+=( 0 )
    done
}

dbg_top10() {
    echo dbg_top10: ${#SLOW10[@]}
    for i in `seq 1 ${#SLOW10[@]}`
    do
        echo ${SLOW10[$i]}
    done
}

#
# main()
#

init

# ファイルを1行ずつ読み込み
while read line
do
    # 配列に格納
    TMP_ARRAY=(`echo $line`)
    
    # パースする
    #parse(line)
    for i in `seq 1 ${#TMP_ARRAY[@]}`
    do
        # 配列要素を変数に格納し直す
        TMP_STR=${TMP_ARRAY[$i-1]}
        #echo $i: ${TMP_STR}

        # 1バイト目を変数に格納
        FIRST_CHAR=${TMP_STR:0:1}

        # 結合フラグがOFF
        if [ ${FLG_JOIN} -eq "0" ]; then
            # 1文字目を検査(")の場合
            if [ ${FIRST_CHAR} = "\"" ]; then
                # 結合フラグを立て、結合用文字列変数に追加
                FLG_JOIN=1
                FLG_JOIN_QT=1
                JOINING_STR=${TMP_STR}

            # 1文字目が"["の場合
            elif [ ${FIRST_CHAR} = "[" ]; then
                FLG_JOIN=1
                FLG_JOIN_BR=1
                JOINING_STR=${TMP_STR}

            # 1文字目が"と[以外
            else
                # そのまま配列に追加
                SPLIT_ARRAY=("${SPLIT_ARRAY[@]}" "${TMP_STR}")
            fi
        # 結合フラグがON
        else
            STR_END=`expr ${#TMP_STR} - 1`
            # " の場合
            if [ ${FLG_JOIN_QT} -eq "1" ]; then
                JOINING_STR=${JOINING_STR}${SPACE}${TMP_STR}

                # 最後尾が"の場合
                if [ ${TMP_STR: -1} = "\"" ]; then
                    # 配列に追加し、結合文字列変数をクリア
                    SPLIT_ARRAY=("${SPLIT_ARRAY[@]}" "${JOINING_STR}")
                    JOINING_STR=
                    FLG_JOIN_QT=0
                    FLG_JOIN=0
                fi
            # [ の場合
            elif [ ${FLG_JOIN_BR} -eq "1" ]; then
                JOINING_STR=${JOINING_STR}${SPACE}${TMP_STR}

                # 最後尾が]の場合
                if [ ${TMP_STR: -1} = "]" ]; then
                    # 配列に追加し、結合文字列変数をクリア
                    SPLIT_ARRAY=("${SPLIT_ARRAY[@]}" "${JOINING_STR}")
                    clear_join_flg
                fi
            fi
        fi
    done

#echo -- OUTPUT --
#    for i in `seq 1 ${#SPLIT_ARRAY[@]}`
#    do
#        echo $i: ${SPLIT_ARRAY[$i-1]}
#    done
#echo -- END --

	if [ "${TMP_ARRAY}" != "" ]; then
	    # 個数 $i, 合計: $sum
	    SUM=`expr ${SUM} + ${TMP_ARRAY[14]}`
	    
	    
	    MAXITEM=`expr ${#SLOW10[@]} - 1`
	    # 大きい場合は格納する
	    if [ ${SLOW10[${MAXITEM}]} -lt ${TMP_ARRAY[14]} ]; then
	        SLOW10[${MAXITEM}]=${TMP_ARRAY[14]}
	        echo slow: ${SLOW10[9]}
	        SLOW10=(`echo "${SLOW10[*]}" | sort -r`)
	        
			echo SORT `seq ${MAXITEM} -1 1`
		    for i in `seq ${MAXITEM} -1 1`
		    do
				echo if ${SLOW10[$i-1]}  ${SLOW10[$i]}
		    	if [ ${SLOW10[$i-1]} -lt ${SLOW10[$i]} ]; then
			    	TEMP=${SLOW10[$i-1]}
			    	SLOW10[$i-1]=${SLOW10[$i]}
			    	SLOW10[$i]=${TEMP}
			    fi
			done
	        dbg_top10
	    fi
	fi
    
done < $FNAME

echo 処理速度合計: $SUM, 平均 `expr $SUM / $i`

