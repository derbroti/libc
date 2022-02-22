#!bash

# LIve BC - calculator
# MIT LIcense. Copyright 2022 Mirko Palmer (derbroti)
###


CLIP_TOOL="pbcopy"

###

IFS=''
line=""
cpos=0
valid='[0-9a-zA-Z\.+-\*/%()]'

while true
do
    recalc=0
    read -n1 -r -s inp
    if [[ "$inp" == 'y' ]]
    then
        clip=$(which ${CLIP_TOOL})
        if [ $? -eq 0 ]; then
            read -n1 -r -s inp
            if [[ "$inp" == 'a' ]] || [[ "${inp}" == 'y' ]]; then
                $(echo -n "${out}" | ${clip})
            elif [[ "${inp}" == 'q' ]]; then
                $(echo -n "${line}" | ${clip})
            fi
            continue
        fi
    elif [[ "$inp" == "" ]] # baclskash
    then
        if [ $cpos -ne 0 ]; then
            line=${line:0:$(($cpos-1))}${line:$cpos:${#line}}
            echo -ne "[2K" # clear line
            cpos=$(( $cpos - 1 ))
            recalc=1
        fi
    elif [[ "$inp" == ' ' ]] # newline (line feed)
    then
        line=""
        cpos=0
        echo -ne "[3B" # go 3 lines down
    elif [[ "$inp" == '' ]] # ctrl+a
    then
        cpos=0
    elif [[ "$inp" == '' ]] # ctrl+e
    then
        cpos=${#line}
    elif [[ $inp == "" ]] # escape
    then
        read -n1 -s -t 0.002 inp2
        if [[ $inp2 == "[" ]]; then
            read -n1 -s inp3
            if [[ $inp3 == "C" ]] # cursor right
            then
                if [ $cpos -lt ${#line} ]; then
                    cpos=$(( $cpos + 1 ))
                fi
            elif [[ $inp3 == "D" ]] # cursor left
            then
                if [ $cpos -gt 0 ]; then
                    cpos=$(( $cpos - 1 ))
                fi
            fi
        else
            exit 0
        fi
    elif [[ $inp =~ $valid ]]
    then
        recalc=1
        line=${line:0:$cpos}$inp${line:$cpos:${#line}}
        cpos=$(( $cpos + 1 ))
    else
        continue
    fi
    echo -ne "[G" # move to column (1)
    echo -n "$line"
    if [ $recalc -eq 1 ]; then
        echo -ne "[B[G[2K" # B: down one; G: column (1); K: erase line
        out=$(echo "scale=10;$line" | bc -q 2>&1)
        if [[ "${out}" == *error ]]; then
            out="<err>"
        fi
        if [[ "$out" =~ ^[.] ]]; then
            out="0${out}"
        fi
        if [[ "$out" == *.* ]]; then
            out=$(echo -n "${out}" | sed -E 's/\.?0*$//')
        fi
        echo -n "${out}"
        echo -ne "[F" #go one up
    fi
    echo -ne "[$((cpos + 1))G" #G: move to column
done

