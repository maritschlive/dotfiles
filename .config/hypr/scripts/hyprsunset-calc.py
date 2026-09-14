#!/usr/bin/env python3
import os
import sys
import math
import json
import urllib.request
from datetime import datetime, timedelta

CONFIG_DIR = os.path.expanduser("~/.config/hypr")
LOCATION_FILE = os.path.join(CONFIG_DIR, "sunset_location.json")

# Default: Hennigsdorf/Berlin, Germany
DEFAULT_LAT = 52.6377
DEFAULT_LON = 13.2161

# NOAA solar calculations
def get_sunset_sunrise(lat, lon, date_val):
    N = date_val.timetuple().tm_yday
    lngHour = lon / 15.0
    
    t_rise = N + ((6 - lngHour) / 24)
    t_set = N + ((18 - lngHour) / 24)
    
    def calculate_time(t, is_sunrise):
        M = (0.9856 * t) - 3.289
        M_rad = math.radians(M)
        L = M + (1.916 * math.sin(M_rad)) + (0.020 * math.sin(2 * M_rad)) + 282.634
        L = L % 360
        
        L_rad = math.radians(L)
        RA = math.degrees(math.atan(0.91764 * math.tan(L_rad)))
        RA = RA % 360
        
        Lquadrant  = (math.floor(L/90)) * 90
        RAquadrant = (math.floor(RA/90)) * 90
        RA = RA + (Lquadrant - RAquadrant)
        RA = RA / 15.0
        
        sinDec = 0.39782 * math.sin(L_rad)
        cosDec = math.cos(math.asin(sinDec))
        
        zenith = 90.8333
        zenith_rad = math.radians(zenith)
        lat_rad = math.radians(lat)
        
        cosH = (math.cos(zenith_rad) - (sinDec * math.sin(lat_rad))) / (cosDec * math.cos(lat_rad))
        
        if cosH > 1:
            return None
        elif cosH < -1:
            return None
            
        if is_sunrise:
            H = 360 - math.degrees(math.acos(cosH))
        else:
            H = math.degrees(math.acos(cosH))
        H = H / 15.0
        
        T = H + RA - (0.06571 * t) - 6.622
        UT = T - lngHour
        UT = UT % 24
        return UT

    ut_rise = calculate_time(t_rise, True)
    ut_set = calculate_time(t_set, False)
    
    return ut_rise, ut_set

def get_location():
    if os.path.exists(LOCATION_FILE):
        try:
            with open(LOCATION_FILE, "r") as f:
                data = json.load(f)
                return data.get("lat", DEFAULT_LAT), data.get("lon", DEFAULT_LON)
        except Exception:
            pass
            
    # Fetch geo-IP
    try:
        req = urllib.request.Request("http://ip-api.com/json", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=2) as response:
            data = json.loads(response.read().decode())
            if data.get("status") == "success":
                lat = data.get("lat")
                lon = data.get("lon")
                os.makedirs(CONFIG_DIR, exist_ok=True)
                with open(LOCATION_FILE, "w") as f:
                    json.dump({"lat": lat, "lon": lon, "city": data.get("city")}, f)
                return lat, lon
    except Exception:
        pass
        
    return DEFAULT_LAT, DEFAULT_LON

def main():
    lat, lon = get_location()
    now = datetime.now()
    rise_ut, set_ut = get_sunset_sunrise(lat, lon, now)
    
    # Calculate dynamic timezone offset
    tz_offset = now.astimezone().utcoffset().total_seconds() / 3600.0
    
    if rise_ut is None or set_ut is None:
        # Polar regions
        is_winter = now.month in [11, 12, 1, 2]
        is_night = is_winter if lat > 0 else not is_winter
        print(f"{'night' if is_night else 'day'} 43200")
        return
        
    local_rise = (rise_ut + tz_offset) % 24
    # Shift sunset 30 minutes (0.5 hours) earlier
    local_set = (set_ut + tz_offset - 0.5) % 24
    
    current_hour = now.hour + now.minute / 60.0 + now.second / 3600.0
    
    if local_rise < local_set:
        is_night = current_hour >= local_set or current_hour < local_rise
    else:
        is_night = current_hour >= local_set and current_hour < local_rise
        
    # Build transition datetime targets
    rise_dt = now.replace(hour=int(local_rise), minute=int((local_rise%1)*60), second=int(((local_rise%1)*60%1)*60), microsecond=0)
    set_dt = now.replace(hour=int(local_set), minute=int((local_set%1)*60), second=int(((local_set%1)*60%1)*60), microsecond=0)
    
    if is_night:
        # Next transition is sunrise
        if current_hour >= local_set:
            target_dt = rise_dt + timedelta(days=1)
        else:
            target_dt = rise_dt
        state = "night"
    else:
        # Next transition is sunset
        if current_hour < local_rise:
            target_dt = set_dt
        else:
            target_dt = set_dt
        state = "day"
        
    delta = int((target_dt - now).total_seconds())
    if delta <= 0:
        delta = 60 # Fail-safe buffer
        
    print(f"{state} {delta}")

if __name__ == "__main__":
    main()
