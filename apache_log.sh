#!/bin/sh

FNAME=logfile.log
SUM=0
FLG_JOIN=0
FLG_JOIN_QT=0
FLG_JOIN_BR=0
SPLIT_ARRAY=()
SPACE=" "
SLOW_RANK=()
FAST_RANK=()

# フラグクリア
clear_join_flg() {
    JOINING_STR=
    FLG_JOIN_QT=0
    FLG_JOIN_BR=0
    FLG_JOIN=0
}

# 初期化処理
init() {
    # SLOW_RANKの初期化
    i=0
    while [ ${i} -lt 10 ]
    do
        i=`expr ${i} + 1`
        SLOW_RANK+=( 0 )
    done

	# FAST_RANKの初期化
    i=0
    while [ ${i} -lt 10 ]
    do
        i=`expr ${i} + 1`
        FAST_RANK+=( 0 )
    done
}

# 速いものTOP10の表示(デバッグ用)
dbg_split_array() {
    echo -- Debug START --
    for i in `seq 1 ${#SPLIT_ARRAY[@]}`
    do
        echo ${i}: ${SPLIT_ARRAY[${i}-1]}
    done
    echo -- Debug END   --
}

# 遅いものTOP10の表示
show_slow_top10() {
    echo 処理速度の遅いものランキング
    for i in `seq 1 ${#SLOW_RANK[@]}`
    do
        echo ${i}: ${SLOW_RANK[${i}-1]}
    done
}
# 遅いものTOP10の表示
show_fast_top10() {
    echo 処理速度の遅いものランキング
    for i in `seq 1 ${#FAST_RANK[@]}`
    do
        echo ${i}: ${FAST_RANK[${i}-1]}
    done
}
# MAX値、MIN値
show_fast_slow() {
	${FAST_RANK[0]}
	${SLOW_RANK[0]}
}

#-----------------------------------------------------------
# main()
#

# 初期化関数
init

# ファイルを1行ずつ読み込み
while read line
do
    # 配列に格納
    TMP_ARRAY=(`echo ${line}`)
    
    # パースする
    #parse(line)
    for i in `seq 1 ${#TMP_ARRAY[@]}`
    do
        # 配列要素を変数に格納し直す
        TMP_STR=${TMP_ARRAY[${i}-1]}
        #echo ${i}: ${TMP_STR}

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

    # デバッグ
    dbg_split_array

    if [ "${TMP_ARRAY}" != "" ]; then
    	# 異常率処理
    	
    
        # 個数 ${i}, 合計: ${SUM}
        SUM=`expr ${SUM} + ${TMP_ARRAY[14]}`
        
        # 配列数の取得
        SLOW_ARR_MAX=`expr ${#SLOW_RANK[@]} - 1`
        FAST_ARR_MAX=`expr ${#FAST_RANK[@]} - 1`
        
        # 遅いものランクにランクインする場合
        if [ ${SLOW_RANK[${SLOW_ARR_MAX}]} -lt ${TMP_ARRAY[14]} ]; then

            # 配列最後尾を置き換え
            SLOW_RANK[${SLOW_ARR_MAX}]=${TMP_ARRAY[14]}
            SLOW_RANK=(`echo "${SLOW_RANK[*]}" | sort -r`)
            
            # ソート対象の表示(デバッグ用)
            # echo SORT `seq ${SLOW_ARR_MAX} -1 1`
            for i in `seq ${SLOW_ARR_MAX} -1 1`
            do
                if [ ${SLOW_RANK[${i}-1]} -lt ${SLOW_RANK[${i}]} ]; then
                    TEMP=${SLOW_RANK[${i}-1]}
                    SLOW_RANK[${i}-1]=${SLOW_RANK[${i}]}
                    SLOW_RANK[${i}]=${TEMP}
                fi
            done
            # ソート結果表示(デバッグ用)
            show_slow_top10

        # 速いものランクにランクインする場合
        elif [ ${FAST_RANK[${FAST_ARR_MAX}]} -gt ${TMP_ARRAY[14]} ]; then
            # 配列最後尾を置き換え
            FAST_RANK[${FAST_ARR_MAX}]=${TMP_ARRAY[14]}
            FAST_RANK=(`echo "${FAST_RANK[*]}" | sort -r`)
            
            # ソート対象の表示(デバッグ用)
            # echo SORT `seq ${FAST_ARR_MAX} -1 1`
            for i in `seq ${FAST_ARR_MAX} -1 1`
            do
                if [ ${FAST_RANK[${i}-1]} -lt ${FAST_RANK[${i}]} ]; then
                    TEMP=${FAST_RANK[${i}-1]}
                    FAST_RANK[${i}-1]=${FAST_RANK[${i}]}
                    FAST_RANK[${i}]=${TEMP}
                fi
            done
        fi
    fi
done < ${FNAME}

echo 処理速度合計: ${SUM}, 平均 `expr ${SUM} / ${i}`
show_slow_top10
show_fast_top10

