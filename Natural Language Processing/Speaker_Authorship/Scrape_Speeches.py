from bs4 import BeautifulSoup
import os
import pandas as pd
import numpy as np
import sys
import requests
from datetime import datetime

os.chdir('C:\\Users\\cason\\Desktop\\Classes\\Assignments\\Stat 666\\Final Project')

speeches_URL = 'https://speeches.byu.edu'

speakers = list(pd.read_csv('Talk_Quotes_Data.csv')['Speaker'].unique())
speakers_format = [spkr.lower().replace(' ','-').replace('.','') for spkr in speakers]

all_speaker_links = [speeches_URL + '/speakers/' + spkr + '/' for spkr in speakers_format]

speeches = pd.DataFrame(columns = ['Speaker', 'Date', 'Title', 'URL'])

escapes = ''.join([chr(char) for char in range(1, 32)])
translator = str.maketrans('', '', escapes)

for spkr_link in all_speaker_links:
    spkr_page = requests.get(spkr_link)
    spkr_soup = BeautifulSoup(spkr_page.content, 'lxml')
    all_talks = spkr_soup.find_all('article', 'card card--reduced')
    this_speaker = spkr_soup.find('h1', 'speaker-listing__name').text
    for talk in all_talks:
        this_Date = datetime.strptime(talk
                    .find('div', 'card__bylines card__bylines--reduced')
                    .text
                    .translate(translator), "%B %d, %Y")
        this_URL = talk.find('a')['href']
        this_Title = talk.find('h2').text.translate(translator)
        this_speech = pd.DataFrame({'Speaker':[this_speaker],
                                    'Date':[this_Date],
                                    'Title':[this_Title],
                                    'URL':[this_URL]})
        speeches = speeches.append(this_speech, ignore_index = True)
      

all_content = []
unavail_text = 'The text for this speech is unavailable.'
int_prop = 'Intellectual Reserve'
rights = 'All rights reserved.'

rows_to_rm = []

for speech_row in range(np.shape(speeches)[0]):
    perc_comp = speech_row / np.shape(speeches)[0] * 100
    sys.stdout.write(f"\rWebscrape Progress: {int(np.round(perc_comp))}%")
    speech_URL = speeches['URL'][speech_row]
    speech_page = requests.get(speech_URL)
    speech_soup = BeautifulSoup(speech_page.content, 'lxml')
    all_paragraphs = speech_soup.findChildren('p', 
                                              recursive = True, 
                                              attrs={'class': None})
    all_text = [p.text.translate(translator) for p in all_paragraphs]
    if len(all_text) > 2:
        end_idx = np.max(np.where([' amen.' in text 
                                   or ' Amen.' in text 
                                   or int_prop in text
                                   or unavail_text in text
                                   or rights in text
                                   for text in all_text]))
        if unavail_text in all_text[end_idx] or int_prop in all_text[end_idx] or rights in all_text[end_idx]:
            end_idx += -1
            all_text = [text for text in all_text if 'Speech highlights' not in text]
        content = all_text[:(end_idx+1)]
        all_content += [content]
    else:
        rows_to_rm += [speech_row]
    sys.stdout.flush()

speeches = speeches[~speeches.index.isin(rows_to_rm)]

sys.stdout.write("\rWebscrape Progress: 100%\n")
sys.stdout.write("Webscrape complete!\n")

quotes = pd.DataFrame(columns = list(speeches.columns))

for i in range(np.shape(speeches)[0]):
    perc_comp = i / np.shape(speeches)[0] * 100
    sys.stdout.write(f"\rData Compiling Progress: {int(np.round(perc_comp))}%")
    num_quotes = len(all_content[i])
    speech_speaker = [speeches.iloc[i,0] for x in range(num_quotes)]
    speech_date = [speeches.iloc[i,1] for x in range(num_quotes)]
    speech_title = [speeches.iloc[i,2] for x in range(num_quotes)]
    speech_URL = [speeches.iloc[i,3] for x in range(num_quotes)]
    
    speech_quote_info = pd.DataFrame({'Speaker':speech_speaker,
                                     'Date':speech_date,
                                     'Title':speech_title,
                                     'URL':speech_URL,
                                     'Content':all_content[i]})
    quotes = quotes.append(speech_quote_info, ignore_index = True)
sys.stdout.write("\rData Compiling Progress: 100%\n")
sys.stdout.write("Compilation complete!\n")

quotes.to_csv('Speech_Quotes_Data.csv', index = False)
