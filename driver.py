from itertools import count
import os
import time
import sys
import datetime
import schedule
import shutil
import tweepy
import keys
import random

cur_root_path = ".\\drawings\\"
cur_path = f".\\drawings\\{datetime.date.today()}"
api = None
words = []


def main():
    global api, words

    # read in file
    with open("adjectives.txt") as f:
        words = f.readline().split()

    # set up twitter api
    oauth = OAuth()
    api = tweepy.API(oauth)

    save_and_send()
    
    # send tweets
    schedule.every().hour.at(":00").do(save_and_send)
    schedule.every().hour.at(":30").do(save_and_send)

    # make new drawings
    # schedule.every().day.at("20:02").do(run_sketch, num_drawings=8) #04p:02pm EST
    # schedule.every().day.at("21:02").do(run_sketch, num_drawings=8) #05p:02pm EST
    # schedule.every().day.at("22:02").do(run_sketch, num_drawings=8) #06p:02pm EST
    # schedule.every().day.at("23:02").do(run_sketch, num_drawings=8) #07p:02pm EST
    # schedule.every().day.at("00:02").do(run_sketch, num_drawings=8) #08p:02pm EST
    # schedule.every().day.at("01:02").do(run_sketch, num_drawings=8) #09p:02pm EST

    # run tasks
    # while True:
    #     schedule.run_pending()
    #     time.sleep(1)

# TWITTER API STUFF
def OAuth():
    try:
        auth = tweepy.OAuthHandler(keys.api_key, keys.api_secret)
        auth.set_access_token(keys.access_token, keys.access_token_secret)
        return auth
    except Exception as e:
        print(e)
        return None

# do something with file and move to cur path
def save_and_send():
    global cur_path
    cur_file = get_top_drawing(cur_root_path)
    if cur_file and os.path.isfile(cur_file):
        # actually send tweet here
        try:
            send_tweet(cur_file)
            print(f"Sent Tweet of {cur_file} at {datetime.datetime.now()}")
        except:
            print("Tweet did not send :(")

        # move to folder
        make_cur_dir()
        try:
            shutil.move(cur_file, cur_path)
        except:
            print(f"could not move file: {cur_file}")

def send_tweet(img):
    global words
    if len(words) <= 0:
        with open("adjectives.txt") as f:
            words = f.readline().split()
    num = int(img[19:-4])
    adj = words[random.randrange(0,len(words))]
    text = f"Drawing #{num}\nThis piece is {adj}."
    api.update_status_with_media(
        status=text,
        filename = img
    )

def run_sketch(num_drawings=-1):
    '''
    draws num_drawing drawings via sketch command and saves them
    if no parameter is given, it will run infinity and not save images
    '''
    command_loc = "C:\\Users\\jarrettvm\\Desktop\\processing-4.0b7"
    sketch_loc = "C:\\Users\\jarrettvm\\Desktop\\JarArtBot"
    run_sketch = f"{command_loc}\\processing-java --sketch={sketch_loc} --run {num_drawings}"
    os.system(f'cmd /c {run_sketch}')

def make_cur_dir():
    global cur_path
    cur_path = f".\\drawings\\{datetime.date.today()}"
    if not os.path.isdir(cur_path):
        os.mkdir(cur_path)

def get_top_drawing(root):
    for f in os.listdir(root):
        if os.path.isfile(os.path.join(root, f)):
            return os.path.join(root, f)
    return None


if __name__ == "__main__":
    main()