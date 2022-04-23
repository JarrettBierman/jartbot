import os
import time
import sys
import datetime
import schedule
import shutil
import tweepy
import keys

cur_root_path = ".\\drawings\\"
cur_path = f".\\drawings\\{datetime.date.today()}"
api = None
counter = 1


def main():
    # set up twitter api
    global api
    oauth = OAuth()
    api = tweepy.API(oauth)

    # schedule tasks
    # schedule.every().hour.at(":00").do(produce_drawings)
    # schedule.every().minute.at(":00").do(save_and_send)
    # schedule.every().day.at("23:30").do(produce_drawings(48))
    # schedule.every().hour.at(":00").do(save_and_send)
    run_sketch()
    # while True:
    #     # run tasks
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

def produce_drawings(num_drawings):
    global cur_path
    # run processing sketch
    run_sketch(num_drawings)
    # make new folder
    update_cur_path()
    if not os.path.isdir(cur_path):
        os.mkdir(cur_path)


# do something with file and move to cur path
def save_and_send():
    global cur_path
    cur_file = get_top_drawing(cur_root_path)
    if cur_file is not None:
        print(f"sending tweet at {datetime.datetime.now()}")
        # actually send tweet here
        send_tweet(img=cur_file)
        # move to folder
        try:
            shutil.move(cur_file, cur_path)
        except:
            print(f"could not move file: {cur_file}")

def send_tweet(img):
    global counter
    text = f"JarBot Art Project \U0001F916 \U0001F58C \n #{counter}"
    api.update_status_with_media(
        status=text,
        filename = img
    )
    counter += 1

def run_sketch(num_drawings=-1):
    '''
    draws num_drawing drawings via sketch command and saves them
    if no parameter is given, it will run infinity and not save images
    '''
    runSketch = f"processing-java --sketch={os.getcwd()} --run {num_drawings}"
    os.system(f'cmd /c {runSketch}')

def update_cur_path():
    global cur_path
    cur_path = f".\\drawings\\{datetime.date.today()}"
    # delete first drawing, it sucks
    count = 1
    while os.path.isdir(cur_path):
        cur_path = f".\\drawings\\{datetime.date.today()}_{str(count)}"
        count += 1

def get_top_drawing(root):
    for f in os.listdir(root):
        if os.path.isfile(os.path.join(root, f)):
            return os.path.join(root, f)
    return None

def test_api():
    public_tweets = api.home_timeline()
    for tweet in public_tweets:
        print(tweet.text)


if __name__ == "__main__":
    main()