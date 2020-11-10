from bs4 import BeautifulSoup
import os
import pandas as pd
import numpy as np
import sys
import requests
from datetime import datetime

church_URL = 'https://www.churchofjesuschrist.org/'

escapes = ''.join([chr(char) for char in range(1, 32)])
translator = str.maketrans('', '', escapes)

all_speakers_page = requests.get(church_URL + 'general-conference/speakers?lang=eng')
all_speaker_soup = BeautifulSoup(all_speakers_page.content, 'lxml')

all_speaker_links_soup = all_speaker_soup.find_all('div', "lumen-tile__title")
all_links = [speaker.find('a')['href'][1:] for speaker in all_speaker_links_soup]
links_to_use = all_links[:15]

page_num = str(1)

talks = pd.DataFrame(columns = ['Speaker', 'Date', 'Title', 'URL'])

for speaker_link in links_to_use:
    page = requests.get(church_URL + speaker_link)
    
    scripture_soup = BeautifulSoup(page.content, 'lxml')
    all_links = scripture_soup.find_all('a', 'pages-nav__list-item__anchor')
    if len(all_links) > 0:
        link_texts = [int(link.text) if len(link.text) == 1 else 0 for link in all_links]
        num_pages = np.max(link_texts)
    else:
        num_pages = 1

    for this_page_num in range(1,num_pages+1):
        this_URL = church_URL + speaker_link + "&page=" + str(this_page_num)
        this_page = requests.get(this_URL)
        speaker_soup = BeautifulSoup(this_page.content, 'lxml')
        
        this_speaker = speaker_soup.find('h1').get_text()
        
        talk_titles_soup = speaker_soup.find_all('div', "lumen-tile__title")
        these_titles = [title.get_text().translate(translator) for title in talk_titles_soup]
    
        talk_dates_soup = speaker_soup.find_all('div', "lumen-tile__content")
        these_dates_str = [date.get_text().translate(translator) for date in talk_dates_soup]
        these_dates = [datetime.strptime(date_str, "%B %Y") for date_str in these_dates_str]
    
        talk_links_soup = speaker_soup.find_all('a', "lumen-tile__link")
        these_URLs = [church_URL + link['href'][1:] for link in talk_links_soup]
        
        these_talks = pd.DataFrame({'Speaker':[this_speaker for i in these_titles],
                      'Date':these_dates,
                      'Title':these_titles,
                      'URL':these_URLs})
        
        talks = talks.append(these_talks, ignore_index = True)

all_content = []

for talk_row in range(np.shape(talks)[0]):
    perc_comp = talk_row / np.shape(talks)[0] * 100
    sys.stdout.write(f"\rWebscrape Progress: {int(np.round(perc_comp))}%")
    talk_URL = talks['URL'][talk_row]
    talk_page = requests.get(talk_URL)
    talk_soup = BeautifulSoup(talk_page.content, 'lxml')
    ids = [p.get('id') for p in talk_soup.find_all('p')]
    paragraphs = [id[0] == 'p' and id[1].isdigit()  if id != None else False for id in ids]
    paragraph_ids = [ids[paragraph_index] for paragraph_index in list(np.where(paragraphs)[0])]
    
    content = [talk_soup.find(id = this_id).get_text().translate(translator) for this_id in paragraph_ids]
    all_content += [content]
    sys.stdout.flush()
sys.stdout.write("\rWebscrape Progress: 100%\n")
sys.stdout.write("Webscrape complete!\n")

quotes = pd.DataFrame(columns = list(talks.columns))

for i in range(np.shape(talks)[0]):
    perc_comp = i / np.shape(talks)[0] * 100
    sys.stdout.write(f"\rData Compiling Progress: {int(np.round(perc_comp))}%")
    num_quotes = len(all_content[i])
    talk_speaker = [talks.iloc[i,0] for x in range(num_quotes)]
    talk_date = [talks.iloc[i,1] for x in range(num_quotes)]
    talk_title = [talks.iloc[i,2] for x in range(num_quotes)]
    talk_URL = [talks.iloc[i,3] for x in range(num_quotes)]
    
    talk_quote_info = pd.DataFrame({'Speaker':talk_speaker,
                                     'Date':talk_date,
                                     'Title':talk_title,
                                     'URL':talk_URL,
                                     'Content':all_content[i]})
    quotes = quotes.append(talk_quote_info, ignore_index = True)
sys.stdout.write("\rData Compiling Progress: 100%\n")
sys.stdout.write("Compilation complete!\n")

quotes.to_csv('Talk_Quotes_Data.csv', index = False)