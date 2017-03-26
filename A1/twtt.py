# -*- coding: utf-8 -*-

# CDF
# /u/cs401/A1/tweets/training.1600000.processed.noemoticon.csv
# /u/cs401/A1/tweets/testdata.manualSUBSET.2009.06.14.csv
# /u/cs401/A1/tweets/testdata.manual.2009.06.14.csv

import sys
import re
import HTMLParser
import NLPlib
import csv
from itertools import chain
import time

reload(sys)
sys.setdefaultencoding('utf8')

import unicodedata

# Read the abbrev.english and store it into abbrev_list.

# wordlist_path = "/u/cs401/Wordlists/abbrev.english."
wordlist_path = "abbrev.english"

with open(wordlist_path) as f:
    lines = f.readlines()
abbrev_list = [x.strip() for x in lines]

tagger = NLPlib.NLPlib()


# twtt1-twtt20 pre-processing functions

# Remove html tags and attributes.
def twtt1(str):
    TAG_RE = re.compile(r'<[^>]+>')
    str1 = TAG_RE.sub('', str)
    return str1


# Replace HTML character codes with ASCII.
def twtt2(str1):
    html_parser = HTMLParser.HTMLParser()
    str2 = html_parser.unescape(str1)
    return str2


# Remove all URLs.
def twtt3(str2):
    str3 = re.sub(r"http\S+|www\S+", "", str2)
    return str3


# Remove the first character in Twitter user names and hash tags.
def twtt4(str3):
    str4 = re.sub(r"@|#", "", str3)
    return str4


# Each sentence within a tweet is on its own line.
def twtt5(str4):
    str5 = []
    skip = False
    # Split just according to periods and conserve periods.
    str4 = re.split(r'(?<=\.) |(?<=\?) |(?<=\!) ', str4)
    for i, item in enumerate(str4):
        if skip == True:
            skip = False
            continue
        # Consider the abbreviation.
        if i != len(str4) - 1 and item.split()[-1] in abbrev_list:
            str5.append(item + " " + str4[i + 1])
            skip = True
        else:
            str5.append(str4[i])

    # Change list to String
    str5 = '\n'.join(str5)

    return str5


# twtt7's auxiliary functions to seperate each token.
def twtt7_aux(j, str, num_pun):
    if re.search(r"" + re.escape(j) * num_pun + '\w', str):
        a = re.search(re.escape(j) * num_pun + "\w", str)
        str = str[:a.start() + num_pun] + " " + str[a.start() + num_pun:]

    if re.search(r'\w' + re.escape(j) * num_pun, str):
        a = re.search(r"\w" + re.escape(j) * num_pun, str)
        str = str[:a.end() - num_pun] + " " + str[a.end() - num_pun:]

    return str


# Each token, including punctuation and clitics, is separated by spaces.
def twtt7(str5):
    str5 = str5.split('\n')

    cl = ["'s ", "s' ", "'re ", "'m ", "'ve ", "'d ", "'ll ", "n't ", "!", "?", "."]
    for i, item in enumerate(str5):
        for j in cl:
            if j in item:
                if j == "s' ":
                    str5[i] = re.sub(j, "s ' ", str5[i])

                elif j in ['!', '?', '.']:
                    if j == "?":
                        if re.search(r"((\?)\2{1,})", str5[i]):
                            find_re = re.findall(r"((\?)\2{1,})", str5[i])
                            find_re = sorted(find_re, reverse=True)
                            for group in find_re:
                                # print group
                                num_pun = len(group[0])
                                str5[i] = twtt7_aux(j, str5[i], num_pun)
                                # print str5[i]

                    if j == ".":
                        if re.search(r"((\.)\2{2,})", str5[i]):
                            find_re = re.findall(r"((\.)\2{1,})", str5[i])
                            find_re = sorted(find_re, reverse=True)
                            for group in find_re:
                                num_pun = len(group[0])
                                str5[i] = twtt7_aux(j, str5[i], num_pun)
                                # print str5[i]

                    if j == "!":
                        if re.search(r"((\!)\2{2,})", str5[i]):
                            find_re = re.findall(r"((\!)\2{1,})", str5[i])
                            find_re = sorted(find_re, reverse=True)
                            for group in find_re:
                                num_pun = len(group[0])
                                str5[i] = twtt7_aux(j, str5[i], num_pun)

                    if j == str5[i][-1]:
                        str5[i] = str5[i].split()
                        str5[i][-1] = re.sub("\\{0}".format(j), " " + j, str5[i][-1], count=1)
                        str5[i] = " ".join(str5[i])

                else:
                    str5[i] = re.sub(j, " " + j, str5[i])
    str5 = '\n'.join(str5)

    return str5


# Each token is tagged with its part-of-speech.
def twtt8(str7):
    str7 = str7.split('\n')

    for i, item in enumerate(str7):
        item = item.split()
        tags = tagger.tag(item)
        str7[i] = [a + '/' + b for a, b in zip(item, tags)]
        str7[i] = ' '.join(str7[i])
    str7 = '\n'.join(str7)
    return str7


# Add '<A=#>'
def twtt9(str8, num_class):
    str8 = str8.split('\n')
    for i, item in enumerate(str8):
        str8[i] = str8[i].split(' ')

    class_attr = "<A=" + str(num_class) + ">"
    for i, item in enumerate(str8):
        # print " ".join(item)
        str8[i] = " ".join(item)
    str8.insert(0, class_attr)
    str8 = filter(None, str8)  # reHmove blank element
    str8 = '\n'.join(str8)

    return str8


if __name__ == "__main__":
    # Initialize the path and get the student number
    path = (sys.argv[1])  # input path
    stud_num = int(sys.argv[2])  # student number
    output = (sys.argv[3])  # output path

    X = stud_num % 80
    print X

    start1 = X * 10000
    end1 = start1 + 9999
    start2 = start1 + 800000
    end2 = start2 + 9999

    count = 0

    # Read the CSV file
    with open(path, 'rb') as f:
        reader = csv.reader(f)
        target = open(output, 'w')
        for row in reader:
            count += 1
            print count
            if count not in chain(range(start1, end1 + 1), range(start2, end2 + 1)): continue

            num_class = row[0]
            twtt_content = row[5].encode("ascii", "ignore")

            #Preprocess the twtts in order.
            t1 = twtt1(twtt_content)
            t2 = twtt2(t1)
            t3 = twtt3(t2)
            t4 = twtt4(t3)

            t5 = twtt5(t4)

            t7 = twtt7(t5)

            t8 = twtt8(t7)
        

            t9 = twtt9(t8, num_class)
            t9 = t9.split('\n')

            print ""
            print ""
            print count, num_class, twtt_content
            target = open(output, 'a')
            print t9
            for i in t9:
                target.write(i + '\n')
            target.close()
