#!/usr/bin/sh

gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=23 -dLastPage=28 -SOutputFile=./chapters/chap2.pdf Thesis.pdf > /dev/null 2>&1
