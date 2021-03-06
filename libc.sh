#!/usr/bin/env bash

# LIve BC - calculator
# MIT LIcense. Copyright 2022 Mirko Palmer (derbroti)
###


CLIP_TOOL="pbcopy"

###

IFS=''
lines=( )
cposx=0
cposy=0
valid='[0-9a-zA-Z\.+-\*/%()]'

while true
do
    recalc=0
    line=""
    read -n1 -r -s inp
    if [[ "$inp" == 'y' ]]
    then
        clip=$(which ${CLIP_TOOL})
        if [ $? -eq 0 ]; then
            read -n1 -r -s inp
            if [[ "$inp" == 'a' ]] || [[ "${inp}" == 'y' ]]; then
                $(echo -n "${out}" | ${clip})
            elif [[ "${inp}" == 'q' ]]; then
                $(echo -n "${lines[$cposy]}" | ${clip})
            fi
            continue
        fi
    elif [[ "$inp" == "" ]] # baclskash
    then
        if [ $cposx -ne 0 ]; then
            line=${lines[$cposy]}
            lines[$cposy]=${line:0:$(($cposx-1))}${line:$cposx:${#line}}
            echo -ne "[2K" # clear line
            cposx=$(( $cposx - 1 ))
            recalc=1
        fi
    elif [[ "$inp" == ' ' ]] # newline (line feed)
    then
        cposx=0
        lines=( "${lines[@]}" "" )
        cposy=$(($cposy + 1))
        echo -ne "[3B" # go 3 lines down
    elif [[ "$inp" == '' ]] # ctrl+a
    then
        cposx=0
    elif [[ "$inp" == '' ]] # ctrl+e
    then
        cposx=${#line[$cposy]}
    elif [[ $inp == "" ]] # escape
    then
        read -n1 -s -t 0.002 inp2
        if [[ $inp2 == "[" ]]; then
            read -n1 -s inp3
            if [[ $inp3 == "C" ]] # cursor right
            then
                if [ $cposx -lt "${#lines[$cposy]}" ]; then
                    cposx=$(( $cposx + 1 ))
                fi
            elif [[ $inp3 == "D" ]] # cursor left
            then
                if [ $cposx -gt 0 ]; then
                    cposx=$(( $cposx - 1 ))
                fi
            elif [[ $inp3 == "A" ]] # cursor up
            then
                if [ $cposy -gt 0 ]; then
                    cposy=$(($cposy - 1))
                    cposx=0
                    echo -ne "[3F" #go up
                fi

            elif [[ $inp3 == "B" ]] # cursor down
            then
                if [ $cposy -lt $((${#lines[@]} - 1)) ]; then
                    cposy=$(($cposy + 1))
                    cposx=0
                    echo -ne "[3B" #go down
                fi
            fi
        else
            exit 0
        fi
    elif [[ $inp =~ $valid ]]
    then
        recalc=1
        line=${lines[$cposy]}
        lines[$cposy]=${line:0:$cposx}$inp${line:$cposx:${#line}}
        cposx=$(( $cposx + 1 ))
    else
        continue
    fi
    echo -ne "[G" # move to column (1)
    echo -ne "[2K" # clear line
    echo -n "${lines[$cposy]}"
    if [ $recalc -eq 1 ]; then
        echo -ne "[B[G[2K" # B: down one; G: column (1); K: erase line
        out=$(echo "scale=10;${lines[$cposy]}" | bc -q 2>&1)
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
    echo -ne "[$((cposx + 1))G" #G: move to column
done

