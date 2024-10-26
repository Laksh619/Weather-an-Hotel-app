from flask import Flask, render_template, request, jsonify
from bs4 import BeautifulSoup
import requests
import pandas as pd

app = Flask(__name__)

def getweather(city, api_key1, api_key2): 
    url1 = 'http://api.openweathermap.org/data/2.5/weather?q={}&appid={}'.format(city, api_key1)
    url2 = 'http://api.openweathermap.org/data/2.5/forecast?q={}&appid={}'.format(city, api_key2)
    
    result1 = requests.get(url1) 
    result2 = requests.get(url2)
    
    if result1.status_code == 200 and result2.status_code == 200: 
        json1 = result1.json() 
        json2 = result2.json()
        city = json1['name'] 
        country = json1['sys']['country']
        temp_kelvin = json1['main']['temp'] 
        temp_celsius = temp_kelvin-273.15
        weather1 = json1['weather'][0]['main']
        
        temp_kel1 = json2['list'][0]['main']['temp']
        temp_cel1 = temp_kel1-273.15
        
        temp_kel2 = json2['list'][1]['main']['temp']
        temp_cel2 = temp_kel2-273.15
        
        temp_kel3 = json2['list'][2]['main']['temp']
        temp_cel3 = temp_kel3-273.15
        
        final = {'city': city, 'country': country, 'temp_celsius': temp_celsius, 
                'weather': weather1, 'forecast': {'3':temp_cel1, '6':temp_cel2, '9':temp_cel3}} 
        return final 
    else: 
        return None

def hotel_data(city):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
    }
    city1=city.split(',')[0]
    city_lc=city1.lower()
    target_url = "https://www.makemytrip.com/hotels/"+city_lc+"-hotels.html"
    resp = requests.get(target_url, headers=headers)
    html = BeautifulSoup(resp.text, 'html.parser')

    a = html.find_all('span')
    hotels = []
    for i in a:
        j = i.attrs
        if 'class' in j.keys():
            if i['class'] == ['wordBreak', 'appendRight10']:
                hotels.append(i.string)

    area = []
    for i in a:
        j = i.attrs
        if 'class' in j.keys():
            if i['class'] == ['blueText']:
                area.append(i.string)

    hotel_area = area[::2]

    b = html.find_all('a')
    link = []
    for i in b:
        j = i.attrs
        if 'class' in j.keys():
            if i['class'] == []:
                link.append(i)

    hotel_link = link[::2]
    hotel_link1 = []
    for i in hotel_link:
        hotel_link1.append(i['href'])

    hotel_dict = {'Name': hotels, 'Area': hotel_area, 'Link': hotel_link1}
    df = pd.DataFrame(hotel_dict)
    return df

@app.route('/', methods=['POST'])
def index():
    city = request.form['city']
    api_key1 = "41f3e319570a13ecf4d68651b787a1f4"
    api_key2 = "99443cdf0394288cf2008ba98cb3b3d9"
    weather_data = getweather(city, api_key1, api_key2)
    if weather_data:
        try:
            hotels_data = hotel_data(city).to_dict(orient='records')
            return jsonify({"weather": weather_data, "hotels": hotels_data})
        except:
            return jsonify({"weather": weather_data, "hotels": 'Error fetching hotel data'})
    else:
        return jsonify({"error": "City not found"})


@app.route('/weather', methods=['POST'])
def weather():
    city = request.form['city']
    api_key1 = "41f3e319570a13ecf4d68651b787a1f4"
    api_key2 = "99443cdf0394288cf2008ba98cb3b3d9"
    weather_data = getweather(city, api_key1, api_key2)
    if weather_data:
        return jsonify(weather_data)
    else:
        return jsonify({"error": "City not found"})

@app.route('/hotels', methods=['POST'])
def hotels():
    city = request.form['city']
    try:
        df = hotel_data(city)
        return df.to_json()
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(debug=True)
