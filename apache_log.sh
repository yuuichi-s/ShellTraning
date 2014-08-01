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

# �ե饰���ꥢ
clear_join_flg() {
    JOINING_STR=
    FLG_JOIN_QT=0
    FLG_JOIN_BR=0
    FLG_JOIN=0
}

# ���������
init() {
    # SLOW10�ν����
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

# �ե������1�Ԥ����ɤ߹���
while read line
do
    # ����˳�Ǽ
    TMP_ARRAY=(`echo $line`)
    
    # �ѡ�������
    #parse(line)
    for i in `seq 1 ${#TMP_ARRAY[@]}`
    do
        # �������Ǥ��ѿ��˳�Ǽ��ľ��
        TMP_STR=${TMP_ARRAY[$i-1]}
        #echo $i: ${TMP_STR}

        # 1�Х����ܤ��ѿ��˳�Ǽ
        FIRST_CHAR=${TMP_STR:0:1}

        # ���ե饰��OFF
        if [ ${FLG_JOIN} -eq "0" ]; then
            # 1ʸ���ܤ򸡺�(")�ξ��
            if [ ${FIRST_CHAR} = "\"" ]; then
                # ���ե饰��Ω�ơ������ʸ�����ѿ����ɲ�
                FLG_JOIN=1
                FLG_JOIN_QT=1
                JOINING_STR=${TMP_STR}

            # 1ʸ���ܤ�"["�ξ��
            elif [ ${FIRST_CHAR} = "[" ]; then
                FLG_JOIN=1
                FLG_JOIN_BR=1
                JOINING_STR=${TMP_STR}

            # 1ʸ���ܤ�"��[�ʳ�
            else
                # ���Τޤ�������ɲ�
                SPLIT_ARRAY=("${SPLIT_ARRAY[@]}" "${TMP_STR}")
            fi
        # ���ե饰��ON
        else
            STR_END=`expr ${#TMP_STR} - 1`
            # " �ξ��
            if [ ${FLG_JOIN_QT} -eq "1" ]; then
                JOINING_STR=${JOINING_STR}${SPACE}${TMP_STR}

                # �Ǹ�����"�ξ��
                if [ ${TMP_STR: -1} = "\"" ]; then
                    # ������ɲä������ʸ�����ѿ��򥯥ꥢ
                    SPLIT_ARRAY=("${SPLIT_ARRAY[@]}" "${JOINING_STR}")
                    JOINING_STR=
                    FLG_JOIN_QT=0
                    FLG_JOIN=0
                fi
            # [ �ξ��
            elif [ ${FLG_JOIN_BR} -eq "1" ]; then
                JOINING_STR=${JOINING_STR}${SPACE}${TMP_STR}

                # �Ǹ�����]�ξ��
                if [ ${TMP_STR: -1} = "]" ]; then
                    # ������ɲä������ʸ�����ѿ��򥯥ꥢ
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
	    # �Ŀ� $i, ���: $sum
	    SUM=`expr ${SUM} + ${TMP_ARRAY[14]}`
	    
	    
	    MAXITEM=`expr ${#SLOW10[@]} - 1`
	    # �礭�����ϳ�Ǽ����
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

echo ����®�ٹ��: $SUM, ʿ�� `expr $SUM / $i`

